# A tool to help you solve Wordle puzzles

use std-rfc/kv ['kv get', 'kv set']
use std-rfc/random

const default_wordlist = path self '2of12inf.txt'

def gen-words [len: int, file: oneof<path,nothing>]: nothing -> list<string> {
    kv get -t nurdle 'allwords'
    | default {
        match $file {
            null => { open --raw $default_wordlist }
            $path => { open --raw $path }
        }
        | lines
        | where ($it | str length) == $len
        | kv set -t nurdle 'allwords'
    }
}

# Used to generate indices from a list to get a random non-duplicate sample
def 'random indices' [--min: int = 0, max: int, amount: int]: nothing -> list<int> {
    0.. | generate {|_,acc=[]| let i = random int $min..<$max; if $i not-in $acc { {out: $i, next: ($acc ++ [$i])} } else {next: $acc} } | first $amount
}

export def main [
  --length(-l): int = 5 # The length of the word you're trying to find
  --wordlist(-w): path # File containing valid words delimited by line.
]: nothing -> nothing {
  let words = gen-words $length $wordlist
}

# Return a random valid word
export def random [
    --length(-l): int = 5 # The length of the word you're trying to find
    --wordlist(-w): path # File containing valid words delimited by line.
    amount: int = 1 # The number of words to return
]: nothing -> list<string> {
    gen-words $length $wordlist | random choice $amount
}
