use std/util ['path add']

# Configure nushell
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
# Set text editor
$env.config.buffer_editor = 'nvim'

# Manage tasks using todo.txt
use todo-txt/ *
# Module to access clipboard
use std-rfc/clip

# Create a new directory and open it
def --env mkcd [path: path] { mkdir $path; cd $path }

# Upload a file to a pastebin for sharing
def "http pastebin" [file: path, extra_data: record = {}] {
	let file_content = open --raw $file | into binary
	let post_data = {file: $file_content} | merge $extra_data
	http post --content-type multipart/form-data 'https://0x0.st' $post_data
}

# Set path
path add ~/.local/bin
$env.PATH = $env.PATH | uniq
