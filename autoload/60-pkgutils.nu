def --wrapped nvcmp [...args: string] {
    ^nvcmp ...$args --json
    | from json -s
}
