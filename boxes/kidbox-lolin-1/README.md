# LOLIN D32 Pro V2.0.0 reference build

USB-powered WeMos LOLIN D32 Pro V2.0.0 with 16MB flash, WROVER PSRAM and
onboard SPI microSD. Uses RC522, MAX98357A, a 12-pixel ring, EC11 and three buttons.

- [Build guide](../../docs/espuino-build-guide.md)
- [Wiring, resistors and wake circuit](wiring.md)
- [Firmware revision](upstream.lock): `1ea941446cd99b495cf6df2a16b6b230b3379f5a`
  from [mgoodfellow/ESPuino](https://github.com/mgoodfellow/ESPuino/commit/1ea941446cd99b495cf6df2a16b6b230b3379f5a).
- Ongoing firmware integration: [`s3-test-all`](https://github.com/mgoodfellow/ESPuino/tree/s3-test-all).
  The lock above selects an older recorded snapshot, not the moving branch head.
- Environment: `lolin_d32_pro` (`HAL=4`), not `lolin_d32_pro_sdmmc_pe`.

The profile includes the upstream HAL 4 map, then overrides the encoder switch
to GPIO22 and uses GPIO32 as a dedicated wake line. Follow the wiring table for
the external resistor and diode requirements. In particular, encoder A/B on
GPIO34/39 need pull-downs to GND; the button on GPIO36 needs a pull-up to 3V3.

Classic Bluetooth is enabled in this profile. Battery measurement and headphone
detection are disabled. LED output uses NeoPixelBus I2S1 in the pinned firmware.
Hardware wiring and fit observations are recorded in the accompanying notes;
see [release validation](../../docs/VALIDATION.md) for the current build checks.
