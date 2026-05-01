# A tool to help you solve Wordle puzzles

const default_wordlist = [apple, bacon, crowd, dream, earth, flood, great, happy, ingot, jelly, krill, lemon, merit,noble, opine, pride, quilt, reign, strip, tumor, under, venom, water, xerox, yelps, zooms]

export def main [
  --length(-l): int = 5 # The length of the word you're trying to find (if given wordlist)
  --wordlist(-w): path # File containing valid guesses. If not provided, a short list of 5 leter words
]: nothing -> nothing {
  let words = if $wordlist != null {
      open --raw $wordlist | lines | where ($it | str length) == $length
    } else {
      $default_wordlist
    }
  let length = if $wordlist != null { 5 } else if ($words | is-not-empty) { $length } else { -1 }
  if $length <= 0 { error make -u 'No words of correct length found using word list' }
}
