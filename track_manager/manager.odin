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

    movement_is_locked: bool,
    group_is_hovered: bool,

    right_click_menu: Right_Click_Menu,
    box_select: Box_Select,

    is_dragging_groups: bool,
    mouse_position_when_drag_started: Vec2,
}

destroy_track_manager :: proc(manager: ^Track_Manager) {
    delete(manager.selected_tracks)

    for group in manager.groups {
        destroy_track_group(group)
        free(group)
    }

    delete(manager.groups)
}

reset_track_manager :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        destroy_track_group(group)
        free(group)
    }
    clear(&manager.groups)
}

add_new_track_group :: proc(manager: ^Track_Manager, name: string, position: Vec2) {
    group := new(Track_Group)
    init_track_group(group)
    group.name = name
    group.position = position
    append(&manager.groups, group)
}

add_selected_tracks_to_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if !group.is_selected do continue

        for track in manager.selected_tracks {
            if !slice.contains(group.tracks[:], track) {
                append(&group.tracks, track)
            }
        }
    }
}

remove_selected_tracks_from_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if !group.is_selected do continue
        keep_if(&group.tracks, manager, proc(track: ^reaper.MediaTrack, manager: ^Track_Manager) -> bool {
            return !slice.contains(manager.selected_tracks[:], track)
        })
    }
}

movement_is_locked :: proc(manager: ^Track_Manager) -> bool {
    return manager.movement_is_locked
}

toggle_lock_movement :: proc(manager: ^Track_Manager) {
    manager.movement_is_locked = !manager.movement_is_locked
}

center_groups :: proc(manager: ^Track_Manager) {
    if len(manager.groups) == 0 {
        return
    }

    top_left := Vec2{max(f32), max(f32)}
    bottom_right := Vec2{min(f32), min(f32)}

    for group in manager.groups {
        top_left.x = min(top_left.x, group.position.x)
        top_left.y = min(top_left.y, group.position.y)

        group_bottom_right := group.position + group.size

        bottom_right.x = max(bottom_right.x, group_bottom_right.x)
        bottom_right.y = max(bottom_right.y, group_bottom_right.y)
    }

    center := top_left + (bottom_right - top_left) * 0.5
    view_center := gui.window_size(&window) * 0.5

    offset := gui.pixel_align(view_center - center)

    for group in manager.groups {
        group.position += offset
    }
}

select_tracks_of_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if group.is_selected {
            select_tracks_of_group(group)
        }
    }
    reaper.MarkProjectDirty(manager.project)
}

update_selected_tracks :: proc(manager: ^Track_Manager) {
    clear(&manager.selected_tracks)
    count := reaper.CountSelectedTracks(manager.project)
    for i in 0 ..< count {
        append(&manager.selected_tracks, reaper.GetSelectedTrack(manager.project, i))
    }
}

remove_invalid_tracks_from_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if len(group.tracks) == 0 do continue

        keep_if(&group.tracks, manager, proc(track: ^reaper.MediaTrack, manager: ^Track_Manager) -> bool {
            return reaper.ValidatePtr2(manager.project, track, "MediaTrack*")
        })
    }
}

update_track_visibility :: proc(manager: ^Track_Manager) {
    tracks := make([dynamic]^reaper.MediaTrack, window.frame_allocator)

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
            reaper.MarkProjectDirty(manager.project)

        } else if !track_should_be_visible && track_is_visible {
            set_track_visible(track, false)

            // Unselect tracks that are hidden by the manager.
            reaper.SetTrackSelected(track, false)
            reaper.MarkProjectDirty(manager.project)
        }
    }
}

update_track_manager :: proc(manager: ^Track_Manager) {
    reaper.PreventUIRefresh(1)

    remove_invalid_tracks_from_groups(manager)

    update_selected_tracks(manager)
    update_track_groups(manager)
    update_right_click_menu(manager)
    update_box_select(manager)

    if gui.key_pressed(.A) do add_selected_tracks_to_selected_groups(manager)
    if gui.key_pressed(.R) do remove_selected_tracks_from_selected_groups(manager)
    if gui.key_pressed(.L) do toggle_lock_movement(manager)
    if gui.key_pressed(.C) do center_groups(manager)
    if !gui.key_down(.Left_Control) && gui.key_pressed(.S) do select_tracks_of_selected_groups(manager)

    update_track_visibility(manager)

    reaper.PreventUIRefresh(-1)
}