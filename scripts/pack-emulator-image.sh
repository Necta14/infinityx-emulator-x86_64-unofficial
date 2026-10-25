#!/usr/bin/env bash
# Packs an emulator system image from a finished infinity_sdk_phone_x86_64 build.
#
# Why this exists: device/generic/goldfish/build/tasks.workaround/emu_img_zip.mk only
# defines the `emu_img_zip` target for products named lineage_sdk_* / sdk_* / gcar_*,
# so `m emu_img_zip` fails with "unknown target" for infinity_sdk_*. This script
# follows the same recipe by hand.
#
# Usage (from the root of the source tree, after `m`):
#   ./pack-emulator-image.sh out/target/product/emu64x OUTPUT_DIR
set -euo pipefail
P=${1:?product out dir, e.g. out/target/product/emu64x}
OUT=${2:?output directory}
WORK=$(mktemp -d)
D="$WORK/x86_64"
mkdir -p "$D" "$OUT"

cp "$P/system/build.prop" "$P/VerifiedBootParams.textproto" "$P/advancedFeatures.ini" \
   "$P/kernel-ranchu" "$P/kernel_cmdline.txt" "$P/encryptionkey.img" "$D/"
cp --sparse=always "$P/system-qemu.img"  "$D/system.img"
cp                 "$P/ramdisk-qemu.img" "$D/ramdisk.img"
cp --sparse=always "$P/vendor-qemu.img"  "$D/vendor.img"
cp --sparse=always "$P/userdata.img"     "$D/userdata.img"
cp -r "$P/data" "$D/"

API=$(grep -m1 '^ro.build.version.sdk=' "$P/system/build.prop" | cut -d= -f2)
cat > "$D/source.properties" <<EOF
Pkg.Desc=Infinity X System Image API $API x86_64 (unofficial)
Pkg.Revision=1
AndroidVersion.ApiLevel=$API
SystemImage.Abi=x86_64
SystemImage.TagId=infinityx
SystemImage.TagDisplay=Infinity X
EOF

NAME="InfinityX-UNOFFICIAL-emulator-x86_64-$(date +%Y%m%d).tar.zst"
tar -C "$WORK" -I "zstd -19 -T0" -cf "$OUT/$NAME" x86_64
(cd "$OUT" && sha256sum "$NAME" > "$NAME.sha256")
echo "Wrote $OUT/$NAME"
