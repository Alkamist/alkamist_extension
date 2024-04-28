package main

import "core:slice"
import "core:strings"
import "core:strconv"
import "reaper"

//==========================================================================
// Global State
//==========================================================================

track_manager_font := Font{
    name = "consola_13",
    size = 13,
    data = #load("consola.ttf"),
}

track_manager_window: Window
track_managers: map[^reaper.ReaProject]^Track_Manager

get_track_manager :: proc(project: ^reaper.ReaProject) -> ^Track_Manager {
    manager, exists := track_managers[project]
    if !exists {
        manager = new(Track_Manager)
        track_manager_init(manager, project)
        track_managers[project] = manager
    }
    return manager
}

//==========================================================================
// Group
//==========================================================================

TRACK_GROUP_PADDING :: 4
TRACK_GROUP_MIN_WIDTH :: 48
TRACK_GROUP_COLOR :: Color{45.0 / 255, 107.0 / 255, 14.0 / 255, 1}
TRACK_SECTION_COLOR :: Color{104.0 / 255, 14.0 / 255, 107.0 / 255, 1}

Track_Group_Kind :: enum {
    Group,
    Section,
}

Track_Group :: struct {
    using rectangle: Rectangle,
    kind: Track_Group_Kind,
    tracks: [dynamic]^reaper.MediaTrack,
    is_selected: bool,
    position_when_drag_started: Vector2,
    name: strings.Builder,
    editable_name: Editable_Text_Line,
    button: Button,
}

track_group_init :: proc(group: ^Track_Group) {
    strings.builder_init(&group.name)
    editable_text_line_init(&group.editable_name, &group.name)
    button_base_init(&group.button)
}

track_group_destroy :: proc(group: ^Track_Group) {
    strings.builder_destroy(&group.name)
    editable_text_line_destroy(&group.editable_name)
}

track_group_update_rectangle :: proc(group: ^Track_Group, font: Font) {
    group.position = pixel_snapped(group.position)
    name_size := measure_string(strings.to_string(group.name), font)
    group.size = name_size + TRACK_GROUP_PADDING * 2
    group.size.x = max(group.size.x, TRACK_GROUP_MIN_WIDTH)
}

track_group_draw_frame :: proc(group: ^Track_Group, manager: ^Track_Manager) {
    pixel := pixel_size()

    shadow_rectangle := group.rectangle
    shadow_rectangle.position.y += 2
    box_shadow(shadow_rectangle, 3, 5, {0, 0, 0, 0.3}, {0, 0, 0, 0})

    color: Color
    switch group.kind {
    case .Group: color = TRACK_GROUP_COLOR
    case .Section: color = TRACK_SECTION_COLOR
    }
    if !group.is_selected {
        color = color_darken(color, 0.5)
    }

    fill_rounded_rectangle(group.rectangle, 3, color)

    group_contains_selected_track := false
    for track in manager.selected_tracks {
        if slice.contains(group.tracks[:], track) {
            group_contains_selected_track = true
            break
        }
    }

    if group_contains_selected_track {
        outline_rounded_rectangle(group.rectangle, 3, pixel.x, {1, 1, 1, 0.5})
    } else {
        outline_rounded_rectangle(group.rectangle, 3, pixel.x, {1, 1, 1, 0.15})
    }
}

//==========================================================================
// Manager
//==========================================================================

TRACK_MANAGER_TOOLBAR_HEIGHT :: 18

Track_Manager_State :: enum {
    Editing,
    Renaming_Groups,
    Confirming_Group_Deletion,
}

Track_Manager :: struct {
    project: ^reaper.ReaProject,
    all_tracks: [dynamic]^reaper.MediaTrack,
    selected_tracks: [dynamic]^reaper.MediaTrack,

    state: Track_Manager_State,
    state_changed: bool,

    groups: [dynamic]^Track_Group,

    is_editing_groups: bool,
    is_dragging_groups: bool,
    mouse_position_when_drag_started: Vector2,

    box_select: Box_Select,
    background_button: Button,

    delete_prompt_yes_button: Button,
    delete_prompt_no_button: Button,

    toolbar_edit_groups_button: Button,
    toolbar_remove_tracks_button: Button,
    toolbar_add_tracks_button: Button,
    toolbar_set_as_group_button: Button,
    toolbar_set_as_section_button: Button,
}

