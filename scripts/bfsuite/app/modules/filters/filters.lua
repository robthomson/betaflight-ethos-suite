--[[
  Copyright (C) 2025 Rotorflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local apidata = {
    api = {[1] = 'FILTER_CONFIG'},
    formdata = {
        labels = {
            -- Gyro Lowpass Filters Section
            {t = "Gyro Lowpass 1", label = 1, inline_size = 17.15},
            {t = "Dynamic", label = 2, inline_size = 17.15},
            {t = "", label = 3, inline_size = 25},
            {t = "Gyro Lowpass 2", label = 4, inline_size = 25},
            {t = "Dynamic", label = 5, inline_size = 20},
            {t = "", label = 6, inline_size = 25},

            -- D Term Lowpass Filters Section
            {t = "D Term Lowpass Filters", label = 7, inline_size = 25},
            {t = "", label = 8, inline_size = 25},
            {t = "D-Term LPF1 Dynamic", label = 9, inline_size = 25},
            {t = "", label = 10, inline_size = 25},
            {t = "D-Term LPF2", label = 11, inline_size = 25},
            {t = "", label = 12, inline_size = 25},

            -- Gyro Notch Filters Section
            {t = "Gyro Notch Filters", label = 13, inline_size = 25},
            {t = "", label = 14, inline_size = 25},
            {t = "Gyro Notch Filter 1", label = 15, inline_size = 25},
            {t = "", label = 16, inline_size = 25},
            {t = "Gyro Notch Filter 2", label = 17, inline_size = 25},
            {t = "", label = 18, inline_size = 25},

            -- D-Term Notch Filter Section
            {t = "D-Term Notch Filter", label = 19, inline_size = 25},
            {t = "", label = 20, inline_size = 25},

            -- Dynamic Notch Filter Section
            {t = "Dynamic Notch Filter", label = 21, inline_size = 25},
            {t = "", label = 22, inline_size = 25},
            {t = "Dynamic Notch Range", label = 23, inline_size = 25},
            {t = "", label = 24, inline_size = 25},

            -- Yaw Lowpass Filter Section
            {t = "Yaw Lowpass Filter", label = 25, inline_size = 25},
            {t = "", label = 26, inline_size = 25}
        },
        fields = {
            -- Gyro Lowpass Filters Section
            -- LPF1 
            -- Need to add "mode" (static and dynamic)
            {t = "Cutoff", label = 1, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_lpf1_static_hz"},
            {t = "Type", label = 1, inline = 2, mspapi = 1, apikey = "gyro_lpf1_type", type = 1},
            {t = "Min Cutoff", label = 2, inline = 1, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_min_hz"},
            {t = "Max Cutoff", label = 2, inline = 2, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_max_hz"},
            
            -- LPF2
            {t = "Cutoff", label = 3, inline = 2, mspapi = 1, unit = "Hz", apikey = "gyro_lpf2_static_hz"},
            {t = "Type", label = 3, inline = 1, mspapi = 1, apikey = "gyro_lpf2_type", type = 1},
            
            -- D Term Lowpass Filters Section
            {t = "Type", label = 4, inline = 1, mspapi = 1, apikey = "dterm_lpf1_type", type = 1},
            {t = "Static Cutoff", label = 4, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_static_hz"},

            {t = "Min Cutoff", label = 5, inline = 1, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_min_hz"},
            {t = "Max Cutoff", label = 5, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_max_hz"},
            {t = "Dynamic Expo", label = 5, inline = 3, mspapi = 1, apikey = "dterm_lpf1_dyn_expo"},
            
            {t = "Filter Type", label = 6, inline = 1, mspapi = 1, apikey = "dterm_lpf2_type", type = 1},
            {t = "Static Cutoff", label = 6, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf2_static_hz"},
            
            -- Gyro Notch Filters Section
            {t = "Center", label = 8, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_1"},
            {t = "Cutoff", label = 8, inline = 2, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_1"},

            {t = "Center", label = 9, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_2"},
            {t = "Cutoff", label = 9, inline = 2, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_2"},

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
