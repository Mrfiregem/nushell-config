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
    --min(-M): oneof<number,duration,filesize,datetime> # Minimum allowed value
    --max(-m): oneof<number,duration,filesize,datetime> # Maximum allowed value
]: [
    number -> number
    duration -> duration
    filesize -> filesize
    datetime -> datetime
    range -> list<number>
    list<number> -> list<number>
    list<duration> -> list<duration>
    list<filesize> -> list<filesize>
    list<datetime> -> list<datetime>
] {
    each {|num|
        match [$min, $max] {
            [null, null] => {error make -u {
                msg: 'Must include provide at least a `--min` or `--max` value'
            }}
            [$min, null] => { if $num < $min { $min } else { $num } }
            [null, $max] => { if $num > $max { $max } else { $num } }
            [$min, $max] => { if $num > $max { $max } else if $num < $min { $min } else { $num } }
        }
    }
}
