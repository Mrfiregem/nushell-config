# Module to work with pacman

use std-rfc/kv ['kv get', 'kv set']

def get-wrapper [] {
    kv get -t pac wrapper | default { which '^paru' '^yay' | get 0?.path | kv set -t pac wrapper }
}

# List installed packages
export def list [
    --orphans(-o) # Show packages installed as dependencies that are no longer needed
    query?: string # Filter output by package name
]: nothing -> table<name: string, version: string> {
    let cmd = [pacman -Q] | if $orphans { append '-dt' } else {}
    ^$cmd | lines | parse '{name} {version}'
    | if $query != null { where name like $query } else {}
}

# Search available packages
export def search [
    --aur(-a) # Include aur packages (requires pacman wrapper)
    query: string
]: nothing -> table {
    let pacwrapper = get-wrapper
    if $aur and $pacwrapper != null {
        ^$pacwrapper -Ss $query
    } else if $aur {
        error make {
            msg: 'Passed `--aur` but did not find a suitable pacman wrapper'
            labels: [{text: 'Remove this flag', span: (metadata $aur).span}]
        }
    } else {
        ^pacman -Ss $query
    }
    | lines
    | split list --split before { $in like '^\S' }
    | skip 1
    | each {|x|
        $x.0 | parse '{repo}/{name} {meta}'
        | only | insert desc { $x.1 | str trim | str join ' ' }
    }
    | move --after name desc meta repo
}

# Update packages
export def update []: nothing -> nothing {
    let pacman = get-wrapper | default 'pacman'
    ^$pacman -Syu
}

export alias upgrade = update
