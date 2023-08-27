package main

import "core:c"
import "core:strings"
import "core:runtime"
import "../gui"
import "../gui/widgets"
import "../reaper"
import "shared"
import "track_manager"

reaper_extension_main :: proc() {
    reaper.load_api_functions(shared.plugin_info)

    if gui.init() != nil {
        reaper.ShowConsoleMsg("Failed to initialize Alkamist Extension.\n")
        return
    }

    widgets.set_default_font(&shared.consola)

    track_manager.init()

    add_reaper_action("Alkamist: Track manager", "ALKAMIST_TRACK_MANAGER", track_manager.run)

    shared.plugin_info.Register("hookcommand", cast(rawptr)hook_command)
    shared.plugin_info.Register("projectconfig", &project_config_extension)

    shared.plugin_info.Register("timer", cast(rawptr)proc "c" () {
        context = shared.main_context

        gui.update()

        if shared.save_requested {
            reaper.Main_OnCommandEx(40026, 0, nil)
            shared.save_requested = false
        }

        free_all(context.temp_allocator)
    })
}

add_reaper_action :: proc(name, id: cstring, action: proc()) {
    command_id := shared.plugin_info.Register("command_id", cast(rawptr)id)
    accel_register: reaper.gaccel_register_t

    accel_register.desc = name
    accel_register.accel.cmd = u16(command_id)

    shared.plugin_info.Register("gaccel", &accel_register)
    action_map[command_id] = action
}

@export
ReaperPluginEntry :: proc "c" (hInst: rawptr, rec: ^reaper.plugin_info_t) -> c.int {
    shared.main_context = runtime.default_context()
    context = shared.main_context

    if rec != nil {
        shared.plugin_info = rec
        reaper_extension_main()
        return 1
    }

    return 0
}

project_config_extension := reaper.project_config_extension_t{
    ProcessExtensionLine = proc "c" (line: cstring, ctx: ^reaper.ProjectStateContext, isUndo: bool, reg: ^reaper.project_config_extension_t) -> bool {
        context = shared.main_context

        line_tokens := strings.split(cast(string)line, " ", context.temp_allocator)

        if len(line_tokens) == 0 {
            return false
        }

        if line_tokens[0] == "<ALKAMISTTRACKMANAGER" {
            track_manager.load_state(ctx)
            return true
        }

        return false
    },
    SaveExtensionConfig = proc "c" (ctx: ^reaper.ProjectStateContext, isUndo: bool, reg: ^reaper.project_config_extension_t) {
        if isUndo {
            return
        }
        context = shared.main_context
        track_manager.save_state(ctx)
    },
    BeginLoadProjectState = proc "c" (isUndo: bool, reg: ^reaper.project_config_extension_t) {
        context = shared.main_context
        track_manager.pre_load()
    },
    userData = nil,
}

action_map: map[c.int]proc()

hook_command :: proc "c" (command, flag: c.int) -> bool {
    context = shared.main_context
    if command == 0 {
        return false
    }
    if action, ok := action_map[command]; ok {
        action()
        return true
    }
    return false
}