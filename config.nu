# Configure nushell
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
# Set text editor
$env.config.buffer_editor = 'neovide'

# Set fuzzy history completion
$env.config.keybindings ++= [{
    name: 'fuzzy_history'
    modifier: CONTROL
    keycode: char_r
    mode: [emacs vi_normal]
    event: [
        {
            send: ExecuteHostCommand
            cmd: "do {
            $env.SHELL = '/usr/bin/bash'
            commandline edit (
            history
            | get command
            | reverse
            | uniq
            | str join (char -i 0)
            | fzf --scheme=history
            --read0
            --layout=reverse
            --height=40%
            --bind 'ctrl-/:change-preview-window(right,70%|right)'
            --preview='echo -n {} | nu --stdin -c 'nu-highlight''
            -q (commandline)
            | decode utf-8
            | str trim
            )
            }"
        }
    ]
}]

# Manage tasks using todo.txt
use todo-txt/ *
# Module to access clipboard
use std-rfc/clip
# Load wrappers for certain externals
overlay use cmd-wrappers/

# Create a new directory and open it
def --env mkcd [path: path] { mkdir $path; cd $path }
def --env cdl [...path: string]: [
    nothing -> nothing
    string -> nothing
    list<string> -> nothing
] {
    cd ($in | append $path | path join)
}

# Upload a file to a pastebin for sharing
def "http pastebin" [file: path, extra_data: record = {}] {
    let file_content = open --raw $file | into binary
    let post_data = {file: $file_content} | merge $extra_data
    http post --content-type multipart/form-data 'https://0x0.st' $post_data
}

# Similar to pwsh's `Format-List`; view table as list of records
def "list-view" []: any -> string { each { table } | to text }

# Set path
do --env {
    use std/util ['path add']
    path add [~/.local/bin, ~/.nimble/bin]
    $env.PATH = $env.PATH | uniq
}

# Set env vars
load-env {
    EDITOR: 'neovide'
}

alias nv = neovide