track_manager_init :: proc(manager: ^Track_Manager, project: ^reaper.ReaProject) {
    manager.project = project
    manager.state = .Editing
    button_base_init(&manager.background_button)
    button_base_init(&manager.delete_prompt_yes_button)
    button_base_init(&manager.delete_prompt_no_button)
    button_base_init(&manager.toolbar_edit_groups_button)
    button_base_init(&manager.toolbar_remove_tracks_button)
    button_base_init(&manager.toolbar_add_tracks_button)
    button_base_init(&manager.toolbar_set_as_group_button)
    button_base_init(&manager.toolbar_set_as_section_button)
}

track_manager_destroy :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        track_group_destroy(group)
        free(group)
    }
    delete(manager.groups)
}

track_manager_reset :: proc(manager: ^Track_Manager) {
    manager.state = .Editing
    for group in manager.groups {
        track_group_destroy(group)
        free(group)
    }
    clear(&manager.groups)
}

track_manager_update :: proc(manager: ^Track_Manager) {
    window_size := current_window().size

    previous_state := manager.state

    // Remove any invalid tracks from groups.

    for group in manager.groups {
        if len(group.tracks) == 0 do continue
        keep_if(&group.tracks, manager, proc(track: ^reaper.MediaTrack, manager: ^Track_Manager) -> bool {
            return reaper.ValidatePtr2(manager.project, track, "MediaTrack*")
        })
    }

    // Poll for any new tracks and add them to selected groups.

    all_tracks := make([dynamic]^reaper.MediaTrack, context.temp_allocator)
    track_count := reaper.CountTracks(manager.project)
    for i in 0 ..< track_count {
        track := reaper.GetTrack(manager.project, i)
        if !slice.contains(manager.all_tracks[:], track) {
            for group in manager.groups {
                if group.is_selected && !slice.contains(group.tracks[:], track) {
                    append(&group.tracks, track)
                }
            }
        }
        append(&all_tracks, track)
    }
    clear(&manager.all_tracks)
    for track in all_tracks {
        append(&manager.all_tracks, track)
    }

    // Update selected tracks.

    manager.selected_tracks = make([dynamic]^reaper.MediaTrack, context.temp_allocator)
    selected_track_count := reaper.CountSelectedTracks(manager.project)
    for i in 0 ..< selected_track_count {
        append(&manager.selected_tracks, reaper.GetSelectedTrack(manager.project, i))
    }

    // Main logic.

    track_manager_toolbar(manager)

    rectangle := Rectangle{
        {0, TRACK_MANAGER_TOOLBAR_HEIGHT},
        {window_size.x, window_size.y - TRACK_MANAGER_TOOLBAR_HEIGHT},
    }

    scoped_clip(rectangle)
    scoped_offset(rectangle.position)

    relative_rectangle := Rectangle{{0, 0}, rectangle.size}

    switch manager.state {
    case .Editing: track_manager_editing(manager, relative_rectangle)
    case .Renaming_Groups: track_manager_renaming_groups(manager, relative_rectangle)
    case .Confirming_Group_Deletion: track_manager_confirming_group_deletion(manager, relative_rectangle)
    }

    manager.state_changed = manager.state != previous_state
}

