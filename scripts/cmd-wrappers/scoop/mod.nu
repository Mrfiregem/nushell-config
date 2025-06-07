use ./util.nu 'get-path'

export def "scoop list" [] {
    ^scoop export | from json -s
    | get apps | rename -b { str downcase }
    | into datetime updated
    |  move --after name version source updated info
}

export def "scoop search" [--force-scoop(-F) ...query: string]: nothing -> table {
    let alt = get-path 'scoop-search'
    if $alt != null and not $force_scoop {
        ^$alt ...$query
        | lines | split list ''
        | where $it != []
        | each {|l|
            skip 1
            | parse -r `^\s+(?<name>\S+) \((?<version>.+?)\)(?: --> includes '(?<binary>.+?)')?$`
            | default { $l.0 | str replace -r `^'(.+?)' bucket:` '$1' } bucket
            | update binary { lines | where $it != '' }
        }
        | flatten
    } else {
        let pwsh_cmd = r#'scoop search $args 6>null | Select-Object -Property *,@{l='VersionString';e={$_.Version.ToString()}} | ConvertTo-Json'#
        ^pwsh -nop -cwa $pwsh_cmd ...$query
        | from json -s
        | select Name VersionString Binaries Source
        | rename name version binary bucket
        | update binary { split row ' | ' | where $it != '' }
    }
}

export def "scoop info" [app: string]: nothing -> table {
    ^scoop info $app
    | lines | ansi strip
    | compact -e
    | parse '{key} : {value}'
    | str trim
    | str snake-case key
    | transpose -rd
    | into datetime updated_at
}

export extern "scoop alias" []
export extern "scoop bucket" []
export extern "scoop cache" []
export extern "scoop cat" []
export extern "scoop checkup" []
export extern "scoop cleanup" []
export extern "scoop config" []
export extern "scoop create" []
export extern "scoop depends" []
export extern "scoop download" []
export extern "scoop export" []
export extern "scoop help" []
export extern "scoop hold" []
export extern "scoop home" []
export extern "scoop import" []
export extern "scoop install" []
export extern "scoop prefix" []
export extern "scoop reset" []
export extern "scoop shim" []
export extern "scoop status" []
export extern "scoop unhold" []
export extern "scoop uninstall" []
export extern "scoop update" []
export extern "scoop virustotal" []
export extern "scoop which" []
