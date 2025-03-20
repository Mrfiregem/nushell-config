module clip {
    export def copy []: string -> nothing { $in | ^pbcopy }
    export def paste []: nothing -> string { ^pbpaste | collect }
}
use clip

source unix-config.nu