track_manager_toolbar :: proc(manager: ^Track_Manager) {
    toolbar_rectangle := Rectangle{
        {0, 0},
        {current_window().size.x, TRACK_MANAGER_TOOLBAR_HEIGHT},
    }

    toolbar_color := Color{0.1, 0.1, 0.1, 1}
    fill_rectangle(toolbar_rectangle, toolbar_color)

    BUTTON_WIDTH :: 42

    toolbar_button_update :: proc(button: ^Button, x: f32, label: string, color: Color) {
        rectangle := Rectangle{{x, 0}, {BUTTON_WIDTH, TRACK_MANAGER_TOOLBAR_HEIGHT}}
        invisible_button_update(button, rectangle)
        fill_rectangle(rectangle, color)
        if mouse_hover() == button.id {
            fill_rectangle(rectangle, {1, 1, 1, 0.15})
        }
        fill_string_aligned(label, rectangle, track_manager_font, {1, 1, 1, 1}, {0.5, 0.5})
    }

    toolbar_group_button_update :: proc(button: ^Button, x: f32, color: Color) {
        rectangle := Rectangle{{x, 0}, {BUTTON_WIDTH, TRACK_MANAGER_TOOLBAR_HEIGHT}}
        invisible_button_update(button, rectangle)

        center := rectangle.position + rectangle.size * 0.5
        fill_circle(center, 4, color)
        if mouse_hover() == button.id {
            fill_rectangle(rectangle, {1, 1, 1, 0.15})
        }
    }

    // Edit button.

    button_x: f32
    toolbar_button_update(&manager.toolbar_edit_groups_button,
        button_x,
        "Edit",
        color_rgb(74, 115, 181) if manager.is_editing_groups else toolbar_color,
    )
    if manager.toolbar_edit_groups_button.clicked {
        manager.is_editing_groups = !manager.is_editing_groups
    }

    // Remove tracks button.

    button_x += BUTTON_WIDTH
    toolbar_button_update(&manager.toolbar_remove_tracks_button, button_x, "-", toolbar_color)
    if manager.toolbar_remove_tracks_button.clicked {
        track_manager_remove_selected_tracks_from_selected_groups(manager)
    }

    // Add tracks button.

    button_x += BUTTON_WIDTH
    toolbar_button_update(&manager.toolbar_add_tracks_button, button_x, "+", toolbar_color)
    if manager.toolbar_add_tracks_button.clicked {
        track_manager_add_selected_tracks_to_selected_groups(manager)
    }

    // Set as group button.

    button_x += BUTTON_WIDTH
    toolbar_group_button_update(&manager.toolbar_set_as_group_button, button_x, TRACK_GROUP_COLOR)
    if manager.toolbar_set_as_group_button.clicked {
        for group in manager.groups {
            if group.is_selected do group.kind = .Group
        }
    }

    // Set as section button.

    button_x += BUTTON_WIDTH
    toolbar_group_button_update(&manager.toolbar_set_as_section_button, button_x, TRACK_SECTION_COLOR)
    if manager.toolbar_set_as_section_button.clicked {
        for group in manager.groups {
            if group.is_selected do group.kind = .Section
        }
    }
}

//==========================================================================
// Utility
//==========================================================================

track_manager_create_new_group :: proc(manager: ^Track_Manager, position: Vector2) {
    group := new(Track_Group)
    track_group_init(group)
    group.position = position
    group.is_selected = true
    append(&manager.groups, group)
}

track_manager_add_selected_tracks_to_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if !group.is_selected do continue
        for track in manager.selected_tracks {
            if !slice.contains(group.tracks[:], track) {
                append(&group.tracks, track)
            }
        }
    }
}

track_manager_remove_selected_tracks_from_selected_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        if !group.is_selected do continue
        keep_if(&group.tracks, manager, proc(track: ^reaper.MediaTrack, manager: ^Track_Manager) -> bool {
            return !slice.contains(manager.selected_tracks[:], track)
        })
    }
}

track_manager_selection_logic :: proc(manager: ^Track_Manager, groups: []^Track_Group, is_box_select: bool) {
    addition := key_down(.Left_Shift)
    invert := key_down(.Left_Control)

    keep_selection := addition || invert

    if !is_box_select {
        for group in manager.groups {
            if group.is_selected && mouse_hover() == group.button.id {
                keep_selection = true
                break
            }
        }
    }

    for group in manager.groups {
        if !keep_selection {
            group.is_selected = false
        }
    }

    for group in groups {
        if invert {
            group.is_selected = !group.is_selected
        } else {
            group.is_selected = true
        }
    }
}

track_manager_bring_groups_to_front :: proc(manager: ^Track_Manager, groups: []^Track_Group) {
    keep_if(&manager.groups, groups, proc(group: ^Track_Group, groups: []^Track_Group) -> bool {
        return !slice.contains(groups, group)
    })
    append(&manager.groups, ..groups)
}

track_manager_bring_selected_groups_to_front :: proc(manager: ^Track_Manager) {
    selected_groups := make([dynamic]^Track_Group, context.temp_allocator)
    for group in manager.groups {
        if group.is_selected {
            append(&selected_groups, group)
        }
    }
    track_manager_bring_groups_to_front(manager, selected_groups[:])
}

