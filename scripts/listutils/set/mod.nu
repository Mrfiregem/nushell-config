# Tools to work with lists as sets

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
    filter {|e| $e in $set_b } | into set
}

# Check if set A and set B share no elements
export def is-disjoint-from [set_b: list<any>]: list<any> -> bool {
    intersect $set_b | is-empty
}

# Return set A but with elements shared with set B removed
export def difference [set_b: list<any>]: list<any> -> list<any> {
    filter {|e| $e not-in $set_b } | into set
}

# COMPLEX OPERATIONS
# ==================

# Generate the set of all possible subsets of a given set
export def powerset []: list<any> -> list<list<any>> {
    let input = $in
    let n = $input | length
    mut result = [[]]
    for i in 0..<$n {
        for j in ($i + 1)..$n {
            $result = $result | append [($input | slice $i..<$j)]
        }
    }
    return $result
}
