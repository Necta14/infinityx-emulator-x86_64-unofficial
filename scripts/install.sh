#!/usr/bin/env bash
# Installs the UNOFFICIAL Infinity X 4.1 x86_64 emulator image into your Android SDK
# and creates an AVD called "InfinityX". Linux and Intel macOS (x86_64 hosts only).
#
# Usage: ./install.sh /path/to/InfinityX-4.1-UNOFFICIAL-emulator-x86_64-20261024.tar.zst
set -euo pipefail

ARCHIVE=${1:-}
EXPECTED_SHA256=e6aafcddcfd24e1204c0ea35f10cfa737d955147a40bc75831d5651b0816df60
API=37
TAG=infinityx
AVD_NAME=${AVD_NAME:-InfinityX}

die() { echo "error: $*" >&2; exit 1; }

[ -n "$ARCHIVE" ] && [ -f "$ARCHIVE" ] || die "usage: $0 <path to the .tar.zst from the release page>"
case "$(uname -m)" in x86_64|amd64) ;; *) die "this image is x86_64 only; your host is $(uname -m)" ;; esac
command -v zstd >/dev/null || die "zstd is required (e.g. 'sudo pacman -S zstd', 'sudo apt install zstd', 'brew install zstd')"

SDK=${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}
[ -x "$SDK/emulator/emulator" ] || die "Android Emulator not found in $SDK (set ANDROID_SDK_ROOT)"

echo "==> Verifying SHA-256 (this takes a few seconds)"
if command -v sha256sum >/dev/null; then got=$(sha256sum "$ARCHIVE" | cut -d' ' -f1)
else got=$(shasum -a 256 "$ARCHIVE" | cut -d' ' -f1); fi
[ "$got" = "$EXPECTED_SHA256" ] || die "checksum mismatch: got $got"

DEST="$SDK/system-images/android-$API/$TAG"
[ -e "$DEST/x86_64" ] && die "$DEST/x86_64 already exists; remove it first if you want to reinstall"
mkdir -p "$DEST"
echo "==> Extracting to $DEST (about 9.4 GB)"
tar -I zstd -xf "$ARCHIVE" -C "$DEST"
[ -f "$DEST/x86_64/system.img" ] || die "extraction failed: system.img missing"

AVD_HOME=${ANDROID_AVD_HOME:-$HOME/.android/avd}
[ -e "$AVD_HOME/$AVD_NAME.avd" ] && die "AVD $AVD_NAME already exists (set AVD_NAME=otherName)"
mkdir -p "$AVD_HOME/$AVD_NAME.avd"
cat > "$AVD_HOME/$AVD_NAME.ini" <<EOF
avd.ini.encoding=UTF-8
path=$AVD_HOME/$AVD_NAME.avd
path.rel=avd/$AVD_NAME.avd
target=android-$API
EOF
cat > "$AVD_HOME/$AVD_NAME.avd/config.ini" <<EOF
AvdId=$AVD_NAME
avd.ini.displayname=Infinity X 4.1 (UNOFFICIAL, Android 17)
abi.type=x86_64
hw.cpu.arch=x86_64
hw.cpu.ncore=4
hw.ramSize=4096
vm.heapSize=512
image.sysdir.1=system-images/android-$API/$TAG/x86_64/
tag.id=$TAG
tag.display=Infinity X (unofficial)
disk.dataPartition.size=8G
hw.lcd.width=1080
hw.lcd.height=2400
hw.lcd.density=440
hw.keyboard=yes
hw.gpu.enabled=yes
hw.gpu.mode=auto
PlayStore.enabled=false
showDeviceFrame=no
EOF

echo
echo "Done. Start it with:"
echo "  $SDK/emulator/emulator -avd $AVD_NAME"
echo "If the screen stays black, try:  -gpu host   (or -gpu swiftshader_indirect)"
