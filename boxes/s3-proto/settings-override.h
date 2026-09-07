// SPDX-License-Identifier: GPL-3.0-only
// Based on ESPuino configuration, copyright its contributors.
// Modified for these box profiles in 2026; public preparation 2026-09-07.
// See ../../NOTICE.md and ../../LICENSE.
// clang-format off
// ============================================================================
// s3-proto — ESPuino settings for a generic ESP32-S3 devkit N16R8
// Copied into ESPuino/src/settings-override.h by deploy.sh (picked up via
// __has_include in settings.h; replaces the stock settings entirely).
// Based on upstream settings-override.h.sample. Pin map lives in
// settings-custom-override.h (included at the bottom).
// ============================================================================

#ifndef __ESPUINO_SETTINGS_OVERRIDE_H__
    #define __ESPUINO_SETTINGS_OVERRIDE_H__
        #include "Arduino.h"
        #include "values.h"

	//################## HARDWARE-PLATFORM ###############################
	#ifndef HAL             // Set by platformio.ini (-DHAL=99 -> custom pin map)
		#define HAL 99
	#endif

	//########################## MODULES #################################
	//#define PORT_EXPANDER_ENABLE          // Buttons via port-expander PCA9555
	//#define I2S_COMM_FMT_LSB_ENABLE       // Don't enable for MAX98357a
	#define MDNS_ENABLE                     // Reach the box via ESPuino.local
	//#define MQTT_ENABLE
	#define FTP_ENABLE                      // Activate after boot: PAUSE + NEXT in parallel
	#define NEOPIXEL_ENABLE                 // NeoPixelBus uses LCD_CAM/GDMA on ESP32-S3.
	//#define NEOPIXEL_REVERSE_ROTATION
	#define LANGUAGE EN
	#define PLAY_MONO_SPEAKER               // One MAX98357A, one speaker
	//#define HEADPHONE_ADJUST_ENABLE       // s3-proto: no headphone PCB / HP-detect wired
	//#define SHUTDOWN_IF_SD_BOOT_FAILS     // s3-proto: OFF during bring-up so SD wiring
	                                        // mistakes leave the console alive instead of
	                                        // deepsleeping after 20s. Re-enable for battery use.
	//#define MEASURE_BATTERY_VOLTAGE       // s3-proto: USB-powered experiment, no divider wired
	//#define MEASURE_BATTERY_MAX17055
	//#define SHUTDOWN_ON_BAT_CRITICAL
	//#define PLAY_LAST_RFID_AFTER_REBOOT
	#define USEROTARY_ENABLE
	//#define BLUETOOTH_ENABLE              // MUST stay off on ESP32-S3: no Classic BT radio,
	                                        // and ESPuino BT is A2DP (Classic-only). Won't build.
	//#define IR_CONTROL_ENABLE
	//#define PAUSE_WHEN_RFID_REMOVED
	//#define DONT_ACCEPT_SAME_RFID_TWICE
	//#define HALLEFFECT_SENSOR_ENABLE

	#ifdef PAUSE_WHEN_RFID_REMOVED
		#define ACCEPT_SAME_RFID_AFTER_TRACK_END
	#endif

	//################## select SD card mode #############################
	//#define SD_MMC_1BIT_MODE              // s3-proto: SD via SPI on FSPI pins (see pin map).
	                                        // 4-bit SD_MMC is the stretch goal (Discussion #251).
	//#define SINGLE_SPI_ENABLE             // Not used: SD & RC522 on separate SPI buses
	                                        // (level-shifted SD module doesn't tri-state MISO)
	//#define NO_SDCARD

	//################## select RFID reader ##############################
	// Reader type is chosen at RUNTIME since #403 (web UI / serial / NVS).
	// 0 = auto-detect, 1 = MFRC522 (SPI), 2 = MFRC522 (I2C), 3 = PN5180
	#define RFID_READER_TYPE_RUNTIME 0    // Auto-detect (finds the RC522 on SPI)

	#if defined(RFID_READER_TYPE_RUNTIME)
		#define MFRC522_ADDR 0x28           // default I2C-address of MFRC522
	#endif

	//############# Port-expander-configuration ######################
	#ifdef PORT_EXPANDER_ENABLE
		constexpr uint8_t expanderI2cAddress = 0x20;
	#endif

	//################## BUTTON-Layout ##################################
	// 0: NEXT_BUTTON  1: PREVIOUS_BUTTON  2: PAUSEPLAY_BUTTON
	// 3: ROTARYENCODER_BUTTON  4: BUTTON_4  5: BUTTON_5
	// *****BUTTON*****        *****ACTION*****
	#define BUTTON_0_SHORT    CMD_NEXTTRACK
	#define BUTTON_1_SHORT    CMD_PREVTRACK
	#define BUTTON_2_SHORT    CMD_PLAYPAUSE
	#define BUTTON_3_SHORT    CMD_PLAYPAUSE   // battery-measure disabled on this box
	#define BUTTON_4_SHORT    CMD_NOTHING
	#define BUTTON_5_SHORT    CMD_NOTHING

	#define BUTTON_0_LONG     CMD_LASTTRACK
	#define BUTTON_1_LONG     CMD_FIRSTTRACK
	#define BUTTON_2_LONG     CMD_PLAYPAUSE
	#define BUTTON_3_LONG     CMD_SLEEPMODE
	#define BUTTON_4_LONG     CMD_NOTHING
	#define BUTTON_5_LONG     CMD_NOTHING

	#define BUTTON_MULTI_01   CMD_NOTHING // was CMD_RESET_WIFI; feature dumped 2026-07-16 (fork PR #7 closed) — web UI per-network delete + AP fallback cover it
	#define BUTTON_MULTI_02   CMD_ENABLE_FTP_SERVER
	#define BUTTON_MULTI_03   CMD_NOTHING
	#define BUTTON_MULTI_04   CMD_NOTHING
	#define BUTTON_MULTI_05   CMD_NOTHING
	#define BUTTON_MULTI_12   CMD_TELL_IP_ADDRESS
	#define BUTTON_MULTI_13   CMD_NOTHING
	#define BUTTON_MULTI_14   CMD_NOTHING
	#define BUTTON_MULTI_15   CMD_NOTHING
	#define BUTTON_MULTI_23   CMD_NOTHING
	#define BUTTON_MULTI_24   CMD_NOTHING
	#define BUTTON_MULTI_25   CMD_NOTHING
	#define BUTTON_MULTI_34   CMD_NOTHING
	#define BUTTON_MULTI_35   CMD_NOTHING
	#define BUTTON_MULTI_45   CMD_NOTHING

	//#################### Various settings ##############################
	#define SERIAL_LOGLEVEL LOGLEVEL_DEBUG

	constexpr uint8_t buttonDebounceInterval = 50;
	constexpr uint16_t intervalToLongPress = 700;

	#define BUTTON_0_ACTIVE_STATE 0
	#define BUTTON_1_ACTIVE_STATE 0
	#define BUTTON_2_ACTIVE_STATE 0
	#define BUTTON_3_ACTIVE_STATE 0
	#define BUTTON_4_ACTIVE_STATE 0
	#define BUTTON_5_ACTIVE_STATE 0

	//#define CONTROLS_LOCKED_BY_DEFAULT
	#define INCLUDE_ROTARY_IN_CONTROLS_LOCK

	#define RFID_SCAN_INTERVAL 100

	#ifdef SHUTDOWN_IF_SD_BOOT_FAILS
		constexpr uint32_t deepsleepTimeAfterBootFails = 20;
	#endif

	// timezone (see https://github.com/nayarsystems/posix_tz_db/blob/master/zones.csv)
	constexpr const char timeZone[] = "GMT0BST,M3.5.0/1,M10.5.0"; // Europe/London

	constexpr const char accessPointNetworkSSID[] = "ESPuino";
	constexpr const char accessPointNetworkPassword[] = "";

	constexpr const char nameBluetoothSinkDevice[] = "ESPuino";

	constexpr const char backupFile[] = "/backup.txt";

	//#################### Settings for optional Modules ##############################
	#ifdef NEOPIXEL_ENABLE
		#define NUM_INDICATOR_LEDS		12          	// 12-LED wheel (bring-up docs said 24; A/B-tested
		                                        		// 2026-07-05: count is NOT related to the boot-hang)
		#define NUM_CONTROL_LEDS		0
		#define CONTROL_LEDS_COLORS		{}
		#define CHIPSET					WS2812B
		#define COLOR_ORDER				GRB
		#define NUM_LEDS_IDLE_DOTS		4
		#define OFFSET_PAUSE_LEDS		false
		#define PROGRESS_HUE_START		85
		#define PROGRESS_HUE_END		-1
		#define ATMO_HUE				10
		#define ATMO_SATURATION			180
		#define DIMMABLE_STATES			50
		//#define LED_OFFSET			0
	#endif

	#if defined(MEASURE_BATTERY_VOLTAGE) || defined(MEASURE_BATTERY_MAX17055)
		#define BATTERY_MEASURE_ENABLE
		constexpr uint8_t s_batteryCheckInterval = 10;
	#endif

	#ifdef MEASURE_BATTERY_VOLTAGE
		constexpr float s_warningLowVoltage = 3.4;
		constexpr float s_warningCriticalVoltage = 3.1;
		constexpr float s_voltageIndicatorLow = 3.0;
		constexpr float s_voltageIndicatorHigh = 4.2;
	#endif

	// I2C-2 DISABLED on this box (2026-07-09): it has NO I2C devices — both RFID
	// readers are SPI, no port-expander, no MAX17055 gauge. Upstream force-enables
	// I2C whenever runtime RFID detection is on (to probe for an I2C MFRC522), but
	// that init does i2cBusTwo.begin() on the ext_IIC pins = GPIO 8/9 — which ARE
	// the PN5180's BUSY/RST here. The clash wedged the PN5180 (LEDs never left the
	// boot spin, web UI unreachable, POWERON blips). Dropping the RFID_READER_TYPE_RUNTIME
	// trigger frees 8/9 for the PN5180; the RC522<->PN5180 runtime swap is unaffected
	// (both are SPI). Re-add the trigger only if an actual I2C device is wired.
	#if defined(PORT_EXPANDER_ENABLE) || defined(MEASURE_BATTERY_MAX17055)
		#define I2C_2_ENABLE
	#endif

	#ifdef HEADPHONE_ADJUST_ENABLE
		constexpr uint16_t headphoneLastDetectionDebounce = 1000;
	#endif

	constexpr uint8_t jumpOffset = 30;

	// !!! Pin map for this box !!!
	#if (HAL == 99)
		#include "settings-custom-override.h"
	#else
		#error "s3-proto profile expects HAL=99 (set by platformio-override.ini)"
	#endif

#endif //settings_override
