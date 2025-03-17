export def html-encode []: [
    string -> string
    list<string> -> list<string>
] {
    each {
        ^python3 -c 'import html,sys; print(html.escape(sys.stdin.read()), end="")'
    } | collect
}

export def html-decode []: [
    string -> string
    list<string> -> list<string>
] {
    each {
        ^python3 -c 'import html,sys; print(html.unescape(sys.stdin.read()), end="")'
    } | collect
}
