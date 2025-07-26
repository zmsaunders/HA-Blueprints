#!/bin/bash

# Motion GIF Creation Script
# Save this as /config/scripts/create_motion_gif.sh
# Make it executable with: chmod +x /config/scripts/create_motion_gif.sh

SNAPSHOT_FOLDER="$1"
NUM_SNAPSHOTS="$2"
OUTPUT_GIF="$3"
GIF_DELAY="$4"

# Check if required parameters are provided
if [ -z "$SNAPSHOT_FOLDER" ] || [ -z "$NUM_SNAPSHOTS" ] || [ -z "$OUTPUT_GIF" ] || [ -z "$GIF_DELAY" ]; then
    echo "Usage: $0 <snapshot_folder> <num_snapshots> <output_gif> <gif_delay>"
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick (convert command) is not installed. Installing..."
    # For Home Assistant OS/Container, you might need to install via apk
    apk add --no-cache imagemagick 2>/dev/null || echo "Could not install ImageMagick automatically"
    exit 1
fi

# Create the directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_GIF")"

# Build the input file list
INPUT_FILES=""
for i in $(seq 1 "$NUM_SNAPSHOTS"); do
    SNAPSHOT_FILE="$SNAPSHOT_FOLDER/snapshot_$i.jpg"
    if [ -f "$SNAPSHOT_FILE" ]; then
        INPUT_FILES="$INPUT_FILES $SNAPSHOT_FILE"
    else
        echo "Warning: $SNAPSHOT_FILE not found"
    fi
done

# Create the GIF with ImageMagick
# -delay uses centiseconds (1/100th of a second)
# -loop 0 = infinite loop
# -resize 50% = reduce size for better mobile performance
if [ -n "$INPUT_FILES" ]; then
    magick -delay "$GIF_DELAY" $INPUT_FILES -loop 0 -resize 50% "$OUTPUT_GIF"
    
    if [ $? -eq 0 ]; then
        echo "GIF created successfully: $OUTPUT_GIF with delay ${GIF_DELAY} centiseconds"
        # Optional: Clean up individual snapshots to save space
        # rm $INPUT_FILES
    else
        echo "Error creating GIF"
        exit 1
    fi
else
    echo "No snapshot files found"
    exit 1
fi
