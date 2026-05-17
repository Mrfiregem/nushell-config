# Wrapper around `winget` to return nu datatypes when applicable

use winutils\pwsh.nu [run-powershell]

# List installed apps
export def list [
    --all(-a) # List all apps, including those not managed by `winget`
    --outdated(-o) # List all apps with newer versions available
]: nothing -> table<name:string, id:string, current:string, latest:string,source:string,outdated:bool> {
    run-powershell --raw 'Get-WinGetPackage | ForEach-Object { ConvertTo-Json -Compress $_ }'
    | from json -os
    | rename -c {InstalledVersion: current, Name: name, Id: id, IsUpdateAvailable: outdated, Source: source, AvailableVersions: latest}
    | update $.latest { get $.0? }
    | move --after name id current latest source outdated
    | if not $all { where source != null } else {}
    | if $outdated { where outdated } else {}
}

# vim: sw=4 et
