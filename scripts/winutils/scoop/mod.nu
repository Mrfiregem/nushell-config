# Module providing externs for scoop commands, or structured data wrappers when applicable.

use winutils\ [run-powershell]
use std-rfc\kv ['kv get', 'kv set']

# Update apps, or Scoop itself
export extern update [
    --force(-f) # Force update even at newest version
    --global(-f) # Update a globally installed app
    --independent(-i) # Don't auto-install dependencies
    --no-cache(-k) # Don't use the download cache
    --skip-hash-check(-s) # Skip hash validation
    --quiet(-q) # Hide extraneous messages
    --all(-a) # Update all apps (alternative to '*')
    app?: string
]

# Add a scoop alias
export extern 'alias add' [
  name: string,
  command: string,
  description?: string
]

# Remove a scoop alias
export extern 'alias rm' [name: string]

# List scoop aliases
export def 'alias list' []: nothing -> table<name: string, command: string, summary: string> {
  run-powershell 'scoop alias list --verbose' | append []
  | rename -b { str downcase }
}

# Add a bucket
export extern 'bucket add' [
  name: string,
  repo?: string
]

# Remove a bucket
export extern 'bucket rm' [name: string]

# List known buckets
export def 'bucket known' []: nothing -> list<string> {
  ^scoop bucket known | lines
}

# List enabled buckets
export def 'bucket list' []: nothing -> table<name: string, source: string, updated: datetime, manifests: int> {
  ^scoop export | from json -s
  | get $.buckets | rename -b { str downcase }
  | into datetime 'updated'
}

# Show the download cache
export def cache [] {
  run-powershell 'scoop cache show 6>$null'
  | rename 'name' 'version' 'size'
  | into filesize 'size'
}

export alias 'cache show' = cache

# Remove cached downloads
export extern 'cache rm' [
  --all(-a) # Remove all downloads (same as '*')
  app?: string@comp-installed
]

# Show content of specified manifest.
export def cat [app: string@comp-searched]: nothing -> record {
  ^scoop cat $app | from json --strict
}

# Check for potential problems
export extern checkup []

# Cleanup apps by removing old versions
export extern cleanup [
  --all(-a) # Alternative to '*'
  --cache(-k) # Remove outdated download cache
  --global(-g) # Cleanup globallyt installed app
  app?: string
]

# Get current configuration values
export def config [name?: string, value?: string]: nothing -> record {
  match [$name, $value] {
    # Get value of `name`, or all values if `name` is null
    [$n, null] => { run-powershell -a {name: $n} 'scoop config $Nu.name' }
    # Set config value and print nothing
    [$n, $v] => { ^scoop config $n $v | ignore }
  }
}

# Remove a configuration value
export extern 'config rm' [name: string]

# Create a custom app manifest
export extern create [url: string]

# List dependencies for an app, in the order they'll be installed
export def depends [app: string@comp-searched]: nothing -> table<source: string, name: string> {
  run-powershell -a {app: $app} 'scoop depends $Nu.app' | append []
  | rename -b { str downcase }
}

# Download apps in the cache folder and verify hashes
export extern download [
  --force(-f) # Force download (override cache)
  --skip-hash-check(-s) # Skip hash verification
  --no-update-scoop(-u) # Don't update scoop before downloading
  --arch(-a): string@[32bit, 64bit, arm64] # Use architecture if supported
  app: string
]

# Exports installed apps, buckets (and optionally configs) in JSON format
export def export [
  --config(-c) # Also export config
]: nothing -> record {
  let cmd = ['scoop', 'export'] | if $config { append '--config' } else {}
  ^$cmd | from json --strict
}

# Show help for a command
export extern help [command: string]

# Hold an app to disable updates
export extern hold [
  --global(-g) # Hold globally installed apps
  ...app: string@comp-installed
]

# Opens the app homepage
export extern home [app: string@comp-searched]

# Imports apps, buckets and configs from a Scoopfile in JSON format
export extern import [
  path: path
]

