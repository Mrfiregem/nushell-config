alias tg = ^topgrade

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
    let editor = [$env.config.buffer_editor?, $env.VISUAL?, $env.EDITOR?, 'vi']
        | reduce {|next,last| $last | default -e $next }
    ^$editor ...$file
}

