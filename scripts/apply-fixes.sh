#!/usr/bin/env bash
# Applies the emulator fixes to a synced Infinity X (branch 17) source tree.
# Usage: ./apply-fixes.sh /path/to/infinity-x-source [--with-local-only]
set -euo pipefail
TOP=${1:?path to the Infinity X source tree}
HERE=$(cd "$(dirname "$0")/.." && pwd)

git -C "$TOP/vendor/infinity" am "$HERE"/patches/vendor_infinity/0001-*.patch
git -C "$TOP/device/generic/goldfish" am "$HERE"/patches/device_generic_goldfish/0001-*.patch

if [ "${2:-}" = "--with-local-only" ]; then
  # Only needed to reproduce the published image's configuration exactly.
  git -C "$TOP/vendor/infinity" am "$HERE"/patches/vendor_infinity/0002-*.patch
fi

cat <<'EOF'
Patches applied. Remaining build-time step (not a patch):

  source build/envsetup.sh
  lunch infinity_sdk_phone_x86_64-userdebug
  export INFINITY_BUILD=emu64x     # see BUILD.md, "Duplicate ro.infinity.device"
  m
  ./scripts/pack-emulator-image.sh out/target/product/emu64x ./dist
EOF
