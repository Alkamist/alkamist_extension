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

    if editor_disabled(manager) {
        box_select.is_active = false
        box_select.start = {0, 0}
        box_select.finish = {0, 0}
        return
    }

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
            box_select_rect := gui.Rect{position, size}

            groups_touched := make([dynamic]^Track_Group, gui.arena_allocator())

            for group in manager.groups {
                group_rect := gui.Rect{group.position, group.size}
                if gui.intersects(box_select_rect, group_rect, true) {
                    append(&groups_touched, group)
                }
            }

            // Don't clear the selection when opening the right click menu in empty space.
            keep_selection := manager.right_click_menu.opened_this_frame && !manager.group_is_hovered

            group_selection_logic(manager, groups_touched[:], keep_selection)

            box_select.is_active = false
        }

        fill_rect(position, size, {0, 0, 0, 0.3})
        outline_rect(position, size, {1, 1, 1, 0.7})
    }
}