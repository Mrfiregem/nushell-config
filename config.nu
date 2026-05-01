$env.config.history.file_format = 'sqlite'
$env.config.history.isolation = true

$env.config.buffer_editor = 'nvim'
$env.VISUAL = 'nvim'

$env.config.show_banner = false

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
  file: path
]: nothing -> nothing {
  let editor = [$env.config.buffer_editor?, $env.VISUAL?, $env.EDITOR?] | first-else 'vi'
  let prefix = if $nvim {
    ^nvim --headless --clean -c 'echo stdpath("config")' -c 'exit' e>| $in
  } else if $nushell {
    $nu.default-config-dir
  } else { '' }

  ^$editor ([$prefix, $file] | path join)
}

$env.NVIM_DIR = do -i { ^nvim --headless --clean -c 'echo stdpath("config")' -c 'exit' e>| $in }

const osutils = if $nu.os-info.name == 'windows' { 'winutils' }
use $osutils *
