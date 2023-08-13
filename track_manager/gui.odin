package test_action

import "../../reaper"
import "../../gui"
import "../../gui/color"
import "../../gui/widgets"

Vec2 :: gui.Vec2

consola := gui.Font{"Consola", #load("../consola.ttf")}

window: gui.Window
track_manager: Track_Manager

on_frame :: proc() {
    update_track_manager(&track_manager)
}

init :: proc() {
    gui.init_window(
        &window,
        title = "Track Manager",
        position = {200, 200},
        background_color = color.rgb(49, 51, 56),
        default_font = &consola,
        child_kind = .Transient,
        on_frame = on_frame,
    )

    _add_new_track_group(&track_manager, "Verse")
    _add_new_track_group(&track_manager, "Chorus")
    _add_new_track_group(&track_manager, "Vocals")
    _add_new_track_group(&track_manager, "Drums")
    _add_new_track_group(&track_manager, "Guitars")
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window()
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}