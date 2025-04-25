# Default path to todo file (~/todo.txt)
const default_todo_path = [$nu.home-path todo.txt] | path join
const default_formatstr = '{fmt.complete}{fmt.priority}{fmt.completion_date}{fmt.creation_date}{description}'

# Load helper functions
use _helpers.nu *

# Manage your todo.txt file
@category 'todo-txt'
export def todo []: nothing -> nothing {
	const link = 'https://github.com/Mrfiregem/nushell-config/blob/master/scripts/todo-txt/README.md'
	print $"Documentation can be found online: '($link)'"
	if (input -n 1 'Would you like to open your browser? [Y/n]: ' | default 'y' |str downcase) != 'n' {
		start $link
	}
}

# Get your todo.txt list as a table
@example 'Get todo.txt as a table' { todo table }
@example 'Get todo.txt as a table from a specific file' { todo table -f /path/to/todo.txt }
@category 'todo-txt'
export def "todo table" [--file(-f): path = $default_todo_path]: nothing -> table {
    if not ($file | path exists) { touch $file }
    open --raw $file | file_parser
    | update cells -c [completion_date creation_date] {|c|
        if $c != null { into datetime }
    }
}

# Print your todo.txt file in human-readable format
@example 'Show a simple list of outstanding tasks' { todo table | where not complete | sort-by priority | todo format '- {description}' }
@category 'todo-txt'
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
@example 'Print your todo list with syntax highlighting' { todo list }
@example 'Include completed tasks' { todo list --all }
@category 'todo-txt'
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

# Remove task(s) from the todo.txt file by ID
@example 'Remove multiple tasks by ID' { todo rm 1 3 4 }
@category 'todo-txt'
export def "todo rm" [...id: int --file(-f): path = $default_todo_path]: nothing -> nothing {
    if ($id | is-empty) { error make {
            msg: 'Task ID missing'
            label: {span: (metadata $id).span, text: 'ID should not be empty'}
    }}
    todo table --file $file
    | where index not-in $id
    | todo format
    | collect { save -f $file }
}

# Remove all completed tasks from file
@category 'todo-txt'
export def "todo tidy" [--file(-f): path = $default_todo_path]: nothing -> nothing {
    todo table --file $file
    | where not complete
    | todo format
    | collect { save -f $file }
}

# Add a task to your todo.txt file
@example 'Add a simple task' { todo add 'Do laundry @chores' }
@example 'Add a task and set priority' { todo add -p A 'Do this urgently' }
@example 'Add an already completed task' { todo add --complete 'Create the todo-txt module' }
@category 'todo-txt'
export def "todo add" [
    --file(-f): path = $default_todo_path # Path to your todo.txt file
    --complete(-c) # Add the task already completed
    --no-creation-date(-C) # Omit adding the creation date (also omits completion_date if `-c` is passed)
    --priority(-p): string = '' # The priority A-Z to give the task
    task_text: string # The task description
]: nothing -> nothing {
    let description = $task_text | str trim | ansi strip
    let priority_span = (metadata $priority).span
    let priority = $priority | str upcase
    if ($task_text | str trim | is-empty) {
        error make {msg: 'Task description missing' label: {span: (metadata $task_text).span, text: 'Task should not be empty'}}
    }
    if priority not-in (seq char A Z) {
        error make {msg: 'Priority should be a single letter [A-Z]' label: {span: $priority_span, text: 'Priority should be A-Z'}}
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
@example 'Mark a task with ID 1 as completed' { todo toggle 1 }
@category 'todo-txt'
export def "todo toggle" [...id: int --file(-f): path = $default_todo_path] {
    if ($id | is-empty) { error make {
            msg: 'Task ID missing'
            label: {span: (metadata $id).span, text: 'ID should not be empty'}
    }}
    todo table --file $file
    | update complete {|rc| if $rc.index in $id { not $rc.complete } else {} }
    | update completion_date {|rc| if $rc.index in $id { if $rc.complete and $rc.creation_date != null { date now } } else {} }
    | todo format
    | collect { save -f $file }
}

# Edit a task by ID using a record with fields you want to overwrite
@example 'Edit the description of the task with 1' { todo edit 1 {description: 'New task description'} }
export def "todo edit" [
    --file(-f): path = $default_todo_path # Path to your todo.txt file
    id: int # The ID of the task to edit
    todo_record: record # Allowed fields: [complete, priority, completion_date, creation_date, description]
]: nothing -> nothing {
    let todo_record_span = (metadata $todo_record).span

    # Make sure record contains only valid fields
    for col in ($todo_record | columns) {
        if $col not-in [complete priority completion_date creation_date description] {
            error make {
                msg: 'Invalid column name'
                label: {span: $todo_record_span, text: $'($col) is not a valid column name'}
                help: 'Check `todo edit --help` for valid column names'
            }
        }
        match $col {
            'complete' => { if ($todo_record.complete | describe -d).type != bool {
                error make {
                    msg: 'Invalid type for complete'
                    label: {span: $todo_record_span, text: 'Complete should be a boolean'}
                }
            }}
            'priority' => { if $'($todo_record.priority)' not-in (seq char A Z) {
                error make {
                    msg: 'Invalid type for priority'
                    label: {span: $todo_record_span, text: 'Priority should be a letter [A-Z]'}
                }
            }}
            'completion_date' => { if ($todo_record.completion_date | describe -d).type != string {
                error make {
                    msg: 'Invalid type for completion_date'
                    label: {span: $todo_record_span, text: 'Completion date should be a string'}
                }
            } else if $todo_record.completion_date !~ '^\d{4}-\d{2}-\d{2}$' {
                error make {
                    msg: 'Invalid type for completion_date'
                    label: {span: $todo_record_span, text: 'Completion date should be formatted as YYYY-MM-DD'}
                }
            }}
            'creation_date' => { if ($todo_record.creation_date | describe -d).type != string {
                error make {
                    msg: 'Invalid type for creation_date'
                    label: {span: $todo_record_span, text: 'Creation date should be a string'}
                }
            } else if $todo_record.creation_date !~ '^\d{4}-\d{2}-\d{2}$' {
                error make {
                    msg: 'Invalid type for creation_date'
                    label: {span: $todo_record_span, text: 'Creation date should be formatted as YYYY-MM-DD'}
                }
            }}
            'description' => {
                if ($todo_record.description | describe -d).type != string {
                    error make {
                        msg: 'Invalid type for description'
                        label: {span: $todo_record_span, text: 'Description should be a string'}
                    }
                } else if ($todo_record.description | str trim | is-empty) {
                    error make {
                        msg: 'Description should not be empty'
                        label: {span: $todo_record_span, text: 'Description should not be empty'}
                    }
                }
            }
        }
    }

    todo table --file $file
    | each {|task|
        if $task.index == $id {
            merge $todo_record
        } else {}
    }
    | todo format
    | collect { save -f $file }
}

# Open the todo.txt file in your editor
@example 'Open the todo.txt file in your editor' { todo open -e 'code' }
@category 'todo-txt'
export def "todo open" [
    --file(-f): path = $default_todo_path # Path to your todo.txt file
    --editor(-e): string # The editor to use (defaults to user editor if set, or vim)
]: nothing -> nothing {
    let editor = $editor | default $env.VISUAL? | default $env.EDITOR? | default 'vim'
    if ($editor | describe -d).type == list {
        run-external ...$editor $file
    } else {
        run-external $editor $file
    }
}