# Import useful std modules
use std/bench
use std-rfc/iter [only]

use prompt.nu # Set left and right prompts

$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

$env.config.buffer_editor = 'nvim'
{} | default $env.config.buffer_editor 'VISUAL' 'EDITOR' | load-env

$env.config.show_banner = false

$env.config.highlight_resolved_externals = true

# Disable creating `~/.lesshist`
$env.LESSHISTFILE = '-'

# Save the last 10 unique directories in `$env.CD_HIST`
$env.config.hooks.env_change.PWD = [{|before|
    $env.CD_HIST = $env.CD_HIST? | prepend $before | uniq | first 10
}]

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
