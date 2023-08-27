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
        yes_button = widgets.make_button(size = {70, 20}),
        no_button = widgets.make_button(size = {70, 20}),
        text = widgets.make_text("Remove the currently selected groups?"),
    }
}

destroy_remove_groups_prompt :: proc(prompt: ^Remove_Groups_Prompt) {
    widgets.destroy_text(&prompt.text)
}

open_remove_groups_prompt :: proc(manager: ^Track_Manager) {
    using manager.remove_groups_prompt

    one_or_more_groups_selected := false
    for group in manager.groups {
        if group.is_selected {
            one_or_more_groups_selected = true
            break
        }
    }

    if !one_or_more_groups_selected {
        return
    }

    if !is_open && !editor_disabled(manager) {
        is_open = true
        return
    }
}

update_remove_groups_prompt :: proc(manager: ^Track_Manager) {
    using manager.remove_groups_prompt

    if !is_open {
        return
    }

    // The prompt is centered in the window.
    window_size := gui.window_size(gui.current_window())
    size = {290, 128}
    position = gui.pixel_align((window_size - size) * 0.5)

    // Draw menu background.
    menu_color := gui.lighten(BACKGROUND_COLOR, 0.1)
    menu_color.a = 0.85
    fill_rounded_rect(position, size, 3, menu_color)
    outline_rounded_rect(position, size, 3, {1, 1, 1, 0.3})

    // Process yes and no buttons.
    text_space := Rect{position, size}

    yes_button_space := gui.trim_bottom(&text_space, 42)
    no_button_space := gui.trim_right(&yes_button_space, size.x * 0.5)

    yes_button.position = {
        yes_button_space.position.x + yes_button_space.size.x - yes_button.size.x - 5,
        yes_button_space.position.y + (yes_button_space.size.y - yes_button.size.y) * 0.5,
    }
    widgets.update_button(&yes_button)
    _draw_prompt_button(&yes_button, "Yes", outline = true)

    no_button.position = {
        no_button_space.position.x + 5,
        no_button_space.position.y + (no_button_space.size.y - no_button.size.y) * 0.5,
    }
    widgets.update_button(&no_button)
    _draw_prompt_button(&no_button, "No")

    // Draw prompt text.
    widgets.update_text(&text)

    extra_x := (text_space.size.x - text.size.x) * 0.5
    gui.trim_left(&text_space, extra_x)
    gui.trim_right(&text_space, extra_x)

    extra_y := (text_space.size.y - text.size.y) * 0.5
    gui.trim_top(&text_space, extra_y)
    gui.trim_bottom(&text_space, extra_y)

    text.position = text_space.position
    widgets.draw_text(&text)

    // Handle outcomes.
    if gui.key_pressed(.Escape) || no_button.clicked {
        is_open = false
    }

    if gui.key_pressed(.Enter) || yes_button.clicked {
        _remove_selected_groups(manager)
        is_open = false
    }
}

_remove_selected_groups :: proc(manager: ^Track_Manager) {
    selected_groups := make([dynamic]^Track_Group, gui.arena_allocator())
    for group in manager.groups {
        if group.is_selected {
            append(&selected_groups, group)
        }
    }

    keep_if(&manager.groups, proc(group: ^Track_Group) -> bool {
        return !group.is_selected
    })

    for group in selected_groups {
        destroy_track_group(group)
        free(group)
    }
}

_draw_prompt_button :: proc(button: ^widgets.Button, label: string, outline := false) {
    fill_rounded_rect(button.position, button.size, 3, gui.darken(BACKGROUND_COLOR, 0.1))

    if outline {
        outline_rounded_rect(button.position, button.size, 3, {0.4, 0.9, 1, 0.7})
    }

    if button.is_down {
        fill_rounded_rect(button.position, button.size, 3, {0, 0, 0, 0.04})
    } else if gui.is_hovered(button) {
        fill_rounded_rect(button.position, button.size, 3, {1, 1, 1, 0.04})
    }

    label_text := widgets.make_text(label, allocator = gui.arena_allocator())
    widgets.update_text(&label_text)

    label_text.position = button.position + (button.size - label_text.size) * 0.5
    widgets.draw_text(&label_text)
}