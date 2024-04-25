package main

import "core:strings"
import "../reaper"

update :: proc() {
    reaper.PreventUIRefresh(1)

    project := reaper.EnumProjects(-1, nil, 0)

    manager := get_track_manager(project)
    if window_update(&track_manager_window) {
        track_manager_update(manager)
    }

    reaper.PreventUIRefresh(-1)
}

init :: proc() {
    gui_startup(update)

    reaper_window_init(&track_manager_window, {{100, 100}, {400, 300}})
    track_manager_window.should_open = false
    track_manager_window.background_color = {0.2, 0.2, 0.2, 1}

    reaper_add_action("Alkamist: Track manager", "ALKAMIST_TRACK_MANAGER", proc() {
        track_manager_window.should_open = true
    })

    reaper_plugin_info.Register("projectconfig", &project_config_extension)
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