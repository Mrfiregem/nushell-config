# Wrapper around powershell to make it take nu data as input and output

def maybe [action: closure]: any -> any {
  let x | try { do $action $x } catch { $x }
}

# Wrapper around powershell to make it take nu data as input and output
export def run-powershell [
  --args(-a): record = {} # Data accessable through the `$Nu` variable alongside stdin
  --depth(-d): int = 8 # When not in `--raw` mode, depth passed to `ConvertTo-Json`
  --shell-flags(-F): list<string> # Flags to pass the powershell binary
  --legacy(-l) # Prefer using Powershell 5.1 even if Powershell Core is installed
  --raw(-r) # Don't attempt to convert output into datatypes
  script: string # The Powershell command to run, given to the `-Command` flag
]: any -> any {
  default null | wrap 'stdin' | merge $args | let $args

  let shell = which ^pwsh ^powershell | if $legacy { try { last | get $.path? } } else { get $.0?.path }
  if $shell == null { error make -u "Couldn't find Powershell on PATH." }

  let script = [
    '$Nu = $Input | ConvertFrom-Json;',
    $script
  ]
  | if not $raw { append $'| ConvertTo-Json -Depth ($depth)' } else {}
  | str join ' '

  let shellcmd = [$shell, '-Command', $script, ...$shell_flags,]

  $args | to json | ^$shellcmd | if not $raw { maybe { from json } } else {}
}
