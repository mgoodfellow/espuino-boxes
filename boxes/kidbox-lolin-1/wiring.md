# kidbox-lolin-1 wiring — WeMos LOLIN D32 Pro V2.0.0

Board: LOLIN D32 Pro V2.0.0, ESP32-WROVER (PSRAM), onboard microSD slot,
16MB flash. Build env: `lolin_d32_pro` (HAL 4 with encoder-switch/wake overrides; schematic: https://www.wemos.cc/en/latest/_static/files/sch_d32_pro_v2.0.0.pdf).

## Pin map (HAL 4 plus profile overrides)

| Function | Signal | GPIO | Notes |
|---|---|---|---|
| microSD (ONBOARD — nothing to wire) | CS | 4 | hardwired: TF-CS silkscreen |
| | MOSI | 23 | shared SPI, hardwired |
| | MISO | 19 | |
| | SCK | 18 | |
| RC522 RFID (2nd SPI bus) | SCK | 14 | **3.3V only, never 5V** |
| | MOSI | 13 | |
| | MISO | 15 | |
| | CS/SDA | 21 | |
| | RST | — | leave unconnected (HAL uses dummy 99; module has onboard pull-up) |
| I2S → MAX98357A | BCLK | 27 | amp on 5V, mono, one speaker |
| | LRC/WS | 26 | |
| | DIN | 25 | |
| NeoPixel ring (12 px) | DIN | 12 | 330Ω in data line, ~1000µF across 5V, brightness ≤30–40% |
| Rotary encoder | CLK | 34 | common(middle pin)→**3V3**; 34 is input-only → external 10k **pull-DOWN to GND** (firmware forces `INPUT_PULLDOWN`, a no-op on input-only pins) |
| | DT | 39 | "VN" pin; input-only → external 10k **pull-DOWN to GND** |
| | SW | 22 | push switch (2-pin side of the encoder) → GPIO 22 + **GND**, active-low, internal pull-up — a normal button, **NOT** to 3V3 like CLK/DT. Moved off 32 so 32 can be the dedicated wake pin (see wake note) |
| Button: next | — | 33 | internal pullup OK; button to GND |
| Button: previous | — | 2 | internal pullup OK; strapping pin — button-to-GND is fine |
| Button: pause/play | — | 36 | "VP" pin; input-only, **needs external 10k pullup**; also diode-OR'd to the wake pin (see below) |
| **Wake line (diode-OR)** | — | 32 | **dedicated ext0 deepsleep-wake pin — no button on it.** 2× Schottky (anode→32, band→rotary-SW 22 *and* play/pause 36) + external **10k pull-UP 32→3V3**. Press either wake-button → 32 pulled low → wake |
| POWER (optional deepsleep transistor) | — | 5 | shares the onboard LED; fine unwired for mains build |
| Battery ADC (onboard divider) | — | 35 | built-in, feature disabled (mains build) |

**Buttons** (incl. pause/play on 36) are momentary to **GND**, active-low → the
input-only button pin (36) needs an external 10k **pull-UP** to 3V3.

**The rotary encoder is the opposite:** its common (middle) pin sits on **3V3**
and ESPuino pulls CLK/DT *down* (`pinMode(CLK/DT, INPUT_PULLDOWN)` in
RotaryEncoder.cpp — the ESP32Encoder default expects the common on 3V3). So
34/39 need external 10k **pull-DOWNs to GND**, *not* pull-ups. Common on 3V3 with
pull-UPs leaves A/B stuck high = no rotation — the classic mistake (and what the
old version of this table wrongly told you to do).

Input-only GPIOs 34/36/39 have **no internal pull resistors of either kind**,
which is why all three need an external one — pull-UP for the button, pull-DOWNs
for the encoder.

**Rotary SW (GPIO 22) — don't confuse it with the encoder's A/B.** The push
switch is a *normal button*: its 2-pin switch side goes to **GND**, active-low;
GPIO 22 (a full I/O pin) uses ESPuino's internal pull-up while awake — wire it
like next/prev, **to GND, not to 3V3**. The 3V3 side is only the encoder's
common/CLK/DT wiring. (It sat on GPIO 32 originally; moved to 22 to free 32 as
the dedicated wake pin.)

**Dual-button deepsleep wake (GPIO 32, diode-OR).** GPIO 32 is now a *dedicated*
ext0 wake pin — no button reads it, it only wakes the box. Both wake buttons feed
it through a diode, so pressing *either* wakes the box while firmware still sees
them as **separate** buttons (rotary-SW short = play/pause, long = sleep;
play/pause keeps its own action):
- **rotary-SW node (GPIO 22)** → Schottky → GPIO 32   (band/cathode toward 22)
- **play/pause node (GPIO 36)** → Schottky → GPIO 32   (band/cathode toward 36)
- **10k pull-UP GPIO 32 → 3V3** (mandatory): holds 32 high in deep sleep — ESPuino
  only re-enables an RTC pull-up for ext1, not ext0 (`Button.cpp`), so without the
  external pull-up 32 floats and wakes spuriously or misses a press.

Use **Schottky** (BAT85 / 1N5819, low Vf): a press pulls 32 to ~0.3 V, well below
the logic-low threshold. Silicon 1N4148 (~0.6 V) is marginal. The dedicated pin
means **no cross-talk** — pressing play/pause never registers as a rotary-SW press
or vice-versa. Config (already in `settings-override.h`): `ROTARYENCODER_BUTTON 22`,
`WAKEUP_BUTTON 32` (explicit — the HAL default `= ROTARYENCODER_BUTTON` would
otherwise follow the SW to 22).

## Board caveats

- **GPIO 16/17 do not exist for you** — used internally by the WROVER's PSRAM.
- **GPIO 12 is a strapping pin (MTDI)**: with the NeoPixel wired through 330Ω
  it's normally fine, but if the board bootloops with the ring attached,
  disconnect the ring's DIN at boot to confirm — known gotcha class.
- **SD_MMC mode is impossible** on this board — the onboard slot is wired to
  SPI. Don't chase MMC advice from other HALs.
- **Flash size**: env assumes 16MB (V2.0.0 spec). Some clones ship 4MB — if
  the first upload errors on partition size, check `esptool flash_id` output
  in the upload log before assuming wiring problems.
- RC522 3.3V rail only; MAX98357A and NeoPixel + SD-module-free here (onboard
  slot runs at 3.3V natively). Common ground everywhere.

## Bring-up order (see ../../docs/espuino-build-guide.md)

1. Bare board: the build guide's explicit-port upload command — boots, web UI reachable
   (AP "ESPuino" first boot), onboard SD mounts with a FAT32 card.
2. One MP3 through the MAX98357A (I2S: 27/26/25).
3. RC522: card scan shows in serial log; assign first card via web UI.
4. NeoPixel ring → encoder (with external pull-downs on A/B) → buttons.
5. Case + mains 5V 2–3A wall wart.

## Deliberate config choices (see settings-override.h)

- Bluetooth ON (Classic ESP32 has A2DP — unlike the S3 box).
- Battery measurement OFF: mains build; the onboard divider on GPIO35 floats
  without a LiPo and would throw spurious low-battery LED warnings.
- SHUTDOWN_IF_SD_BOOT_FAILS OFF: on mains, a deepsleep on SD hiccup looks like
  a dead box to a child; leave it retrying with the console alive.
- 12-LED ring (`NUM_INDICATOR_LEDS 12`).
