use std/util [null_device]

def shorten []: string -> string {
    if $in starts-with '.' {
        str substring 0..<2
    } else {
        str substring 0..<1
    }
}

def git-info []: nothing -> record<in-repo: bool, is-dirty: bool, branch: string> {
    if (^git rev-parse --is-inside-work-tree | complete).exit_code == 0 {
        {
            in-repo: true
            is-dirty: (^git status --porcelain | is-not-empty)
            branch: (^git branch --show-current)
        }
    } else {
        {in-repo: false, is-dirty: false, branch: ''}
    }
}

export-env {
    $env.PROMPT_COMMAND = {||
        match (do -i { $env.PWD | path relative-to $nu.home-dir }) {
            null => { $env.PWD | path split }
            '' => ['~']
            $relative_pwd => { '~' | append ($relative_pwd | path split) }
        }
        | match ($in | length) {
            1..2 => {}
            _ => {
                let p
                [$p.0] ++ ($p | skip 1 | drop 1 | each { shorten }) ++ [($p | last)]
            }
        }
        | path join
    }

    $env.PROMPT_COMMAND_RIGHT = {||
        let g = git-info
        if $g.in-repo {
            date now | format date '%F %r' | append $'($g.branch)(if $g.is-dirty {"*"})' | str join ' | '
        } else {
            date now | format date '%F %r'
        }
    }
}
