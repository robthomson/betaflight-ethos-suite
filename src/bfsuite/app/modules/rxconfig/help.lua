--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local helpdata = {
    name = "RX Configuration",
    api = "RX_CONFIG",
    sections = {
        {
            title = "Receiver Configuration",
            items = {
                {
                    label = "RX Provider",
                    description = "Select the type of receiver protocol. Common options:\n• SERIAL: For UART-based receivers (SBUS, CRSF, etc.)\n• SPI: For built-in receivers\n• PPM/PWM: For analog receivers"
                },
                {
                    label = "Spektrum Bind",
                    description = "Spektrum satellite bind configuration. Use when binding Spektrum receivers."
                },
                {
                    label = "USB HID Type", 
                    description = "Configure how the flight controller appears as a USB device:\n• NONE: Disabled\n• JOYSTICK: Acts as joystick\n• GAMEPAD: Acts as gamepad"
                },
                {
                    label = "FPV Cam Angle",
                    description = "Camera angle in degrees for horizon line calculation in OSD."
                }
            }
        },
        {
            title = "Channel Limits",
            items = {
                {
                    label = "Min Check",
                    description = "Minimum RC value to consider stick movement. Usually around 1050us."
                },
                {
                    label = "Max Check", 
                    description = "Maximum RC value to consider stick movement. Usually around 1900us."
                },
                {
                    label = "Mid RC",
                    description = "Center point for RC channels. Standard is 1500us."
                },
                {
                    label = "Air Mode Threshold",
                    description = "Throttle threshold for enabling air mode (value x 0.1 + 1000us)."
                },
                {
                    label = "RX Min/Max",
                    description = "Full range of receiver output. Standard: 885-2115us."
                }
            }
        },
        {
            title = "RC Smoothing",
            items = {
                {
                    label = "Enable Smoothing",
                    description = "Enable RC input smoothing to reduce noise and jitter."
                },
                {
                    label = "Setpoint Cutoff",
                    description = "Low-pass filter frequency for roll/pitch/yaw channels (Hz)."
                },
                {
                    label = "Throttle Cutoff", 
                    description = "Low-pass filter frequency for throttle channel (Hz)."
                },
                {
                    label = "Auto Factor",
                    description = "Automatic smoothing adjustment based on RC link quality."
                }
            }
        },
        {
            title = "SPI RX Configuration",
            items = {
                {
                    label = "SPI Protocol",
                    description = "Protocol for built-in SPI receivers (FrSky, FlySky, etc.)."
                },
                {
                    label = "RF Channel Count",
                    description = "Number of RF channels for SPI receiver protocol."
                },
                {
                    label = "SPI ID",
                    description = "Unique identifier for SPI receiver binding."
                }
            }
        },
        {
            title = "ELRS Configuration", 
            items = {
                {
                    label = "ELRS UID",
                    description = "ExpressLRS unique identifier (6 bytes). Used for binding ELRS receivers. Get from transmitter or ExpressLRS Configurator."
                }
            }
        }
    }
}

return helpdata