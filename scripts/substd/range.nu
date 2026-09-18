# Small module to work with the range datatype

use std-rfc/conversions [name-values]

# `into value` leaves the numbers as strings for some reason at times. This is a workaround
def 'into number' []: string -> number {
    if $in has '.' { into float } else { into int }
}

# Return a record containing information about a range input
@example 'Parse a simple range' { 1..5 | range parse } --result {start: "1", end: "5", inclusive: true}
@example 'Parse a range containing a step' {
    0..1.5..<4 | range parse
} --result {start: "0.0", step: "1.5", end: "4.0", inclusive: false}
export def parse []: range -> record<start: number, end: oneof<number, nothing>, inclusive: bool> {
    to nuon
    | split row '..'
    | match $in {
        [$start, $step, ''] => {
            name-values 'start' 'step' 'end'
            | update cells -c [start step] { into number }
            | update 'end' null
            | insert 'inclusive' true
        }
        [$start, $step, $end] => {
            name-values 'start' 'step' 'end'
            | if $end starts-with '<' {
                update 'end' { str substring 1.. }
                | insert 'inclusive' false
            } else {
                insert 'inclusive' true
            }
            | update cells -c [start, step, end] { into number }
        }
        [$start, ''] => {
            name-values 'start' 'end'
            | update 'end' null
            | update 'start' { into number }
            | insert 'inclusive' true
        }
        [$start, $end] => {
            name-values 'start' 'end'
            | if $end starts-with '<' {
                update 'end' { str substring 1.. }
                | insert 'inclusive' false
            } else {
                insert 'inclusive' true
            }
            | update cells -c [start, end] { into number }
        }
    }
}

# Convert the record provided by `range parse` back into a range
export def join []: [
    record<start: number, end: oneof<number, nothing>, inclusive: bool> -> range
] {
    match $in {
        {$start, $step, $end, $inclusive} => {
            if $inclusive {
                if $end == null {
                    ($start)..($step)..
                } else {
                    ($start)..($step)..($end)
                }
            } else {
                ($start)..($step)..<($end)
            }
        }
        {$start, $end, $inclusive} => {
            if $inclusive {
                if $end == null {
                    ($start)..
                } else {
                    ($start)..($end)
                }
            } else {
                ($start)..<($end)
            }
        }
    }
}
