package track_manager

import "core:slice"
import "../../gui"
import "../../gui/widgets"
import "../../reaper"

Track_Group :: struct {
    name: string,
    position: Vec2,
    size: Vec2,
    is_selected: bool,

    tracks: [dynamic]^reaper.MediaTrack,

    name_text: widgets.Text,
    button_state: widgets.Button,

    position_when_drag_started: Vec2,
}

init_track_group :: proc(group: ^Track_Group) -> ^Track_Group {
    widgets.init_text(&group.name_text)
    widgets.init_button(&group.button_state)
    return group
}

destroy_track_group :: proc(group: ^Track_Group) {
    delete(group.name)
    delete(group.tracks)
    widgets.destroy_text(&group.name_text)
}

select_tracks_of_group :: proc(group: ^Track_Group) {
    for track in group.tracks {
        reaper.SetTrackSelected(track, true)
    }
}

process_dragging :: proc(manager: ^Track_Manager) {
    if manager.is_dragging_groups && !gui.mouse_down(.Left) && !gui.mouse_down(.Middle) {
        manager.is_dragging_groups = false
    }

    start_left_drag := !manager.movement_is_locked && manager.group_is_hovered && gui.mouse_pressed(.Left)
    start_middle_drag := gui.mouse_pressed(.Middle)
    start_drag := !manager.is_dragging_groups && (start_left_drag || start_middle_drag)

    if start_drag {
        manager.is_dragging_groups = true
        manager.mouse_position_when_drag_started = gui.mouse_position()
    }

    do_left_drag := !manager.movement_is_locked && manager.is_dragging_groups && gui.mouse_down(.Left)
    do_middle_drag := manager.is_dragging_groups && gui.mouse_down(.Middle)

    for group in manager.groups {
        if start_drag {
            group.position_when_drag_started = group.position
        }

        if do_middle_drag || (do_left_drag && group.is_selected) {
            drag_delta := gui.mouse_position() - manager.mouse_position_when_drag_started
            group.position = group.position_when_drag_started + drag_delta
        }
    }
}

update_track_groups :: proc(manager: ^Track_Manager) {
    PADDING :: 3

    process_dragging(manager)

    // Clear selection when left clicking empty space.
    if gui.mouse_pressed(.Left) && gui.get_hover() == nil {
        for group in manager.groups {
            group.is_selected = false
        }
    }

    // Process groups.
    manager.group_is_hovered = false
    mouse_position := gui.mouse_position()

    group_button_pressed := false

    for group in manager.groups {
        // Update name text.
        group.name_text.position = group.position + PADDING
        group.name_text.data = group.name
        group.name_text.color = {1, 1, 1, 1}
        widgets.update_text(&group.name_text)

        // Update sizes to fit name text.
        group.size = group.name_text.size + PADDING * 2
        group.button_state.position = group.position
        group.button_state.size = group.size

        widgets.update_button(&group.button_state)

        // Selection logic.
        if group.button_state.pressed {
            single_group_selection_logic(manager, group, false)
            group_button_pressed = true
        }

        // Draw background.
        if len(group.tracks) > 0 {
            fill_rounded_rect(group.position, group.size, 3, gui.lighten(BACKGROUND_COLOR, 0.1))
        } else {
            fill_rounded_rect(group.position, group.size, 3, BACKGROUND_COLOR)
            outline_rounded_rect(group.position, group.size, 3, {1, 1, 1, 0.1})
        }

        // Highlight green if group has a selected track.
        group_contains_selected_track := false
        for track in manager.selected_tracks {
            if slice.contains(group.tracks[:], track) {
                group_contains_selected_track = true
                break
            }
        }

        if group_contains_selected_track {
            fill_rounded_rect(group.position, group.size, 3, {0, 1, 0, 0.2})
        }

        // Outline if selected.
        if group.is_selected {
            outline_rounded_rect(group.position, group.size, 3, {1, 1, 1, 0.7})
        }

        // Draw group name.
        widgets.draw_text(&group.name_text)

        // Highlight when hovered.
        if gui.is_hovered(&group.button_state) {
            manager.group_is_hovered = true
            fill_rounded_rect(group.position, group.size, 3, {1, 1, 1, 0.08})
        }
    }

    // Bring selected groups to front on group left click interaction.
    if group_button_pressed {
        selected_groups := make([dynamic]^Track_Group, window.frame_allocator)

        for group in manager.groups {
            if group.is_selected {
                append(&selected_groups, group)
            }
        }

        bring_groups_to_front(manager, selected_groups[:])
    }
}

bring_groups_to_front :: proc(manager: ^Track_Manager, groups: []^Track_Group) {
    keep_if(&manager.groups, groups, proc(group: ^Track_Group, groups: []^Track_Group) -> bool {
        return !slice.contains(groups, group)
    })
    append(&manager.groups, ..groups)
}