# Upload a file to a pastebin for sharing
def "http pastebin" [
    file: path # File to upload to 0x0.st
    extra_data: record = {} # Extra data to send to the server
]: nothing -> nothing {
    let file_content = open --raw $file | into binary
    let post_data = {file: $file_content} | merge $extra_data
    http post --content-type multipart/form-data 'https://0x0.st' $post_data
}

# Download a file from the web
def wget [
    --force(-f) # Override an existing file
    url: string # Link to the file
    out?: path  # Filename (default: taken from url)
]: nothing -> nothing {
    let filename = $out | default { $url | url parse | get path | path basename }
    http get $url | if $force { save -f $filename } else { save $filename }
}
