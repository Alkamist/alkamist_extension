package track_manager

import "../utility"
import "../../gui"
import "../../reaper"



// state saving/loading
// text edit to facilitate adding groups
// delete groups (prompt if sure)



Vec2 :: gui.Vec2
Color :: gui.Color

BACKGROUND_COLOR :: Color{0.2, 0.2, 0.2, 1}

consola := gui.init_font("Consola", #load("../consola.ttf"))

window := gui.init_window(
    title = "Track Manager",
    position = {200, 200},
    background_color = BACKGROUND_COLOR,
    child_kind = .Transient,
    on_frame = on_frame,
)

track_managers: map[^reaper.ReaProject]Track_Manager

on_project_load :: proc(project: ^reaper.ReaProject) {
    // debug("Loaded")
}

on_project_save :: proc(project: ^reaper.ReaProject) {
    // debug("Saved")
}

on_frame :: proc() {
    current_project := reaper.EnumProjects(-1, nil, 0)

    if !(current_project in track_managers) {
        track_managers[current_project] = init_track_manager(current_project)

        // Temporary test groups.
        position := Vec2{50, 50}
        add_new_track_group(&track_managers[current_project], "Vocals", position);  position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Drums", position);   position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Guitars", position); position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Bass", position);    position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Strings", position); position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Brass", position);   position += {0, 30}
    }

    update_track_manager(&track_managers[current_project])

    // Save project when control + s pressed.
    if gui.key_down(.Left_Control) && gui.key_pressed(.S) {
        utility.save_project()
    }

    // Play the project when pressing space bar.
    if gui.key_pressed(.Space) {
        reaper.Main_OnCommandEx(40044, 0, nil)
    }

    if gui.key_pressed(.Escape) {
        gui.request_window_close()
    }
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window(&window)
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}