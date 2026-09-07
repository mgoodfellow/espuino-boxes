# ESP32-S3 DevKitC-1 N16R8 reference build

A USB-powered generic DevKitC-1 clone with 16MB quad flash and 8MB octal PSRAM,
SPI microSD, MAX98357A, RC522, 12-pixel WS2812B ring, EC11 and three buttons.
The directory name `s3-proto` is retained for existing deployment commands.

- [Build guide](../../docs/espuino-build-guide.md)
- [Wiring and hardware caveats](wiring.md)
- [Firmware revision](upstream.lock): `f3eec352659eb7cc195b3059cfd3d398ac1d0412`
  from [mgoodfellow/ESPuino](https://github.com/mgoodfellow/ESPuino/commit/f3eec352659eb7cc195b3059cfd3d398ac1d0412).
- Ongoing firmware integration: [`s3-test-all`](https://github.com/mgoodfellow/ESPuino/tree/s3-test-all).
  The lock above selects an older recorded snapshot, not the moving branch head.
- Environment: `esp32-s3-devkitc-1`, custom pin map (`HAL=99`).

## What the profile supplies

| Setting | Purpose |
|---|---|
| Explicit pioarduino `55.03.38-1` platform URL | Avoids the bare `espressif32` name resolving to a different toolchain |
| Pinned NeoPixelBus v2.8.4 dependency | Repairs the missing dependency declaration in the recorded firmware revision |
| `lib_ignore = ESP32-A2DP` and Bluetooth disabled | Keeps the Classic Bluetooth dependency out of S3 compilation |
| `qio_opi`, 16MB flash, `BOARD_HAS_PSRAM` | Describes this N16R8 memory arrangement |
| `CONFIG_SPIRAM_MODE_OCT=y` | Selects octal PSRAM |
| `CONFIG_SPIRAM_BOOT_INIT=y` | Initializes PSRAM before code/data placed there are used |
| `CONFIG_SPIRAM_SPEED_40M=y` | Retains the stable setting found for this particular clone |
| `custom_16mb_ota.csv` and OTA build flag | Enables both the partition layout and web OTA handler |

This firmware builds Arduino as an ESP-IDF component: `qio_opi` alone is not a
replacement for the SDK defaults. Verify about 8MB PSRAM in the boot log.
The 40MHz setting is a board-specific workaround; it does not establish that all
N16R8 boards require that speed.

## Recorded hardware experience

Development notes record successful boot, SD/audio playback, RC522 detection,
LED operation, encoder control and button wake. The pinned S3 revision was
recorded as running after web OTA in August 2026. These are historical hardware
observations; see [release validation](../../docs/VALIDATION.md) for checks run
while preparing this release.

The pinned firmware uses NeoPixelBus LCD/GDMA output for the S3 ring, retaining
FastLED animation/color math. Earlier SPI/RMT attempts encountered bus conflicts
or driver failures. Do not follow the old RMT port experiments as current setup
instructions. Use the pinned revision before experimenting with newer drivers.

Classic Bluetooth/A2DP is unavailable on this S3. Batteries, headphone detection,
4-bit SD_MMC and external Bluetooth transmitters are not validated by this profile.
The optional PN5180 wiring remains experimental.
