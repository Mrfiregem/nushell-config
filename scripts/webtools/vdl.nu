# Interactively provide urls using text editor
def interactive-vdl [cmd: list<string>]: nothing -> nothing {
  let editor = $env | get -o $.config.buffer_editor $.VISUAL $.EDITOR | append 'vi' | compact | first
  let urlfile = mktemp

  try {
    ^$editor $urlfile
    ^$cmd --batch-file $urlfile
  } finally {
    rm $urlfile
  }
}

# Download videos from the internet using yt-dlp or youtube-dl
export def main [
  url?: string # The video to download, if not given through stdin
  title?: string # If `url` is the only video provided, name the file this (exluding extension)
]: [nothing -> nothing, string -> nothing, list<string> -> nothing] {
  append $url | let urls

  let dlcmd = which 'yt-dlp' 'youtube-dl' | get 0?.path
  let outdir = $env.VDLDIR? | default { $nu.home-dir | path join 'Videos' }

  if $dlcmd == null { error make -u '`yt-dlp` is not installed or is missing from PATH.' }

  let cmd = [$dlcmd, '-P', $outdir]

  match $urls {
    [] => { interactive-vdl $cmd }
    [$url] => {
      if $title != null {
        let outfile = ($title | str replace -a (char psep) '_') ++ '.%(ext)s'
        ^$cmd -o $outfile -- $url
      } else {
        ^$cmd -- $url
      }
    }
    [..$url] => { ^$cmd -- ...$url }
    _ => { error make -u 'Unreachable match arm reached in vdl command' }
  }
}
