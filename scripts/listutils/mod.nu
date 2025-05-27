# Include the set submodule if importing all of listutils
export use set/

# Given a list, create a list of slices of the original list with increasing length
#
# # Example
# > 'foo/bar/baz' | path split | step-list | to nuon
# [[foo], [foo, bar], [foo, bar, baz]]
export def "list step" []: list<any> -> list<list<any>> {
     reduce -f [] {|part,acc|
        let item = try { $acc | last | path join $part } catch { $part }
        $acc | append $item
    }
}

# Returns the index of the first element matching `value`, or -1 if there's no match.
@example "Get the index of 'bar'" { [foo bar baz] | list index-of bar } --result 1
export def "list index-of" [value: any]: list<any> -> int {
    for el in ($in | enumerate) {
        if $el.item == $value { return $el.index }
    }
    return (-1)
}

# Check if all items of a list are a record (stopgap until `table` type exists)
@example "Check if list<any> can perform table operations" { [{a: 1}, {b: 2}, 'c'] | list is-table } --result false
export def "list is-table" []: list<any> -> bool {
    collect | describe -d | get values | all {|val| $val has 'type' and $val.type == 'record' }
}

# If the input is a list with 1 item, return that item, otherwise no-op
@example "Doesn't unwrap" { ls | list try-unwrap }
@example "Unwraps into individual record or null" { which 'nvim' | list try-unwrap }
export def "list try-unwrap" [] {
    match $in {
        [$x] => $x,
        _ => $in
    }
}

# Wraps a single value into a list. Opposite of `list try-unwrap`
@example 'Wrap a string' { 'foo' | list wrap } --result ['foo']
@example 'Wrap null' { null | list wrap } --result []
@example 'Returns as-is' { ls | list wrap }
export def "list wrap" []: any -> list<any> {
    match $in {
        null => [],
        [ ..$x ] => [...$x],
        $x => [$x]
    }
}

# Return the first non-null entry in a list
export def "list first-valid" [
    --empty(-e) # Also ignore empty list, record, and string values
]: list<any> -> any {
    if $empty { compact -e } else { compact } | get 0?
}
