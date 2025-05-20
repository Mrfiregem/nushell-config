def setup_memo_table []: nothing -> closure {
    # Create the table if it doesn't exist
    let schema = {name: 'str', closure: 'str', value: 'str', type: 'str'}
    try { stor create --table-name 'memoize_cache' --columns $schema | ignore }
    {|| stor open }
}

def add-memo [name: string, fn: closure]: nothing -> nothing {
    let db_open = setup_memo_table
    # If row with name already exists, delete it
    try { do $db_open | query db 'DELETE FROM memoize_cache WHERE name = :name' --params {name: $name} }

    # Insert the new memoized function
    {name: $name, closure: ($fn | to nuon -s | str substring 1..<-1), value: '__none__', type: 'nothing'}
    | stor insert -t memoize_cache | ignore
}

def into_type []: record<type: string, value: string> -> any {
    let input = $in
    match $input.type {
        'string' => $input.value
        'int' => { $input.value | into int }
        'float' => { $input.value | into float }
        'bool' => { $input.value | into bool }
        $x => { $input.value | from nuon }
    }
}

def get-memo-value [name: string]: nothing -> any {
    let db_open = setup_memo_table
    # Get row with the given name
    let memo: record = try {
        do $db_open
        | query db 'SELECT * FROM memoize_cache WHERE name = :name' --params {name: $name}
        | into record
    } catch { {} }

    # If value is '__none__', run the closure and update the value
    match $memo.value? {
        '__none__' => {
            let result = (^$nu.current-exe -c
                $"do ($memo.closure) | {type: \($in | describe\), value: $in} | to nuon -s")
                | tee { print $'input: ($in)' }
                | from nuon
            # Update the value in the database
            do $db_open
            | query db 'UPDATE memoize_cache
                SET value = :value, type = :type
                WHERE name = :name' --params {value: ($result.value | to nuon -s), name: $name, type: $result.type}

            # Return the result
            $result.value
        }
        _ => { {value: $memo.value, type: $memo.type} | into_type }
    }
}

export def main [name: string, fn?: closure]: nothing -> any {
    # If a function is provided, add it to the memo table
    if $fn != null {
        add-memo $name $fn
    } else {
        # Get the memoized value
        get-memo-value $name
    }
}