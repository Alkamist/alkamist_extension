package track_manager

import "core:fmt"
import "core:math"
import "core:slice"
import "../../gui"
import "../../gui/widgets"
import "../../reaper"

Track_Manager :: struct {
    project: ^reaper.ReaProject,
    selected_tracks: [dynamic]^reaper.MediaTrack,
    groups: [dynamic]^Track_Group,

    right_click_menu: Right_Click_Menu,
    box_select: Box_Select,

    is_dragging_group: bool,
    mouse_position_when_drag_started: Vec2,

    scroll: Vec2,
    mouse_position_when_scroll_started: Vec2,
    scroll_when_scroll_started: Vec2,
}

init_track_manager :: proc(project: ^reaper.ReaProject) -> Track_Manager {
    return {
        project = project,
        right_click_menu = init_right_click_menu(),
    }
}

destroy_track_manager :: proc(manager: ^Track_Manager) {
    delete(manager.selected_tracks)

    for group in manager.groups {
        destroy_track_group(group)
        free(group)
    }

    delete(manager.groups)
}

add_new_track_group :: proc(manager: ^Track_Manager, name: string, position: Vec2) {
    group := new(Track_Group)
    group^ = init_track_group(manager, name, position)
    append(&manager.groups, group)
}

add_selected_tracks_to_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if group.is_selected {
            add_selected_tracks_to_group(group)
        }
    }
}

remove_selected_tracks_from_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if group.is_selected {
            remove_selected_tracks_from_group(group)
        }
    }
}

update_group_selection :: proc{
    update_group_selection_single,
    update_group_selection_multi,
}

update_group_selection_single :: proc(manager: ^Track_Manager, selection: ^Track_Group, keep_selection: bool) {
    selection_multi := [?]^Track_Group{selection}
    update_group_selection_multi(manager, selection_multi[:], keep_selection)
}

update_group_selection_multi :: proc(manager: ^Track_Manager, selection: []^Track_Group, keep_selection: bool) {
    addition := gui.key_down(.Left_Shift)
    invert := gui.key_down(.Left_Control)

    if !keep_selection && !addition && !invert {
        for group in manager.groups {
            group.is_selected = false
        }
    }

    for group in selection {
        if invert {
            group.is_selected = !group.is_selected
        } else {
            group.is_selected = true
        }
    }
}

update_track_manager :: proc(manager: ^Track_Manager) {
    reaper.PreventUIRefresh(1)

    // Update selected tracks.
    clear(&manager.selected_tracks)
    count := reaper.CountSelectedTracks(manager.project)
    for i in 0 ..< count {
        append(&manager.selected_tracks, reaper.GetSelectedTrack(manager.project, i))
    }

    // Handle scroll with middle click logic.
    if gui.mouse_pressed(.Middle) {
        manager.mouse_position_when_scroll_started = gui.global_mouse_position()
        manager.scroll_when_scroll_started = manager.scroll
    }
    if gui.mouse_down(.Middle) {
        scroll_delta := gui.global_mouse_position() - manager.mouse_position_when_scroll_started
        manager.scroll = manager.scroll_when_scroll_started + scroll_delta
    }

    gui.offset(manager.scroll)

    // Update track groups.
    group_is_hovered := false

    for group in manager.groups {
        update_track_group(group)
        if gui.is_hovered(&group.button_state) {
            group_is_hovered = true
        }
    }

    // Update right click menu.
    update_right_click_menu(manager)

    // Update box select. (must come after right click menu)
    update_box_select(manager)

    // Loop through groups again and process selection clearing and dragging.
    left_click_in_empty_space := gui.mouse_pressed(.Left) && gui.get_hover() == nil

    for group in manager.groups {
        if left_click_in_empty_space {
            group.is_selected = false
        }

        if gui.mouse_pressed(.Left) && group_is_hovered {
            manager.is_dragging_group = true
            group.position_when_drag_started = group.position
            manager.mouse_position_when_drag_started = gui.global_mouse_position()
        }
        if group.is_selected && gui.mouse_down(.Left) && manager.is_dragging_group {
            drag_delta := gui.global_mouse_position() - manager.mouse_position_when_drag_started
            group.position = group.position_when_drag_started + drag_delta
        }
    }

    if gui.mouse_released(.Left) {
        manager.is_dragging_group = false
    }

    // Update track visibility.
    tracks: [dynamic]^reaper.MediaTrack
    defer delete(tracks)

    for group in manager.groups {
        for track in group.tracks {
            if !slice.contains(tracks[:], track) {
                append(&tracks, track)
            }
        }
    }

    for track in tracks {
        track_should_be_visible := false

        for group in manager.groups {
            if group.is_selected && slice.contains(group.tracks[:], track) {
                track_should_be_visible = true
            }
        }

        track_is_visible := track_is_visible(track)

        if track_should_be_visible && !track_is_visible {
            set_track_visible(track, true)
        } else if !track_should_be_visible && track_is_visible {
            set_track_visible(track, false)
        }
    }

    reaper.PreventUIRefresh(-1)
}