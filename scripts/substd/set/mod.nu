# A module to perform simple set operations on lists.
#
# Nushell recently added a collection of set commands, so this just fills them out.

use std-rfc/iter prod

# --- Basic Operations

# Return the set of all set A elements not in set B, and all set B elements not in set A.
@example 'Find the symmetric difference' { seq 1 4 | set symdiff (seq 2 6) } --result [1 5 6]
export def symdiff [set_b: list<any>]: list<any> -> list<any> {
    let set_a
    | difference $set_b
    | union ($set_b | difference $set_a)
}

# Return the set of all possible subsets of the given set of elements.
@example 'Generate all subsets' { seq 1 3 | set powerset | to nuon } --result '[[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]'
export def powerset []: list<any> -> list<list<any>> {
    reduce -f [[]] {|el,acc| append ($acc | each { $in ++ [$el] }) }
}

# Return the set of all elements in the universal set not present in the given set. (A' or U - A)
# Note: The universal set must be provided through `$env.SET_UNIVERSAL`, as output would be nonsensical otherwise.
@example 'Compliment the set' { with-env {SET_UNIVERSAL: (seq 1 10)} { seq 2 8 | set compliment } } --result [1 9 10]
export def compliment []: list<any> -> list<any> {
    let set_a
    | if $env has 'SET_UNIVERSAL' {
        $env.SET_UNIVERSAL | difference $set_a
    } else {
        error make -u {msg: 'No universal set defined.', help: 'Populate the variable `$env.SET_UNIVERSAL`'}
    }
}

# Return each ordered pair (a, b), the Cartesian product, of set A and set B. (A × B)
@example 'Multiply two sets' { seq 1 3 | set product (seq char a b) | to nuon } --result '[[1, a], [1, b], [2, a], [2, b], [3, a], [3, b]]'
export def product [...set_b: list<any>]: list<any> -> list<any> {
    [$in, ...$set_b] | let $sets
    if ($sets | length) < 2 { error make -u 'Must provide at least 2 sets.' }
    mut col = 0
    mut rec = {}
    for set in $sets {
        $rec = $rec | insert $'($col)' $set
        $col += 1
    }
    prod $rec | transpose --ignore-titles | values
}

# --- Numeric Operations

# Return the set of all possible sums (a + b) for each ordered pair (a, b) from the product of sets A and B.
@example 'Find all sums of pairs' { seq 1 3 | set addition (seq 4 5) } --result [5 6 7 8]
export def addition [set_b: list<number>]: list<number> -> list<number> {
    product $set_b
    | each { math sum }
    | from-list
}

# Return the set of all possible differences (a - b) for each ordered pair (a, b) of the product of sets A and B.
@example 'Find all differences of pairs' { seq 1 3 | set subtraction (seq 4 5) } --result [-4 -3 -2 -1]
export def subtraction [set_b: list<number>]: list<number> -> list<number> {
    addition ($set_b | each { $in * -1 })
}
