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
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_pids_mode)@", mspapi = 1, apikey = "simplified_pids_mode", type = 1},
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_master_multiplier)@", mspapi = 1, apikey = "simplified_master_multiplier"},

            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_d_gain)@", mspapi = 1, apikey = "simplified_d_gain"},
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_pi_gain)@", mspapi = 1, apikey = "simplified_pi_gain"},
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_i_gain)@", mspapi = 1, apikey = "simplified_i_gain"},
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_feedforward_gain)@", mspapi = 1, apikey = "simplified_feedforward_gain"},
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_d_max_gain)@", mspapi = 1, apikey = "simplified_d_max_gain"},

            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_roll_pitch_ratio)@", mspapi = 1, apikey = "simplified_roll_pitch_ratio"},
            {t = "@i18n(app.modules.simplified_tuning_pids.simplified_pitch_pi_gain)@", mspapi = 1, apikey = "simplified_pitch_pi_gain"},

        }
    }
}

return {apidata = apidata, eepromWrite = true, reboot = true, API = {}}
