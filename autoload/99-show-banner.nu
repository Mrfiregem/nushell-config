def _nu_banner [] {
    let out = nvcmp
    if ($out | length) > 0 { $out } else { ^fortune -s }
    | print
}

_nu_banner
