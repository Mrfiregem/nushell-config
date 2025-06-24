# BASIC OPERATIONS
# ================

# Convert a list into a set of unique values
export def "into set" []: list<any> -> list<any> { uniq | sort }

# Check if set A is contained within set B
export def is-subset-of [superset: list<any>]: list<any> -> bool {
    into set | all {|e| $e in ($superset | into set) }
}

# Check if set A contains all elements of set B
export def is-superset-of [subset: list<any>]: list<any> -> bool {
    do {|superset| $subset | into set | is-subset-of $superset } $in
}

# Return the set of elements in set A, set B, or both
export def union [set_b: list<any>]: list<any> -> list<any> {
    append $set_b | into set
}

# Return the set of elements that are only in both set A and B
export def intersect [set_b: list<any>]: list<any> -> list<any> {
    where $it in $set_b | into set
}

# Check if set A and set B share no elements
export def is-disjoint-from [set_b: list<any>]: list<any> -> bool {
    intersect $set_b | is-empty
}

# Return set A but with elements shared with set B removed
export def difference [set_b: list<any>]: list<any> -> list<any> {
    where $it not-in $set_b | into set
}

# COMPLEX OPERATIONS
# ==================

# Generate the set of all possible subsets of a given set
export def powerset []: list<any> -> list<list<any>> {
    let input: list<any> = $in
    let n = $input | length
    mut power_set = []

    for i in 0..<(2 ** $n) {
        mut subset = []
        for j in 0..<$n {
            if ($i | bits and (1 | bits shl $j)) > 0 {
                $subset = $subset | append ($input | get $j)
            }
        }
        $power_set = $power_set | append [$subset]
    }

    return $power_set
}
