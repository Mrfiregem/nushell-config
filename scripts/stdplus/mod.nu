# Run a closure to modify the value of each record key.
#
# The closure recieves value as input, and also optionally
# is passed the current key and value as parameters.
@example "Capitalize strings" { {foo: 'bar', baz: 'quox'} | update keys { str upcase } } --result {foo: 'BAR', baz: 'QUOX'}
@example "Using closure params" { {a:1, b:2, c:3} | update keys {|k,v| [$k $v] | str join } } --result {a: "a1", b: "b2", c: "c3"}
@category "filters"
export def "update keys" [
    --keys(-k): list<string> # Which record keys to modify
    closure: closure         # The closure to run on each key
]: record -> record {
    mut input = $in
    let keys = $keys | default ($input | columns) | where $it in ($input | columns)
    for k in $keys {
        $input = $input | update $k {|rc| do $closure $k ($rc | get $k)}
    }
    return $input
}

# Rename a deeply nested record using a block
@category 'filters'
def "rename deep" [block: closure]: record -> record {
    rename -b $block | transpose k v
    | each {
        update v {|rc| match ($rc.v | describe -d).type {
            'record' => { $rc.v | rename deep $block }
            _ => $rc.v
        }}
    }
    | transpose -rd
}

# Get the base type of any input
@example "Get the type of `ls`" { ls | type } --result "table"
@example "Identify a list" { seq 1 5 | type } --result "list"
@category 'core'
export def typeof []: any -> string {
    match ($in | describe -d) {
        {type: 'list', values: $l} => {
            if ($l | each { typeof } | uniq) == ['record'] { 'table' } else { 'list' }
        }
        {type: $t} => $t
    }
}

# Get environment variable or fallback to a default value
@category 'env'
export def env-or-default [var: string, default: any]: nothing -> any {
    if $env has $var { $env | get $var } else { $default }
}
