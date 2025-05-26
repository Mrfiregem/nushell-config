def fpup [] {
    ^flatpak remote-ls --updates
    | from tsv -n --no-infer
    | rename name id version branch arch
    | collect
}

def pacup [] {
    ^checkupdates-with-aur
    | lines | ansi strip
    | parse '{package} {old} -> {new}'
    | collect
}

