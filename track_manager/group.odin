package track_manager

import "core:slice"
import "../../gui"
import "../../gui/color"
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

    contains_selected_track: bool,
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

update_track_group :: proc(group: ^Track_Group) {
    manager := group.manager

    group.contains_selected_track = false
    for track in manager.selected_tracks {
        if slice.contains(group.tracks[:], track) {
            group.contains_selected_track = true
            break
        }
    }

    gui.offset(group.position)

    pixel := gui.pixel_distance()

    group.name_text.data = group.name
    group.name_text.color = {1, 1, 1, 1}

    widgets.update_text(&group.name_text)

    size := group.name_text.size

    group.size = size
    group.button_state.size = size

    widgets.update_button(&group.button_state)

    if group.button_state.pressed {
        group.is_selected = !group.is_selected
    }

    if group.is_selected {
        gui.begin_path()
        gui.path_rounded_rect({0, 0}, size, 3)
        gui.fill_path(color.darken(BACKGROUND_COLOR, 0.2))

        gui.begin_path()
        gui.path_rounded_rect(pixel * 0.5, size - pixel, 3)
        gui.stroke_path({1, 1, 1, 1}, 1)

    } else if group.contains_selected_track {
        gui.begin_path()
        gui.path_rounded_rect({0, 0}, size, 3)
        gui.fill_path(color.lighten(BACKGROUND_COLOR, 0.1))

    } else {
        gui.begin_path()
        gui.path_rounded_rect(pixel * 0.5, size - pixel, 3)
        gui.stroke_path(color.lighten(BACKGROUND_COLOR, 0.1), 1)
    }

    widgets.draw_text(&group.name_text)

    if gui.is_hovered(&group.button_state) {
        gui.begin_path()
        gui.path_rounded_rect({0, 0}, size, 3)
        gui.fill_path({1, 1, 1, 0.08})
    }
}