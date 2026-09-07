# Release verification — 2026-09-07

This record distinguishes build checks performed for public-release preparation
from earlier observations on the physical boxes. No device was flashed, no new
hardware test was performed, and no CAD geometry was changed for this release.

## Firmware source and revision policy

The integration branch is `mgoodfellow/ESPuino:s3-test-all`. Its remote head was
checked as `1a05eb639a6ce0b5cc940e7807475c8ecf20d1d5` on 2026-09-07. The
build results below apply to the profile locks, not that newer integration head.
Naming the branch explicitly in the clone instructions does not change those
locks or the validation scope.

## Firmware build checks

Builds use separate clean firmware checkouts at the profile's locked revision,
with the local PlatformIO package/download cache. This is not a test on a new OS
installation or a guarantee of byte-for-byte reproducibility across machines.

| Profile | Firmware commit | Toolchain | Result |
|---|---|---|---|
| S3 N16R8 | `f3eec352659eb7cc195b3059cfd3d398ac1d0412` | pioarduino 55.03.38-1 | PASS with the dependency repair below |
| LOLIN D32 Pro | `1ea941446cd99b495cf6df2a16b6b230b3379f5a` | pioarduino 55.03.39 | PASS |

### S3 dependency repair

The first fresh S3 build failed at `NeoPixelBus.h`: the locked firmware includes
that header but omits its library declaration. The profile now inherits
`${env.lib_deps}` and adds NeoPixelBus commit
`fd670ee534064ddf5765e4db63c213ba05bbe880` (v2.8.4), matching the dependency
in the D32 firmware. The firmware lock and hardware feature settings are unchanged.
Remove this extra declaration if a future firmware revision supplies it itself.

The repaired build passed. Its generated SDK configuration contains:

- `CONFIG_SPIRAM_MODE_OCT=y`
- `CONFIG_SPIRAM_BOOT_INIT=y`
- `CONFIG_SPIRAM_SPEED_40M=y`

Embedded revision: `f3eec35` (no `-dirty` suffix).
Application flash usage: 3,041,823 / 6,553,600 bytes.
Application binary SHA-256:
`931f7361b0ead7584fb790cfa7838001ecdfa62ecf9251a354ee464f2d57d814`.
This checksum records the local validation artifact; no firmware binary is
included in the public snapshot. Compiler warnings remain in the pinned firmware
and libraries; successful compilation is not a warning-free or hardware verdict.

### D32 result

The pinned D32 build passed with embedded revision `1ea9414` (no `-dirty`
suffix). Application flash usage: 3,450,199 / 6,553,600 bytes.
Application binary SHA-256:
`a703859ddf7e354cce0720a0914641c97c34f1667aac123bb0cfda75dde84e7c`.

During the build, PlatformIO modified `dependencies.lock` and its pre-build
script deleted the tracked `sdkconfig.defaults.esp32s3` file in this isolated D32
checkout. The embedded revision was generated while the source tree was clean.
A later build/upload can therefore embed a `-dirty` suffix unless the source
state is deliberately reconciled. Do not discard unrelated edits in a working
checkout to hide this; use a dedicated clean checkout when recording artifacts.

## Deployment script

`bash -n deploy.sh` and `python3 tests/test_deploy.py` pass. Six tests use temporary
Git repositories and a fake PlatformIO executable, without network or hardware:

- Missing upload port stops before building or copying settings.
- An explicit upload port reaches PlatformIO as a single argument.
- SDK options dropped once are restored before upload.
- Persistently missing SDK options prevent upload.
- `sync` rejects staged changes and preserves the checkout.
- `sync` accepts a clean checkout.

Upload now requires a third argument: `./deploy.sh <profile> upload <port>`.
The script still copies profile overrides into the target checkout and does not
remove files from a previously selected profile; use a separate checkout per box.

## Documentation, privacy and enclosure assets

- Superseded handoffs and personal network/device identifiers were removed from
  the public tree. A fresh publication snapshot omits the old private history.
- Local Markdown links were checked against the files in the release snapshot.
- Text was scanned for credential/key patterns and known private identifiers.
  No obvious credentials were found; the profiles retain only the intentional
  empty password for the initial ESPuino setup access point. This is a bounded
  review, not a guarantee that every possible secret format is detectable.
- PNG ancillary metadata was inspected: sRGB plus EXIF pixel dimensions, with no
  location, camera or author fields. STL files are ASCII OpenSCAD exports.
- OpenSCAD geometry is unchanged after removing comments/whitespace from the
  comparison. Existing STL exports were retained, not regenerated or newly printed.
  OpenSCAD was not available for a fresh render during this preparation.

## Hardware evidence and limits

The original development notes record S3 boot, PSRAM, SD/audio, RC522, LED,
encoder, button-wake and OTA observations, plus D32 wiring/fit work. They do not
constitute new hardware verification of this release. In particular, the S3
fresh-build dependency repair has not been re-flashed and checked on hardware.

PN5180 remains experimental. Other clones, batteries, headphone detection,
4-bit SD_MMC and current upstream firmware branches are outside this validation.
The main intended use is a reproducible starting point for the documented boards.
