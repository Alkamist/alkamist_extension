package track_manager

import "../../gui"
import "../../gui/color"
import "../../gui/widgets"

Right_Click_Menu :: struct {
    using button: widgets.Button,
    is_open: bool,
    click_start: Vec2,
}

init_right_click_menu :: proc() -> Right_Click_Menu {
    return {
        button = widgets.init_button(),
    }
}

update_right_click_menu :: proc(manager: ^Track_Manager) {
    menu := &manager.right_click_menu

    // Handle the logic for opening the menu.
    if !menu.is_open {
        if gui.mouse_pressed(.Right) {
            menu.click_start = gui.mouse_position()
        }
        if gui.mouse_released(.Right) && gui.mouse_position() == menu.click_start {
            menu.is_open = true
            menu.position = gui.mouse_position()
        }
    }

    // Don't process the menu if it is not open.
    if !menu.is_open {
        return
    }

    gui.offset(menu.position)

    // Add menu items every frame.
    item :: proc(name: string) -> widgets.Text {
        return widgets.init_text(&consola, name)
    }

    items := [?]widgets.Text{
        item("Add selected tracks to selected groups"),
        item("Remove selected tracks from selected groups"),
        item("Add new group"),
        item("Delete selected groups"),
    }

    // Clean up menu items every frame.
    defer for item in &items {
        widgets.destroy_text(&item)
    }

    // Measure menu items and update menu size accordingly.
    item_position := Vec2{0, 0}
    menu.size = Vec2{0, 0}
    for item in &items {
        item.position = item_position
        widgets.update_text(&item)
        item_bottom_right := item.position + item.size
        menu.size.x = max(menu.size.x, item_bottom_right.x)
        menu.size.y = max(menu.size.y, item_bottom_right.y)
        item_position.y += item.size.y
    }

    // Update the button state of the menu since the size is now known.
    widgets.update_button(menu)

    // Draw the menu frame.
    gui.begin_path()
    gui.path_rounded_rect({0, 0}, menu.size, 3)
    gui.fill_path(color.lighten(BACKGROUND_COLOR, 0.1))

    pixel := gui.pixel_distance()
    gui.begin_path()
    gui.path_rounded_rect(pixel * 0.5, menu.size - pixel, 3)
    gui.stroke_path({1, 1, 1, 0.3}, 1)

    // Draw the menu items.
    for item in &items {
        widgets.draw_text(&item)
    }
}