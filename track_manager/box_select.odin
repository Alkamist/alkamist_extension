package track_manager

import "../../gui"
import "../../gui/widgets"
import "../../reaper"

Box_Select :: struct {
    is_active: bool,
    start: Vec2,
    finish: Vec2,
}

update_box_select :: proc(manager: ^Track_Manager) {
    box_select := &manager.box_select
    mouse_position := gui.mouse_position()

    if gui.mouse_pressed(.Right) {
        box_select.is_active = true
        box_select.start = mouse_position
        box_select.finish = mouse_position
    }

    if gui.mouse_down(.Right) {
        box_select.finish = mouse_position
    }

    if gui.mouse_released(.Right) {
        box_select.is_active = false
    }

    if box_select.is_active {
        top_left := Vec2{
            min(box_select.start.x, box_select.finish.x),
            min(box_select.start.y, box_select.finish.y),
        }
        bottom_right := Vec2{
            max(box_select.start.x, box_select.finish.x),
            max(box_select.start.y, box_select.finish.y),
        }
        size := bottom_right - top_left

        gui.begin_path()
        gui.path_rect(top_left, size)
        gui.fill_path({0, 0, 0, 0.3})

        pixel := gui.pixel_distance()
        gui.begin_path()
        gui.path_rect(top_left + pixel * 0.5, size - pixel)
        gui.stroke_path({1, 1, 1, 0.7}, 1)
    }
}