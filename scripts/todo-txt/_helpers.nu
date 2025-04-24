# Colorize 'fmt.priority' formatted strings < "([A-Z]) " >
export def stress_colorize []: [string -> string, nothing -> string] {
    match $'($in)' {
        '(A) ' => $'(char lparen)(ansi red_bold)A(ansi reset)(char rparen) '
        '(B) ' => $'(char lparen)(ansi yellow_bold)B(ansi reset)(char rparen) '
        '(C) ' => $'(char lparen)(ansi blue_bold)C(ansi reset)(char rparen) '
        $c if $c like '^\([D-Z]\) $' => $'(char lparen)(ansi attr_bold)($c | str substring 1..1)(ansi reset)(char rparen) '
        _ => ''
    }
}

# Parse each line of the file into a record
export def line_parser []: record<index: int full: string> -> record {
    let input = $in
    mut tokens = $input.full | split row -r '\s+'
    mut result = {
        index: $input.index     # Line number from file
        complete: false         # If task is done or not
        priority: null          # Capital letter [A-Z]
        completion_date: null   # Only if creation_date isn't empty
        creation_date: null     # Optional time of creation
        description: null       # Only required param; the actual todo item
        projects: []            # List of +words from description
        contexts: []            # List of @words from description
        tags: {}                # Record of key:value pairs from description
    }

    # Set completion status
    $result.complete = if $tokens.0 == 'x' { $tokens = $tokens | skip 1; true } else { false }

    # Set letter priority
    $result.priority = if $tokens.0 like '^\([A-Z]\)$' {
        let res = ($tokens.0 | split chars).1
        $tokens = $tokens | skip 1
        $res
    }

    # Set creation and completion dates
    if $tokens.0 like '\d{4}-\d{2}-\d{2}' {
        if $tokens.1 like '\d{4}-\d{2}-\d{2}' {
            $result.completion_date = $tokens.0
            $result.creation_date = $tokens.1
            $tokens = $tokens | skip 2
        } else {
            $result.creation_date = $tokens.0
            $tokens = $tokens | skip 1
        }
    }

    # Set description from remaining tokens
    $result.description = $tokens | str join ' '

    # Set tags from remaining tokens
    $result.projects = $tokens | where $it starts-with '+' | str substring 1..
    $result.contexts = $tokens | where $it starts-with '@' | str substring 1..
    $result.tags = $tokens | where $it like '^\S+:\S+$' | split column -n 2 ':' k v | transpose -rd

    return $result
}

# Helper function to split todo file into lines for parsing
export def file_parser []: string -> table {
    lines
    | where { is-not-empty }
    | wrap full
    | enumerate | flatten
    | each { line_parser }
}
