package track_manager

import "../../gui"
import "../../gui/widgets"
import "../../reaper"

Box_Select :: struct {
    is_active: bool,
    start: Vec2,
    finish: Vec2,
}

select_point :: proc(manager: ^Track_Manager, position: Vec2, keep_selection: bool) {
    select_box(manager, position, {0, 0}, keep_selection)
}

select_box :: proc(manager: ^Track_Manager, position, size: Vec2, keep_selection: bool) {
    addition := gui.key_down(.Left_Shift)
    invert := gui.key_down(.Left_Control)

    keep_selection := keep_selection || addition || invert

    // I don't know if there is a way to avoid looping twice.
    for group in manager.groups {
        if group.is_selected && gui.is_hovered(&group.button_state) {
            keep_selection = true
        }
    }

    for group in manager.groups {
        if !keep_selection {
            group.is_selected = false
        }

        box_select_rect := gui.Rect{position, size}
        group_rect := gui.Rect{group.position, group.size}

        if gui.intersects(box_select_rect, group_rect, true) {
            if invert {
                group.is_selected = !group.is_selected
            } else {
                group.is_selected = true
            }
        }
    }
}

update_box_select :: proc(manager: ^Track_Manager) {
    box_select := &manager.box_select
    mouse_position := gui.mouse_position()

    if gui.mouse_pressed(.Right) {
        box_select.is_active = true
        box_select.start = mouse_position
        box_select.finish = mouse_position
    }

    if box_select.is_active {
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

        if gui.mouse_released(.Right) {
            // Don't clear the selection when opening the right click menu in empty space.
            keep_selection := manager.right_click_menu.opened_this_frame && !manager.group_is_hovered

            select_box(manager, position, size, keep_selection)
            box_select.is_active = false
        }

        fill_rect(position, size, {0, 0, 0, 0.3})
        outline_rect(position, size, {1, 1, 1, 0.7})
    }
}