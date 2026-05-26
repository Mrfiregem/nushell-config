# Utilities to reduce video filesize

use std/util [null_device]

# Round the input down to the nearest multiple of a given divisor
def 'round down' [divisor: number = 10]: number -> number { $in - ($in mod $divisor) }

# Use two-pass encoding to compress an .mp4 video to a certain filesize
@example 'Compress video size to under 10 MB' { vidtools compress ./video.mp4 }
export def compress [
    --target-size(-s): filesize = 10MB # Output will be below this size
    --in-place(-i) # Replace the original file in-place
    --audio-bitrate(-a): int = 64 # Audio bitrate in kBit
    input: path # The input file to compress
    output?: path # # An optional output path (default: '{name}-{size}.{ext}')
]: nothing -> nothing {
    let file_ext = $input | path parse | get 'extension'

    if $file_ext != 'mp4' {
        error make {
            msg: 'Invalid filetype'
            labels: [{
                text: 'Only supports `.mp4` files'
                span: (metadata $input).span
            }]
        }
    }

    let video_duration_sec: float = (
        ^ffprobe -v error
        -show_entries format=duration
        -of default=noprint_wrappers=1:nokey=1
        $input
    )
    | into float

    let target_output_size_kbit: number = $target_size
    | into int # Convert to bytes
    | $in * 8 # Convert to bits
    | $in / 1000.0 # Convert to kBits
    | round down

    # Calculate required bitrate to be below target size
    let target_bitrate = $'($target_output_size_kbit / $video_duration_sec | $in - $audio_bitrate)k'

    # Choose where to save the file
    let output_path = if $in_place {
        mktemp --suffix $'.($file_ext)'
    } else {
        $output
        | default {
            $input
            | path parse
            | update 'stem' {
                append ($target_size | into string | str downcase | str replace '.0 ' '' | str replace -a ' ' '')
                | str join '-'
            }
            | path join
        }
    }

    # Compress the video using calculated bitrate
    ^ffmpeg -y -i $input -c:v libx264 -b:v $target_bitrate -pass 1 -an -f 'null' $null_device
    ^ffmpeg -i $input -c:v libx264 -b:v $target_bitrate -pass 2 -c:a aac -b:a $'($audio_bitrate)k' $output_path

    # Cleanup files
    rm 'ffmpeg2pass-0.log' 'ffmpeg2pass-0.log.mbtree'

    # Move file to old location if requested
    if $in_place {
        mv --force $output_path $input
    }
}

export def scale [
    --in-place(-i) # Overwrite the original input file
    --width(-w): int = 480 # The output width of the video in pixels
    --height(-h): int = -2 # The output height of the video in pixels
    input: path # The original video
    output?: path # An optional output path (default: '{name}-{scale}.{ext}')
]: nothing -> nothing {
    # Construct the scale string ('{width}:{height}')
    let scale_str = [$width, $height] | str join ':'

    # Determine where to save the compressed file to
    let output_path = if $in_place {
        mktemp
    } else {
        $output
        | default {
            $input
            | path parse
            | update 'stem' { append ($scale_str | str replace ':' 'x') | str join '-' }
            | path join
        }
    }

    # Scale the input video to the given dimensions
    ^ffmpeg -i $input -vf $'scale=($scale_str)' $output_path

    # Overwrite original file if desired
    if $in_place {
        mv --force $output_path $input
    }
}
