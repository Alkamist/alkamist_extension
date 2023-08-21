package shared

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../../reaper"

Project_State_Parser :: struct {
    line_buffer: [4096]byte,
    line_tokens: [dynamic]string,
    ctx: ^reaper.ProjectStateContext,
    is_done: bool,
    nest_level: int,
}

add_line :: proc(ctx: ^reaper.ProjectStateContext, line: string) {
    line_cstring := strings.clone_to_cstring(line)
    defer delete(line_cstring)

    reaper.ProjectStateContext_AddLine(ctx, line_cstring)
}

add_linef :: proc(ctx: ^reaper.ProjectStateContext, format: string, args: ..any) {
    line_formatted := fmt.aprintf(format, ..args)
    defer delete(line_formatted)

    line_cstring := strings.clone_to_cstring(line_formatted)
    defer delete(line_cstring)

    reaper.ProjectStateContext_AddLine(ctx, line_cstring)
}

get_line :: proc(ctx: ^reaper.ProjectStateContext, backing_buffer: []byte) -> (result: string, ok: bool) {
    if reaper.ProjectStateContext_GetLine(ctx, &backing_buffer[0], i32(len(backing_buffer))) != 0 {
        return "", false
    }

    return strings.trim_null(cast(string)backing_buffer[:]), true
}

destroy_project_state_parser :: proc(parser: ^Project_State_Parser) {
    delete(parser.line_tokens)
}

is_empty_line :: proc(parser: ^Project_State_Parser) -> bool {
    return len(parser.line_tokens) == 0
}

advance_line :: proc(parser: ^Project_State_Parser) {
    clear(&parser.line_tokens)
    parser.line_buffer = 0

    line, exists := get_line(parser.ctx, parser.line_buffer[:])
    if !exists {
        return
    }

    for token in strings.split_iterator(&line, " ") {
        append(&parser.line_tokens, token)
    }

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

get_string_field :: proc(parser: ^Project_State_Parser) -> string {
    if len(parser.line_tokens) < 2 {
        return ""
    }
    return strings.clone(parser.line_tokens[1])
}

get_f32_field :: proc(parser: ^Project_State_Parser) -> f32 {
    if len(parser.line_tokens) < 2 {
        return 0
    }
    return strconv.parse_f32(parser.line_tokens[1]) or_else 0
}

get_int_field :: proc(parser: ^Project_State_Parser) -> int {
    if len(parser.line_tokens) < 2 {
        return 0
    }
    return strconv.parse_int(parser.line_tokens[1]) or_else 0
}

get_vec2_field :: proc(parser: ^Project_State_Parser) -> Vec2 {
    if len(parser.line_tokens) < 3 {
        return {0, 0}
    }
    return {
        strconv.parse_f32(parser.line_tokens[1]) or_else 0,
        strconv.parse_f32(parser.line_tokens[2]) or_else 0,
    }
}