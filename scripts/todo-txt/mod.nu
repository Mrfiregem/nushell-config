# Default path to todo file (~/todo.txt)
const default_todo_path = [$nu.home-path todo.txt] | path join
const default_formatstr = '{fmt.complete}{fmt.priority}{fmt.completion_date}{fmt.creation_date}{description}'

# Load helper functions
use _helpers.nu *

# Get your todo.txt list as a table
#
# Examples:
# # Get all tasks
# todo table
#
# # Parse a todo file from another location
# todo table -f /path/to/todo.txt
export def "todo table" [--file(-f): path = $default_todo_path]: nothing -> table {
    if not ($file | path exists) { touch $file }
    open --raw $file | file_parser
    | update cells -c [completion_date creation_date] {|c|
        if $c != null { into datetime }
    }
}

# Print your todo.txt file in human-readable format
#
# Examples:
# # Show a simple list of outstanding tasks
# todo table | where complete | sort-by priority | todo format '- {description}'
export def "todo format" [
    formatstr: string = $default_formatstr # The string used to format table input (same as `format pattern`)
    --pre-block(-B): closure # Code to run to modify columns before `format pattern`
    --post-block(-b): closure # Any code to run afterwards to further tweak output (closure takes 1 param - the formatted line)
]: table -> string {
    insert fmt {|rc|
        {
            complete: (if $rc.complete { 'x ' })
            priority: (if $rc.priority != null { $"\(($rc.priority)\) " })
            completion_date: (if $rc.completion_date != null { $rc.completion_date | format date '%F ' })
            creation_date: (if $rc.creation_date != null { $rc.creation_date | format date '%F ' })
            projects: ($rc.projects | str join ', ')
            contexts: ($rc.projects | str join ', ')
            tags: (if $rc.tags != [] { $rc.tags | items {|k,v| [$k $v] | str join ':' } | str join ', ' })
        }
    } | if $pre_block != null { do $pre_block $in } else {}
    | format pattern $formatstr
    | if $post_block != null {
        each {|line| do $post_block $line }
    } else {} | to text
}

# Print outstanding tasks with syntax highlighting
export def "todo list" [
    --all(-a) # Include completed tasks
    --file(-f): path = $default_todo_path # The path to the todo.txt file
]: nothing -> nothing {
    todo table --file $file
    | if not $all { where not complete } else {}
    | sort-by priority
    | todo format -B {
        update fmt.priority { stress_colorize }
        | update description { $'(ansi green)($in)(ansi reset)' }
    } -b {|line|
        str replace -ra '(\d{4}-\d{2}-\d{2}) ' $'(ansi magenta)$1(ansi reset) '
        | str replace -ra '(@\S+)' $'(ansi cyan)$1(ansi green)'
        | str replace -ra '(\+\S+)' $'(ansi blue)$1(ansi green)'
        | str replace -ra '(\S+):(\S+)' $'(ansi yellow_bold)$1:(ansi reset)$2(ansi green)'
        | if $line =~ '^\d+: x ' { ansi strip | $'(ansi s)($in)' } else {}
        | str replace -r '$' (ansi reset)
    } ('{index}: ' + $default_formatstr)
    | print
}

# Remove a task from the todo.txt file by ID
export def "todo rm" [id: int --file(-f): path = $default_todo_path]: nothing -> nothing {
    todo table --file $file
    | where index != $id
    | todo format
    | collect { save -f $file }
}

# Remove all completed tasks from file
export def "todo tidy" [--file(-f): path = $default_todo_path]: nothing -> nothing {
    todo table --file $file
    | where not complete
    | todo format
    | collect { save -f $file }
}

# Add a task to your todo.txt file
export def "todo add" [
    --file(-f): path = $default_todo_path # Path to your todo.txt file
    --complete(-c) # Add the task already completed
    --no-creation-date(-C) # Omit adding the creation date (also omits completion_date if `-c` is passed)
    --priority(-p): string = '' # The priority A-Z to give the task
    task_text: string # The task description
]: nothing -> nothing {
    let description = $task_text | str trim | ansi strip
    let priority = $priority | str upcase
    if ($task_text | is-empty) {
        error make {msg: 'Task description missing' label: {span: (metadata $task_text).span text: 'Task should not be empty'}}
    }
    todo table --file $file
    | append {
        complete: $complete
        priority: (if $priority in (seq char A Z) { $priority })
        completion_date: (if $complete and not $no_creation_date { date now })
        creation_date: (if not $no_creation_date { date now })
        description: $description
        projects: [] # The following 3 fields are not needed by `table format` but do need to exist
        contexts: []
        tags: []
    }
    | todo format
    | collect { save -f $file }
}

# Mark a task as (un)completed
export def "todo toggle" [id: int --file(-f): path = $default_todo_path] {
    todo table --file $file
    | update complete {|rc| if $rc.index == $id { not $rc.complete } else {} }
    | update completion_date {|rc| if $rc.complete and $rc.creation_date != null { date now } }
    | todo format
    | collect { save -f $file }
}
