# Replace the characters '<', '>', and '&' with their HTML entity codes
export def "html encode" []: [string -> string, list<string> -> list<string>] {
    each {
        ^python3 -c 'import html,sys; print(html.escape(sys.stdin.read()), end="")'
        | decode
    }
}

# Replace all HTML entity codes with the character they represent
export def "html decode" []: [string -> string, list<string> -> list<string>] {
    each {
        ^python3 -c 'import html,sys; print(html.unescape(sys.stdin.read()), end="")'
        | decode
    }
}

# Convert HTML to a textual representation.
export def "html to-text" []: [string -> string, list<string> -> list<string>] {
    par-each --keep-order {
        ^python3 -c r#'
import sys; from html.parser import HTMLParser
class H(HTMLParser):
    pieces = []
    def handle_data(self, data):
        self.pieces.append(data)
h = H()
h.feed(sys.stdin.read())
print(''.join(h.pieces), end="")
        '# | decode
    }
}
