# Configure nushell
$env.config.show_banner = false
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true
# Set text editor
$env.config.buffer_editor = 'nvim'
$env.EDITOR = $env.config.buffer_editor
# Enable carapace completers
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

# Module to access clipboard
use std-rfc/clip
# Load custom functions that should be builtins
use stdplus/ *

# Similar to pwsh's `Format-List`; view table as list of records
def "list-view" []: any -> string { each { table } | to text }

# Set path
do --env {
    use std/util 'path add'
    path add [
        {linux: ~/.local/bin, macos: ~/.local/bin, windows: ~/bin}
        ~/.cargo/bin
        {macos: /usr/local/bin, linux: /usr/local/bin}
        {macos: /usr/local/sbin, linux: /usr/local/sbin}
    ]
}

# Source os-local config
const os_conf = if $nu.os-info.name == 'linux' {
    'os-config/linux.nu'
} else if $nu.os-info.name == 'macos' {
    'os-config/macos.nu'
} else if $nu.os-info.name == 'windows' {
    'os-config/windows.nu'
}
source $os_conf
