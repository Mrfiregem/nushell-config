# Run a closure on non-null values while maintaining streaming.
export def and-then [closure: closure]: any -> any {
    peek | metadata access {|m| if $m.peek.type != 'nothing' { do $closure } }
}

# Return the first non-null list element, otherwise a default value
export def first-else [
  --empty(-e) # Filter empty values along with `null`
  default: any # The fallback value to use
]: list<any> -> any {
    append $default | compact --empty=$empty | first
}
