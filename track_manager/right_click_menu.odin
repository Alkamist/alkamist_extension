package track_manager

import "../../gui"
import "../../gui/widgets"

Right_Click_Menu_Item :: struct {
    name: string,
    action: proc(manager: ^Track_Manager),
}

right_click_menu_items := [?]Right_Click_Menu_Item{
    {"Add selected tracks", add_selected_tracks_to_selected_groups},
    {"Remove selected tracks", remove_selected_tracks_from_selected_groups},
    {"Add group", nil},
    {"Delete groups", nil},
}

Right_Click_Menu :: struct {
    position: Vec2,
    size: Vec2,
    is_open: bool,
    click_start: Vec2,
    button_state: widgets.Button,
    opened_this_frame: bool,
}

init_right_click_menu :: proc() -> Right_Click_Menu {
    return {
        button_state = widgets.init_button(),
    }
}

update_right_click_menu :: proc(manager: ^Track_Manager) {
    menu := &manager.right_click_menu

    menu.opened_this_frame = false

    // Handle the logic for opening the menu.
    if !menu.is_open {
        if gui.mouse_pressed(.Right) {
            menu.click_start = gui.mouse_position()
        }
        if gui.mouse_released(.Right) && gui.mouse_position() == menu.click_start {
            menu.is_open = true
            menu.opened_this_frame = true
            menu.position = gui.mouse_position()
        }
    }

    // Don't process the menu if it is not open.
    if !menu.is_open {
        gui.release_hover(&menu.button_state)
        return
    }

    gui.offset(menu.position)

    // Add menu text every frame.
    item_texts := [?]widgets.Text{
        widgets.init_text(&consola),
        widgets.init_text(&consola),
        widgets.init_text(&consola),
        widgets.init_text(&consola),
    }

    // Clean up menu text every frame.
    defer for text in &item_texts {
        widgets.destroy_text(&text)
    }

    PADDING :: 3
    SPACING :: 3

    // Measure menu text and update menu size accordingly.
    item_position := Vec2{PADDING, PADDING}
    menu.size = Vec2{0, 0}

    for text, i in &item_texts {
        item := right_click_menu_items[i]

        text.data = item.name
        text.position = item_position

        widgets.update_text(&text)

        item_bottom_right := text.position + text.size
        menu.size.x = max(menu.size.x, item_bottom_right.x)
        menu.size.y = max(menu.size.y, item_bottom_right.y)
        item_position.y += text.size.y + SPACING
    }

    menu.size += PADDING

    // Update the button state of the menu since the size is now known.
    menu.button_state.size = menu.size
    widgets.update_button(&menu.button_state)

    menu_hovered := gui.is_hovered(&menu.button_state)

    // Draw the menu frame.
    fill_rounded_rect({0, 0}, menu.size, 3, gui.lighten(BACKGROUND_COLOR, 0.1))
    outline_rounded_rect({0, 0}, menu.size, 3, {1, 1, 1, 0.3})

    // Process the menu items.
    for text, i in &item_texts {
        widgets.draw_text(&text)

        // The menu item the mouse is over.
        if menu_hovered && gui.contains({text.position, text.size}, gui.mouse_position()) {
            item := right_click_menu_items[i]

            // Perform the action if the item is clicked.
            if gui.mouse_pressed(.Left) && item.action != nil {
                item.action(manager)
            }

            highlight_size := Vec2{
                menu.size.x - PADDING * 2.0,
                text.size.y,
            }

            fill_rounded_rect(text.position, highlight_size, 3, {1, 1, 1, 0.2})
        }
    }

    // Handling closing logic.
    if !menu.opened_this_frame && (gui.mouse_pressed(.Left) || gui.mouse_pressed(.Middle) || gui.mouse_pressed(.Right)) {
        menu.is_open = false
    }
}