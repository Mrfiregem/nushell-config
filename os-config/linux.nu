def fpup []: nothing -> table {
    ^flatpak remote-ls --updates
    | from tsv -n --no-infer
    | rename name id version branch arch
    | collect
}

def pacup []: nothing -> table {
    ^checkupdates-with-aur
    | lines | ansi strip
    | parse '{package} {old} -> {new}'
    | collect
}

def --wrapped pacdiff [...args]: nothing -> nothing {
    ^sudo DIFFPROG='nvim -d' pacdiff ...$args
}
