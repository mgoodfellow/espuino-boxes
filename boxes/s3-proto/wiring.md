# s3-proto wiring — generic ESP32-S3 devkit N16R8

Board: generic ESP32-S3 DevKitC-1 clone, **N16R8** module = 16MB **quad** flash
+ 8MB **octal** PSRAM. Build env: `esp32-s3-devkitc-1` (HAL 99).

## Pin map

| Function | Signal | GPIO | Notes |
|---|---|---|---|
| SD card (SPI) | CLK | 12 | module VCC → **5V** (onboard reg needs 4.5–5.5V) |
| | MOSI | 11 | |
| | MISO | 13 | |
| | CS | 10 | |
| RC522 RFID (2nd SPI bus) | SCK | 5 | **3.3V only, never 5V** |
| | MOSI | 6 | |
| | MISO | 4 | |
| | CS | 7 | |
| | RST | 15 | |
| I2S → MAX98357A | BCLK | 16 | amp on 5V, mono, one speaker |
| | LRC/WS | 17 | |
| | DOUT | 18 | |
| NeoPixel ring | DIN | 21 | 330Ω in data line, ~1000µF across 5V, brightness ≤30–40% |
| Rotary encoder | CLK | 39 | common (middle pin) → **3V3**; pinned firmware applies INPUT_PULLDOWN |
| | DT | 40 | |
| | SW | 1 | switch (2-pin side) → GPIO 1 + GND, active-low; **RTC pin = deepsleep wake** (rewired from 41, 2026-07-05) |
| Button: next | — | 38 | |
| Button: previous | — | 42 | |
| Button: pause/play | — | 14 | **RTC pin = deepsleep wake** (rewired from 47, 2026-07-05) |

Pins **2/8/9** are reserved in the profile for the optional PN5180 IRQ/BUSY/RST.
GPIO41 is unused; GPIO47 is assigned to optional POWER control but is unwired.
Do not connect a button to a pin configured as a power-control output.
SD and RC522 are on **separate SPI buses** — the level-shifted SD module
doesn't reliably tri-state MISO.

## Reserved GPIOs on THIS board (N16R8) — never map

- **26–32** SPI flash
- **33–37** octal PSRAM extra data lines *(free on quad-PSRAM R2 boards — a
  common source of bad pinout advice; reserved here because R8 = octal)*
- **19, 20** USB-JTAG (native USB)
- **0, 3, 45, 46** strapping (46 also input-only)
- **43, 44** UART0 TX/RX
- **48** onboard RGB LED — **confirmed on 48 for this actual board**
  (2026-07-02 bare-sketch check: RGB cycles on 48, so GPIO 38 is safe for the
  NEXT button). Board also verified N16R8: eFuse reports 8MB embedded PSRAM +
  16MB quad flash; `ps_malloc(4MB)` OK; auto-reset flashing works on the COM
  port (CH343 → `/dev/ttyACM0`, ACM not ttyUSB).

## Build configuration

Follow the [S3 profile guide](README.md) and [build instructions](../../docs/espuino-build-guide.md).
This is a USB-powered build: battery measurement, headphone detection and
shutdown-on-SD-failure are disabled. Bluetooth must stay disabled.

Pause/play (GPIO14) and encoder press (GPIO1) are RTC-capable wake inputs. The
profile sets `WAKEUP_BUTTON_EXT1_MASK` for both. GPIO0 is deliberately excluded:
holding the BOOT strap low during wake can enter the serial bootloader.

## Check the clone's 5V supply routing

On the tested clone, the header marked **5V IN** was disconnected from USB VBUS
by an open IN/OUT solder jumper. The external SD module and amp had no supply
until that jumper was bridged. Other boards route power differently: identify
your board's circuit and confirm with a meter before applying this change.
On the modified board, do not simultaneously supply the 5V header externally
and connect USB; the jumper bypasses the original isolation.

## Troubleshooting from the tested build

| Symptom | What helped on this build |
|---|---|
| A2DP compile failure despite disabled Bluetooth | Add `lib_ignore = ESP32-A2DP`, as supplied by the profile |
| `NeoPixelBus.h` missing in a fresh build | Use the updated profile, which explicitly supplies the dependency omitted by its firmware pin |
| Missing PSRAM / very early boot failure | Check octal mode and boot initialization in the generated SDK config; confirm about 8MB in the boot log |
| Warm/boxed boot hang | The tested clone became reliable with PSRAM at 40MHz; the profile retains that setting |
| No SD mount / apparently dead box | Check card seating, supply and SPI wiring; inspect the boot log before assuming a failed board |
| Ring stays dark after an earlier LED-disabled build | Inspect saved runtime LED counts/brightness as well as compiled settings |
| Encoder does nothing | Check common to 3V3, A/B wiring and pull-downs; encoder press is a separate switch to GND |
| RC522 registers respond but cards are unreliable | Check supply integrity at the module; a local 470µF capacitor improved this particular assembly |
| Card detected then immediately treated as removed | Check reader/card spacing and runtime gain; gain 5 performed better than maximum gain at contact distance on the tested reader |

These are observations from one hardware stack, not diagnoses for every board.
The historical LED experiments used older FastLED/RMT paths; the pinned firmware
uses NeoPixelBus LCD/GDMA. An SD mount problem should be investigated separately
from an earlier boot hang; the serial log distinguishes them.

For the RC522 capacitor, observe polarity and use a suitable voltage rating.
Do not rely on a bulk capacitor to repair an incorrect supply or ground connection.
Test both stationary-card detection and removal with the actual cards and enclosure.
Runtime gain and pause-on-removal settings are not supplied by these source files.

## Optional PN5180 reader swap (experimental)

The pin map reserves these signals so the same second SPI bus can be used with
one reader at a time. This is a record of trial wiring, not a validated replacement
for every PN5180 module. Check the module's power requirements and pin labels.

| PN5180 signal | GPIO / supply |
|---|---|
| SCK | 5 |
| MOSI | 6 |
| MISO | 4 |
| NSS | 7 |
| BUSY | 8 |
| RST | 9 (RC522 reset uses 15 instead) |
| IRQ | 2 (optional low-power card-detection wake) |
| 5V | 5V rail on the tested module |
| 3V3 | 3.3V logic rail on the tested module |
| GND | Common ground |

Disconnect power and remove the RC522 before rewiring. Select PN5180 explicitly
in runtime settings and reboot; do not rely on auto-detection. GPIO8/9 must not
also be used for I2C: they are BUSY/RST here. This profile disables the unused
I2C-2 initialization, because earlier probing on those pins interfered with the
reader. Do not enable I2C peripherals without revisiting the pin allocation.

## Bring-up checklist

1. Inspect power routing and confirm the board really has N16R8 memory.
2. Build the pinned profile and upload to the explicitly selected port.
3. Confirm PSRAM, FAT32 SD mount and one audio file through the MAX98357A.
4. Confirm RC522 card detection and assign a test folder in the web UI.
5. Check LEDs, encoder, buttons and wake, one at a time.
6. Check runtime card-removal settings before closing the enclosure.

Related community context: [ESPuino S3 discussion](https://github.com/biologist79/ESPuino/discussions/251)
and [N16R8 build-support issue](https://github.com/biologist79/ESPuino/issues/459).
