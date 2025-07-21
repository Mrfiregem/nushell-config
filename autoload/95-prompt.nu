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
    let duration = $env.CMD_DURATION_MS | into int | $in * 1_000_000 | into duration

    $'(ansi cyan_bold)($env.PWD | path fishify)(ansi reset)'
    | if $duration > 2sec { $in ++ $' ◎ (ansi yellow)($duration)' } else {} 
}

$env.PROMPT_INDICATOR = {
    $' (if $env.LAST_EXIT_CODE == 0 { ansi green_bold } else { ansi red_bold })›(ansi reset) '
}

$env.PROMPT_COMMAND_RIGHT = {||
    let git_branch = (^git branch --show-current | complete).stdout | str trim
    if $git_branch != "" {
        let status = ^git status --porcelain | complete
        if $status.exit_code == 0 and $status.stdout != "" { $git_branch ++ '*' } else { $git_branch }
    } else { $git_branch }
    | append $'(ansi light_blue)(date now | format date "%I:%M %p")(ansi reset)'
    | compact -e
    | str join $'(ansi reset) ◎ '
}
