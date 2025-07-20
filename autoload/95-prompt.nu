$env.PROMPT_COMMAND = {
    let pwd = $env.PWD
        | if $in starts-with $nu.home-path { str replace $nu.home-path '~' } else {}
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

    $'(char nl)(ansi cyan_bold)($pwd)(ansi reset)(char nl)'
}

$env.PROMPT_INDICATOR = {
    $'(ansi green_bold)›(ansi reset) '
}
