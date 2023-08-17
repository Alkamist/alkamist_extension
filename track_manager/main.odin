package track_manager

import "../../gui"
import "../../reaper"

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

track_manager := init_track_manager(project = nil)

on_frame :: proc() {
    update_track_manager(&track_manager)
}

init :: proc() {
    position := Vec2{50, 50}
    add_new_track_group(&track_manager, "Vocals", position);  position += {0, 30}
    add_new_track_group(&track_manager, "Drums", position);   position += {0, 30}
    add_new_track_group(&track_manager, "Guitars", position); position += {0, 30}
    add_new_track_group(&track_manager, "Bass", position);    position += {0, 30}
    add_new_track_group(&track_manager, "Strings", position); position += {0, 30}
    add_new_track_group(&track_manager, "Brass", position);   position += {0, 30}
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window()
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}