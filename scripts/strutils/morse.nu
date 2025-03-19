
const morse_map = {
    A: '.-'    B: '-...'  C: '-.-.'
    D: '-..'   E: '.'     F: '..-.'
    G: '--.'   H: '....'  I: '..'
    J: '.---'  K: '-.-'   L: '.-..'
    M: '--'    N: '-.'    O: '---'
    P: '.--.'  Q: '--.-'  R: '.-.'
    S: '...'   T: '-'     U: '..-'
    V: '...-'  W: '.--'   X: '-..-'
    Y: '-.--'  Z: '--..'
    '1': '.----' '2': '..---' '3': '...--'
    '4': '....-' '5': '.....' '6': '-....'
    '7': '--...' '8': '---..' '9': '----.'
    '0': '-----'
    '.': '.-.-.-'  ',': '--..--'  '?': '..--..'
    "'": '.----.'  '!': '-.-.--'  '&': '.-...'
    ':': '---...'  ';': '-.-.-.'  '"': '.-..-.'
    '+': '.-.-.'   '-': '-....-'  '/': '-..-.'
    '=': '-...-'   '@': '.--.-.'  '$': '...-..-'
    '_': '..--.-'  '(': '-.--.'   ')': '-.--.-'
}

# Convert a string of alphanumeric ASCII characters to morse code
export def "str to-morse" []: [string -> string, list<string> -> list<string>] {
    each {
        split row -r '\s+' | each {
            split chars | each {|c| $morse_map | get -i ($c | str upcase) }
            | str join ' '
        }
        | str join ' / '
    }
}

# Convert a string of morse code into an alphanumeric ASCII string
export def "str from-morse" []: [string -> string, list<string> -> list<string>] {
    each {|line|
        split row -r '\s+' | split list '/' | each {
            each {|c| $morse_map | transpose | roll right | transpose -rd | get -i $c }
            | str join
        } | str join ' '
    }
}
