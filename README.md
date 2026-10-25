# Infinity X 4.1 · x86_64 emulator image (UNOFFICIAL)

> [!WARNING]
> **UNOFFICIAL. Not made, endorsed or supported by the Project Infinity X team.**
> A community build for **developers and themers** who want to test apps, features
> or UI changes on Infinity X quickly, without flashing a phone. Not for daily use,
> not for real devices. Please don't ask the official Infinity X groups for support
> with this image.

**Website:** https://necta14.github.io/infinityx-emulator-x86_64-unofficial/

| | |
|---|---|
| Base | Project Infinity X **4.1**, branch `17` |
| Android | **17** (API 37), security patch **2026‑10‑01** |
| Target | `infinity_sdk_phone_x86_64-userdebug`, vanilla (no GApps) |
| Kernel | 6.12.58 android16 (AOSP prebuilt `kernel-ranchu`) |
| Download | ~1.1 GB `.tar.zst`, ~9.4 GB once extracted |
| SHA‑256 | `e6aafcddcfd24e1204c0ea35f10cfa737d955147a40bc75831d5651b0816df60` |
| Built | 2026‑10‑24, from unmodified sources plus the patches in `patches/` |

## Quick start (Linux / Intel macOS)

Requirements: an **x86_64 host** with hardware virtualization (KVM / HVF), the
Android SDK with **Android Emulator 36+** (tested with 37.1.11), `zstd`, at least
8 GB of RAM (the AVD uses 4 GB) and ~10 GB of free disk space.

```bash
# 1. download the .tar.zst from the Releases page, then:
git clone https://github.com/Necta14/infinityx-emulator-x86_64-unofficial
cd infinityx-emulator-x86_64-unofficial
./scripts/install.sh ~/Downloads/InfinityX-4.1-UNOFFICIAL-emulator-x86_64-20261024.tar.zst

# 2. start it
$ANDROID_SDK_ROOT/emulator/emulator -avd InfinityX
```

The script checks the SHA‑256, extracts the image to
`$ANDROID_SDK_ROOT/system-images/android-37/infinityx/x86_64` and creates an AVD
called `InfinityX` (1080×2400, 440 dpi, 4 GB RAM, 8 GB data).

**Windows (untested):** extract the archive with a tool that supports Zstandard
(`tar` from Git Bash/WSL, PeaZip or 7‑Zip ZS) into
`%LOCALAPPDATA%\Android\Sdk\system-images\android-37\infinityx\`. Then create
`%USERPROFILE%\.android\avd\InfinityX.ini` and `InfinityX.avd\config.ini` with the
same contents `scripts/install.sh` writes. Needs WHPX or AEHD enabled.

**Apple Silicon Macs can't run this image**: it is x86_64 only.

## Tips

* **Black screen or glitches:** start with `-gpu host`, or `-gpu swiftshader_indirect` as a fallback.
* **Clean start:** `-wipe-data` resets the AVD; `-no-snapshot` forces a cold boot.
* **Fingerprint testing:** Extended controls (`…`) → *Fingerprint* has ten virtual
  fingers. Enroll several and test per-finger behaviour without hardware.
* **Freeform windows / sidebar, Infinity Suite, Launcher3, QS styles, lockscreen
  clocks** all work and are what this image is best for.
* **Root shell:** this is a `userdebug` build, so `adb root` is the usual first try.
* **No setup wizard:** that comes with GApps; this build is vanilla and boots
  straight to the launcher.
* **No personal data:** `userdata.img` is the pristine one from the build. No
  accounts, keys or user data are baked in.

## What does *not* work (by design)

No Google apps / Play Store · no FaceUnlock (ARM-only prebuilts) · no real camera,
Dolby, MIUI camera or other device-specific features · not signed with the official
Infinity X keys · no OTA updates. Bugs you find here may come from the emulator
target, not from Infinity X itself, so check on a real device before reporting
anything upstream.

## Building it yourself

See **[BUILD.md](BUILD.md)**: the full recipe and the five issues the emulator
target had, with the fixes in **[patches/](patches/)**:

| Patch | Repo | Upstream? |
|---|---|---|
| `0001-sdk_phone_x86_64-make-the-emulator-target-build-as-I…` | `vendor/infinity` | ✅ suitable |
| `0002-LOCAL-ONLY-DO-NOT-MERGE-common-default-FaceUnlock…` | `vendor/infinity` | ❌ local only |
| `0001-emu64x-tolerate-missing-ARM-only-required-modules` | `device/generic/goldfish` | ⚠️ emulator only |

## Credits & licenses

All the real work is by the **[Project Infinity X](https://projectinfinity-x.com)**
team and contributors, **LineageOS** and **AOSP**. This repo only adds the emulator
fixes, packaging and docs. Please support the official project.

Scripts and docs in this repository: Apache-2.0 (see `LICENSE`). The image itself
contains software under many licenses (Apache-2.0, GPL-2.0 for the kernel and
others) and third-party assets owned by their respective owners. See
**[NOTICE.md](NOTICE.md)**, including where to get the kernel source.
"Infinity X" and "Project Infinity X" are names of their respective owners and
are used here only to describe what this build is based on.
