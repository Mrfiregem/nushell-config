def _nu_prompt_git_status [] {
    let branch = ^git rev-parse --abbrev-ref HEAD | complete
    let dirty = if (^git status --porcelain | complete).stdout != '' { '*' } else { '' }
    if ($branch.exit_code == 0) {
        $'(char lp)($branch.stdout | str trim)($dirty)(char rp)'
    } else { '' }
}

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

$env.PROMPT_COMMAND = {
    let git_status = _nu_prompt_git_status
    let path = $env.PWD | path format-fish
    if $git_status == '' { $path + "\n" } else { $"($path) ($git_status)\n" }
}
