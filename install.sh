#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

echo "Select theme size:"
echo "1. Very small 128-25"
echo "2. Small 192-38"
echo "3. Medium 256-51 (Recommended for 1920x1080)"
echo "4. Large 384-76"
echo "5. Very large 512-102"
echo "Enter your choice (1-5): "
read choice

case "$choice" in
  1)
    ICON_SIZE="128-25"
    FONT_SIZE="10"
    ;;
  2)
    ICON_SIZE="192-38"
    FONT_SIZE="12"
    ;;
  3)
    ICON_SIZE="256-51"
    FONT_SIZE="14"
    ;;
  4)
    ICON_SIZE="384-76"
    FONT_SIZE="20"
    ;;
  5)
    ICON_SIZE="512-102"
    FONT_SIZE="28"
    ;;
  *)
    echo "Invalid choice. Please choose a number between 1 and 5."
    exit 1
    ;;
esac

THEME_DIR="/boot/efi/EFI/refind/themes/refind-pure-sketch"
ICON_DIR="$THEME_DIR/icons/${ICON_SIZE}"
FONT_DIR="$THEME_DIR/fonts"

if [ ! -d "/boot/efi/EFI/refind" ]; then
  echo "/boot/efi/EFI/refind does not exist. Please make sure refind is installed."
  exit 1
fi

if [ -d "$THEME_DIR" ]; then
  rm -r "$THEME_DIR"
fi

mkdir -p "$ICON_DIR"
mkdir -p "$FONT_DIR"
cp icons/${ICON_SIZE}/* "$ICON_DIR"
cp fonts/font-${FONT_SIZE}.png "$FONT_DIR"

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
selection_big themes/refind-pure-sketch/icons/${ICON_SIZE}/selection-big.png
selection_small themes/refind-pure-sketch/icons/${ICON_SIZE}/selection-small.png

# FONT
font themes/refind-pure-sketch/fonts/font-${FONT_SIZE}.png
EOF

cp theme.conf "$THEME_DIR"

# Adding line to refind.conf
echo "include themes/refind-pure-sketch/theme.conf" | sudo tee -a /boot/efi/EFI/refind/refind.conf > /dev/null

echo "Theme installed successfully!"
