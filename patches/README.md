# Patches

Generated with `git format-patch` against the upstream files on 2026-10-24.
Apply with `scripts/apply-fixes.sh` or `git am` inside each repository.

| File | Repository | Status |
|---|---|---|
| `vendor_infinity/0001-…` | `vendor/infinity` (ProjectInfinity-X/vendor_infinity, branch 17) | Suitable for upstream |
| `vendor_infinity/0002-LOCAL-ONLY-…` | `vendor/infinity` | **Do not merge.** Only reproduces the published config |
| `device_generic_goldfish/0001-…` | `device/generic/goldfish` (LineageOS, lineage-24.0) | Emulator-only workaround |

Not a patch: `export INFINITY_BUILD=emu64x` after `lunch` (see ../BUILD.md, item 4).
