// SPDX-License-Identifier: GPL-3.0-only
// Based on ESPuino configuration, copyright its contributors.
// Modified for these box profiles in 2026; public preparation 2026-09-07.
// See ../../NOTICE.md and ../../LICENSE.
// clang-format off
// ============================================================================
// kidbox-lolin-1 — ESPuino settings for WeMos LOLIN D32 Pro V2.0.0
// Copied into ESPuino/src/settings-override.h by deploy.sh.
// Pin map = upstream's tested settings-lolin_d32_pro.h (HAL 4), included at
// the bottom, with encoder-switch and wake overrides below the include.
// Wiring details and external resistor requirements are in wiring.md.
// ============================================================================

#ifndef __ESPUINO_SETTINGS_OVERRIDE_H__
    #define __ESPUINO_SETTINGS_OVERRIDE_H__
        #include "Arduino.h"
        #include "values.h"

	//################## HARDWARE-PLATFORM ###############################
	#ifndef HAL             // Set by platformio.ini (env lolin_d32_pro -> -DHAL=4)
		#define HAL 4
	#endif

	//########################## MODULES #################################
	//#define PORT_EXPANDER_ENABLE
	//#define I2S_COMM_FMT_LSB_ENABLE       // Don't enable for MAX98357a
	#define MDNS_ENABLE                     // Reach the box via ESPuino.local
	//#define MQTT_ENABLE
	#define FTP_ENABLE                      // Activate after boot: PAUSE + NEXT in parallel
	#define NEOPIXEL_ENABLE                 // classic-ESP32 WS2812 now goes through NeoPixelBus (I2S1 method)
	                                        // since 2026-07-09 — FastLED's WS2812 backend aborts on this
	                                        // Arduino-3.3.8/IDF-5.5 stack (no free SPI host; SD+RC522 own
	                                        // HSPI/VSPI). See Led.cpp + this box's platformio-override.ini.
	//#define NEOPIXEL_REVERSE_ROTATION
	#define LANGUAGE EN
	#define PLAY_MONO_SPEAKER               // One MAX98357A, one speaker
	//#define HEADPHONE_ADJUST_ENABLE       // No headphone PCB / HP-detect wired
	//#define SHUTDOWN_IF_SD_BOOT_FAILS     // OFF during bring-up (keeps console alive on
	                                        // SD trouble). This box is mains-powered, so a
	                                        // dead-looking deepsleep on SD failure is worse
	                                        // than a retry loop; reconsider if battery added.
	//#define MEASURE_BATTERY_VOLTAGE       // Mains-powered, no battery fitted. The onboard
	                                        // divider on GPIO35 floats without a battery ->
	                                        // spurious low-battery Neopixel warnings.
	                                        // Enable if a LiPo goes in later.
	//#define MEASURE_BATTERY_MAX17055
	//#define SHUTDOWN_ON_BAT_CRITICAL
	//#define PLAY_LAST_RFID_AFTER_REBOOT
	#define USEROTARY_ENABLE
	#define BLUETOOTH_ENABLE                // Classic ESP32 has BT-Classic; A2DP works here
	                                        // (unlike the S3 box)
	//#define IR_CONTROL_ENABLE
	//#define PAUSE_WHEN_RFID_REMOVED
	//#define DONT_ACCEPT_SAME_RFID_TWICE
	//#define HALLEFFECT_SENSOR_ENABLE

	#ifdef PAUSE_WHEN_RFID_REMOVED
		#define ACCEPT_SAME_RFID_AFTER_TRACK_END
	#endif

	//################## select SD card mode #############################
	//#define SD_MMC_1BIT_MODE              // NOT possible on D32 Pro — onboard slot is
	                                        // hardwired to SPI (23/19/18, CS 4)
	//#define SINGLE_SPI_ENABLE
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

	// Rotary gestures: hold the button, turn the encoder. CMD_NOTHING = button is not a modifier.
	// A modifier button keeps its normal short/long action when pressed WITHOUT turning the encoder.
	#define BUTTON_0_ROTARY_CW   CMD_SEEK_FORWARDS   // hold NEXT + turn: seek within the chapter
	#define BUTTON_0_ROTARY_CCW  CMD_SEEK_BACKWARDS
	#define BUTTON_1_ROTARY_CW   CMD_NOTHING
	#define BUTTON_1_ROTARY_CCW  CMD_NOTHING
	#define BUTTON_2_ROTARY_CW   CMD_BRIGHTNESS_UP   // hold PLAY/PAUSE + turn: LED brightness
	#define BUTTON_2_ROTARY_CCW  CMD_BRIGHTNESS_DOWN
	#define BUTTON_3_ROTARY_CW   CMD_NOTHING         // rotary push: short=play/pause, long=SLEEPMODE -- left free
	#define BUTTON_3_ROTARY_CCW  CMD_NOTHING
	#define BUTTON_4_ROTARY_CW   CMD_NOTHING
	#define BUTTON_4_ROTARY_CCW  CMD_NOTHING
	#define BUTTON_5_ROTARY_CW   CMD_NOTHING
	#define BUTTON_5_ROTARY_CCW  CMD_NOTHING

	#define BUTTON_MULTI_01   CMD_NOTHING // CMD_RESET_WIFI dropped 2026-07-16 (web UI's per-network delete + AP fallback cover it); this override now compiles against plain dev/PR branches
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
		#define NUM_INDICATOR_LEDS		12          	// 12-pixel ring per the build guide
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

	// enable I2C if necessary (always on with runtime RFID detection — it
	// probes for an I2C MFRC522; ext_IIC pins come from the HAL file)
	#if defined(RFID_READER_TYPE_RUNTIME) || defined(PORT_EXPANDER_ENABLE) || defined(MEASURE_BATTERY_MAX17055)
		#define I2C_2_ENABLE
	#endif

	#ifdef HEADPHONE_ADJUST_ENABLE
		constexpr uint16_t headphoneLastDetectionDebounce = 1000;
	#endif

	constexpr uint8_t jumpOffset = 30;
	#define JUMP_OFFSET_ROTARY 10   // seconds per encoder-detent when seeking via a rotary gesture (NVS "rotSeekStep" overrides)

	// !!! Pin map: upstream's tested D32 Pro map, unmodified !!!
	// (PN5180 test 2026-07-10 reverted — modules had dead RF front-ends, back to RC522.
	//  If retrying PN5180: RFID_BUSY=33 clashes with NEXT_BUTTON, RFID_IRQ=39 clashes
	//  with ROTARYENCODER_DT — move NEXT off 33 and set RFID_IRQ 99. See wiring.md.)
	#if (HAL == 4)
		#include "settings-lolin_d32_pro.h"
	#else
		#error "kidbox-lolin-1 profile expects HAL=4 (env lolin_d32_pro)"
	#endif

	// ---- Dual-button deepsleep wake (2026-07-10) --------------------------------
	// Move the rotary push-switch off GPIO32 so 32 becomes a DEDICATED ext0 wake
	// pin, then diode-OR both wake buttons (rotary-SW + play/pause) onto it. Keeps
	// the two buttons distinct in firmware while letting EITHER wake the box.
	// Wiring (see wiring.md): rotary-SW -> GPIO22+GND; play/pause -> GPIO36+GND;
	// Schottky diodes anode->G32 / band(cathode)->each button node; 10k pull-up G32->3V3.
	// NB: WAKEUP_BUTTON must be set explicitly to 32 — the HAL default is
	// (= ROTARYENCODER_BUTTON), which would otherwise follow the rotary-SW to 22.
	#undef  ROTARYENCODER_BUTTON
	#define ROTARYENCODER_BUTTON 22   // rotary push-switch (moved off 32)
	#undef  WAKEUP_BUTTON
	#define WAKEUP_BUTTON        32    // dedicated ext0 wake pin (no button assigned)

#endif //settings_override
