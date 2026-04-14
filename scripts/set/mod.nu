# A module to perform simple set operations on lists.
#
# Since Nushell doesn't have a Set datatype, this module uses normalized lists instead, and
# all commands assume lists have been run through `set from-list` prior to being passed in.

# --- Basic Operations

# Transform a list into a set for use in other module functions.
export def from-list []: list<any> -> list<any> { sort | uniq }

# Return the set of elements of set A that are also present in set B. (A ∩ B)
export def intersect [set_b: list<any>]: list<any> -> list<any> {
    wrap item
    | join ($set_b | wrap item) item # from discord: faster than `where` check for large inputs
    | get item
}

# Return the set of elements in both set A and set B. (A ∪ B)
export def union [set_b: list<any>]: list<any> -> list<any> {
    append $set_b | from-list
}

# Return the set of all elements of set A not in set B. (A - B)
export def difference [set_b: list<any>]: list<any> -> list<any> {
    where $it not-in $set_b
}

# Return the set of all set A elements not in set B, and all set B elements not in set A.
export def symdiff [set_b: list<any>]: list<any> -> list<any> {
    let set_a
    | difference $set_b
    | union ($set_b | difference $set_a)
}

# Return the set of all possible subsets of the given set of elements.
export def powerset []: list<any> -> list<list<any>> {
    reduce -f [[]] {|el,acc| append ($acc | each { $in ++ [$el] }) }
}

# Return the set of all elements in the universal set not present in the given set. (A' or U - A)
# Note: The universal set must be provided through `$env.SET_UNIVERSAL`, as output would be nonsensical otherwise.
export def compliment []: list<any> -> list<any> {
    let set_a
    | if $env has 'SET_UNIVERSAL' {
        $env.SET_UNIVERSAL | difference $set_a
    } else {
        error make -u {msg: 'No universal set defined.', help: 'Populate the variable `$env.SET_UNIVERSAL`'}
    }
}

# Return each ordered pair (a, b), the Cartesian product, of set A and set B. (A × B)
export def product [set_b: list<any>]: list<any> -> list<list<any>> {
    reduce -f [] {|i| append ($set_b | reduce -f [] {|j| append [[$i, $j]] }) }
}

# --- Numeric Operations

# Return the set of all possible sums (a + b) for each ordered pair (a, b) from the product of sets A and B.
export def addition [set_b: list<number>]: list<number> -> list<number> {
    product $set_b
    | each { math sum }
    | from-list
}

# Return the set of all possible differences (a - b) for each ordered pair (a, b) of the product of sets A and B.
export def subtraction [set_b: list<number>]: list<number> -> list<number> {
    addition ($set_b | each { $in * -1 })
}

