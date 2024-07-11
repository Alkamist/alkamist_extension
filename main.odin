package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:time"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:unicode"
import "reaper"

MAX_UPDATE_FPS :: 240.0

main_context: runtime.Context
plugin_info: ^reaper.plugin_info_t

gui_event :: proc(window: ^Window, event: Gui_Event) {
    #partial switch event in event {
    case Gui_Event_Close_Button_Pressed: window.should_close = true
    case Gui_Event_Loop_Timer: update()
    case Gui_Event_Mouse_Move: update()
    case Gui_Event_Mouse_Press: update()
    case Gui_Event_Mouse_Release: update()
    case Gui_Event_Mouse_Scroll: update()
    case Gui_Event_Key_Press: update()
    case Gui_Event_Key_Release: update()
    case Gui_Event_Rune_Input: update()
    }
}

init :: proc() {
    plugin_info.Register("timer", cast(rawptr)proc "c" () {
        context = main_context
        poll_window_events()
        update()
        if reaper_save_project_requested {
            reaper.Main_OnCommandEx(40026, 0, nil)
            reaper_save_project_requested = false
        }
    })
    plugin_info.Register("projectconfig", &project_config_extension)

    reaper_window_init(&track_manager_window, {{100, 100}, {400, 300}})
    track_manager_load_window_position_and_size()
    track_manager_window.title = "Alkamist Track Manager"

    reaper_add_action("Alkamist: Track manager", "ALKAMIST_TRACK_MANAGER", proc() {
        track_manager_window.should_open = true
    })
}

shutdown :: proc() {
    for _, manager in track_managers {
        track_manager_destroy(manager)
    }
    window_destroy(&track_manager_window)
}

update :: proc() {
    @(static) tick_last_frame: time.Tick
    if time.duration_seconds(time.tick_since(tick_last_frame)) > 1.0 / MAX_UPDATE_FPS {
        tick_last_frame = time.tick_now()
    } else {
        return
    }

    reaper.PreventUIRefresh(1)

    project := reaper.EnumProjects(-1, nil, 0)

    manager := get_track_manager(project)
    track_manager_update_active_group_tracks(manager)
    if window_update(&track_manager_window) {
        clear_background({0.2, 0.2, 0.2, 1})
        track_manager_update(manager)
    }

    reaper.PreventUIRefresh(-1)
}

project_config_extension := reaper.project_config_extension_t{
    ProcessExtensionLine = proc "c" (line: cstring, ctx: ^reaper.ProjectStateContext, isUndo: bool, reg: ^reaper.project_config_extension_t) -> bool {
        context = main_context

        line_tokens := strings.split(cast(string)line, " ", context.temp_allocator)

        if len(line_tokens) == 0 {
            return false
        }

        if line_tokens[0] == "<ALKAMISTTRACKMANAGER" {
            track_manager_load_state(ctx)
            return true
        }

        return false
    },

    SaveExtensionConfig = proc "c" (ctx: ^reaper.ProjectStateContext, isUndo: bool, reg: ^reaper.project_config_extension_t) {
        if isUndo {
            return
        }
        context = main_context
        track_manager_save_state(ctx)
    },

    BeginLoadProjectState = proc "c" (isUndo: bool, reg: ^reaper.project_config_extension_t) {
        context = main_context
        track_manager_pre_load()
    },

    userData = nil,
}

//==========================================================================
// Utility
//==========================================================================

keep_if :: proc{
    keep_if_no_user_data,
    keep_if_user_data,
}

keep_if_no_user_data :: proc(array: ^[dynamic]$T, should_keep: proc(x: T) -> bool) {
    keep_position := 0

    for i in 0 ..< len(array) {
        if should_keep(array[i]) {
            if keep_position != i {
                array[keep_position] = array[i]
            }
            keep_position += 1
        }
    }

    resize(array, keep_position)
}

keep_if_user_data :: proc(array: ^[dynamic]$T, user_data: $D, should_keep: proc(x: T, user_data: D) -> bool) {
    keep_position := 0

    for i in 0 ..< len(array) {
        if should_keep(array[i], user_data) {
            if keep_position != i {
                array[keep_position] = array[i]
            }
            keep_position += 1
        }
    }

    resize(array, keep_position)
}

