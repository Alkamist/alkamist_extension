package main

import "core:c"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:unicode"
import "core:runtime"
import "../reaper"

main_context: runtime.Context
reaper_plugin_info: ^reaper.plugin_info_t

//==========================================================================
// Utility
//==========================================================================

reaper_window_init :: proc(window: ^Window, rectangle: Rectangle) {
    window_init(window, rectangle)
    window.child_kind = .Transient
    window.parent_handle = reaper_plugin_info.hwnd_main
}

reaper_print :: proc(format: string, args: ..any) {
    msg := fmt.tprintf(format, ..args)
    msg_with_newline := strings.concatenate({strings.trim_null(cast(string)msg[:]), "\n"}, context.temp_allocator)
    reaper.ShowConsoleMsg(strings.clone_to_cstring(msg_with_newline, context.temp_allocator))
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

//==========================================================================
// Actions
//==========================================================================

reaper_add_action :: proc(name, id: cstring, action: proc()) {
    command_id := reaper_plugin_info.Register("command_id", cast(rawptr)id)
    accel_register: reaper.gaccel_register_t

    accel_register.desc = name
    accel_register.accel.cmd = u16(command_id)

    reaper_plugin_info.Register("gaccel", &accel_register)
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
// Plugin Entry Point
//==========================================================================

@export
ReaperPluginEntry :: proc "c" (hInst: rawptr, rec: ^reaper.plugin_info_t) -> c.int {
    main_context = runtime.default_context()
    context = main_context

    if rec != nil {
        reaper_plugin_info = rec
        reaper.load_api_functions(reaper_plugin_info)

        init()

        reaper_plugin_info.Register("hookcommand", cast(rawptr)_reaper_hook_command)
        reaper_plugin_info.Register("timer", cast(rawptr)proc "c" () {
            context = main_context
            gui_update()
            if reaper_save_project_requested {
                reaper.Main_OnCommandEx(40026, 0, nil)
                reaper_save_project_requested = false
            }
        })

        return 1
    }

    return 0
}