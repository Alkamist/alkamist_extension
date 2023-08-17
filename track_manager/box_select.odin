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

    position := Vec2{
        min(box_select.start.x, box_select.finish.x),
        min(box_select.start.y, box_select.finish.y),
    }

    bottom_right := Vec2{
        max(box_select.start.x, box_select.finish.x),
        max(box_select.start.y, box_select.finish.y),
    }

    size := bottom_right - position

    if !manager.right_click_menu.opened_this_frame && gui.mouse_released(.Right) {
        selection: [dynamic]^Track_Group
        defer delete(selection)

        for group in manager.groups {
            box_select_rect := gui.Rect{position, size}
            group_rect := gui.Rect{group.position, group.size}

            if gui.intersects(box_select_rect, group_rect, true) {
                append(&selection, group)
            }
        }

        update_group_selection(manager, selection[:], false)
    }

    if gui.mouse_released(.Right) {
        box_select.is_active = false
    }

    if box_select.is_active {
        fill_rect(position, size, {0, 0, 0, 0.3})
        outline_rect(position, size, {1, 1, 1, 0.7})
    }
}