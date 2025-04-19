# Configure nushell
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
# Set text editor
$env.config.buffer_editor = (which 'neovide').0?.path | default 'nvim'
$env.EDITOR = $env.config.buffer_editor
alias nv = ^$env.EDITOR

# Manage tasks using todo.txt
use todo-txt/ *
# Module to access clipboard
use std-rfc/clip
# Load custom functions that should be builtins
use stdplus/ *

# Create a new directory and open it
def --env mkcd [path: path] { mkdir $path; cd $path }
# Combine path parts with `path join` then `cd` to result
def --env cdl [...path: string]: [
    nothing -> nothing
    string -> nothing
    list<string> -> nothing
] { cd ($in | append $path | path join) }
# Edit a file with your preferred text editor
def edit [...file: path]: nothing -> nothing {
    use listutils/ ["list first-valid", "list wrap"]
    let editor = [$env.config.buffer_editor?, $env.VISUAL?, $env.EDITOR?, 'nvim']
        | list first-valid | list wrap
    run-external ...$editor ...$file
}

# Upload a file to a pastebin for sharing
def "http pastebin" [file: path, extra_data: record = {}] {
    let file_content = open --raw $file | into binary
    let post_data = {file: $file_content} | merge $extra_data
    http post --content-type multipart/form-data 'https://0x0.st' $post_data
}

# Download a file from the web
def wget [--force(-f), url: string, out?: path] {
    let filename = $out | default ($url | url parse | get path | path basename)
    http get $url | if $force { save -f $filename } else { save $filename }
}

# Similar to pwsh's `Format-List`; view table as list of records
def "list-view" []: any -> string { each { table } | to text }

# Set path
do --env {
    use std/util ['path add']
    path add [~/.local/bin, ~/.nimble/bin]
    $env.PATH = $env.PATH | uniq
}

# Source os-local config
const os_conf = if $nu.os-info.name == 'macos' {
    'os-config/macos.nu'
} else if $nu.os-info.name == 'windows' {
    'os-config/windows.nu'
}
source $os_conf
