package track_manager

import "core:fmt"
import "core:math"
import "core:slice"
import "../../gui"
import "../../gui/widgets"
import "../../reaper"



// lock/unlock movement button
// movement logic
// add/delete/undo
// box select
// state serialization
// text editing



Track_Manager :: struct {
    project: ^reaper.ReaProject,
    selected_tracks: [dynamic]^reaper.MediaTrack,
    groups: [dynamic]^Track_Group,
    right_click_menu: Right_Click_Menu,
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

update_track_manager :: proc(manager: ^Track_Manager) {
    reaper.PreventUIRefresh(1)

    // Update selected tracks.
    clear(&manager.selected_tracks)
    count := reaper.CountSelectedTracks(manager.project)
    for i in 0 ..< count {
        append(&manager.selected_tracks, reaper.GetSelectedTrack(manager.project, i))
    }

    // Update track groups.
    for group in manager.groups {
        update_track_group(group)
    }

    // Update right click menu.
    update_right_click_menu(manager)

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
            if group.tracks_are_visible && slice.contains(group.tracks[:], track) {
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