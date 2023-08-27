package track_manager

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../shared"
import "../../gui"
import "../../reaper"

BACKGROUND_COLOR :: Color{0.2, 0.2, 0.2, 1}

window: gui.Window
track_managers: map[^reaper.ReaProject]^Track_Manager

get_track_manager :: proc(project: ^reaper.ReaProject) -> ^Track_Manager {
    manager, exists := track_managers[project]
    if !exists {
        manager = new(Track_Manager)
        manager^ = make_track_manager(project)
        track_managers[project] = manager
    }
    return manager
}

on_frame :: proc() {
    project := reaper.EnumProjects(-1, nil, 0)
    manager := get_track_manager(project)

    update_track_manager(manager)
}

init :: proc() {
    window = gui.make_window(
        title = "Track Manager",
        position = {200, 200},
        background_color = BACKGROUND_COLOR,
        child_kind = .Transient,
        on_frame = on_frame,
    )
    load_window_position_and_size()
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window(&window)
        return
    }

    gui.set_window_parent(&window, shared.plugin_info.hwnd_main)
    gui.open_window(&window)
}