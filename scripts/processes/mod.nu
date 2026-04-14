# Filter running processes by name using regex
@example 'Get the PIDs of nushell instances' { pgrep '^nu' | get pid }
export def pgrep [
    --ignore-case(-i)
    --long(-l)
    pattern: string
]: nothing -> table {
    let regex: string = $pattern | if $ignore_case { '(?i)' ++ $in } else {}
    ps --long=$long | where name like $regex
}

# Kill running processes by name using regex
@example 'Forcefully close Discord' { pkill -i discord }
export def pkill [
    --ignore-case(-i)
    --force(-f)
    pattern: string
]: nothing -> table {
    pgrep --ignore-case=$ignore_case $pattern
    | if $in == [] { return $in } else {}
    | tee { kill --force=$force ...$in.pid }
}

