# Configure nushell
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
# Set text editor
$env.config.buffer_editor = 'neovide'
$env.EDITOR = 'neovide'
alias nv = ^$env.EDITOR

# Manage tasks using todo.txt
use todo-txt/ *
# Module to access clipboard
use std-rfc/clip
# Load wrappers for certain externals
overlay use cmd-wrappers/
# Load custom functions that should be builtins
use stdplus/

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
