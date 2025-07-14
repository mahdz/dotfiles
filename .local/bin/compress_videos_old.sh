#!/usr/bin/env bash
# Requires: ffmpeg, exiftool (install via apt/brew first)
# Usage:
#     $ cd ~/Videos
#     $ ./compress_videos.sh
#     [+] Converting all .mov files in ~/Videos to .x265.mov files...
#        - √ GP013838.mov (2.5GB)     ->     GP013838.x265.mov (142MB)
#        - √ ...
#     [√] Done converting all .mov files in $PWD.

set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
IFS=$'\n'

#
# Constants
#

# Variables
INPUT_DIR="$HOME/Movies/convert"  # Directory containing videos to compress
OUTPUT_DIR="$HOME/Movies/convert/optimised"      # Directory to save compressed videos
CRF=22                                 # Constant Rate Factor/Quality, between 18 up to 51, 28 in H.265 = 23 in H.264
PRESET=superfast    # Preset: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo.

echo "[+] Converting all .mov files in $INPUT_DIR to .x265.mov files..."

for filename in "$INPUT_DIR"/*.{mov,MOV}; do
    if echo "$filename" | grep "\.x265\.mov"; then
        continue
    fi
    without_ext="$(echo $filename | cut -d'.' -f1)"
    x265_filename="${without_ext}.x265.mov"

    orig_size="$(du -h $filename | awk '{print $1}')"

    if ! [[ -f "$x265_filename" ]]; then
        ffmpeg \
            -i "$filename" \
            -map_metadata 0 \
            -movflags use_metadata_tags \
            -c:v libx265 \
            -tag:v hvc1 \
            -c:a copy \
            -crf $CRF \
            -preset $PRESET \
            "$x265_filename"
    fi
#    exiftool -TagsFromFile "$filename" "-all:all>all:all" "$x265_filename"
    x265_size=="$(du -h $x265_filename | awk '{print $1}')"
    echo "   - √ $filename ($orig_size)     ->     $x265_filename ($x265_size)"
done

echo "[√] Done converting all .mov files in $PWD."
