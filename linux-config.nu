module clip {
    # Copy text to system clipboard
    export def copy []: string -> nothing { $in | ^wl-copy }
    # Read text from system clipboard
    export def paste []: nothing -> string { ^wl-paste | collect }
}
use clip
