#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

echo "Select theme color:"
echo "1. Light"
echo "2. Dark"
echo "Enter your choice (1-2): "
read theme_choice

echo "Select theme size:"
echo "1. Very small 128-25px"
echo "2. Small 192-38px"
echo "3. Medium 256-51px (Recommended for 1920x1080)"
echo "4. Large 384-76px"
echo "5. Very large 512-102px"
echo "Enter your choice (1-5): "
read size_choice

case "$size_choice" in
  1)
    ICON_SIZE="128-25"
    FONT_SIZE="12"
    ;;
  2)
    ICON_SIZE="192-38"
    FONT_SIZE="14"
    ;;
  3)
    ICON_SIZE="256-51"
    FONT_SIZE="16"
    ;;
  4)
    ICON_SIZE="384-76"
    FONT_SIZE="24"
    ;;
  5)
    ICON_SIZE="512-102"
    FONT_SIZE="32"
    ;;
  *)
    echo "Invalid choice. Please choose a number between 1 and 5."
    exit 1
    ;;
esac

THEME_DIR="/boot/efi/EFI/refind/themes/refind-pure-sketch"
ICON_DIR="$THEME_DIR/icons/${ICON_SIZE}"
FONT_DIR="$THEME_DIR/fonts"
FONT_SUFFIX=""

if [ ! -d "/boot/efi/EFI/refind" ]; then
  echo "/boot/efi/EFI/refind does not exist. Please make sure refind is installed."
  exit 1
fi

if [ -d "$THEME_DIR" ]; then
  rm -r "$THEME_DIR"
fi

mkdir -p "$ICON_DIR"
mkdir -p "$FONT_DIR"

if [[ "$theme_choice" -eq 2 ]]; then
  cp icons/${ICON_SIZE}/*_dark.png "$ICON_DIR"
  for dark_icon in "$ICON_DIR"/*_dark.png; do
    mv "$dark_icon" "${dark_icon%_dark.png}.png"
  done
  FONT_SUFFIX="_dark"
else
  cp icons/${ICON_SIZE}/*[!_dark].png "$ICON_DIR"
fi

cp fonts/font_${FONT_SIZE}${FONT_SUFFIX}.png "$FONT_DIR"/font_${FONT_SIZE}.png

cat > theme.conf <<EOF
# Theme by Zalimannard

# ICON
icons_dir themes/refind-pure-sketch/icons/${ICON_SIZE}

# ICON SIZE
big_icon_size ${ICON_SIZE%%-*}
small_icon_size ${ICON_SIZE##*-}

# BACKGROUND IMAGE
banner themes/refind-pure-sketch/icons/${ICON_SIZE}/bg.png

# SELECTION IMAGE
selection_big themes/refind-pure-sketch/icons/${ICON_SIZE}/selection_big.png
selection_small themes/refind-pure-sketch/icons/${ICON_SIZE}/selection_small.png

# FONT
font themes/refind-pure-sketch/fonts/font_${FONT_SIZE}.png
EOF

cp theme.conf "$THEME_DIR"

# Removing line if it already exists in refind.conf
sudo sed -i '/include themes\/refind-pure-sketch\/theme.conf/d' /boot/efi/EFI/refind/refind.conf

# Adding line to the end of refind.conf
echo "include themes/refind-pure-sketch/theme.conf" | sudo tee -a /boot/efi/EFI/refind/refind.conf > /dev/null
echo "Theme added to refind.conf"

echo "Theme installed successfully!"
