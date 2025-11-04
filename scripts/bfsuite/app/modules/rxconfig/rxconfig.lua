--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local apidata = {
    api = {[1] = 'RX_CONFIG'},
    formdata = {
        labels = {
            -- Receiver Configuration Section
            -- {t = "Receiver Configuration", label = 1, inline_size = 25},
            -- {t = "", label = 2, inline_size = 25},
            
            -- Channel Limits Section
            {t = "Channel Limits", label = 1, inline_size = 15},
            {t = "", label = 2, inline_size = 15},
            {t = "", label = 3, inline_size = 15},
            {t = "", label = 4, inline_size = 15},

            -- Advanced Settings Section
            {t = "Advanced Settings", label = 5, inline_size = 18},
            {t = "", label = 6, inline_size = 15},
            {t = "", label = 7, inline_size = 15},

            -- RC Smoothing Section
            {t = "RC Smoothing Auto", label = 8, inline_size = 15},
            {t = "", label = 9, inline_size = 15},
            {t = "", label = 10, inline_size = 15},

            -- SPI RX Section
            --{t = "SPI RX Configuration", label = 12, inline_size = 25},
            --{t = "", label = 13, inline_size = 25},
            --{t = "", label = 14, inline_size = 25},
            
            -- ELRS Section
            -- {t = "ELRS Configuration", label = 15, inline_size = 25},
            -- {t = "", label = 16, inline_size = 25}
        },
        fields = {
            -- Removed because these aren't items you'd typically want to adjust on your radio.  Left for reference.
            -- Receiver Configuration Section
            --{t = "RX Provider", label = 1, inline = 1, mspapi = 1, apikey = "serialrx_provider", type = 1, table = rxProviders},
            --{t = "Spektrum Bind", label = 1, inline = 2, mspapi = 1, apikey = "spektrum_sat_bind"},
            
            --{t = "USB HID Type", label = 2, inline = 1, mspapi = 1, apikey = "usb_hid_type", type = 1, table = usbHidTypes},
            --{t = "FPV Cam Angle", label = 2, inline = 2, mspapi = 1, apikey = "fpvCamAngleDegrees", unit = "°"},
            
            -- Channel Limits Section
            {t = "Channel Limits", label = 1, inline = 1, type = 4}, -- blank line
            {t = "Min Check", label = 2, inline = 1, mspapi = 1, apikey = "mincheck", unit = "us"},
            {t = "Max Check", label = 2, inline = 2, mspapi = 1, apikey = "maxcheck", unit = "us"},
            
            {t = "Mid RC", label = 3, inline = 1, mspapi = 1, apikey = "midrc", unit = "us"},
            {t = "Air Mode Threshold", label = 3, inline = 2, mspapi = 1, apikey = "airModeActivateThresholdX10p1000", unit="us"},
            
            {t = "RX Min", label = 4, inline = 1, mspapi = 1, apikey = "rx_min_usec", unit = "us"},
            {t = "RX Max", label = 4, inline = 2, mspapi = 1, apikey = "rx_max_usec", unit = "us"},
            
            -- RC Smoothing Section
            {t = "Smoothing", label = 5, inline = 1, mspapi = 1, apikey = "rc_smoothing_enable", type = 1},
            
            {t = "Setpoint Cutoff", label = 6, inline = 1, mspapi = 1, apikey = "rc_smoothing_setpoint_cutoff", unit = "Hz"},
            {t = "Throttle Cutoff", label = 6, inline = 2, mspapi = 1, apikey = "rc_smoothing_throttle_cutoff", unit = "Hz"},
            
            {t = "RPY", label = 7, inline = 1, mspapi = 1, apikey = "rc_smoothing_auto_factor_rpy"},
            {t = "Throttle", label = 7, inline = 2, mspapi = 1, apikey = "rc_smoothing_auto_factor_throttle"},
            

            -- Below Sections Removed Due to not being needed for on-radio configuration.  Left in here just in case....
            -- SPI RX Section
            -- {t = "SPI Protocol", label = 12, inline = 1, mspapi = 1, apikey = "rx_spi_protocol", type = 1, table = spiProtocols},
            --{t = "RF Channel Count", label = 12, inline = 2, mspapi = 1, apikey = "rx_spi_rf_channel_count"},
             
            -- {t = "SPI ID", label = 13, inline = 1, mspapi = 1, apikey = "rx_spi_id"},
            
            -- ELRS Configuration Section
            --{t = "ELRS UID 0", label = 15, inline = 1, mspapi = 1, apikey = "elrs_uid_0"},
            --{t = "ELRS UID 1", label = 15, inline = 2, mspapi = 1, apikey = "elrs_uid_1"},
            --{t = "ELRS UID 2", label = 15, inline = 3, mspapi = 1, apikey = "elrs_uid_2"},
            
            --{t = "ELRS UID 3", label = 16, inline = 1, mspapi = 1, apikey = "elrs_uid_3"},
            --{t = "ELRS UID 4", label = 16, inline = 2, mspapi = 1, apikey = "elrs_uid_4"},
            --{t = "ELRS UID 5", label = 16, inline = 3, mspapi = 1, apikey = "elrs_uid_5"}
        }
    }
}

return {apidata = apidata, eepromWrite = true, reboot = false, API = {}}