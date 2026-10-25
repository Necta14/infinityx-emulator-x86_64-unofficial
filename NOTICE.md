# Notice

This repository distributes an **unofficial** build of Project Infinity X for the
Android Emulator. It is not affiliated with, endorsed by or supported by the
Project Infinity X team, LineageOS, Google or the Android Open Source Project.

## Sources

The image was built from the public sources below, at their state on 2026‑10‑24,
plus the patches in [`patches/`](patches/):

* Project Infinity X manifest, branch `17`: https://github.com/ProjectInfinity-X/manifest
  (pulls in AOSP, LineageOS and Project Infinity X repositories)
* `vendor/infinity`: https://github.com/ProjectInfinity-X/vendor_infinity (branch `17`)
* `device/generic/goldfish`: https://github.com/LineageOS/android_device_generic_goldfish (branch `lineage-24.0`)

## Linux kernel (GPL-2.0)

The image contains the prebuilt emulator kernel shipped in the source tree
(`kernel-ranchu`):

```
6.12.58-android16-6-gccafb60de224-ab14828483 (kleaf@build-host) #1 SMP PREEMPT Tue Feb 3 2026
```

Its complete corresponding source is the Android Common Kernel, branch
`android16-6.12`, commit `ccafb60de224` (Android CI build `14828483`):
https://android.googlesource.com/kernel/common/

If you can't get it from there, open an issue in this repository and the
corresponding source will be provided.

## Other components

Most of the userspace is licensed under Apache-2.0; other components use their own
licenses (BSD, MIT, GPL, LGPL and others). The license texts are in the
corresponding source repositories listed above. The image also contains
third-party resources (fonts, sounds, wallpapers, icons) that belong to their
respective owners and are redistributed as included in the Infinity X sources.

If you are a rights holder and want something removed, please open an issue.
