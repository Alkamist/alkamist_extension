package track_manager

import "../../gui"
import "../../gui/widgets"

Right_Click_Menu_Item :: struct {
    name: string,
    action: proc(manager: ^Track_Manager),
    is_active: proc(manager: ^Track_Manager) -> bool,
}

right_click_menu_items := [?]Right_Click_Menu_Item{
    {"(A) Add selected tracks", add_selected_tracks_to_selected_groups, nil},
    {"(R) Remove selected tracks", remove_selected_tracks_from_selected_groups, nil},
    {"(S) Select tracks", select_tracks_of_selected_groups, nil},
    {"(C) Center all groups", center_groups, nil},
    {"(L) Lock movement", toggle_lock_movement, movement_is_locked},
    {"Add group", nil, nil},
    {"Delete groups", nil, nil},
}

Right_Click_Menu :: struct {
    position: Vec2,
    size: Vec2,
    is_open: bool,
    opened_this_frame: bool,
    click_start: Vec2,

    button_state: widgets.Button,
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
    if gui.mouse_pressed(.Right) {
        menu.click_start = gui.mouse_position()
    }

    if !menu.is_open && gui.mouse_released(.Right) {
        // The right click menu only opens if the
        // mouse stayed relatively still while clicking.
        PIXEL_TOLERANCE :: 3
        if distance(menu.click_start, gui.mouse_position()) <= gui.pixel_distance() * PIXEL_TOLERANCE {
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

    // Add menu text every frame.
    item_texts: [len(right_click_menu_items)]widgets.Text
    for i in 0 ..< len(item_texts) {
        item_texts[i] = widgets.init_text(&consola)
    }

    // Clean up menu text every frame.
    defer for text in &item_texts {
        widgets.destroy_text(&text)
    }

    PADDING :: 3
    SPACING :: 3
    ACTIVE_CIRCLE_RADIUS :: 3

    // Measure menu text and update menu size accordingly.
    text_position := menu.position + Vec2{PADDING, PADDING}
    menu.size = Vec2{0, 0}

    for text, i in &item_texts {
        item := right_click_menu_items[i]

        text.data = item.name
        text.position = text_position

        widgets.update_text(&text)

        relative_item_bottom_right := text.position + text.size - menu.position

        // Make room for the active circle if the item needs one.
        if item.is_active != nil {
            relative_item_bottom_right.x += f32(ACTIVE_CIRCLE_RADIUS + PADDING) * 2
        }

        menu.size.x = max(menu.size.x, relative_item_bottom_right.x)
        menu.size.y = max(menu.size.y, relative_item_bottom_right.y)

        text_position.y += text.size.y + SPACING
    }

    menu.size += PADDING
    menu.size = gui.pixel_align(menu.size)

    // Update the button state of the menu since the size is now known.
    menu.button_state.position = menu.position
    menu.button_state.size = menu.size
    widgets.update_button(&menu.button_state)

    menu_hovered := gui.is_hovered(&menu.button_state)

    // Draw the menu frame.
    fill_rounded_rect(menu.position, menu.size, 3, gui.lighten(BACKGROUND_COLOR, 0.1))
    outline_rounded_rect(menu.position, menu.size, 3, {1, 1, 1, 0.3})

    // Process the menu items.
    for text, i in &item_texts {
        item := right_click_menu_items[i]

        widgets.draw_text(&text)

        is_active := item.is_active != nil ? item.is_active(manager) : false

        if is_active {
            max_item_width := menu.size.x - PADDING * 2
            position := Vec2{
                text.position.x + max_item_width - ACTIVE_CIRCLE_RADIUS * 2 - PADDING,
                text.position.y + text.size.y * 0.5,
            }
            fill_circle(position, ACTIVE_CIRCLE_RADIUS, {1, 1, 1, 1})
        }

        // The menu item the mouse is over.
        if menu_hovered && gui.contains({text.position, text.size}, gui.mouse_position()) {
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