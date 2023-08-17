package track_manager

import "core:slice"
import "../../gui"
import "../../gui/widgets"
import "../../reaper"

Track_Group :: struct {
    name: string,
    position: Vec2,
    size: Vec2,
    manager: ^Track_Manager,
    is_selected: bool,
    tracks_are_visible: bool,
    tracks: [dynamic]^reaper.MediaTrack,
    name_text: widgets.Text,
    button_state: widgets.Button,
}

init_track_group :: proc(manager: ^Track_Manager, name: string, position: Vec2) -> Track_Group {
    return {
        name = name,
        position = position,
        manager = manager,
        tracks_are_visible = true,
        name_text = widgets.init_text(&consola),
        button_state = widgets.init_button(),
    }
}

destroy_track_group :: proc(group: ^Track_Group) {
    delete(group.name)
    delete(group.tracks)
}

add_selected_tracks_to_group :: proc(group: ^Track_Group) {
    manager := group.manager
    for track in manager.selected_tracks {
        if !slice.contains(group.tracks[:], track) {
            append(&group.tracks, track)
        }
    }
}

remove_selected_tracks_from_group :: proc(group: ^Track_Group) {
    manager := group.manager
    keep_position := 0

    for i in 0 ..< len(group.tracks) {
        if !slice.contains(manager.selected_tracks[:], group.tracks[i]) {
            if keep_position != i {
                group.tracks[keep_position] = group.tracks[i]
            }
            keep_position += 1
        }
    }

    resize(&group.tracks, keep_position)
}

group_contains_selected_track :: proc(group: ^Track_Group) -> bool {
    manager := group.manager
    for track in manager.selected_tracks {
        if slice.contains(group.tracks[:], track) {
            return true
        }
    }
    return false
}

update_track_group :: proc(group: ^Track_Group) {
    PADDING :: 3

    manager := group.manager

    gui.offset(group.position)

    pixel := gui.pixel_distance()

    // Update name text.
    group.name_text.position = PADDING
    group.name_text.data = group.name
    group.name_text.color = {1, 1, 1, 1}
    widgets.update_text(&group.name_text)

    // Update sizes to fit name text.
    group.size = group.name_text.size + PADDING * 2
    group.button_state.size = group.size

    widgets.update_button(&group.button_state)

    if group.button_state.clicked {
        update_group_selection(manager, group, group.is_selected)

        show_groups := !group.tracks_are_visible

        for group in manager.groups {
            if group.is_selected {
                group.tracks_are_visible = show_groups
            }
        }
    }

    // Draw the group background.
    if group_contains_selected_track(group) {
        fill_rounded_rect({0, 0}, group.size, 3, gui.lighten(BACKGROUND_COLOR, 0.2))
    } else {
        outline_rounded_rect({0, 0}, group.size, 3, gui.lighten(BACKGROUND_COLOR, 0.1))
    }

    if group.tracks_are_visible {
        outline_rounded_rect({0, 0}, group.size, 3, {1, 1, 1, 1})
    }

    // Draw group name.
    widgets.draw_text(&group.name_text)

    // Highlight when hovered/selected.
    if group.is_selected {
        fill_rounded_rect({0, 0}, group.size, 3, {1, 1, 1, 0.15})
    }
    if gui.is_hovered(&group.button_state) {
        fill_rounded_rect({0, 0}, group.size, 3, {1, 1, 1, 0.08})
    }
}