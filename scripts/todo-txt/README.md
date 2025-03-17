# todo-txt

A pure Nushell module to read, write, and update your todo.txt task file.

## Loading Module

Place this folder containing the `mod.nu` file into a directory listed in `$NU_LIB_DIRS`, then load the module from your configuration file.

```nushell
# config.nu
use todo-txt/ *
# Or alternatively...
overlay use todo-txt/
```

## Usage

Note: All commands aside from `todo format` take an optional `--file(-f)` flag, which will determine the location of the `todo.txt` file that is deing operated on. (Default: `~/todo.txt`)

### `todo add`

> Add a task to your todo.txt file

| Example | Description |
| ------- | ----------- |
| `todo add 'Do the dishes'` | Add a simple task with only a description and creation date |
| `todo add -p 'A' 'Finish @coding +project'` | Add a task with a priority letter (A-Z) and tags |
| `todo --complete 'Go to school'` | Add a task to the file that is already marked complete |
| `todo -C 'Live life'` | Add a task but omit the creation (and completion, if `-c` is passed) date field(s) |

### `todo list`

> List tasks that have yet to be completed with syntax highlighting

| Example | Description |
| ------- | ----------- |
| `todo list` | Print all outstanding tasks, sorted by priority |
| `todo list --all` | Include completed tasks in the printed list |

### `todo toggle`

> Toggle a task's completed state and set its completion date if it has a set creation date

| Example | Description |
| ------- | ----------- |
| `todo toggle 0` | If the task with ID 0 is incomplete, mark it as complete; otherwise mark it incomplete |

### `todo rm`

> Remove a task from your todo.txt file

| Example | Description |
| ------- | ----------- |
| `todo rm 0` | Remove the task with an ID of 0 |

### `todo tidy`

> Remove all tasks marked complete from your todo.txt file

| Example | Description |
| ------- | ----------- |
| `todo tidy` | Remove all completed tasks |

### `todo table`

> Parse your todo.txt file into a formatted table

| Example | Description |
| ------- | ----------- |
| `todo table` | Get your tasks as a Nushell table |

The columns outputted are as follows:

| Column | Description |
| ------ | ----------- |
| index | An int representing both the line number of the task in the file and its ID |
| complete | A bool tracking its completion state |
| priority | A string containing a single letter from the set A-Z, or `null` |
| completion_date | `null` if not complete or if creation_date is not available, otherwise the date of completion |
| creation_date | The date of the task's creation, if provided, or `null` |
| description | The main body of the task. This should always be a string |
| projects | A list of `+project` keywords extracted from description |
| contexts | A list of `@context` keywords extracted from description |
| tags | A record of `key:value` keywords extracted from description, or an empty list |

### `todo format`

> Taking in the output of `todo table`, formats it as a string using `formatstr`

| Example | Description |
| ------- | ----------- |
| `todo table \| todo format` | Format your tasks to match the `todo.txt` file specification using the default `formatstr` |
| `todo table \| where not complete \| todo format '- {description}'` | Get a list of incomplete tasks as a simple bulleted list |
| `todo table \| todo format --post-block { str replace -r '^x ' $'(ansi attr_strike)' \| str replace -r '$' (ansi reset) }` | List tasks but with completed tasks striked out by running code on each line of formatted text |
| `todo table \| todo format --pre-block { update priority { try { str downcase } } } '({priority}) {description}'` | Run code on the `todo table` table before `formatstr` is applied, but after the `fmt` table column is generated |

The `formatstr` uses the same syntax as the `format pattern` command. To ease incorporating some columns into the `formatstr`, a `fmt` column is generated containing a record with the following columns you can use in the string:

| Column | Example if column is populated |
| ------ | ----------- |
| fmt.complete | `'x '` |
| fmt.priority | `'(A) '` |
| fmt.completion_date and fmt.creation_date | `'2015-03-11 '` |
| fmt.projects and fmt.contexts | `'categorizer1, categorizer2'`
| fmt.tags | `'key1:value1, key2:value2'`