println :: proc(args: ..any, sep := " ") {
    msg := fmt.tprintln(..args, sep = sep)
    reaper.ShowConsoleMsg(strings.clone_to_cstring(msg, context.temp_allocator))
}

printfln :: proc(format: string, args: ..any) {
    msg := fmt.tprintfln(format, ..args)
    reaper.ShowConsoleMsg(strings.clone_to_cstring(msg, context.temp_allocator))
}

reaper_window_init :: proc(window: ^Window, rectangle: Rectangle) {
    window_init(window, rectangle)
    window.child_kind = .Transient
    window.parent_handle = plugin_info.hwnd_main
}

reaper_format_f32 :: proc(value: f32) -> string {
    value_string := fmt.tprintf("%f", value)
    no_zeros := strings.trim_right(value_string, "0")
    no_dot := strings.trim_right(no_zeros, ".")
    return no_dot
}

reaper_get_tracks_from_guid_strings :: proc(tracks: ^[dynamic]^reaper.MediaTrack, project: ^reaper.ReaProject, guid_strings: []string) {
    guids := make([dynamic]reaper.GUID, context.temp_allocator)

    for guid_string in guid_strings {
        guid_cstring := strings.clone_to_cstring(guid_string, context.temp_allocator)

        guid: reaper.GUID
        reaper.stringToGuid(guid_cstring, &guid)

        append(&guids, guid)
    }

    for i in 0 ..< reaper.CountTracks(project) {
        track := reaper.GetTrack(project, i)
        track_guid := reaper.GetTrackGUID(track)

        if track_guid == nil do continue

        if !slice.contains(tracks[:], track) && slice.contains(guids[:], track_guid^) {
            append(tracks, track)
        }
    }
}

reaper_track_is_visible :: proc(track: ^reaper.MediaTrack) -> bool {
    return reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER") == 1 &&
           reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP") == 1
}

reaper_set_track_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", visible ? 1 : 0)
    reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", visible ? 1 : 0)
    reaper.TrackList_AdjustWindows(false)
}

