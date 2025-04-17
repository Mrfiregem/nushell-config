# Set prompt
def "path format-fish" []: string -> string {
    path expand --no-symlink | str replace $nu.home-path '~'
    | path split | match ($in) {
        [$a] => $a
        [$a $b] => { $a | path join $b }
        [$a ..$b] => {
            $b | slice 0..<(-1)
            | each {
                if $in starts-with '.' {
                    str substring 0..1
                } else {
                    str substring 0..<1
                }
            }
            | [$a ...$in ($b | last)] | path join
        }
    }
}

$env.PROMPT_COMMAND = { $'($env.PWD | path format-fish) ' }
