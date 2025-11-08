--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local apidata = {
    api = {[1] = 'RX_CONFIG'},
    formdata = {
        labels = {
            -- Lots of sections removed as they either aren't in the configurator except for CLI or aren't something you want changed using your radio.
            -- Channel Limits Section
            {t = "Stick Thresholds", label = 1, inline_size = 13},
            {t = "", label = 2, inline_size = 13},
            {t = "", label = 3, inline_size = 13},
            {t = "", label = 4, inline_size = 13},

            -- RC Smoothing Section
            {t = "RC Smoothing", label = 5, inline_size = 13},
            {t = "", label = 6, inline_size = 13},
            {t = "", label = 7, inline_size = 13}
        },
        fields = {
            -- Channel Limits Section
            {t = "", label = 1, inline = 1, type = 0, value=""}, -- blank line
            {t = "Low", label = 2, inline = 1, mspapi = 1, apikey = "mincheck", unit = "us"},
            {t = "Center", label = 2, inline = 2, mspapi = 1, apikey = "midrc", unit = "us"},
            {t = "High", label = 2, inline = 3, mspapi = 1, apikey = "maxcheck", unit = "us"},
            
            {t = "Air Mode Threshold", label = 3, inline = 1, mspapi = 1, apikey = "airModeActivateThresholdX10p1000", unit="us"},
            
            -- RC Smoothing Section
            {t = "", label = 5, inline = 1, type = 0, value=""}, -- blank line
            {t = "State", label = 6, inline = 1, mspapi = 1, apikey = "rc_smoothing_enable", type = 1},
            {t = "Auto Factor", label = 7, inline = 1, mspapi = 1, apikey = "rc_smoothing_auto_factor_rpy"},
        }
    }
}

return {apidata = apidata, eepromWrite = true, reboot = false, API = {}}