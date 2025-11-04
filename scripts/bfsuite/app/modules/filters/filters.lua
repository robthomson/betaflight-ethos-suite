--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local filterModes = {[0] = "STATIC", [1] = "DYNAMIC"}

local apidata = {
    api = {[1] = 'FILTER_CONFIG'},
    formdata = {
        labels = {
            -- Gyro Lowpass Filters Section
            {t = "Gyro Lowpass 1", label = 1, inline_size = 14},
            {t = "    Static Cutoff", label = 2, inline_size = 14},
            {t = "    Dynamic Cutoff", label = 3, inline_size = 14},
            {t = "Gyro Lowpass 2", label = 4, inline_size = 14},

            {t = "D Term Lowpass 1", label = 5, inline_size = 14},
            {t = "    Static Cutoff", label = 6, inline_size = 14},
            {t = "    Dynamic Cutoff", label = 7, inline_size = 14},
            {t = "D Term Lowpass 2", label = 8, inline_size = 14},

            -- Gyro Notch Filters Section
            {t = "Gyro Notch 1", label = 9, inline_size = 14},
            {t = "Gyro Notch 2", label = 10, inline_size = 14},

            -- D-Term Notch Filter Section
            {t = "D-Term Notch", label = 11, inline_size = 14},
            {t = "", label = 12, inline_size = 14},

            -- Dynamic Notch Filter Section
            {t = "Dynamic Notch", label = 13, inline_size = 14},
            {t = "Dynamic Notch Range", label = 14, inline_size = 14},

            -- Yaw Lowpass Filter Section
            {t = "Yaw Lowpass", label = 15, inline_size = 14},
            {t = "", label = 15, inline_size = 14}
        },
        fields = {
            -- Gyro Lowpass Filters Section
            -- LPF1 
            -- Need to make "Mode" actually do something, currently it's just a placeholder
            {t = "Mode", label = 1, inline = 2, table = filterModes},
            {t = "Type", label = 1, inline = 1, mspapi = 1, apikey = "gyro_lpf1_type", type = 1},
            {t = "", label = 2, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_lpf1_static_hz"},
            {t = "Min", label = 3, inline = 1, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_min_hz"},
            {t = "Max", label = 3, inline = 2, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_max_hz"},

            -- LPF2
            {t = "Type", label = 4, inline = 1, mspapi = 1, apikey = "gyro_lpf2_type", type = 1},
            {t = "Cutoff", label = 4, inline = 2, mspapi = 1, unit = "Hz", apikey = "gyro_lpf2_static_hz"},
            
            -- D Term Lowpass Filters Section
            -- LPF1
            {t = "Mode", label = 5, inline = 2, table = filterModes},
            {t = "Type", label = 5, inline = 1, mspapi = 1, apikey = "dterm_lpf1_type", type = 1},
            {t = "", label = 6, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_lpf1_static_hz"},
            {t = "Min", label = 7, inline = 1, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_min_hz"},
            {t = "Max", label = 7, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_max_hz"},

            -- LPF2
            {t = "Type", label = 8, inline = 1, mspapi = 1, apikey = "dterm_lpf2_type", type = 1},
            {t = "Cutoff", label = 8, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf2_static_hz"},
            
            -- Gyro Notch Filters Section
            {t = "Center", label = 9, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_1"},
            {t = "Cutoff", label = 9, inline = 2, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_1"},

            {t = "Center", label = 10, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_2"},
            {t = "Cutoff", label = 10, inline = 2, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_2"},

            
            -- D-Term Notch Filter Section
            {t = "Center", label = 10, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_notch_hz"},
            {t = "Cutoff", label = 10, inline = 2, unit = "Hz", mspapi = 1, apikey = "dterm_notch_cutoff"},

            -- Dynamic Notch Filter Section
            {t = "Count", label = 11, inline = 1, mspapi = 1, apikey = "dyn_notch_count"},
            {t = "Q Factor", label = 11, inline = 2, unit = "Hz", mspapi = 1, apikey = "dyn_notch_q"},

            {t = "Min", label = 12, inline = 1, unit = "Hz", mspapi = 1, apikey = "dyn_notch_min_hz"},
            {t = "Max", label = 12, inline = 2, unit = "Hz", mspapi = 1, apikey = "dyn_notch_max_hz"},

            -- Yaw Lowpass Filter Section
            {t = "Cutoff", label = 13, inline = 1, unit = "Hz", mspapi = 1, apikey = "yaw_lowpass_hz"}
        }
    }
}

return {apidata = apidata, eepromWrite = true, reboot = true, API = {}}
