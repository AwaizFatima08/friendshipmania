#!/bin/bash
# Rebuilds the launcher-icon sources and the Play Store graphics from the
# approved homidev art in assets/images/. Needs ImageMagick + Inkscape.
#   cd assets/icon && ./build_store_graphics.sh && (cd ../.. && dart run flutter_launcher_icons)
set -e
cd "$(dirname "$0")"
IMG=../images
B=.build; mkdir -p $B
convert $IMG/20261010-1125-friendshipmania-icon-01_cutout.png -trim +repage $B/mascot.png
for n in 1125-friendshipmania-icon-02 1126-friendshipmania-icon-01 1127-friendshipmania-icon-01 1127-friendshipmania-icon-02; do
  convert $IMG/20261010-${n}_cutout.png -trim +repage $B/st_$n.png
done
inkscape icon_background.svg --export-type=png --export-filename=icon_background.png -w 1024 -h 1024 >/dev/null 2>&1
# Adaptive foreground: mascot inside the ~61% safe circle.
convert -size 1024x1024 xc:none \( $B/mascot.png -resize 420x511 \) -gravity center -composite icon_foreground.png
# Legacy / Play icon: lime background + soft shadow + larger mascot.
convert icon_background.png \
  \( $B/mascot.png -resize 640x780 -background '#3a1a6e' -shadow 40x14+0+18 \) -gravity center -geometry +0+14 -composite \
  \( $B/mascot.png -resize 640x780 \) -gravity center -composite icon_flat.png
convert icon_flat.png -resize 512x512 ../../graphics/store/app_icon_512.png
inkscape feature_graphic.svg --export-type=png --export-filename=../../graphics/store/feature_graphic.png -w 1024 -h 500 >/dev/null 2>&1
convert ../../graphics/store/feature_graphic.png -background '#7C5CF0' -alpha remove -alpha off ../../graphics/store/feature_graphic.png
echo "built: icon_background.png icon_foreground.png icon_flat.png, graphics/store/{app_icon_512,feature_graphic}.png"
