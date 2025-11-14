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
            {t = "Mode", mspapi = 1, apikey = "simplified_pids_mode", type = 1},
            {t = "Master Multiplier", mspapi = 1, apikey = "simplified_master_multiplier"},

            {t = "D Gain", mspapi = 1, apikey = "simplified_d_gain"},
            {t = "PI Gain", mspapi = 1, apikey = "simplified_pi_gain"},
            {t = "I Gain", mspapi = 1, apikey = "simplified_i_gain"},
            {t = "Feedforward Gain", mspapi = 1, apikey = "simplified_feedforward_gain"},
            {t = "D Max Gain", mspapi = 1, apikey = "simplified_d_max_gain"},

            {t = "D Roll/Pitch Ratio", mspapi = 1, apikey = "simplified_roll_pitch_ratio"},
            {t = "P,I,FF Roll/Pitch Ratio", mspapi = 1, apikey = "simplified_pitch_pi_gain"},

        }
    }
}


local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "PIDs", "pids/pids.lua")
end

return {apidata = apidata, eepromWrite = true, reboot = false, API = {}, onNavMenu = onNavMenu}