track_manager_unselect_all_groups :: proc(manager: ^Track_Manager) {
    for group in manager.groups {
        group.is_selected = false
    }
}

track_manager_selected_group_count :: proc(manager: ^Track_Manager) -> (res: int) {
    for group in manager.groups {
        if group.is_selected {
            res += 1
        }
    }
    return
}

track_manager_remove_selected_groups :: proc(manager: ^Track_Manager) {
    selected_groups := make([dynamic]^Track_Group, context.temp_allocator)
    for group in manager.groups {
        if group.is_selected {
            append(&selected_groups, group)
        }
    }

    keep_if(&manager.groups, proc(group: ^Track_Group) -> bool {
        return !group.is_selected
    })

    for group in selected_groups {
        track_group_destroy(group)
        free(group)
    }
}

track_manager_center_groups :: proc(manager: ^Track_Manager, rectangle: Rectangle) {
    if len(manager.groups) == 0 {
        return
    }

    top_left := Vector2{max(f32), max(f32)}
    bottom_right := Vector2{min(f32), min(f32)}

    for group in manager.groups {
        top_left.x = min(top_left.x, group.position.x)
        top_left.y = min(top_left.y, group.position.y)

        group_bottom_right := group.position + group.size

        bottom_right.x = max(bottom_right.x, group_bottom_right.x)
        bottom_right.y = max(bottom_right.y, group_bottom_right.y)
    }

    center := top_left + (bottom_right - top_left) * 0.5
    view_center := rectangle.size * 0.5

    offset := pixel_snapped(view_center - center)

    for group in manager.groups {
        group.position += offset
    }
}

//==========================================================================
// States
//==========================================================================

