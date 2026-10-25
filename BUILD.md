# Building the x86_64 emulator image yourself

This is exactly how the published image was produced on 2026‑10‑24, including the
problems hit along the way, so you can reproduce it or fix the target upstream.

## Environment used

| | |
|---|---|
| Host | AWS EC2 `m6id.4xlarge`: 16 vCPU Xeon Platinum 8375C, 64 GB RAM, local NVMe |
| OS | Ubuntu 24.04.5 LTS, plus 32 GB of swap as a safety net |
| Source | `ProjectInfinity-X/manifest`, branch `17` (Infinity X **4.1**, Android 17, security patch 2026‑10‑01) |
| Sync | `repo init --depth=1 --git-lfs …`, which uses ~138 GB on disk after checkout |
| Build | `lunch infinity_sdk_phone_x86_64-userdebug`, `WITH_GAPPS=false` |
| Time | full build ~3 h 35 min at 16 threads; output ~225 GB including `out/` |

Smaller machines work, but give the build **at least 32 GB of RAM plus swap** and
~400 GB of disk.

## Steps

```bash
repo init --depth=1 --no-repo-verify --git-lfs \
  -u https://github.com/ProjectInfinity-X/manifest -b 17 \
  -g default,-mips,-darwin,-notdefault
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j16

/path/to/this/repo/scripts/apply-fixes.sh "$PWD"      # patches/, see below

export WITH_GAPPS=false
source build/envsetup.sh
lunch infinity_sdk_phone_x86_64-userdebug
export INFINITY_BUILD=emu64x
m -j16
/path/to/this/repo/scripts/pack-emulator-image.sh out/target/product/emu64x ./dist
```

## What was broken, and why

1. **`lunch` fails.** `vendor/infinity/build/target/product/infinity_sdk_phone_x86_64.mk`
   still includes `lineage_generic_target.mk`, which does not exist in
   `vendor/infinity`. The right file is `infinity_generic_target.mk`.
   `PRODUCT_NAME`/`PRODUCT_MODEL` were also still LineageOS's.
   → `patches/vendor_infinity/0001-*.patch`
   *Side effect worth knowing:* when lunch fails, the build silently falls back to
   another product. That product does not get `vendor/infinity/config/common.mk`,
   which normally excludes `prebuilts/misc/protobuf_vendorcompat` from Soong. You
   then also see `module "prebuilt_libprotobuf-cpp-full-21.12-vendorcompat" already
   defined`. Once lunch is fixed, that second error does not happen. (During the
   original build, that `Android.bp` was disabled by hand before the real cause
   was found. It is not needed.)

2. **`Device makefile produces files inside generic_system.mk's artifact path
   requirement`** for `system/priv-app/OmniStyle`. Even `relaxed` enforcement
   aborts Soong here, so the target uses `false`. Emulator only, harmless.
   → same patch.

3. **`TARGET module FaceUnlock requires non-existent TARGET module: libMegviiUnlock`**
   (and three more). The Megvii prebuilts are ARM-only. Setting
   `TARGET_FACE_UNLOCK_SUPPORTED := false` in the product makefile was **not**
   enough. What fixed it was `BUILD_BROKEN_MISSING_REQUIRED_MODULES := true` in
   the emulator's `BoardConfig.mk`.
   → `patches/device_generic_goldfish/0001-*.patch`
   `patches/vendor_infinity/0002-*` changes the FaceUnlock default for **every**
   device. It was applied in the published build but is marked LOCAL ONLY and
   must not go upstream.

4. **`error: found duplicate sysprop assignments: ro.infinity.device=emu64x /
   ro.infinity.device=sdk_phone_x86_64`** at ~89 %. `gen_build_prop.py` writes
   `ro.infinity.device=<TARGET_DEVICE>` (`emu64x`), while `config/version.mk`
   writes `ro.infinity.device=$(INFINITY_BUILD)`. `build/envsetup.sh` derives
   `INFINITY_BUILD` from the product name (`sdk_phone_x86_64`). On real devices
   both are the codename, so nobody noticed. Duplicates with the **same** value
   are allowed, so `export INFINITY_BUILD=emu64x` after `lunch` fixes it. A
   proper upstream fix would make `version.mk` and `gen_build_prop.py` agree.

5. **`m emu_img_zip` → `unknown target "emu_img_zip"`.**
   `device/generic/goldfish/build/tasks.workaround/emu_img_zip.mk` only defines it
   for `lineage_sdk_% sdk_% gcar_%` products.
   `scripts/pack-emulator-image.sh` follows the same recipe by hand.

## Ideas for upstream

* Fix the generic targets in `vendor_infinity` (the GSI x86_64 target has the same
  `lineage_generic_target.mk` include).
* Add `infinity_sdk_%` to the `emu_img_zip.mk` filter, or ship an equivalent rule.
* Make `ro.infinity.device` come from a single place.
