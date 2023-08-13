package test_action

import "core:slice"
import "../../gui"
import "../../gui/color"
import "../../gui/widgets"
import "../../reaper"

SPACING :: Vec2{5, 5}
PADDING :: Vec2{5, 5}

Track_Group :: struct {
    track_manager: ^Track_Manager,
    name: string,
    tracks: [dynamic]^reaper.MediaTrack,
    position: Vec2,
    size: Vec2,
    is_visible: bool,
    visibility_button: widgets.Button,
    add_selection_button: widgets.Button,
    remove_selection_button: widgets.Button,

    _place_x: f32,
}

destroy_track_group :: proc(group: ^Track_Group) {
    delete(group.name)
    delete(group.tracks)
    free(group)
}

Track_Manager :: struct {
    project: ^reaper.ReaProject,
    selected_tracks: [dynamic]^reaper.MediaTrack,
    groups: [dynamic]^Track_Group,
}

destroy_track_manager :: proc(manager: ^Track_Manager) {
    delete(manager.selected_tracks)

    for group in manager.groups {
        destroy_track_group(group)
    }
    delete(manager.groups)
}

update_track_manager :: proc(manager: ^Track_Manager) {
    GROUP_HEIGHT :: 24.0

    reaper.PreventUIRefresh(1)

    _update_selected_tracks(manager)

    window_size := gui.window_size(&window)
    group_position := PADDING
    group_size := Vec2{window_size.x - group_position.x * 2, GROUP_HEIGHT}

    for group in manager.groups {
        group.position = group_position
        group.size = group_size
        _update_track_group(group)
        group_position.y += group_size.y + SPACING.y
    }

    _update_track_visibility(manager)

    reaper.PreventUIRefresh(-1)
}

_update_track_visibility :: proc(manager: ^Track_Manager) {
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
            if group.is_visible && slice.contains(group.tracks[:], track) {
                track_should_be_visible = true
            }
        }

        track_is_visible := _track_is_visible(track)

        if track_should_be_visible && !track_is_visible {
            _set_track_visible(track, true)
        } else if !track_should_be_visible && track_is_visible {
            _set_track_visible(track, false)
        }
    }
}

_update_visibility_button :: proc(group: ^Track_Group) {
    button := &group.visibility_button

    button.position = {group._place_x, 0}
    button.size = {group.size.y, group.size.y}

    widgets.update_button(button)

    if button.clicked {
        group.is_visible = !group.is_visible
    }

    gui.begin_path()
    gui.rounded_rect(button.position, button.size, 3)
    gui.fill_path(color.rgb(31, 32, 34))

    if group.is_visible {
        gui.begin_path()
        gui.rect(button.position + {3, 3}, button.size - {6, 6})
        gui.fill_path(color.rgb(70, 70, 70))
    }
}

_update_add_selection_button :: proc(group: ^Track_Group) {
    button := &group.add_selection_button

    button.size = {group.size.y, group.size.y}
    button.position = {group._place_x - button.size.x, 0}

    widgets.update_button(button)

    if button.clicked {
        _add_selected_tracks_to_group(group)
    }

    gui.begin_path()
    gui.rect(button.position + {3, 3}, button.size - {6, 6})
    gui.fill_path(color.rgb(0, 255, 0))
}

_update_remove_selection_button :: proc(group: ^Track_Group) {
    button := &group.remove_selection_button

    button.size = {group.size.y, group.size.y}
    button.position = {group._place_x - button.size.x, 0}

    widgets.update_button(button)

    if button.clicked {
        _remove_selected_tracks_from_group(group)
    }

    gui.begin_path()
    gui.rect(button.position + {3, 3}, button.size - {6, 6})
    gui.fill_path(color.rgb(255, 0, 0))
}

_update_track_group :: proc(group: ^Track_Group) {
    gui.offset(group.position)

    // Visibility button
    group._place_x = 0.0
    _update_visibility_button(group)

    // Group name
    group._place_x += group.visibility_button.size.x + SPACING.x
    gui.fill_text_line(group.name, {group._place_x, 0})

    // Add selection button
    group._place_x = group.size.x - PADDING.x
    _update_add_selection_button(group)

    // Remove selection button
    group._place_x -= group.add_selection_button.size.x + SPACING.x
    _update_remove_selection_button(group)

    // Separator line
    gui.begin_path()
    gui.move_to({0, group.size.y - 0.5})
    gui.line_to({group.size.x, group.size.y - 0.5})
    gui.stroke_path(color.rgb(160, 160, 160), 1)
}

_add_new_track_group :: proc(manager: ^Track_Manager, name: string) {
    group := new(Track_Group)
    group.track_manager = manager
    group.name = name
    group.is_visible = true
    append(&manager.groups, group)
}

_add_selected_tracks_to_group :: proc(group: ^Track_Group) {
    manager := group.track_manager
    for track in manager.selected_tracks {
        if !slice.contains(group.tracks[:], track) {
            append(&group.tracks, track)
        }
    }
}

_remove_selected_tracks_from_group :: proc(group: ^Track_Group) {
    manager := group.track_manager
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

_update_selected_tracks :: proc(manager: ^Track_Manager) {
    clear(&manager.selected_tracks)
    count := reaper.CountSelectedTracks(manager.project)
    for i in 0 ..< count {
        append(&manager.selected_tracks, reaper.GetSelectedTrack(manager.project, i))
    }
}

_track_is_visible :: proc(track: ^reaper.MediaTrack) -> bool {
    return reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER") == 1 &&
           reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1
}

_set_track_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", visible ? 1 : 0)
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", visible ? 1 : 0)
    reaper.TrackList_AdjustWindows(false)
}