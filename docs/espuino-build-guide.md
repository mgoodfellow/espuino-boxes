# Build and first boot

Start from one of the profiles in the [README](../README.md). These commands
build the revision in that profile's `upstream.lock`, including firmware changes
that may not be in the current upstream release.

## Requirements

- Linux or macOS with Bash, Git and [PlatformIO Core](https://docs.platformio.org/en/latest/core/installation/index.html).
- Several GB of free disk space and network access for the first build.
- A board matching the selected profile, a USB data cable, FAT32 microSD card,
  RC522, MAX98357A and speaker. Encoder, buttons and LEDs follow the wiring guide.
- A regulated 5V USB supply; the builds were designed around 2–3A supplies.

Use only low-voltage DC inside the enclosure. The external USB supply provides
power; there is no mains wiring inside the box. Power down before changing wires.

## Get a separate firmware checkout for each profile

From a directory where you keep projects:

```bash
git clone https://github.com/mgoodfellow/espuino-boxes.git
cd espuino-boxes

# Choose ONE profile; substitute kidbox-lolin-1 for the D32 build.
profile=s3-proto
firmware_dir="$PWD/../ESPuino-$profile"
git clone --branch s3-test-all https://github.com/mgoodfellow/ESPuino.git "$firmware_dir"
revision="$(cat "boxes/$profile/upstream.lock")"
git -C "$firmware_dir" fetch origin "$revision"
git -C "$firmware_dir" checkout --detach "$revision"

ESPUINO_DIR="$firmware_dir" ./deploy.sh "$profile" build
```

`pio` must be on PATH. Alternatively prefix the final command with
`PIO="$HOME/.platformio/penv/bin/pio"` if that is where you installed it.
The firmware source is **mgoodfellow/ESPuino**, integration branch
**[`s3-test-all`](https://github.com/mgoodfellow/ESPuino/tree/s3-test-all)**.
The clone command selects that branch explicitly, then the checkout command
selects the profile's recorded commit. It intentionally leaves a detached HEAD
at that commit. The branch may be rebased; the locked snapshots need not remain
ancestors of its latest tip, which is why the exact commit is fetched separately.

`deploy.sh` itself neither clones nor follows a remote branch: it builds whatever
commit is checked out in `ESPUINO_DIR`, warning on a lock mismatch. Its `sync`
action checks out the lock, not the current `s3-test-all` head.
The initial build downloads substantial dependencies and may take several minutes.

Keep **one firmware checkout per profile**. `deploy.sh` copies override files,
but does not remove extra files left by another profile. Reusing a checkout
can leave custom pin maps or SDK defaults from the previous build.
The script warns if the checkout differs from the profile's pinned revision;
a warning is not a compatibility check.

For the S3, the script checks that the per-target PSRAM options survived SDK
configuration generation. If needed it recopies the defaults and rebuilds once.
Use this script for the build, not a bare `pio run`.

## USB upload

After a successful build, list connected devices:

```bash
pio device list
```

Choose the port for this board. With the same `profile` and `firmware_dir`
variables as above, explicitly pass it to the upload command:

```bash
# Example only: replace this with the port from the device list.
port=/dev/ttyACM0
ESPUINO_DIR="$firmware_dir" ./deploy.sh "$profile" upload "$port"
```

This builds again and uploads via PlatformIO. It does not intentionally erase
NVS. Use the normal USB upload when provisioning a board for the first time or
changing the partition table. No upload command should run until you have
identified the correct physical device.

```bash
pio device monitor --port "$port" --baud 115200
```

## Wiring and first boot

Use the profile's wiring table, not a generic ESP32 pin diagram:

- [S3 N16R8 wiring](../boxes/s3-proto/wiring.md)
- [LOLIN D32 Pro wiring](../boxes/kidbox-lolin-1/wiring.md)

RC522 uses **3.3V**, while the documented amp and ring use **5V**. All grounds
must be connected. The external S3 SD module has its own regulator and is powered
from 5V; this does not apply to a bare 3.3V SD socket. The D32 uses its onboard slot.

1. Insert a working FAT32 microSD card. These profiles expect an SD card and reader.
2. Connect the minimal audio/RC522 hardware according to the wiring table.
3. Power up and inspect the serial log for PSRAM, SD mount and RFID detection.
4. On a device without saved Wi-Fi settings, join the `ESPuino` access point
   and open `http://192.168.4.1` to configure your own network. The compiled AP
   password is empty; provision the device on a trusted network.
5. Open its web interface using the hostname/IP shown in the boot log. Add a
   small DRM-free test audio folder and associate it with a card.
6. Check playback, then add/test the ring, encoder and buttons.
7. Validate card removal behaviour in the runtime settings before relying on
   a card-in/card-out enclosure interaction. It is not enabled by the compile-time
   `PAUSE_WHEN_RFID_REMOVED` flag in these profiles.

Keep one directory per audiobook and number chapter files consistently. Runtime
settings and card mappings are stored separately from the firmware; a reflash
does not necessarily reset them. Do not erase NVS merely to troubleshoot a build.

## OTA

After the device already has an OTA-capable partition table and firmware:

```bash
ESPUINO_DIR="$firmware_dir" ./deploy.sh "$profile" ota
```

Upload the printed **application `firmware.bin`** path using the device's web
interface (Settings → OTA). Do not upload a factory image, bootloader or partition
table there. The S3 needs both `custom_16mb_ota.csv` and
`BOARD_HAS_16MB_FLASH_AND_OTA_SUPPORT`; the profile supplies both.

## Updating a profile

New integration work belongs on `mgoodfellow/ESPuino:s3-test-all`. As checked on
2026-09-07, its head was `1a05eb639a6ce0b5cc940e7807475c8ecf20d1d5`; that is
**not** the firmware revision built in this release's verification record.
Use a separate checkout when evaluating that branch, record the exact commit,
and review the profile overrides before building.

In particular, that integration revision already declares NeoPixelBus in its
base `lib_deps`. When updating the S3 profile to it, remove the extra
`lib_deps = ${env.lib_deps}` / NeoPixelBus addition from the S3 override so the
library is not declared twice. Keep `lib_ignore = ESP32-A2DP` and the other
board-specific settings. The extra dependency remains necessary for the older
S3 revision currently in `upstream.lock`.

Keep the recorded working revision until you have tested its replacement.
Build newer firmware in another checkout, review settings compatibility, then
validate boot, storage, playback, controls, LEDs and wake/OTA as applicable on
hardware. Only then use `./deploy.sh <profile> pin` with `ESPUINO_DIR` pointing
to that checkout, and commit the lock plus any configuration changes.

`sync` checks out the existing lock; it does not fetch missing commits or update
the lock. `pin` records the checkout's HEAD; it is not hardware verification.

PlatformIO may modify tracked dependency locks or SDK configuration during a
build. Record the embedded revision from
`.pio/build/<environment>/generated/gitrevision.h`, plus the source revision and
firmware checksum, if sharing an artifact. A `-dirty` suffix must be reported.
This repository's initial release distributes profiles and CAD, not firmware binaries.
