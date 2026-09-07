#!/usr/bin/env bash
# Deploy an espuino-boxes profile into the ESPuino tree and build/flash it.
# Usage: ./deploy.sh <box> [build|upload|monitor|ota|sync|pin|clean] [upload-port]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ESPUINO_DIR="${ESPUINO_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)/ESPuino}"
PIO="${PIO:-pio}"

die() { echo "error: $*" >&2; exit 1; }

BOX="${1:-}"
ACTION="${2:-build}"
UPLOAD_PORT="${3:-}"
[ "$ACTION" != upload ] || [ -n "$UPLOAD_PORT" ] || die "upload requires an explicit port (run 'pio device list')"
[ -n "$BOX" ] || { echo "usage: $0 <box> [build|upload|monitor|ota|sync|pin|clean] [upload-port]"; echo; echo "boxes:"; ls "$SCRIPT_DIR/boxes"; exit 1; }
BOX_DIR="$SCRIPT_DIR/boxes/$BOX"
[ -d "$BOX_DIR" ] || die "no such box: $BOX (see $SCRIPT_DIR/boxes/)"
[ -d "$ESPUINO_DIR" ] || die "ESPuino clone not found at $ESPUINO_DIR (set ESPUINO_DIR)"

# shellcheck disable=SC1091
source "$BOX_DIR/box.conf"   # provides ENV (platformio env name)
[ -n "${ENV:-}" ] || die "box.conf must set ENV"

check_upstream_pin() {
	local lock head
	[ -f "$BOX_DIR/upstream.lock" ] || return 0
	lock="$(cat "$BOX_DIR/upstream.lock")"
	head="$(git -C "$ESPUINO_DIR" rev-parse HEAD)"
	if [ "$lock" != "$head" ]; then
		echo "WARNING: ESPuino is at ${head:0:10} but $BOX is pinned to ${lock:0:10}."
		echo "         Run '$0 $BOX sync' to check out the pinned commit, or"
		echo "         '$0 $BOX pin' to move the pin to the current checkout."
	fi
}

copy_profile() {
	cp "$BOX_DIR/platformio-override.ini" "$ESPUINO_DIR/platformio-override.ini"
	cp "$BOX_DIR/settings-override.h" "$ESPUINO_DIR/src/settings-override.h"
	[ -f "$BOX_DIR/settings-custom-override.h" ] \
		&& cp "$BOX_DIR/settings-custom-override.h" "$ESPUINO_DIR/src/settings-custom-override.h"
	local f
	for f in "$BOX_DIR"/sdkconfig.defaults.*; do
		[ -e "$f" ] && cp "$f" "$ESPUINO_DIR/$(basename "$f")"
	done
	return 0
}

# ESPuino's pre-build script (updateSdkConfig.py) deletes sdkconfig.* (except
# sdkconfig.defaults) whenever sdkconfig.defaults' mtime is newer than the last
# build — which can silently remove our per-target sdkconfig.defaults.<target>
# BEFORE the config is generated. So after building, verify every option from
# the profile's per-target defaults made it into the generated sdkconfig; if
# not, re-copy and rebuild once.
verify_sdkconfig() {
	local gen="$ESPUINO_DIR/sdkconfig.$ENV" f line ok=0
	for f in "$BOX_DIR"/sdkconfig.defaults.*; do
		[ -e "$f" ] || return 0
		[ -f "$gen" ] || { echo "generated $gen not found"; return 1; }
		while IFS= read -r line; do
			case "$line" in ''|\#*) continue ;; esac
			grep -qxF "$line" "$gen" || { echo "missing in $gen: $line"; ok=1; }
		done < "$f"
	done
	return $ok
}

build() {
	check_upstream_pin
	copy_profile
	(cd "$ESPUINO_DIR" && "$PIO" run -e "$ENV")
	if ! verify_sdkconfig; then
		echo "-- per-target sdkconfig options were dropped by the pre-build script; rebuilding once --"
		rm -f "$ESPUINO_DIR/sdkconfig.$ENV"
		copy_profile
		(cd "$ESPUINO_DIR" && "$PIO" run -e "$ENV")
		verify_sdkconfig || die "sdkconfig options from profile still missing after rebuild — investigate before flashing"
	fi
	echo "-- build OK: $ESPUINO_DIR/.pio/build/$ENV/firmware.bin --"
}

case "$ACTION" in
	build)
		build
		;;
	upload)
		build
		(cd "$ESPUINO_DIR" && "$PIO" run -e "$ENV" -t upload --upload-port "$UPLOAD_PORT")
		;;
	monitor)
		(cd "$ESPUINO_DIR" && "$PIO" device monitor)
		;;
	ota)
		build
		echo
		echo "OTA: upload this file via the box's web UI (Settings -> OTA):"
		echo "  $ESPUINO_DIR/.pio/build/$ENV/firmware.bin"
		;;
	sync)
		[ -f "$BOX_DIR/upstream.lock" ] || die "no upstream.lock for $BOX"
		[ -z "$(git -C "$ESPUINO_DIR" status --porcelain --untracked-files=normal)" ] || die "ESPuino tree has uncommitted changes; refusing to check out"
		git -C "$ESPUINO_DIR" checkout "$(cat "$BOX_DIR/upstream.lock")"
		;;
	pin)
		git -C "$ESPUINO_DIR" rev-parse HEAD > "$BOX_DIR/upstream.lock"
		echo "pinned $BOX to $(cat "$BOX_DIR/upstream.lock")"
		;;
	clean)
		(cd "$ESPUINO_DIR" && "$PIO" run -e "$ENV" -t clean)
		;;
	*)
		die "unknown action: $ACTION"
		;;
esac
