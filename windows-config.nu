module clip {
    export def copy []: string -> nothing { $in | clip.exe }
    export def paste []: nothing -> string { ^powershell -NoProfile -Command 'Get-Clipboard' | collect }
}
use clip
