package track_manager

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../../gui"
import "../../reaper"



// text edit to facilitate adding groups
// delete groups (prompt if sure)



Vec2 :: gui.Vec2
Color :: gui.Color

BACKGROUND_COLOR :: Color{0.2, 0.2, 0.2, 1}

consola := gui.init_font("Consola", #load("../consola.ttf"))

last_window_position: Vec2
last_window_size: Vec2

window := gui.init_window(
    title = "Track Manager",
    position = {200, 200},
    background_color = BACKGROUND_COLOR,
    child_kind = .Transient,
    on_frame = on_frame,
)

track_managers: map[^reaper.ReaProject]^Track_Manager

get_track_manager :: proc(project: ^reaper.ReaProject) -> ^Track_Manager {
    manager, exists := track_managers[project]
    if !exists {
        manager = new(Track_Manager)
        manager^ = init_track_manager(project)
        track_managers[project] = manager
    }
    return manager
}

pre_load :: proc() {
    project := reaper.GetCurrentProjectInLoadSave()
    manager := get_track_manager(project)
    reset_track_manager(manager)
}

load_state :: proc(ctx: ^reaper.ProjectStateContext) {
    project := reaper.GetCurrentProjectInLoadSave()
    manager := get_track_manager(project)

    parser := Project_State_Parser{
        ctx = ctx,
    }
    defer destroy_project_state_parser(&parser)

    for {
        advance_line(&parser)
        if parser.is_done {
            return
        }

        if is_empty_line(&parser) {
            continue
        }

        switch parser.line_tokens[0] {
        case "<GROUP":
            parse_group(&parser, manager)
        }
    }
}

parse_group :: proc(parser: ^Project_State_Parser, manager: ^Track_Manager) {
    group := new(Track_Group)
    group^ = init_track_group()

    nest_start := parser.nest_level

    for parser.nest_level >= nest_start {
        advance_line(parser)

        switch parser.line_tokens[0] {
        case "NAME":
            group.name = get_string_field(parser)
        case "POSITION":
            group.position = get_vec2_field(parser)
        case "ISSELECTED":
            group.is_selected = cast(bool)get_int_field(parser)

        case "<TRACKGUIDS":
            guid_strings: [dynamic]string

            // The strings are cloned and need to be cleaned up.
            defer for guid_string in guid_strings {
                delete(guid_string)
            }

            track_guid_nest_start := parser.nest_level

            for parser.nest_level >= track_guid_nest_start {
                advance_line(parser)
                if len(parser.line_tokens) == 0 {
                    continue
                }

                // Need to clone here because the parser stores
                // line tokens in a temporary buffer.
                guid_string := strings.clone(parser.line_tokens[0])

                append(&guid_strings, guid_string)
            }

            load_tracks_from_guid_strings(&group.tracks, manager.project, guid_strings[:])
        }
    }

    append(&manager.groups, group)
}

save_state :: proc(ctx: ^reaper.ProjectStateContext) {
    save_window_position_and_size()

    project := reaper.GetCurrentProjectInLoadSave()

    manager, exists := track_managers[project]
    if !exists {
        return
    }

    for group in manager.groups {
        save_group_state(ctx, group)
    }
}

save_group_state :: proc(ctx: ^reaper.ProjectStateContext, group: ^Track_Group) {
    add_line(ctx, "<GROUP")
    add_linef(ctx, "NAME %s", group.name)

    x_string := format_f32_for_storage(group.position.x)
    defer delete(x_string)
    y_string := format_f32_for_storage(group.position.y)
    defer delete(y_string)
    add_linef(ctx, "POSITION %s %s", x_string, y_string)

    add_linef(ctx, "ISSELECTED %d", cast(int)group.is_selected)

    add_line(ctx, "<TRACKGUIDS")
    for track in group.tracks {
        buffer: [64]byte
        reaper.guidToString(reaper.GetTrackGUID(track), &buffer[0])
        add_linef(ctx, "%s", cast(string)buffer[:])
    }
    add_line(ctx, ">")

    add_line(ctx, ">")
}

save_window_position_and_size :: proc() {
    position := gui.window_position()
    size := gui.window_size()

    x := format_f32_for_storage(position.x)
    x_cstring := strings.clone_to_cstring(x)
    reaper.SetExtState("Alkamist_Track_Manager", "window_x", x_cstring, true)
    delete(x)
    delete(x_cstring)

    y := format_f32_for_storage(position.y)
    y_cstring := strings.clone_to_cstring(y)
    reaper.SetExtState("Alkamist_Track_Manager", "window_y", y_cstring, true)
    delete(y)
    delete(y_cstring)

    width := format_f32_for_storage(size.x)
    width_cstring := strings.clone_to_cstring(width)
    reaper.SetExtState("Alkamist_Track_Manager", "window_width", width_cstring, true)
    delete(width)
    delete(width_cstring)

    height := format_f32_for_storage(size.y)
    height_cstring := strings.clone_to_cstring(height)
    reaper.SetExtState("Alkamist_Track_Manager", "window_height", height_cstring, true)
    delete(height)
    delete(height_cstring)
}

load_window_position_and_size :: proc() {
    position := Vec2{200, 200}
    size := Vec2{400, 300}

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

    gui.set_window_position(position, &window)
    gui.set_window_size(size, &window)
}

on_frame :: proc() {
    project := reaper.EnumProjects(-1, nil, 0)
    manager := get_track_manager(project)

    update_track_manager(manager)

    // Save project when control + s pressed.
    if gui.key_down(.Left_Control) && gui.key_pressed(.S) {
        save_project()
    }

    // Play the project when pressing space bar.
    if gui.key_pressed(.Space) {
        reaper.Main_OnCommandEx(40044, 0, nil)
    }

    if gui.key_pressed(.Escape) {
        gui.request_window_close()
    }

    // if gui.key_pressed(.T) {
    //     reaper.Undo_BeginBlock2(nil)
    //     reaper.Undo_EndBlock2(nil, "Alkamist Test", reaper.UNDO_STATE_MISCCFG)
    //     // reaper.Undo_OnStateChangeEx2(nil, "Alkamist Test", reaper.UNDO_STATE_MISCCFG, -1)
    // }

    // if gui.key_pressed(.Enter) {
    //     // Temporary test groups.
    //     position := Vec2{50, 50}
    //     add_new_track_group(manager, "Vocals", position);  position += {0, 30}
    //     add_new_track_group(manager, "Drums", position);   position += {0, 30}
    //     add_new_track_group(manager, "Guitars", position); position += {0, 30}
    //     add_new_track_group(manager, "Bass", position);    position += {0, 30}
    //     add_new_track_group(manager, "Strings", position); position += {0, 30}
    //     add_new_track_group(manager, "Brass", position);   position += {0, 30}
    // }
}

init :: proc() {
    load_window_position_and_size()
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window(&window)
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}