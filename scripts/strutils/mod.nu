export use morse.nu *

# `str trim` but left and right delimiters are regular expressions
export  def "str unwrap" [left_delim: string, right_delim?: string]: [
    string -> string
    list<string> -> list<string>
] {
    each {
        str replace -r $'^($left_delim)(char lp).*(char rp)($right_delim | default $left_delim)$' '$1'
    }
}
