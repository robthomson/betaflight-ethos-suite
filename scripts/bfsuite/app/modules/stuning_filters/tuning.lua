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

            {t = "@i18n(app.modules.simplified_tuning_filters.simplified_gyro_filter)@", mspapi = 1, apikey = "simplified_gyro_filter", type=1},
            {t = "@i18n(app.modules.simplified_tuning_filters.simplified_gyro_filter_multiplier)@", mspapi = 1, apikey = "simplified_gyro_filter_multiplier"},
            {t = "@i18n(app.modules.simplified_tuning_filters.simplified_dterm_filter)@", mspapi = 1, apikey = "simplified_dterm_filter"},
            {t = "@i18n(app.modules.simplified_tuning_filters.simplified_dterm_filter_multiplier)@", mspapi = 1, apikey = "simplified_dterm_filter_multiplier"},

        }
    }
}

return {apidata = apidata, eepromWrite = true, reboot = true, API = {}}
