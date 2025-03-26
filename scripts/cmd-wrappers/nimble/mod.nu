# Installs a list of packages
export extern install [
    --noRebuild    # Don't rebuild binaries if they're up-to-date
    --passNim(-p)  # Forward specified flag to compiler
    --depsOnly(-d) # Only install dependencies. Leave out pkgname to install deps for a local nimble package
    ...pkgname: string
]

# Clones a list of packages for development.
# Adds them to a develop file if specified or to `nimble.develop` if not specified and executed in package's directory
export extern develop [
    --withDependencies  # Puts in develop mode also the dependencies of the packages in the list or of the current directory package
    --path(-p): path    # Specifies the path whether the packages should be cloned
    --add(-a): path     # Adds a package at given path to a specified develop file or to `nimble.develop`
    --removePath(-r): path # Removes a package at given path from a specified develop file or from `nimble.develop`
    --removeName(-n): string # Removes a package with a given name from a specified develop file or from `nimble.develop`
    --include(-i): path # Includes a develop file into a specified develop file or to `nimble.develop`
    --exclude(-e): path # Excludes a develop file from a specified develop file or to `nimble.develop`
    --global(-g)        # Creates an old style link file in the special `links` directory
]

# Verifies the validity of a package in the current working directory
export extern check []

# Initializes a new Nimble project in the current directory
# or if a name is provided a new directory of the same name.
export extern init [
    --git # Creates a git repo in the new nimble project
    --hg  # Creates a hg repo in the new nimble project
    pkgname?: string
]

# Publishes a package on nim-lang/packages. The current working
# directory needs to be the top level directory of the Nimble package.
export extern publish []

# Uninstalls a list of packages
export extern uninstall [
    --inclDeps(-i) # Uninstalls package and dependent package(s)
    ...pkgname: string
]

# Builds a package. Passes options to the Nim compiler
export extern build [ ...opts: string ]

# Clean build artifacts
export extern clean []

# Adds packages to your project's dependencies
export extern add [ ...pkgname: string ]

# Builds and runs a package
export extern run [ ...opts: string ]

# Builds a file inside a package. Passes options to the Nim compiler
export extern c [ ...opts: string, file: path ]
# Builds a file inside a package. Passes options to the Nim compiler
export extern cc [ ...opts: string, file: path ]
# Builds a file inside a package. Passes options to the Nim compiler
export extern js [ ...opts: string, file: path ]

# Compiles and executes tests
export extern test [
    --continue(-c)  # Don't stop execution on a failed test
    ...opts: string # Passes options to the Nim compiler
]

# Builds documentation for a file inside a package. Passes options to the Nim compiler
export extern doc [ ...opts: string, file: path ]
# Builds documentation for a file inside a package. Passes options to the Nim compiler
export extern doc2 [ ...opts: string, file: path ]

# Refreshes the package list. A package list URL can be optionally specified
export extern refresh [ url?: string ]

# Lists all packages
export def list [
    --installed(-i) # Lists all installed packages
    --as-df(-d)     # Don't convert the output into a table (`-i` does not use polars, so it ignores this)
    --group(-g)     # Output record with pkgnames as keys (Only used in conjunction with `-i`)
]: nothing -> any {
    let nimble_home = $env.NIMBLE_DIR? | default ($nu.home-path | path join '.nimble')
    if $installed {
        glob -F $'($nimble_home)/pkgs2/*'
        | path basename | sort
        | parse '{package}-{version}-{checksum}'
        | if $group and $in != [] {
            group-by package --to-table
            | update items {|rc| if ($rc.items | length) == 1 { into record } else {} | reject package }
            | transpose -rd
        } else {}
    } else {
        list-all $nimble_home
        | if not $as_df { polars into-nu } else {}
    }
}

# Searches for a specified package. Search is performed by tag, name, and description
export def search [
    --with-df(-d)   # Filter by name, description, and tags of `nimble list -d` output. `text` is concatinated
    ...text: string # Text to search by (default: name & tags)
] {
    if ($text | is-empty) { error make {msg: 'Missing query', label: {span: (metadata $text).span, text: 'No search terms given'}} }

    if $with_df {
        search-df $text
    } else {
        ^nimble search ...$text
        | lines | str trim
        | split list '' | compact -e
        | each { update 0 { $'name: ($in | str trim -rc ":")' } | split column -rn 2 ':\s+' k v | transpose -rd }
        | upsert url { default '' | str replace -r ' \(\w+\)$' '' }
        | upsert tags { default [] | split row ', ' }
    }
}

def list-all [nimbledir: path] {
    let pkgfile = $nimbledir | path join 'packages_official.json'
    if not ($pkgfile | path exists) {
        error make -u {msg: $'Unable to read packge file from [($pkgfile)]', help: 'Try `nimble refresh` or make sure nimble is correctly configured'}
    }
    if (plugin list).name not-has 'polars' { error make -u {msg: 'Polars plugin not installed'} }

    polars open $pkgfile -s {name: str, url: str, tags: list<str>, description: str, license: str, web: str}
}

def search-df [words: list<string>] {
    let name_filter = $words | slice 1..
        | reduce --fold (polars col name | polars contains $words.0) {|w,acc|
            $acc or (polars col name | polars contains $w)
        }
    let desc_filter = $words | slice 1..
        | reduce --fold (polars col name | polars contains $words.0) {|w,acc|
            $acc or (polars col name | polars contains $w)
        }
    let tags_filter = $words | slice 1..
        | reduce --fold (polars col tags | polars list-contains (polars lit $words.0)) {|w,acc|
            $acc or (polars col tags | polars list-contains (polars lit $w))
        }

    list --as-df | polars filter ($name_filter or $desc_filter or $tags_filter)
}
