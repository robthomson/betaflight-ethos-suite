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
            {t = "Stick Thresholds", label = 1, inline_size = 15},
            {t = "", label = 2, inline_size = 15},
            {t = "", label = 3, inline_size = 15},
            {t = "", label = 4, inline_size = 15},

            -- RC Smoothing Section
            {t = "RC Smoothing", label = 5, inline_size = 15},
            {t = "", label = 6, inline_size = 15},
            {t = "", label = 7, inline_size = 15}
        },
        fields = {
            -- Channel Limits Section
            {t = "", label = 1, inline = 1, type = 0, value=""}, -- blank line
            {t = "Low", label = 2, inline = 1, mspapi = 1, apikey = "mincheck", unit = "us", min = 750, max = 2250, default = 1050},
            {t = "Center", label = 2, inline = 2, mspapi = 1, apikey = "midrc", unit = "us", min = 1200, max = 1700, default = 1500},
            {t = "High", label = 2, inline = 3, mspapi = 1, apikey = "maxcheck", unit = "us", min = 750, max = 2250, default = 1900},
            
            {t = "Air Mode Threshold", label = 3, inline = 1, mspapi = 1, apikey = "airModeActivateThresholdX10p1000", unit="us", min = 0, max = 300, default = 25},
            
            -- RC Smoothing Section
            {t = "", label = 5, inline = 1, type = 0, value=""}, -- blank line
            {t = "State", label = 6, inline = 1, mspapi = 1, apikey = "rc_smoothing_enable", type = 1, min = 0, max = 1, default = 1},
            {t = "Auto Factor", label = 7, inline = 1, mspapi = 1, apikey = "rc_smoothing_auto_factor_rpy", min = 0, max = 250, default = 30},
        }
    }
}

return {apidata = apidata, eepromWrite = true, reboot = false, API = {}}