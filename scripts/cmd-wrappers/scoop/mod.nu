use ./util.nu 'get-path'
export use externs.nu *

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

