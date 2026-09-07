// SPDX-License-Identifier: GPL-3.0-only
// Based on ESPuino configuration, copyright its contributors.
// Modified for these box profiles in 2026; public preparation 2026-09-07.
// See ../../NOTICE.md and ../../LICENSE.
// clang-format off
// ============================================================================
// s3-proto pin map — generic ESP32-S3 devkit N16R8
// Copied into ESPuino/src/settings-custom-override.h by deploy.sh; included
// from settings-override.h (HAL 99). Full rationale + wiring in wiring.md.
//
// NEVER map these GPIOs on an N16R8:
//   26-32  SPI flash
//   33-37  octal PSRAM extra data lines (free on quad-PSRAM R2 boards — do not
//          trust R2 pinout advice on this board)
//   19,20  USB-JTAG (native USB)
//   0,3,45,46  strapping (46 also input-only)
//   43,44  UART0 TX/RX (keep for serial)
//   48     onboard RGB LED (left free on purpose; some revs use 38 — confirm,
//          ours uses 38 for the NEXT button!)
// Spare free pins: 1, 2, 8, 9, 14
// ============================================================================

#ifndef __ESPUINO_SETTINGS_CUSTOM_OVERRIDE_H__
#define __ESPUINO_SETTINGS_CUSTOM_OVERRIDE_H__
    #include "Arduino.h"

    //################## GPIO-configuration ##############################
    // ESP32-S3 note: unlike classic ESP32 there are no input-only pins in use
    // here (only GPIO46 is input-only on S3) and the GPIO matrix routes any
    // signal to any pin.

    #ifdef SD_MMC_1BIT_MODE
        #error "s3-proto uses SD via SPI; SD_MMC pin set not defined for this board yet (stretch goal)"
    #else
        // uSD-card-reader (via SPI) — FSPI-native pins, fastest bus.
        // SD module VCC -> 5V (module has its own regulator + level shifter).
        #define SPISD_CS                    10          // GPIO for chip select (SD)
        #ifndef SINGLE_SPI_ENABLE
            #define SPISD_MOSI              11          // GPIO for master out slave in (SD)
            #define SPISD_MISO              13          // GPIO for master in slave out (SD)
            #define SPISD_SCK               12          // GPIO for clock-signal (SD)
        #endif
    #endif

    // RFID-reader RC522 (via SPI, second/bit-banged bus — kept separate from SD
    // because the level-shifted SD module doesn't reliably tri-state MISO).
    // RC522 on 3.3V ONLY — never 5V.
    #define RST_PIN                         15          // RC522 reset
    #define RFID_CS                         7           // GPIO for chip select (RFID)
    #define RFID_MOSI                       6           // GPIO for master out slave in (RFID)
    #define RFID_MISO                       4           // GPIO for master in slave out (RFID)
    #define RFID_SCK                        5           // GPIO for clock-signal (RFID)

    #if defined(RFID_READER_TYPE_RUNTIME)
        // Only used if runtime RFID detection probes for a PN5180 — mapped to
        // spare pins so probing never touches anything wired.
        #define RFID_BUSY                   8           // PN5180 BUSY
        #define RFID_RST                    9           // PN5180 RESET
        #define RFID_IRQ                    2           // PN5180 IRQ (LPCD only)
    #endif

    // I2S (DAC) -> MAX98357A (on 5V, mono, one speaker)
    #define I2S_DOUT                        18          // Digital out (I2S)
    #define I2S_BCLK                        16          // BCLK (I2S)
    #define I2S_LRC                         17          // LRC/WS (I2S)

    // Rotary encoder
    #ifdef USEROTARY_ENABLE
        //#define REVERSE_ROTARY                        // To reverse encoder's direction
        #define ROTARYENCODER_CLK           39          // rotary encoder's CLK
        #define ROTARYENCODER_DT            40          // rotary encoder's DT
    #endif

    // Amp enable (optional) — not wired on s3-proto
    //#define GPIO_PA_EN                    112
    //#define GPIO_HP_EN                    113

    // Control-buttons (99 = DISABLE; 0->47 GPIO; 100->115 port-expander)
    // PAUSEPLAY + encoder SW sit on RTC-capable pins (0-21) so they can wake
    // the box from deepsleep (rewired 47->14 and 41->1).
    #define NEXT_BUTTON                     38          // Button 0
    #define PREVIOUS_BUTTON                 42          // Button 1
    #define PAUSEPLAY_BUTTON                14          // Button 2 (RTC pin, deepsleep wake)
    #define ROTARYENCODER_BUTTON            1           // Button 3 (encoder SW, RTC pin, deepsleep wake)
    #define BUTTON_4                        99          // unused
    #define BUTTON_5                        99          // unused

    //#define BUTTONS_LED                   114

    #ifdef PORT_EXPANDER_ENABLE
        #define PE_INTERRUPT_PIN            99
    #endif

    // I2C (only compiled in if I2C_2_ENABLE gets set) — spare pins
    #ifdef I2C_2_ENABLE
        #define ext_IIC_CLK                 8           // i2c-SCL
        #define ext_IIC_DATA                9           // i2c-SDA
    #endif

    // Deepsleep wake: S3 RTC-wake works on GPIO 0-21 only. PAUSEPLAY (14) and
    // encoder SW (1) wake via ext1 ANY_LOW (see Button.cpp; RTC pullups
    // enabled there — 14/1 have no external resistors). The devkit BOOT
    // button (GPIO 0) is deliberately NOT in the mask: straps are re-sampled
    // on deepsleep wake, so waking with GPIO 0 held low enters the serial
    // bootloader and the box looks dead until reset.
    // ext0/WAKEUP_BUTTON stays disabled in favour of the mask.
    #define WAKEUP_BUTTON                   99
    #define WAKEUP_BUTTON_EXT1_MASK         ((1ULL << PAUSEPLAY_BUTTON) | (1ULL << ROTARYENCODER_BUTTON))

    // (optional) Power-control transistor for peripherals during deepsleep.
    // Assigned to a spare pin; harmless unwired, wire later for battery use.
    // Moved 14 -> 47 when PAUSEPLAY took 14 (Power_Init drives this pin as
    // OUTPUT — sharing it with a button would short it to GND on press).
    #define POWER                           47
    #ifdef POWER
        //#define INVERT_POWER
    #endif

    // Neopixel ring: 330R in the data line, ~1000uF across its 5V rail.
    // Cap brightness ~30-40% via the web UI.
    #define LED_PIN                         21          // GPIO for Neopixel data

    // (optional) Headphone-detection — feature disabled on s3-proto
    #ifdef HEADPHONE_ADJUST_ENABLE
        //#define DETECT_HP_ON_HIGH
        #define HP_DETECT                   1           // spare; wire if ever enabled
    #endif

    // (optional) Battery voltage via ADC — feature disabled on s3-proto.
    // If enabled later: S3 ADC1 is GPIO1-10, so the spare pins 1/2/8/9 work.
    #ifdef MEASURE_BATTERY_VOLTAGE
        #define VOLTAGE_READ_PIN            1
        constexpr float offsetVoltage = 0.00;
        constexpr uint16_t rdiv1 = 100;
        constexpr uint16_t rdiv2 = 100;
        constexpr adc_attenuation_t inputAttenuation = ADC_11db;
    #endif

    #ifdef HALLEFFECT_SENSOR_ENABLE
        #define HallEffectSensor_PIN        2
    #endif

    #ifdef IR_CONTROL_ENABLE
        #define IRLED_PIN                   2
        #define IR_DEBOUNCE                 200
        #define RC_PLAY                     0x68
        #define RC_PAUSE                    0x67
        #define RC_NEXT                     0x6b
        #define RC_PREVIOUS                 0x6a
        #define RC_FIRST                    0x6c
        #define RC_LAST                     0x6d
        #define RC_VOL_UP                   0x1a
        #define RC_VOL_DOWN                 0x1b
        #define RC_MUTE                     0x1c
        #define RC_SHUTDOWN                 0x2a
        #define RC_BLUETOOTH                0x72
        #define RC_FTP                      0x65
    #endif
#endif
