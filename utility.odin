package main

keep_if :: proc{
    keep_if_no_user_data,
    keep_if_user_data,
}

keep_if_no_user_data :: proc(array: ^[dynamic]$T, should_keep: proc(x: T) -> bool) {
    keep_position := 0

    for i in 0 ..< len(array) {
        if should_keep(array[i]) {
            if keep_position != i {
                array[keep_position] = array[i]
            }
            keep_position += 1
        }
    }

    resize(array, keep_position)
}

keep_if_user_data :: proc(array: ^[dynamic]$T, user_data: $D, should_keep: proc(x: T, user_data: D) -> bool) {
    keep_position := 0

    for i in 0 ..< len(array) {
        if should_keep(array[i], user_data) {
            if keep_position != i {
                array[keep_position] = array[i]
            }
            keep_position += 1
        }
    }

    resize(array, keep_position)
}