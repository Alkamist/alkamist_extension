package track_manager

import "../../gui"
import "../../gui/widgets"

Remove_Groups_Prompt :: struct{
    is_open: bool,
    position: Vec2,
    size: Vec2,
    yes_button: widgets.Button,
    no_button: widgets.Button,
    text: widgets.Text,
}

make_remove_groups_prompt :: proc() -> Remove_Groups_Prompt {
    return {
        yes_button = widgets.make_button(size = {96, 32}),
        no_button = widgets.make_button(size = {96, 32}),
        text = widgets.make_text("Remove the currently selected groups?"),
    }
}

update_remove_groups_prompt :: proc(manager: ^Track_Manager) {
    using manager.remove_groups_prompt

    if !is_open {
        if !editor_disabled(manager) && gui.key_pressed(.Delete) {
            is_open = true
        }
        return
    }

    PADDING :: 3
    SPACING :: 3

    window_size := gui.window_size(gui.current_window())

    widgets.update_text(&text)

    size.x = max(text.size.x, yes_button.size.x + no_button.size.x + SPACING) + PADDING * 2
    size.y = text.size.y + max(yes_button.size.y, no_button.size.y) + SPACING + PADDING * 2

    position = gui.pixel_align((window_size - size) * 0.5)

    text.position.x = position.x + (size.x - text.size.x) * 0.5
    text.position.y = position.y + PADDING

    middle := position + size * 0.5

    yes_button.position.x = middle.x - yes_button.size.x - SPACING * 0.5
    yes_button.position.y = text.position.y + text.size.y + SPACING
    widgets.update_button(&yes_button)

    no_button.position.x = yes_button.position.x + yes_button.size.x + SPACING
    no_button.position.y = yes_button.position.y
    widgets.update_button(&no_button)

    fill_rounded_rect(position, size, 3, gui.lighten(BACKGROUND_COLOR, 0.1))
    outline_rounded_rect(position, size, 3, {1, 1, 1, 0.3})

    fill_rounded_rect(yes_button.position, yes_button.size, 3, gui.darken(BACKGROUND_COLOR, 0.3))
    fill_rounded_rect(no_button.position, no_button.size, 3, gui.darken(BACKGROUND_COLOR, 0.3))

    widgets.draw_text(&text)

    if gui.key_pressed(.Enter) {
        is_open = false
    }
}