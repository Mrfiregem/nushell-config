let copy_cmd = if $env.WAYLAND_DISPLAY? == null {
    ['xclip' '-sel' 'clip']
} else { ['wl-copy'] }
let paste_cmd = if $env.WAYLAND_DISPLAY? == null {
    ['xclip' '-o' '-sel' 'clip']
} else { ['wl-paste'] }

module clip {
    # Copy text to system clipboard
    export def copy []: string -> nothing { $in | run-external ...$copy_cmd }

    # Read text from system clipboard
    export def paste []: nothing -> string { run-external ...$paste_cmd | collect }
}
use clip
