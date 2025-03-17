# Get the latest config files
def "config pull" [] { ^git -C $nu.default-config-dir pull }
# Push config to github
def "config push" [] { ^git -C $nu.default-config-dir push 'origin' 'master' }
# Open config folder in interactive git TUI
def "config git" [] { ^lazygit --path $nu.default-config-dir }
