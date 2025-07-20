# Format paths in the style of the fish shell
@example 'Display a path in fish-shell style' { '/home/me/.config/nushell' | path fishify } --result '~/.c/nushell'
def "path fishify" []: string -> string {
    if $in starts-with $nu.home-path { str replace $nu.home-path '~' } else {}
    | path split
    | do {|paths|
        match ($paths | length) {
            1..2 => { $paths | path join },
            3.. => {
                $paths | slice 1..<(-1)
                | each {|p|
                    if $p starts-with '.' {
                        str substring ..1
                    } else {
                        str substring ..0
                    }
                }
                | prepend $paths.0
                | append ($paths | last)
            }
        }
    } $in
    | path join
}

$env.PROMPT_COMMAND = {
    let duration = $env.CMD_DURATION_MS | into int | into duration --unit ms

    $'(ansi cyan_bold)($env.PWD | path fishify)(ansi reset)'
    | if $duration > 2sec { $in ++ $' ◎ (ansi yellow)($duration | format duration sec)' } else {} 
}

$env.PROMPT_INDICATOR = {
    $' (if $env.LAST_EXIT_CODE == 0 { ansi green_bold } else { ansi red_bold })›(ansi reset) '
}

$env.PROMPT_COMMAND_RIGHT = {||
    $'(ansi light_red_italic)(date now | format date "%I:%M %p")(ansi reset)'
}
