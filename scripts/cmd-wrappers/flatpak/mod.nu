const default_columns = [name, id, version, branch, system]
def types-completion [] { [app, runtime, *] }

# List installed flatpaks
export def list [
    --type(-t): string@types-completion = '*' # 'app', 'runtime', or '*' for both
    --columns(-c): list<string> = $default_columns # Which columns to show
]: nothing -> table {
    ^flatpak list --columns=all
    | from tsv -n --no-infer
    | rename name description id version branch arch origin system ref commit_active commit_latest size options
    | into filesize 'size'
    | update options { split row ',' }
    | match ($type | str downcase) {
        'app' => { where options not-has 'runtime' }
        'runtime' => { where options has 'runtime' }
        _ => {}
    }
    | if $columns has '*' {} else { select ...$columns }
}
