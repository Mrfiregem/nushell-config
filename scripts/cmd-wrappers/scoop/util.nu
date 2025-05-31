export def get-path [cmd: string]: nothing -> any {
    which $cmd | get 0?.path
}