# Display information about an app
export def info [app: string@comp-searched]: nothing -> record {
  run-powershell -a {app: $app} 'scoop info $Nu.app'
  | rename -b { str snake-case }
  | %update $.binaries? { split row ' | ' }
  | %update $.shortcuts? { split row ' | ' }
  | into datetime $.updated_at?
}

# Install apps
export extern install [
  --global(-g) # Install the app globally
  --independent(-i) # Don't install dependencies automatically
  --no-cache(-k) # Don't use the download cache
  --skip-hash-check(-s) # Skip hash validation
  --no-update-scoop(-u) # Don't update Scoop before installing
  --arch(-a): string@[32bit, 64bit, arm64] # Use the specified architecture, if the app supports it
  app: string@comp-searched
]

# List installed apps
@example 'Filter by bucket' { scoop list | where source == 'games' }
export def list []: [
  nothing -> table<name: string, version: string, source: string, updated: datetime, info: string>
] {
  ^scoop export
  | from json --strict
  | get $.apps
  | rename -b { str downcase }
  | into datetime $.updated
  | move --after name version source updated info
}

# Returns the path to the specified app
export extern prefix [app: string@comp-installed]

# Reset an app to resolve conflicts
export extern reset [
  --all(-a) # Reset all apps (same as '*')
  app?: string@comp-installed
]

# Search available apps
export def search [query: string@comp-searched]: nothing -> table {
  let cmd = 'scoop search $Nu.query 6>$null | ForEach-Object { ConvertTo-Json $_ -Compress }'
  run-powershell -a {query: $query} -r $cmd
  | from json -os
  | rename -b { str downcase }
  | %update $.binaries { if $in != '' { split row ' | ' } }
}

# Add a custom scoop shim
export extern 'shim add' [
    name: string,
    command_path: path,
    ...args
]

# Remove scoop shims
export extern 'shim rm' [...name: string]

# List scoop shims
export def 'shim list' [...pattern: string]: nothing -> table<name: string, source: string> {
    run-powershell -a {pats: ($pattern | default [])} -r '$x = $Nu.pats; scoop shim list @x | % { ConvertTo-Json -Compress $_ }'
    | from json --objects --strict
    | rename -b { str snake-case }
}

# Show information about a shim
export def 'shim info' [app: string@comp-searched]: nothing -> record {
    run-powershell -a {app: $app} 'scoop shim info $Nu.app'
    | rename -b { str snake-case }
}

# Alter a shim's target source
export extern 'shim alter' [name: string]

# Show status and check for new app versions
export def status [
    --local(-l) # Only check installed apps, disables fetching updates
]: nothing -> table {
    run-powershell $'scoop status (if $local { "--local" })'
    | rename -c {
        Name: name,
        'Installed Version': current,
        'Latest Version': latest,
        'Missing Dependencies': new_deps,
        Info: info
    }
}

# Unhold an app to enable updates
export extern unhold [
    --global(-g) # Unhold a globally installed app
    app: string@comp-installed
]

# Uninstall an app
export extern uninstall [
    --global(-g) # Uninstall a globally installed app
    --purge(-p) # Remove persistent data
    app: string@comp-installed
]

# Look for app's hash or url on virustotal.com
export extern virustotal [
    --all(-a) # Check all installed apps
    --scan(-s) # Let Virustotal scan app if not in its database
    --no-depends(-n) # Don't check dependencies
    --no-update-scoop(-u) # Don't update scoop before checking
    --passthru(-p) # Return reports as objects
    ...app: string@comp-installed
]

# Locate a shim/executable (similar to 'which' on Linux)
export extern which [command: string]


# --- Completions

def get-or-set [key: string, fallback: closure] {
    kv get -t 'scoopextern' $key | default { do $fallback | kv set -t 'scoopextern' $key }
}

def comp-installed [] { get-or-set 'installed' { list | get name } }
def comp-searched [ctx: string] {
    let query = $ctx | split row ' ' | last | str trim
    if ($query | is-not-empty) {
        search $query | get name
    }
}
