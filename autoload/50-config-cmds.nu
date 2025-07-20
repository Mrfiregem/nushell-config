# Get the latest config files
def "config pull" [] { ^git -C $nu.default-config-dir pull }

# Push config to github
def "config push" [] { ^git -C $nu.default-config-dir push 'origin' 'master' }

# Open config folder in interactive git TUI
def --wrapped "config git" [...args] {
    if ($args | is-empty) {
        ^lazygit --path $nu.default-config-dir
    } else {
        ^git -C $nu.default-config-dir ...$args
    }
}

def 'nu-complete config-files' [] {
    cd $nu.default-config-dir
    glob **/*.nu | path relative-to $nu.default-config-dir
}

# Edit a file relative to the config directory
def "config edit" [file: string@'nu-complete config-files'] {
    let editor = $env.config.buffer_editor? | default $env.EDITOR? | default 'nvim'
    ^$editor ($nu.default-config-dir | path join $file)
}

# Open nvim config in lazygit
def --env "config nvim" [
    --folder(-f) # cd to the directory instead
]: nothing -> nothing {
    let nvim_dir = ^nvim --headless --cmd 'echo stdpath("config")' -c 'quit' e>| $in
    if $folder { cd $nvim_dir } else { ^lazygit --path $nvim_dir }
}
