#!/bin/bash

# Script to compress video files in ~/Movies/Convert/todo using the H.265 (HEVC) codec.
# This script will preserve HDR, ensure compatibility with Apple devices, and copy metadata using exiftool.

# Function to display help message
show_help() {
    echo "Usage: $0 [-h|--help]"
    echo
    echo "Options:"
    echo "  -h, --help   Display this help message"
}

# Variables (configure as needed)
INPUT_DIR="$HOME/Movies/convert/ffmpeg"  # Directory containing videos to compress
OUTPUT_DIR="$HOME/Movies/convert/optimized"      # Directory to save compressed videos
CRF=22                                     # Constant Rate Factor (lower is higher quality, default is 28)
PRESET="superfast"                              # FFmpeg preset (options: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow)
LOG_FILE="$OUTPUT_DIR/compression.log"     # Log file for the operation

# Function to compress a video
compress_video() {
    local input_file="$1"                    # Input video file path
    local output_file="$2"                   # Output video file path

    # Compress video using FFmpeg while preserving HDR
    ffmpeg -i "$input_file" -c:v libx265 -crf "$CRF" -preset "$PRESET" \
           -c:a copy -c:s copy -tag:v hvc1 \
           -x265-params "hdr-opt=1" \
           "$output_file"




    # Check if the compression was successful
    if [[ $? -eq 0 ]]; then
        echo "Compression successful for $input_file"

        # Copy metadata from source to output using exiftool
        exiftool -overwrite_original -TagsFromFile "$input_file" "$output_file"

        # Log the success
        echo "$(date): Compressed $input_file -> $output_file" >> "$LOG_FILE"
    else
        echo "Compression failed for $input_file"
        echo "$(date): Compression failed for $input_file" >> "$LOG_FILE"
    fi
}

# Function to check if a video is already in H.265 format
is_already_hevc() {
    local input_file="$1"

    # Use ffprobe to check if the video is already in H.265 format
    codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 "$input_file")

    if [[ "$codec" == "hevc" ]]; then
        return 0  # True: Already in H.265 format
    else
        return 1  # False: Needs compression
    fi
}

# Main function to handle the script logic
main() {
    # Parse command-line options
    while getopts ":h-:" opt; do
        case $opt in
            h)
                show_help
                exit 0
                ;;
            -)
                case "${OPTARG}" in
                    help)
                        show_help
                        exit 0
                        ;;
                    *)
                        echo "Invalid option: --${OPTARG}"
                        show_help
                        exit 1
                        ;;
                esac
                ;;
            *)
                echo "Invalid option: -${OPTARG}"
                show_help
                exit 1
                ;;
        esac
    done

    # Ensure the input directory exists
    if [[ ! -d "$INPUT_DIR" ]]; then
        echo "Input directory $INPUT_DIR does not exist."
        exit 1
    fi

    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_DIR"

    # Process each video file in the input directory
    for input_file in "$INPUT_DIR"/*; do
        # Check if the file is a video file
        if [[ "$input_file" =~ \.(mp4|mkv|mov|avi|flv|wmv)$ ]]; then
            # Generate the output file path
            output_file="$OUTPUT_DIR/$(basename "${input_file%.*}").h265.mov"

            # Check if the video is already in H.265 format
            if is_already_hevc "$input_file"; then
                echo "Skipping $input_file (already in H.265 format)"
                continue
            fi

            # Compress the video
            compress_video "$input_file" "$output_file"
        else
            echo "Skipping $input_file (not a recognized video format)"
        fi
    done
}

# Execute the main function
main "$@"
