use std/util null_device

# Update brew packages and check for issues
def brewup [] {
    ^brew update
    do -i { ^brew upgrade; ^brew cleanup }
    ^brew doctor
}

def "brew search" [...query: string]: nothing -> table<name: string, type: string> {
    if ($query | is-empty) { return [] }
    let parser = {|type| lines | wrap name | default $type type }
    (interleave
        { ^brew search --formula ...$query e> $null_device | do $parser formula }
        { ^brew search --cask ...$query e> $null_device | do $parser cask }
    ) | sort-by name
}
