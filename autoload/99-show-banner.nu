def _nu_banner [] {
    try {
        let out = nvcmp
        if ($out | length) > 0 { $out } else { ^fortune -s }
    } catch { date now | format date '%c' }
    | print
}

_nu_banner