track_manager_editing :: proc(manager: ^Track_Manager, rectangle: Rectangle) {
    mouse_pos := mouse_position()
    group_pressed := false
    start_dragging_groups := false

    // Group logic.

    invisible_button_update(&manager.background_button, rectangle)
    if manager.background_button.pressed && !key_down(.Left_Shift) && !key_down(.Left_Control) {
        for group in manager.groups {
            group.is_selected = false
        }
    }

    for group in manager.groups {
        track_group_update_rectangle(group, track_manager_font)
        track_group_draw_frame(group, manager)

        invisible_button_update(&group.button, group.rectangle)
        fill_string_aligned(strings.to_string(group.name), group.rectangle, track_manager_font, {1, 1, 1, 1}, {0.5, 0.5})

        if group.button.pressed {
            group_pressed = true
            track_manager_selection_logic(manager, {group}, false)
            start_dragging_groups = group.is_selected
        }
    }

    if manager.is_editing_groups && group_pressed {
        track_manager_bring_selected_groups_to_front(manager)
    }

    // Dragging logic.

    if mouse_pressed(.Middle) && mouse_clip_test() {
        start_dragging_groups = true
    }

    if start_dragging_groups {
        manager.is_dragging_groups = true
        manager.mouse_position_when_drag_started = mouse_pos
    }

    if manager.is_dragging_groups && !mouse_down(.Left) && !mouse_down(.Middle) {
        manager.is_dragging_groups = false
    }

    if manager.is_dragging_groups {
        drag_delta := mouse_pos - manager.mouse_position_when_drag_started
        for group in manager.groups {
            if start_dragging_groups {
                group.position_when_drag_started = group.position
            }
            if (group.is_selected && manager.is_editing_groups) || mouse_down(.Middle) {
                group.position = group.position_when_drag_started + drag_delta
            }
        }
    }

    // Box select logic.

    box_select_update(&manager.box_select, .Right)
    if manager.box_select.selected {
        groups_touched_by_box_select := make([dynamic]^Track_Group, context.temp_allocator)
        for group in manager.groups {
            if rectangle_intersects(manager.box_select.rectangle, group, true) {
                append(&groups_touched_by_box_select, group)
            }
        }
        track_manager_selection_logic(manager, groups_touched_by_box_select[:], true)
    }

    // Update track visibility.

    if !manager.is_editing_groups {
        tracks := make([dynamic]^reaper.MediaTrack, context.temp_allocator)

        at_least_one_group_is_selected := false
        at_least_one_section_is_selected := false

        for group in manager.groups {
            for track in group.tracks {
                if !slice.contains(tracks[:], track) {
                    append(&tracks, track)
                }
            }
            if group.is_selected {
                switch group.kind {
                case .Group: at_least_one_group_is_selected = true
                case .Section: at_least_one_section_is_selected = true
                }
            }
        }

        for track in tracks {
            track_is_in_selected_group := false
            track_is_in_selected_section := false

            for group in manager.groups {
                if !group.is_selected || !slice.contains(group.tracks[:], track) {
                    continue
                }
                switch group.kind {
                case .Group: track_is_in_selected_group = true
                case .Section: track_is_in_selected_section = true
                }
            }

            track_should_be_visible := true

            if at_least_one_section_is_selected {
                if at_least_one_group_is_selected {
                    track_should_be_visible = track_is_in_selected_group && track_is_in_selected_section
                } else {
                    track_should_be_visible = track_is_in_selected_section
                }
            } else {
                if at_least_one_group_is_selected {
                    track_should_be_visible = track_is_in_selected_group
                }
            }

            track_is_visible := reaper_track_is_visible(track)

            set_track_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
                reaper_set_track_and_children_visible(track, visible)
                if visible {
                    parent := reaper.GetParentTrack(track)
                    for parent != nil {
                        reaper_set_track_visible(parent, true)
                        parent = reaper.GetParentTrack(parent)
                    }
                }
            }

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

    // Add a new group at mouse position on double click.

    if manager.background_button.pressed && mouse_repeat_count(.Left) == 2 {
        track_manager_unselect_all_groups(manager)
        track_manager_create_new_group(manager, mouse_pos)
        manager.state = .Renaming_Groups
    }

    if key_pressed(.F2) {
        manager.state = .Renaming_Groups
    }

    if key_pressed(.Delete) && track_manager_selected_group_count(manager) > 0 {
        manager.state = .Confirming_Group_Deletion
    }

    if key_pressed(.C) {
        track_manager_center_groups(manager, rectangle)
    }

    // Play the project when pressing space bar.

    if key_pressed(.Space) {
        reaper.Main_OnCommandEx(40044, 0, nil)
    }

    // Save the project when ctrl + s is pressed.

    if key_down(.Left_Control) && key_pressed(.S) {
        track_manager_save_window_position_and_size()
        reaper_save_project()
    }
}

track_manager_renaming_groups :: proc(manager: ^Track_Manager, rectangle: Rectangle) {
    if key_pressed(.Enter) || key_pressed(.Escape) {
        manager.state = .Editing
    }

    invisible_button_update(&manager.background_button, rectangle)
    if manager.background_button.pressed {
        track_manager_unselect_all_groups(manager)
        manager.state = .Editing
    }

    for group in manager.groups {
        if manager.state_changed {
            editable_text_line_edit(&group.editable_name, .Select_All)
        }

        track_group_update_rectangle(group, track_manager_font)
        track_group_draw_frame(group, manager)

        if group.is_selected {
            editable_text_line_update(&group.editable_name, group.rectangle, track_manager_font, {1, 1, 1, 1}, {0.5, 0.5})
        } else {
            fill_string_aligned(strings.to_string(group.name), group.rectangle, track_manager_font, {1, 1, 1, 1}, {0.5, 0.5})
        }
    }
}

track_manager_confirming_group_deletion :: proc(manager: ^Track_Manager, rectangle: Rectangle) {
    pixel := pixel_size()

    do_abort := false
    do_delete := false

    if key_pressed(.Escape) {
        do_abort = true
    }

    if key_pressed(.Enter) {
        do_delete = true
    }

    for group in manager.groups {
        track_group_update_rectangle(group, track_manager_font)
        track_group_draw_frame(group, manager)
        fill_string_aligned(strings.to_string(group.name), group.rectangle, track_manager_font, {1, 1, 1, 1}, {0.5, 0.5})
    }

    prompt_rectangle := Rectangle{
        pixel_snapped((rectangle.size - {290, 128}) * 0.5),
        {290, 128},
    }

    shadow_rectangle := prompt_rectangle
    shadow_rectangle.position += {3, 5}
    box_shadow(shadow_rectangle, 3, 10, {0, 0, 0, 0.3}, {0, 0, 0, 0})

    fill_rounded_rectangle(prompt_rectangle, 3, {0.4, 0.4, 0.4, 0.6})
    outline_rounded_rectangle(prompt_rectangle, 3, pixel.x, {1, 1, 1, 0.3})

    scoped_clip(prompt_rectangle)

    fill_string_aligned(
        "Delete selected groups?",
        {prompt_rectangle.position + {0, 16}, {prompt_rectangle.size.x, 24}},
        track_manager_font,
        {1, 1, 1, 1},
        {0.5, 0.5},
    )

    BUTTON_SPACING :: 10
    BUTTON_SIZE :: Vector2{96, 32}

    button_anchor := prompt_rectangle.position + prompt_rectangle.size * 0.5
    button_anchor.y += 12

    prompt_button :: proc(button: ^Button, rectangle: Rectangle, label: string, font: Font, outline := false) {
        invisible_button_update(button, rectangle)

        fill_rounded_rectangle(rectangle, 3, {0.1, 0.1, 0.1, 1})

        if outline {
            outline_rounded_rectangle(rectangle, 3, pixel_size().x, {0.4, 0.9, 1, 0.7})
        }

        if button.is_down {
            fill_rounded_rectangle(rectangle, 3, {0, 0, 0, 0.04})
        } else if mouse_hover() == button.id {
            fill_rounded_rectangle(rectangle, 3, {1, 1, 1, 0.04})
        }

        fill_string_aligned(label, rectangle, font, {1, 1, 1, 1}, {0.5, 0.5})
    }

    yes_button_position: Vector2
    yes_button_position = button_anchor
    yes_button_position.x -= BUTTON_SIZE.x + BUTTON_SPACING * 0.5
    prompt_button(
        &manager.delete_prompt_yes_button,
        {yes_button_position, BUTTON_SIZE},
        "Yes",
        track_manager_font,
        true,
    )
    if manager.delete_prompt_yes_button.clicked {
        do_delete = true
    }

    no_button_position: Vector2
    no_button_position = button_anchor
    no_button_position.x += BUTTON_SPACING * 0.5
    prompt_button(
        &manager.delete_prompt_no_button,
        {no_button_position, BUTTON_SIZE},
        "No",
        track_manager_font,
        false,
    )
    if manager.delete_prompt_no_button.clicked {
        do_abort = true
    }

    if do_delete {
        track_manager_remove_selected_groups(manager)
        manager.state = .Editing
    } else if do_abort {
        manager.state = .Editing
    }
}

//==========================================================================
// Project Saving/Loading
//==========================================================================

track_manager_pre_load :: proc() {
    project := reaper.GetCurrentProjectInLoadSave()
    manager := get_track_manager(project)
    track_manager_reset(manager)
}

track_manager_load_state :: proc(ctx: ^reaper.ProjectStateContext) {
    project := reaper.GetCurrentProjectInLoadSave()
    manager := get_track_manager(project)

    parser: Reaper_Project_Parser
    reaper_project_parser_init(&parser, ctx)

    for {
        reaper_project_parser_advance_line(&parser)
        if parser.is_done {
            break
        }

        if reaper_project_parser_is_empty_line(&parser) {
            continue
        }

        switch parser.line_tokens[0] {
        case "<GROUP":
            track_manager_parse_group(&parser, manager)
        }
    }
}

track_manager_parse_group :: proc(parser: ^Reaper_Project_Parser, manager: ^Track_Manager) {
    group := new(Track_Group)
    track_group_init(group)

    nest_start := parser.nest_level

    for parser.nest_level >= nest_start {
        reaper_project_parser_advance_line(parser)

        switch parser.line_tokens[0] {
        case "NAME":
            name := reaper_project_parser_get_string_field(parser, context.temp_allocator)
            strings.write_string(&group.name, name)

        case "POSITION":
            group.position = reaper_project_parser_get_vector2_field(parser)

        case "KIND":
            group.kind = cast(Track_Group_Kind)reaper_project_parser_get_int_field(parser)

        case "ISSELECTED":
            group.is_selected = cast(bool)reaper_project_parser_get_int_field(parser)

        case "<TRACKGUIDS":
            guid_strings := make([dynamic]string, context.temp_allocator)
            track_guid_nest_start := parser.nest_level

            for parser.nest_level >= track_guid_nest_start {
                reaper_project_parser_advance_line(parser)
                if len(parser.line_tokens) == 0 {
                    continue
                }

                // Need to clone here because the parser stores line tokens
                // in a temporary buffer that gets overwritten each line.
                guid_string := strings.clone(parser.line_tokens[0], context.temp_allocator)

                append(&guid_strings, guid_string)
            }

            reaper_get_tracks_from_guid_strings(&group.tracks, manager.project, guid_strings[:])
        }
    }

    append(&manager.groups, group)
}

track_manager_save_state :: proc(ctx: ^reaper.ProjectStateContext) {
    track_manager_save_window_position_and_size()
    project := reaper.GetCurrentProjectInLoadSave()

    manager, exists := track_managers[project]
    if !exists {
        return
    }

    if len(manager.groups) == 0 {
        return
    }

    reaper_project_parser_add_line(ctx, "<ALKAMISTTRACKMANAGER")
    for group in manager.groups {
        track_manager_save_group_state(ctx, group)
    }
    reaper_project_parser_add_line(ctx, ">")
}

track_manager_save_group_state :: proc(ctx: ^reaper.ProjectStateContext, group: ^Track_Group) {
    reaper_project_parser_add_line(ctx, "<GROUP")

    reaper_project_parser_add_linef(ctx, "NAME \"%s\"", strings.to_string(group.name))
    reaper_project_parser_add_linef(ctx, "POSITION %s %s", reaper_format_f32(group.position.x), reaper_format_f32(group.position.y))
    reaper_project_parser_add_linef(ctx, "KIND %d", cast(int)group.kind)
    reaper_project_parser_add_linef(ctx, "ISSELECTED %d", cast(int)group.is_selected)

    reaper_project_parser_add_line(ctx, "<TRACKGUIDS")
    for track in group.tracks {
        buffer: [64]byte
        reaper.guidToString(reaper.GetTrackGUID(track), &buffer[0])
        reaper_project_parser_add_linef(ctx, "%s", cast(string)buffer[:])
    }
    reaper_project_parser_add_line(ctx, ">")

    reaper_project_parser_add_line(ctx, ">")
}

track_manager_save_window_position_and_size :: proc() {
    position := track_manager_window.position
    size := track_manager_window.size

    x := reaper_format_f32(position.x)
    x_cstring := strings.clone_to_cstring(x, context.temp_allocator)
    reaper.SetExtState("Alkamist_Track_Manager", "window_x", x_cstring, true)

    y := reaper_format_f32(position.y)
    y_cstring := strings.clone_to_cstring(y, context.temp_allocator)
    reaper.SetExtState("Alkamist_Track_Manager", "window_y", y_cstring, true)

    width := reaper_format_f32(size.x)
    width_cstring := strings.clone_to_cstring(width, context.temp_allocator)
    reaper.SetExtState("Alkamist_Track_Manager", "window_width", width_cstring, true)

    height := reaper_format_f32(size.y)
    height_cstring := strings.clone_to_cstring(height, context.temp_allocator)
    reaper.SetExtState("Alkamist_Track_Manager", "window_height", height_cstring, true)
}

track_manager_load_window_position_and_size :: proc() {
    position := Vector2{200, 200}
    size := Vector2{400, 300}

    if reaper.HasExtState("Alkamist_Track_Manager", "window_x") {
        value_cstring := reaper.GetExtState("Alkamist_Track_Manager", "window_x")
        position.x = strconv.parse_f32(cast(string)value_cstring) or_else position.x
    }
    if reaper.HasExtState("Alkamist_Track_Manager", "window_y") {
        value_cstring := reaper.GetExtState("Alkamist_Track_Manager", "window_y")
        position.y = strconv.parse_f32(cast(string)value_cstring) or_else position.y
    }
    if reaper.HasExtState("Alkamist_Track_Manager", "window_width") {
        value_cstring := reaper.GetExtState("Alkamist_Track_Manager", "window_width")
        size.x = strconv.parse_f32(cast(string)value_cstring) or_else size.x
    }
    if reaper.HasExtState("Alkamist_Track_Manager", "window_height") {
        value_cstring := reaper.GetExtState("Alkamist_Track_Manager", "window_height")
        size.y = strconv.parse_f32(cast(string)value_cstring) or_else size.y
    }

    track_manager_window.position = position
    track_manager_window.size = size
}