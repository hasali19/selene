#!/usr/bin/env bash

set -eoux pipefail

echo "::group::Executing build-watermark"
trap 'echo "::endgroup::"' EXIT

# renders the plymouth watermark from the selene wordmark logo, so it never
# drifts out of sync with the SVG it's derived from. Must run before
# build-initramfs.sh: dracut bakes the plymouth theme into the initramfs.

dnf5 install -y librsvg2-tools

# rsvg-convert can't load the @font-face embedded (as a woff2 data URI) in
# the logo SVG, so install the same font as a real font for it to find.
install -Dm644 /ctx/branding/Audiowide-Regular.ttf /usr/share/fonts/audiowide/Audiowide-Regular.ttf
fc-cache -f >/dev/null

mkdir -p /usr/share/plymouth/themes/spinner
rsvg-convert -w 300 -h 72 /ctx/branding/logo-dark.svg -o /usr/share/plymouth/themes/spinner/watermark.png

# both the font and the SVG renderer are only needed to produce the PNG above
rm -rf /usr/share/fonts/audiowide
fc-cache -f >/dev/null
dnf5 remove -y librsvg2-tools
