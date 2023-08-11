package test_action

import "../../reaper"
import "../../gui"
import "../../gui/widgets"

Vec2 :: gui.Vec2

consola := gui.Font{"Consola", #load("../consola.ttf")}

button := widgets.make_button(position = {50, 50})
rect_position := Vec2{100, 100}

test_action_window := gui.make_window(
    title = "Test Action Window",
    position = {200, 200},
    background_color = {0.05, 0.05, 0.05, 1},
    default_font = &consola,
    child_kind = .Transient,
    on_frame = on_frame,
)

on_frame :: proc() {
    gui.begin_path()
    gui.rounded_rect(rect_position, {100, 100}, 5)
    gui.fill_path({1, 0, 0, 1})

    if gui.mouse_pressed(.Right) {
        reaper.ShowConsoleMsg("Right mouse button pressed.\n")
    }

    if gui.mouse_down(.Left) && gui.mouse_moved() {
        rect_position += gui.mouse_delta()
    }

    widgets.update_button(&button)
    widgets.draw_button(&button)

    if button.clicked {
        reaper.ShowConsoleMsg("Button clicked.\n")
    }
}

run :: proc() {
    if gui.window_is_open(&test_action_window) {
        gui.close_window()
    }

    gui.set_window_parent(&test_action_window, reaper.window_handle())
    gui.open_window(&test_action_window)
}