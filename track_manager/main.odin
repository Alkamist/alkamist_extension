package track_manager

import "core:fmt"
import "core:strings"
import "core:strconv"
import "../utility"
import "../../gui"
import "../../reaper"



// state saving/loading
// text edit to facilitate adding groups
// delete groups (prompt if sure)

// Save:
// window position
// groups:
//     name
//     position
//     is_selected
//     track_guids


Vec2 :: gui.Vec2
Color :: gui.Color

BACKGROUND_COLOR :: Color{0.2, 0.2, 0.2, 1}

consola := gui.init_font("Consola", #load("../consola.ttf"))

window := gui.init_window(
    title = "Track Manager",
    position = {200, 200},
    background_color = BACKGROUND_COLOR,
    child_kind = .Transient,
    on_frame = on_frame,
)

track_managers: map[^reaper.ReaProject]Track_Manager

load_state :: proc(ctx: ^reaper.ProjectStateContext) {
    project := reaper.GetCurrentProjectInLoadSave()
    if !(project in track_managers) {
        track_managers[project] = init_track_manager(project)
    }

    manager := &track_managers[project]
    buffer: [4096]byte

    // Loop through lines.
    for {
        line, ok := get_line(ctx, buffer[:])
        if !ok {
            break
        }

        line_tokens := strings.split(line, " ")
        defer delete(line_tokens)

        if len(line_tokens) == 0 {
            break
        }

        switch line_tokens[0] {
        case "<GROUP":

        }
    }
}

save_state :: proc(ctx: ^reaper.ProjectStateContext) {
    project := reaper.GetCurrentProjectInLoadSave()

    manager, exists := &track_managers[project]
    if !exists {
        return
    }

    for group in manager.groups {
        save_group_state(ctx, group)
    }
}

save_group_state :: proc(ctx: ^reaper.ProjectStateContext, group: ^Track_Group) {
    add_line(ctx, "<GROUP")
    add_line(ctx, "NAME %s", group.name)
    add_line(ctx, "POSITION %f %f", group.position.x, group.position.y)
    add_line(ctx, "ISSELECTED %d", cast(int)group.is_selected)

    add_line(ctx, "<TRACKGUIDS")
    for track in group.tracks {
        buffer: [64]byte
        reaper.guidToString(reaper.GetTrackGUID(track), &buffer[0])
        add_line(ctx, "%s", cast(string)buffer[:])
    }
    add_line(ctx, ">")

    add_line(ctx, ">")
}

on_frame :: proc() {
    current_project := reaper.EnumProjects(-1, nil, 0)

    if !(current_project in track_managers) {
        track_managers[current_project] = init_track_manager(current_project)

        // Temporary test groups.
        position := Vec2{50, 50}
        add_new_track_group(&track_managers[current_project], "Vocals", position);  position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Drums", position);   position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Guitars", position); position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Bass", position);    position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Strings", position); position += {0, 30}
        add_new_track_group(&track_managers[current_project], "Brass", position);   position += {0, 30}
    }

    update_track_manager(&track_managers[current_project])

    // Save project when control + s pressed.
    if gui.key_down(.Left_Control) && gui.key_pressed(.S) {
        utility.save_project()
    }

    // Play the project when pressing space bar.
    if gui.key_pressed(.Space) {
        reaper.Main_OnCommandEx(40044, 0, nil)
    }

    if gui.key_pressed(.Escape) {
        gui.request_window_close()
    }

    // if gui.key_pressed(.T) {
    //     reaper.Undo_BeginBlock2(nil)
    //     reaper.Undo_EndBlock2(nil, "Alkamist Test", reaper.UNDO_STATE_MISCCFG)
    //     // reaper.Undo_OnStateChangeEx2(nil, "Alkamist Test", reaper.UNDO_STATE_MISCCFG, -1)
    // }
}

run :: proc() {
    if gui.window_is_open(&window) {
        gui.close_window(&window)
        return
    }

    gui.set_window_parent(&window, reaper.window_handle())
    gui.open_window(&window)
}