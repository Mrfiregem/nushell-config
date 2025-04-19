export def list [] {
    ^scoop export | from json -s
    | get apps | rename -b { str downcase }
    | into datetime updated
    |  move --after name version source updated info
}

export extern alias []
export extern bucket []
export extern cache []
export extern cat []
export extern checkup []
export extern cleanup []
export extern config []
export extern create []
export extern depends []
export extern download []
export extern export []
export extern help []
export extern hold []
export extern home []
export extern import []
export extern info []
export extern install []
export extern prefix []
export extern reset []
export extern search []
export extern shim []
export extern status []
export extern unhold []
export extern uninstall []
export extern update []
export extern virustotal []
export extern which []
