const default_columns = [name, id, version, branch, system]

# List installed flatpaks
export def list [
    --app(-a) # Only show installed apps
    --runtime(-r) # Only show installed runtimes
    --columns(-c): list<string> = $default_columns # Which columns to show (or ['all'])
]: nothing -> table {
    if $app and not $runtime {
        ^flatpak list --app --columns=all
    } else if $runtime and not $app {
        ^flatpak list --runtime --columns=all
    } else {
        ^flatpak list --columns=all
    }
    | from tsv -n --no-infer
    | rename name description id version branch arch origin system ref commit_active commit_latest size options
    | into filesize 'size'
    | update options { split row ',' }
    | if $columns has 'all' {} else { select ...$columns }
}

# Remove packages interactively
export def rmi --wrapped [...flatpak_rm_args: string] {
    let id = list --columns [name description id]
    | insert fmt {|rc| $'($rc.name): ($rc.description)' }
    | input list -fd fmt 'Choose flatpak to uninstall'
    | get id?

    if ($id | is-not-empty) {
        print $'Uninstalling package: ($id)'
        ^flatpak uninstall ...$flatpak_rm_args $id
    }
}
