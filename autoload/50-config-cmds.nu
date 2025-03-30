# Get the latest config files
def "config pull" [] { ^git -C $nu.default-config-dir pull }

# Push config to github
def "config push" [] { ^git -C $nu.default-config-dir push 'origin' 'master' }

# Open config folder in interactive git TUI
def "config git" [] { ^lazygit --path $nu.default-config-dir }

# Edit a file relative to the config directory
def "config edit" [...file: string] {
    let editor = $env.config.buffer_editor? | default $env.EDITOR? | default 'nvim'
    ^$editor ($nu.default-config-dir | path join ...$file)
}
