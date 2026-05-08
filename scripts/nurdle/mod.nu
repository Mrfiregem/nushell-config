# A tool to help you solve Wordle puzzles

const default_wordlist = path self '2of12inf.txt'

# Used to generate indices from a list to get a random non-duplicate sample
def 'random indices' [--min: int = 0, max: int, amount: int]: nothing -> list<int> {
    0.. | generate {|_,acc=[]| let i = random int $min..<$max; if $i not-in $acc { {out: $i, next: ($acc ++ [$i])} } else {next: $acc} } | first $amount
}

export def main [
  --length(-l): int = 5 # The length of the word you're trying to find
  --wordlist(-w): path = $default_wordlist # File containing valid words delimited by line.
]: nothing -> nothing {
  let words = open --raw $wordlist | lines | where ($it | str length) == $length
}

# Return a random valid word
export def random [
    --length(-l): int = 5 # The length of the word you're trying to find
    --wordlist(-w): path = $default_wordlist # File containing valid words delimited by line.
    amount: int = 1 # The number of words to return
]: [nothing -> string, nothing -> list<string>] {
    let words = open --raw $wordlist | lines | where ($it | str length) == $length
    match $amount {
        0 => []
        1 => { $words | get (random int 0..<($words | length)) }
        $i if $i < 0 => { error make {msg: 'invalid amount', label: {span: (metadata $amount).span, text: 'number must be positive'}} }
        $i => {
            let len = $words | length
            let indices = random indices $len $i
            $words | get $indices.0 ...($indices | skip 1)
        }
    }

}

# Guess a word given the board state
export def guesser [
    --length(-l): int = 5 # The length of the word you're trying to find
    --wordlist(-w): path = $default_wordlist # File containing valid words delimited by line.
]: record<green:string,yellow:string,black:string> -> list<string> {
    update cells { str downcase } | update 'green' { str replace --all '_' '\w' } | let data

    open --raw $wordlist | lines | where ($it | str length) == $length
    | where $it like $'^($data.green)$'
    | where {|word| $data.yellow | split chars | uniq | all {|c| $c in $word } }
    | where {|word| $data.black | split chars | uniq | any {|c| $c in $word } | not $in }
}
