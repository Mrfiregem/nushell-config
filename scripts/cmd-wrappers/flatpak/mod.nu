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
