# Convert a list into a set of unique values
export def "into set" []: list<any> -> list<any> { uniq }

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

# Check if a list is a subset of another list
export def is-subset-of [superset: list<any>]: list<any> -> bool {
    all {|e| $e in $superset }
}

# Check if a list is a superset of another list
export def is-superset-of [subset: list<any>]: list<any> -> bool {
    do {|superset| $subset | is-subset-of $superset } $in
}
