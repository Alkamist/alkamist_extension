package shared

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:strconv"
import "core:unicode"
import "../../reaper"

Project_State_Parser :: struct {
    line_buffer: [4096]byte,
    line_tokens: [dynamic]string,
    ctx: ^reaper.ProjectStateContext,
    is_done: bool,
    nest_level: int,
}

make_project_state_parser :: proc(ctx: ^reaper.ProjectStateContext) -> Project_State_Parser {
    return {
        ctx = ctx,
        line_tokens = make([dynamic]string, context.temp_allocator),
    }
}

add_line :: proc(ctx: ^reaper.ProjectStateContext, line: string) {
    reaper.ProjectStateContext_AddLine(ctx, strings.clone_to_cstring(line, context.temp_allocator))
}

add_linef :: proc(ctx: ^reaper.ProjectStateContext, format: string, args: ..any) {
    line_formatted := fmt.tprintf(format, ..args)
    reaper.ProjectStateContext_AddLine(ctx, strings.clone_to_cstring(line_formatted, context.temp_allocator))
}

get_line :: proc(ctx: ^reaper.ProjectStateContext, backing_buffer: []byte) -> (result: string, ok: bool) {
    if reaper.ProjectStateContext_GetLine(ctx, &backing_buffer[0], i32(len(backing_buffer))) != 0 {
        return "", false
    }
    return strings.trim_null(cast(string)backing_buffer[:]), true
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

    _parse_line(&parser.line_tokens, line)

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
get_string_field :: proc(parser: ^Project_State_Parser, allocator := context.allocator) -> string {
    if len(parser.line_tokens) < 2 {
        return ""
    }
    return strings.clone(strings.trim(parser.line_tokens[1], "\""), allocator)
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

// Splits a line by spaces, but keeps spaces inside strings.
// Tokens are appended to the dynamic array passed in.
_parse_line :: proc(tokens: ^[dynamic]string, line: string) {
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