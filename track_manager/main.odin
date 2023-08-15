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
    add_new_track_group(&track_manager, "Hello World.", {100, 70})
    add_new_track_group(&track_manager, "Chorus",{100, 100})
    add_new_track_group(&track_manager, "Vocals",{100, 130})
    add_new_track_group(&track_manager, "Drums",{100, 160})
    add_new_track_group(&track_manager, "Guitars",{100, 190})
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window()
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}