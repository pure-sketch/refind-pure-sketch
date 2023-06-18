#!/bin/bash

# Paths to SVG directories
declare -A SVG_DIRS=(
  ["big"]="./svg/big"
  ["small"]="./svg/small"
)

# Path to the target directory
TARGET_DIR="./icons"

# Array of sizes for the PNG images
SIZES=(128 192 256 384 512)
SMALL_DIVISOR=5

# Check for the presence of the rsvg-convert command (part of librsvg)
if ! command -v rsvg-convert &>/dev/null; then
  echo "librsvg is not installed. Please install it before running this script."
  exit 1
fi

# Function to convert SVG files to PNG format
process_files() {
  local input_dir=$1
  local size_divisor=$2

  # Process each SVG file in the input directory
  for svg_file in "$input_dir"/*.svg; do
    local basename=$(basename "$svg_file" .svg)

    # Create PNG images of different sizes
    for size in "${SIZES[@]}"; do
      local new_size=$((size/size_divisor))
      local output_dir="$TARGET_DIR/$size-$((size/$SMALL_DIVISOR))"
      local output_file="$output_dir/$basename.png"

      # Create the output directory if it does not exist
      mkdir -p "$output_dir"

      # Convert the SVG file to a PNG image
      if ! rsvg-convert -w "$new_size" -h "$new_size" "$svg_file" -o "$output_file"; then
        echo "An error occurred while converting $svg_file to $output_file"
        exit 1
      fi
    done
  done
}

# Convert SVG files from both the "big" and "small" directories
for dir in "${!SVG_DIRS[@]}"; do
  divisor=1
  [[ $dir == "small" ]] && divisor=$SMALL_DIVISOR
  process_files "${SVG_DIRS[$dir]}" "$divisor"
done
