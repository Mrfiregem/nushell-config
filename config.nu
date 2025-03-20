# Configure nushell
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
# Set text editor
$env.config.buffer_editor = 'nvim'

# Create a new directory and open it
def --env mkcd [path: path] { mkdir $path; cd $path }

# Manage tasks using todo.txt
use todo-txt/ *

# Upload a file to a pastebin for sharing
def "http pastebin" [file: path, extra_data: record = {}] {
	let file_content = open --raw $file | into binary
	let post_data = {file: $file_content} | merge $extra_data
	http post --content-type multipart/form-data 'https://0x0.st' $post_data
}

# Load additional os-specific configurations
const OS_EXTRA_CONFIG = if $nu.os-info.name == 'windows' {
    'os-config/windows-config.nu'
} else if $nu.os-info.name == 'macos' {
    'os-config/macos-config.nu'
} else if $nu.os-info.name == 'linux' {
    'os-config/linux-config.nu'
}
source $OS_EXTRA_CONFIG
