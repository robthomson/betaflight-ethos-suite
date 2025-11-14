--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local apidata = {
    api = {[1] = 'SIMPLIFIED_TUNING'},
    formdata = {
        labels = {
        },
        fields = {

            {t = "Gyro Filter", mspapi = 1, apikey = "simplified_gyro_filter", type=1},
            {t = "Multiplier", mspapi = 1, apikey = "simplified_gyro_filter_multiplier"},
            {t = "D-Term Filter", mspapi = 1, apikey = "simplified_dterm_filter"},
            {t = "Multiplier", mspapi = 1, apikey = "simplified_dterm_filter_multiplier"},

        }
    }
}

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "Filters", "filters/filters.lua")
end

return {apidata = apidata, eepromWrite = true, reboot = false, API = {}, onNavMenu = onNavMenu}
