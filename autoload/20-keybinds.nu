$env.config.keybindings ++= [
    {
        name: toggle_sudo
        modifier: alt
        keycode: char_s
        mode: [emacs vi_insert vi_normal]
        event: {
            send: executehostcommand
            cmd: "let cmd = commandline; commandline edit (if $cmd starts-with sudo { $cmd | str replace -r '^sudo ' '' } else { 'sudo ' ++ $cmd });"
        }
    }
]
