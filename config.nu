# Import useful std modules
use std/bench
use std-rfc/iter [only]

use prompt.nu # Set left and right prompts

$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

$env.config.buffer_editor = 'nvim'
$env.VISUAL = 'nvim'

$env.config.show_banner = false

$env.config.color_config.shape_externalarg = 'green'

# Disable creating `~/.lesshist`
$env.LESSHISTFILE = '-'

# Return the first non-null list element, otherwise a default value
def first-else [default: any]: list<any> -> any {
    append $default | compact | first
}

# `cd` to the directory provided by stdin
def --env cdl [
    --physical(-p) # Resolve symbolic links
    ...postfix: path # Additional paths to append to input
]: oneof<path, nothing> -> nothing {
    append $postfix
    | if $in == [] { $nu.home-dir } else { path join }
    | cd --physical=$physical $in
}

def --env mkcd [path: path]: nothing -> nothing {
    mkdir $path; cd $path
}

# Edit files with the user's configured text editor
def edit [
    --nvim(-v) # Interpret path relative to nvim's config directory
    --nushell(-n) # Interpret path relative to nushell's config directory
    file?: path
]: oneof<nothing, string> -> nothing {
    append $file | get 0? | default '' | let file
    let editor = [$env.config.buffer_editor?, $env.VISUAL?, $env.EDITOR?] | first-else 'vi'
    let prefix = if $nvim {
        ^nvim --headless --clean -c 'echo stdpath("config")' -c 'exit' e>| $in
    } else if $nushell {
        $nu.default-config-dir
    } else { '' }

    match ([$prefix, $file] | path join) {
        '' => { ^$editor }
        $path => { ^$editor $path }
    }
}

$env.NVIM_DIR = do -i { ^nvim --headless --clean -c 'echo stdpath("config")' -c 'exit' e>| $in }

const osutils = if $nu.os-info.name == 'windows' { 'winutils' }
use $osutils *

# Limit a numerical value between an upper and/or lower bound
def clamp [
    bounds: list<oneof<number,duration,filesize,datetime, nothing>> # Minimum allowed value
]: [
    number -> number
    duration -> duration
    filesize -> filesize
    datetime -> datetime
] {
    let input
    # $max's span will be the call span if it isn't provided
    let bounds = match $bounds {
        [$max] => {lower: null, upper: $max}
        [$min, $max] => {lower: $min, upper: $max}
        _ => { error make -u 'Bounds must be provided in the form `[$max]` or `[$min $max]`' }
    }
    print $bounds
    if $bounds.lower != null and $input < $bounds.lower {
        $bounds.lower
    } else if $bounds.upper != null and $input > $bounds.upper {
        $bounds.upper
    } else {
        $input
    }
}

# Open a web search through its DuckDuckGo bang
def bang [code: string, ...query: string]: nothing -> nothing {
    use std-rfc/url with-params
    let q = $'!($code)' | append $query | str join ' '
    start ('https://duckduckgo.com' | with-params {q: $q})
}
