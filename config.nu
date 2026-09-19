# Import useful std modules
use std/bench
use std-rfc/iter [only]

# Set left and right prompts
use prompt.nu

# Use sqlite file instead of txt to store history
$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

# Set editor variables
$env.config.buffer_editor = 'nvim'
{VISUAL: nvim, EDITOR: nvim} | load-env

$env.config.show_banner = false

# Fish-like highlighting of resolved externals
$env.config.highlight_resolved_externals = true
$env.config.color_config.shape_external = 'red'
$env.config.color_config.shape_external_resolved = 'cyan'

# Save the last 10 unique directories in `$env.CD_HIST`
$env.config.hooks.env_change.PWD = [{|before|
    $env.CD_HIST = $env.CD_HIST? | prepend $before | uniq | first 10
}]

# Configure carapace to use fallback completers
$env.CARAPACE_BRIDGES = 'zsh,fish,bash'

# Disable creating `~/.lesshist`
$env.LESSHISTFILE = '-'

# `cd` to the directory provided by stdin
def --env cdl [
    --physical(-p) # Resolve symbolic links
    ...postfix: path # Additional paths to append to input
]: oneof<path, nothing> -> nothing {
    append $postfix
    | if $in == [] { $nu.home-dir } else { path join }
    | cd --physical=$physical $in
}

# Create a new directory and navigate to it
def --env mkcd [path: path]: nothing -> nothing {
    mkdir $path; cd $path
}

# Open a web search through its DuckDuckGo bang
def bang [code: string, ...query: string]: nothing -> nothing {
    use std-rfc/url with-params
    let q = $'!($code)' | append $query | str join ' '
    start ('https://duckduckgo.com' | with-params {q: $q})
}

# Load extra configuration based on OS
const osutils = if $nu.os-info.name == 'windows' { 'winutils' }
use $osutils *
