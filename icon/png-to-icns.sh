#!/usr/bin/env bash
set -euo pipefail

in_png="${1:?usage: $0 input.png output.icns}"
out_icns="${2:?usage: $0 input.png output.icns}"

tmp="$(mktemp -d /tmp/png-to-icns.XXXXXX)"
iconset="$tmp/icon.iconset"
mkdir -p "$iconset"

make_icon() {
  local size="$1"
  local name="$2"
  sips -z "$size" "$size" "$in_png" --out "$iconset/$name" >/dev/null
}

make_icon 16   icon_16x16.png
make_icon 32   icon_16x16@2x.png
make_icon 32   icon_32x32.png
make_icon 64   icon_32x32@2x.png
make_icon 128  icon_128x128.png
make_icon 256  icon_128x128@2x.png
make_icon 256  icon_256x256.png
make_icon 512  icon_256x256@2x.png
make_icon 512  icon_512x512.png
make_icon 1024 icon_512x512@2x.png

iconutil -c icns "$iconset" -o "$out_icns"

sips -g pixelWidth -g pixelHeight "$out_icns"
file "$out_icns"
