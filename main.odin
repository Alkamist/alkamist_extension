package main

import "core:c"
import "core:runtime"
import "../gui"
import "../reaper"
import "track_manager"

reaper_extension_main :: proc() {
    reaper.add_action("Alkamist: Track manager", "ALKAMIST_TRACK_MANAGER", track_manager.run)

    reaper.add_timer(proc() {
        gui.update()
    })
}

@export
ReaperPluginEntry :: proc "c" (hInst: rawptr, rec: ^reaper.plugin_info_t) -> c.int {
    context = runtime.default_context()
    if rec != nil {
        reaper.plugin_info = rec
        reaper.load_api_functions()
        reaper.register_actions()
        reaper_extension_main()
        return 1
    }
    return 0
}