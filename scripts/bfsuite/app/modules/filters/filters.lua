--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local filterModes = {[0] = "@i18n(api.FILTER_CONFIG.tbl_static)@", [1] = "@i18n(api.FILTER_CONFIG.tbl_dynamic)@"}

local loaded = false

local apidata = {
    api = {[1] = 'FILTER_CONFIG'},
    formdata = {
        labels = {
            -- Gyro Lowpass Filters Section
            {t = "Gyro Lowpass 1", label = 1, inline_size = 20},
            {t = "    Static Cutoff", label = 2, inline_size = 14},
            {t = "    Dynamic Cutoff", label = 3, inline_size = 14},
            {t = "    Filter Type", label = 4, inline_size = 14},
            {t = "Gyro Lowpass 2", label = 5, inline_size = 14},

            {t = "D Term Lowpass 1", label = 6, inline_size = 20},
            {t = "    Static Cutoff", label = 7, inline_size = 14},
            {t = "    Dynamic Cutoff", label = 8, inline_size = 14},
            {t = "    Filter Type", label = 9, inline_size = 14},
            {t = "D Term Lowpass 2", label = 10, inline_size = 14},

            -- Gyro Notch Filters Section
            {t = "Gyro Notch 1", label = 11, inline_size = 14},
            {t = "Gyro Notch 2", label = 12, inline_size = 14},

            -- D-Term Notch Filter Section
            {t = "D-Term Notch", label = 13, inline_size = 14},
            {t = "", label = 14, inline_size = 14},

            -- Dynamic Notch Filter Section
            {t = "Dynamic Notch", label = 15, inline_size = 14},
            {t = "Dynamic Notch Range", label = 16, inline_size = 14},

            -- Yaw Lowpass Filter Section
            {t = "Yaw Lowpass", label = 17, inline_size = 14},
            {t = "", label = 18, inline_size = 14}
        },
        fields = {
            -- Gyro Lowpass Filters Section
            -- LPF1 
            {t = "Mode", label = 1, inline = 1, table = filterModes, type = 1},
            {t = "", label = 2, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_lpf1_static_hz"},
            {t = "Min", label = 3, inline = 1, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_min_hz"},
            {t = "Max", label = 3, inline = 2, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_max_hz"},
            {t = "", label = 4, inline = 1, mspapi = 1, apikey = "gyro_lpf1_type", type = 1},

            -- LPF2
            {t = "Type", label = 5, inline = 1, mspapi = 1, apikey = "gyro_lpf2_type", type = 1},
            {t = "Cutoff", label = 5, inline = 2, mspapi = 1, unit = "Hz", apikey = "gyro_lpf2_static_hz"},
            

            -- D Term Lowpass Filters Section
            -- LPF1
            {t = "Mode", label = 6, inline = 1, table = filterModes, type = 1},
            {t = "", label = 7, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_lpf1_static_hz"},
            {t = "Min", label = 8, inline = 1, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_min_hz"},
            {t = "Max", label = 8, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_max_hz"},
            {t = "", label = 9, inline = 1, mspapi = 1, apikey = "dterm_lpf1_type", type = 1},

            -- LPF2
            {t = "Type", label = 10, inline = 1, mspapi = 1, apikey = "dterm_lpf2_type", type = 1},
            {t = "Cutoff", label = 10, inline = 2, mspapi = 1, unit = "Hz", apikey = "dterm_lpf2_static_hz"},
            

            -- Gyro Notch Filters Section
            {t = "Center", label = 11, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_1"},
            {t = "Cutoff", label = 11, inline = 2, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_1"},

            {t = "Center", label = 12, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_2"},
            {t = "Cutoff", label = 12, inline = 2, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_2"},

            
            -- D-Term Notch Filter Section
            {t = "Center", label = 13, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_notch_hz"},
            {t = "Cutoff", label = 13, inline = 2, unit = "Hz", mspapi = 1, apikey = "dterm_notch_cutoff"},


            -- Dynamic Notch Filter Section
            {t = "Count", label = 14, inline = 1, mspapi = 1, apikey = "dyn_notch_count"},
            {t = "Q Factor", label = 14, inline = 2, unit = "Hz", mspapi = 1, apikey = "dyn_notch_q"},

            {t = "Min", label = 15, inline = 1, unit = "Hz", mspapi = 1, apikey = "dyn_notch_min_hz"},
            {t = "Max", label = 15, inline = 2, unit = "Hz", mspapi = 1, apikey = "dyn_notch_max_hz"},


            -- Yaw Lowpass Filter Section
            {t = "Cutoff", label = 16, inline = 1, unit = "Hz", mspapi = 1, apikey = "yaw_lowpass_hz"}
        }
    }
}

local function updateFilterFieldStates()
    -- START GYRO_LPF1 --
    -- MSP does not set the gyro filter mode field value on load, so we have to infer its value from the other fields and set it explicitly
    if bfsuite.app.Page.apidata.formdata.fields[1].value == nil then 
        if bfsuite.app.Page.apidata.formdata.fields[3].value == 0 and bfsuite.app.Page.apidata.formdata.fields[4].value == 0 then -- dynamic min and max both 0, so static mode is in use
            bfsuite.app.Page.apidata.formdata.fields[1].value = 0 -- set to static mode
        else
            bfsuite.app.Page.apidata.formdata.fields[1].value = 1 -- set to dynamic mode
        end
    end

    -- Set field states after selecting a filter mode (dyn or sta)
    if bfsuite.app.Page.apidata.formdata.fields[1].value == 0 then -- static mode
        bfsuite.app.Page.apidata.formdata.fields[2].value = bfsuite.app.Page.apidata.formdata.fields[2].default -- set static hz to default when in static mode
        bfsuite.app.Page.apidata.formdata.fields[3].value = 0 -- set dynamic min to 0 when in static mode
        bfsuite.app.Page.apidata.formdata.fields[4].value = 0 -- set dynamic max to 0 when in static mode
        bfsuite.app.formFields[2]:enable(true) -- enable static cutoff field
        bfsuite.app.formFields[3]:enable(false) -- disable dynamic min field
        bfsuite.app.formFields[4]:enable(false) -- disable dynamic max field
    elseif bfsuite.app.Page.apidata.formdata.fields[1].value == 1 then -- dynamic mode
        bfsuite.app.Page.apidata.formdata.fields[2].value = 0 -- set static hz to 0 when in dynamic mode
        bfsuite.app.Page.apidata.formdata.fields[3].value = bfsuite.app.Page.apidata.formdata.fields[3].default -- set dynamic min to default value when in dynamic mode
        bfsuite.app.Page.apidata.formdata.fields[4].value = bfsuite.app.Page.apidata.formdata.fields[4].default -- set dynamic max to default value when in dynamic mode
        bfsuite.app.formFields[2]:enable(false)
        bfsuite.app.formFields[3]:enable(true)
        bfsuite.app.formFields[4]:enable(true)
    end
    -- END GYRO_LPF1 --

    -- START DTERM_LPF1 --
    -- MSP does not set the dterm filter mode field value on load, so we have to infer its value from the other fields and set it explicitly
    if bfsuite.app.Page.apidata.formdata.fields[8].value == nil then 
        if bfsuite.app.Page.apidata.formdata.fields[10].value == 0 and bfsuite.app.Page.apidata.formdata.fields[11].value == 0 then -- dynamic min and max both 0, so static mode is in use
            bfsuite.app.Page.apidata.formdata.fields[8].value = 0 -- set to static mode
        else
            bfsuite.app.Page.apidata.formdata.fields[8].value = 1 -- set to dynamic mode
        end
    end

    -- Set field states after selecting a filter mode (dyn or sta)
    if bfsuite.app.Page.apidata.formdata.fields[8].value == 0 then -- static mode
        bfsuite.app.Page.apidata.formdata.fields[9].value = bfsuite.app.Page.apidata.formdata.fields[9].default -- set static hz to default when in static mode
        bfsuite.app.Page.apidata.formdata.fields[10].value = 0 -- set dynamic min to 0 when in static mode
        bfsuite.app.Page.apidata.formdata.fields[11].value = 0 -- set dynamic max to 0 when in static mode
        bfsuite.app.formFields[9]:enable(true) -- enable static cutoff field
        bfsuite.app.formFields[10]:enable(false) -- disable dynamic min field
        bfsuite.app.formFields[11]:enable(false) -- disable dynamic max field
    elseif bfsuite.app.Page.apidata.formdata.fields[8].value == 1 then -- dynamic mode
        bfsuite.app.Page.apidata.formdata.fields[9].value = 0 -- set static hz to 0 when in dynamic mode
        bfsuite.app.Page.apidata.formdata.fields[10].value = bfsuite.app.Page.apidata.formdata.fields[10].default -- set dynamic min to default value when in dynamic mode
        bfsuite.app.Page.apidata.formdata.fields[11].value = bfsuite.app.Page.apidata.formdata.fields[11].default -- set dynamic max to default value when in dynamic mode
        bfsuite.app.formFields[9]:enable(false)
        bfsuite.app.formFields[10]:enable(true)
        bfsuite.app.formFields[11]:enable(true)
    end
    -- END DTERM_LPF1 --
end

local activateWakeup = false

local function wakeup()
    if activateWakeup then
        updateFilterFieldStates()    
    end
end

local function postLoad()
    bfsuite.app.triggers.isReady = true
    bfsuite.app.triggers.closeProgressLoader = true
    activateWakeup = true
end

return {wakeup = wakeup, postLoad = postLoad, apidata = apidata, eepromWrite = true, reboot = true, API = {}}
