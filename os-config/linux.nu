# List upgradable flatpak packages
def fpup []: nothing -> table {
    ^flatpak remote-ls --updates
    | from tsv -n --no-infer
    | rename name id version branch arch
    | collect
}

# List upgradable system packages
def pacup []: nothing -> table {
    ^checkupdates-with-aur
    | lines | ansi strip
    | parse '{package} {old} -> {new}'
    | collect
}

# Show outdated packages tracked by `nvchecker`
def --wrapped pacdiff [...args]: nothing -> nothing {
    ^sudo DIFFPROG='nvim -d' pacdiff ...$args
}

# Manage your AUR packages
module aurpublish {
    def ap-root []: nothing -> path { ^git rev-parse --show-toplevel }
    def ap-pkglist []: nothing -> list<string> {
        ls -s (ap-root) | where type == 'dir' | get name
    }

    # Manage your AUR packages
    export extern main [
        pkg: string@ap-pkglist # Package to publish to the AUR
        --pull(-p) # Pull package changes instead of pushing
        --speedup(-s) # Speedup publishing by recording subtree history during push
        --url(-u): string # Specify the URL of the server used for git operations
        --help(-h) # Show help message
    ]

    # Wrapper for `git log` to work with subtrees
    export extern log [
        pkg: path # Path to the package directory
    ]

    # Install githooks to the repository
    export extern setup []
}

use aurpublish
