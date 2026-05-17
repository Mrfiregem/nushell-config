export use pwsh.nu [run-powershell]
export use scoop
export use winget

# Interactively update apps managed by `winget`
export def winup []: nothing -> nothing {
    let apps = winget list --outdated | input list --multi --display {|| format pattern '{name} [{id}]' } 'Upgrade Apps'
    if ($apps | is-empty) { return }
    for app in $apps {
        print $'Updating: (ansi attr_bold)($app.name)(ansi reset) [($app.id)] from (ansi yellow)($app.current)(ansi reset) -> (ansi green)($app.latest)(ansi reset)'
        ^winget update -e --id $app.id
    }
}

# vim: sw=4 et
