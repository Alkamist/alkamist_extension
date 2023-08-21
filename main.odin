package main

import "core:c"
import "core:strings"
import "core:runtime"
import "../gui"
import "../reaper"
import "shared"
import "track_manager"

main_context: runtime.Context

project_config_extension := reaper.project_config_extension_t{
    ProcessExtensionLine = proc "c" (line: cstring, ctx: ^reaper.ProjectStateContext, isUndo: bool, reg: ^reaper.project_config_extension_t) -> bool {
        context = main_context

        line_tokens := strings.split(cast(string)line, " ")
        defer delete(line_tokens)

        if len(line_tokens) == 0 {
            return false
        }

        if line_tokens[0] == "<ALKAMISTTRACKMANAGER" {
            track_manager.load_state(ctx)
        }

        return true
    },
    SaveExtensionConfig = proc "c" (ctx: ^reaper.ProjectStateContext, isUndo: bool, reg: ^reaper.project_config_extension_t) {
        if isUndo {
            return
        }

        context = main_context

        shared.add_line(ctx, "<ALKAMISTTRACKMANAGER")
        track_manager.save_state(ctx)
        shared.add_line(ctx, ">")

    },
    BeginLoadProjectState = proc "c" (isUndo: bool, reg: ^reaper.project_config_extension_t) {
        context = main_context
        track_manager.pre_load()
    },
    userData = nil,
}

reaper_extension_main :: proc() {
    reaper.add_action("Alkamist: Track manager", "ALKAMIST_TRACK_MANAGER", track_manager.run)

    reaper.plugin_info.Register("projectconfig", &project_config_extension)

    reaper.add_timer(proc() {
        gui.update()
        if shared.save_requested {
            reaper.Main_OnCommandEx(40026, 0, nil)
            shared.save_requested = false
        }
    })

    track_manager.init()
}

@export
ReaperPluginEntry :: proc "c" (hInst: rawptr, rec: ^reaper.plugin_info_t) -> c.int {
    main_context = runtime.default_context()
    context = main_context
    if rec != nil {
        reaper.plugin_info = rec
        reaper.load_api_functions()
        reaper.register_actions()
        reaper_extension_main()
        return 1
    }
    return 0
}