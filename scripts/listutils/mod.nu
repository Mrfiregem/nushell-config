export use set/ *

export def step []: list<any> -> list<list<any>> {
    let input = $in
    let n = $input | length
    mut result = []
    for i in 1..$n {
        $result = $result | append [($input | first $i)]
    }
    return $result
}