reaper_set_track_and_children_visible :: proc(track: ^reaper.MediaTrack, visible: bool) {
    reaper_set_track_visible(track, visible)

    track := track
    current_depth := reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")

    for current_depth > 0 {
        next_track_index := i32(reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER"))
        if next_track_index <= 0 do return
        track = reaper.GetTrack(nil, next_track_index)
        reaper_set_track_visible(track, visible)
        current_depth += reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH")
    }
}

//==========================================================================
// Actions
//==========================================================================

reaper_add_action :: proc(name, id: cstring, action: proc()) {
    command_id := plugin_info.Register("command_id", cast(rawptr)id)
    accel_register: reaper.gaccel_register_t

    accel_register.desc = name
    accel_register.accel.cmd = u16(command_id)

    plugin_info.Register("gaccel", &accel_register)
    _reaper_action_map[command_id] = action
}

_reaper_action_map: map[c.int]proc()

_reaper_hook_command :: proc "c" (command, flag: c.int) -> bool {
    context = main_context
    if command == 0 {
        return false
    }
    if action, ok := _reaper_action_map[command]; ok {
        action()
        return true
    }
    return false
}

//==========================================================================
// Project State
//==========================================================================

reaper_save_project_requested: bool

reaper_save_project :: proc() {
    reaper_save_project_requested = true
}

Reaper_Project_Parser :: struct {
    line_buffer: [4096]byte,
    line_tokens: [dynamic]string,
    ctx: ^reaper.ProjectStateContext,
    is_done: bool,
    nest_level: int,
}

reaper_project_parser_init :: proc(parser: ^Reaper_Project_Parser, ctx: ^reaper.ProjectStateContext) {
    parser.ctx = ctx
    parser.line_tokens = make([dynamic]string, context.temp_allocator)
}

reaper_project_parser_add_line :: proc(ctx: ^reaper.ProjectStateContext, line: string) {
    reaper.ProjectStateContext_AddLine(ctx, strings.clone_to_cstring(line, context.temp_allocator))
}

reaper_project_parser_add_linef :: proc(ctx: ^reaper.ProjectStateContext, format: string, args: ..any) {
    line_formatted := fmt.tprintf(format, ..args)
    reaper.ProjectStateContext_AddLine(ctx, strings.clone_to_cstring(line_formatted, context.temp_allocator))
}

reaper_project_parser_get_line :: proc(ctx: ^reaper.ProjectStateContext, backing_buffer: []byte) -> (result: string, ok: bool) {
    if reaper.ProjectStateContext_GetLine(ctx, &backing_buffer[0], i32(len(backing_buffer))) != 0 {
        return "", false
    }
    return strings.trim_null(cast(string)backing_buffer[:]), true
}

reaper_project_parser_is_empty_line :: proc(parser: ^Reaper_Project_Parser) -> bool {
    return len(parser.line_tokens) == 0
}

reaper_project_parser_advance_line :: proc(parser: ^Reaper_Project_Parser) {
    clear(&parser.line_tokens)
    parser.line_buffer = 0

    line, exists := reaper_project_parser_get_line(parser.ctx, parser.line_buffer[:])
    if !exists {
        return
    }

    _reaper_project_parser_parse_line(&parser.line_tokens, line)

    if parser.line_buffer[0] == '<' {
       parser.nest_level += 1
    }
    if parser.line_buffer[0] == '>' {
        if parser.nest_level == 0 {
            parser.is_done = true
            return
        }
        parser.nest_level -= 1
    }
}

// Clones the string with the provided allocator.
reaper_project_parser_get_string_field :: proc(parser: ^Reaper_Project_Parser, allocator := context.allocator) -> string {
    if len(parser.line_tokens) < 2 {
        return ""
    }
    return strings.clone(strings.trim(parser.line_tokens[1], "\""), allocator)
}

reaper_project_parser_get_f32_field :: proc(parser: ^Reaper_Project_Parser) -> f32 {
    if len(parser.line_tokens) < 2 {
        return 0
    }
    return strconv.parse_f32(parser.line_tokens[1]) or_else 0
}

reaper_project_parser_get_int_field :: proc(parser: ^Reaper_Project_Parser) -> int {
    if len(parser.line_tokens) < 2 {
        return 0
    }
    return strconv.parse_int(parser.line_tokens[1]) or_else 0
}

reaper_project_parser_get_vector2_field :: proc(parser: ^Reaper_Project_Parser) -> Vector2 {
    if len(parser.line_tokens) < 3 {
        return {0, 0}
    }
    return {
        strconv.parse_f32(parser.line_tokens[1]) or_else 0,
        strconv.parse_f32(parser.line_tokens[2]) or_else 0,
    }
}

// Splits a line by spaces, but keeps spaces inside strings.
// Tokens are appended to the dynamic array passed in.
_reaper_project_parser_parse_line :: proc(tokens: ^[dynamic]string, line: string) {
    Parse_State :: enum {
        Normal,
        Inside_Non_String,
        Inside_String,
    }

    state := Parse_State.Normal
    token_start := 0

    for c, i in line {
        is_space := unicode.is_space(c)
        is_quote := c == '\"'

        just_entered_token := false

        if state == .Normal {
            if is_quote {
                token_start = i
                state = .Inside_String
                just_entered_token = true
            } else if !is_space {
                token_start = i
                state = .Inside_Non_String
                just_entered_token = true
            }
        }

        #partial switch state {
        case .Inside_Non_String:
            if is_space {
                append(tokens, line[token_start:i])
                state = .Normal
            }

        case .Inside_String:
            if is_quote && !just_entered_token {
                append(tokens, line[token_start:i + 1])
                state = .Normal
            }
        }
    }

    if state == .Inside_Non_String {
        append(tokens, line[token_start:len(line)])
        return
    }
}

//==========================================================================
// Entry Point
//==========================================================================

@export
ReaperPluginEntry :: proc "c" (hInst: rawptr, rec: ^reaper.plugin_info_t) -> c.int {
    main_context = runtime.default_context()
    context = main_context

    if rec == nil do return 0

    plugin_info = rec

    reaper.load_api_functions(plugin_info)
    plugin_info.Register("hookcommand", cast(rawptr)_reaper_hook_command)

    init()

    return 1
}