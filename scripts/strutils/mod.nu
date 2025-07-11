# Wrap a string using the given delimiter(s)
@example "wrap a string in quotes" { 'foo' | str wrap "\"" } --result r#'"foo"'#
@example 'use differing left and right delimiters' { 'bar' | str wrap foo baz } --result 'foobarbaz'
def 'str wrap' [left: string, right?: string]: string -> string {
    $left ++ $in ++ ($right | default $left)
}

# `str trim` but left and right delimiters are regular expressions
export  def "str unwrap" [left_delim: string, right_delim?: string]: [
    string -> string
    list<string> -> list<string>
] {
    each {
        str replace -r $'^($left_delim)(char lp).*(char rp)($right_delim | default $left_delim)$' '$1'
    }
}
