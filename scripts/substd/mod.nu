# Run a closure on non-null values while maintaining streaming.
export def and-then [closure: closure]: any -> any {
    peek | metadata access {|m| if $m.peek.type != 'nothing' { do $closure } }
}
