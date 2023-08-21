package track_manager

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../../gui"
import "../../reaper"



// text edit to facilitate adding groups
// delete groups (prompt if sure)



BACKGROUND_COLOR :: Color{0.2, 0.2, 0.2, 1}

consola := gui.init_font("Consola", #load("../consola.ttf"))

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
        gui.request_window_close(&window)
    }

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

    when ODIN_DEBUG {
        if gui.key_pressed(.M) {
            check_for_memory_issues()
        }
    }
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