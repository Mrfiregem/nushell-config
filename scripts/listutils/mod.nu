# Include the set submodule if importing all of listutils
export use set/

# Given a list, create a list of slices of the original list with increasing length
#
# # Example
# > 'foo/bar/baz' | path split | step-list | to nuon
# [[foo], [foo, bar], [foo, bar, baz]]
export def "list step" []: list<any> -> list<list<any>> {
    let input = $in
    let n = $input | length
    mut result = []
    for i in 1..$n {
        $result = $result | append [($input | first $i)]
    }
    return $result
}

# Returns the index of the first element matching `value`, or -1 if there's no match.
export def "list index-of" [value: any]: list<any> -> int {
for el in ($in | enumerate) {
    if $el.item == $value { return $el.index }
}
return (-1)
}

