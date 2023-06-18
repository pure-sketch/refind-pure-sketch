#!/bin/bash

# Customizable parameters
FONT_NAME="JetBrains-Mono-Regular"
VERTICAL_OFFSET_PERCENT=83
FONT_SIZES=(10 12 14 20 28)

# Check if ImageMagick and the font are installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick could not be found, please install it first."
    exit
elif ! convert -list font | grep -P "^  Font: $FONT_NAME$" > /dev/null; then
    echo "The font '$FONT_NAME' could not be found, please install it first."
    exit
fi

# Create output directory
mkdir -p "fonts"

# ASCII characters
CHARS='  !"$%&\()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'

# Generate an image for each font size
for FONT_SIZE in "${FONT_SIZES[@]}"; do
    HEIGHT="$FONT_SIZE"
    OUTPUT_PNG="fonts/font-$FONT_SIZE.png"

    # Compute character and image dimensions
    CHAR_WIDTH=$((HEIGHT * 60 / 100))
    WIDTH=$((CHAR_WIDTH * 96))

    # Initialize an array to store all convert commands
    convert_commands=()

    # Prepare the command for creating the image with all the characters
    for (( i=0; i<${#CHARS}; i++ )); do
        X_POS=$((i * CHAR_WIDTH))
        Y_OFFSET=$((FONT_SIZE * VERTICAL_OFFSET_PERCENT / 100))
        CHAR=${CHARS:$i:1}
        convert_commands+=("-font" "$FONT_NAME" "-pointsize" "$FONT_SIZE" "-draw" "text $X_POS,$Y_OFFSET '$CHAR'")
    done

    # Execute the commands
    if ! convert -size "${WIDTH}x${HEIGHT}" xc:transparent "${convert_commands[@]}" "$OUTPUT_PNG"; then
        echo "Error creating image for font size $FONT_SIZE"
        exit 1
    fi
done
