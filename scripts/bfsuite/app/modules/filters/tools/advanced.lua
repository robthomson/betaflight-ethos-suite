--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local filterModes = {[0] = "@i18n(api.FILTER_CONFIG.tbl_static)@", [1] = "@i18n(api.FILTER_CONFIG.tbl_dynamic)@"}

local apidata = {
    api = {[1] = 'FILTER_CONFIG'},
    formdata = {
        labels = {
            -- Gyro Lowpass Filters Section
            {t = "@i18n(app.modules.filters.gyro_lowpass_1)@", label = 1, inline_size = 50},
            {t = "    @i18n(app.modules.filters.mode)@", label = 2, inline_size = 50},
            {t = "    @i18n(app.modules.filters.static_cutoff)@", label = 3, inline_size = 50},
            {t = "    @i18n(app.modules.filters.dynamic_cutoff_max)@", label = 4, inline_size = 50},
            {t = "    @i18n(app.modules.filters.dynamic_cutoff_min)@", label = 5, inline_size = 50},
            {t = "    @i18n(app.modules.filters.filter_type)@", label = 6, inline_size = 50},
            {t = "@i18n(app.modules.filters.gyro_lowpass_2)@", label = 7, inline_size = 50},
            {t = "    @i18n(app.modules.filters.cutoff)@", label = 8, inline_size = 50},
            {t = "    @i18n(app.modules.filters.filter_type)@", label = 9, inline_size = 50},

            -- D Term Lowpass Filters Section
            {t = "@i18n(app.modules.filters.d_term_lowpass_1)@", label = 10, inline_size = 50},
            {t = "    @i18n(app.modules.filters.mode)@", label = 11, inline_size = 50},
            {t = "    @i18n(app.modules.filters.static_cutoff)@", label = 12, inline_size = 50},
            {t = "    @i18n(app.modules.filters.dynamic_cutoff_max)@", label = 13, inline_size = 50},
            {t = "    @i18n(app.modules.filters.dynamic_cutoff_min)@", label = 14, inline_size = 50},
            {t = "    @i18n(app.modules.filters.filter_type)@", label = 15, inline_size = 50},
            {t = "@i18n(app.modules.filters.d_term_lowpass_2)@", label = 16, inline_size = 50},
            {t = "    @i18n(app.modules.filters.cutoff)@", label = 17, inline_size = 50},
            {t = "    @i18n(app.modules.filters.filter_type)@", label = 18, inline_size = 50},

            -- Gyro Notch Filters Section
            {t = "@i18n(app.modules.filters.gyro_notch_1)@", label = 19, inline_size = 50},
            {t = "    @i18n(app.modules.filters.gyro_notch_center_freq)@", label = 20, inline_size = 50},
            {t = "    @i18n(app.modules.filters.gyro_notch_cutoff)@", label = 21, inline_size = 50},
            {t = "@i18n(app.modules.filters.gyro_notch_2)@", label = 22, inline_size = 50},
            {t = "    @i18n(app.modules.filters.gyro_notch_center_freq)@", label = 23, inline_size = 50},
            {t = "    @i18n(app.modules.filters.gyro_notch_cutoff)@", label = 24, inline_size = 50},
            -- D-Term Notch Filter Section
            {t = "@i18n(app.modules.filters.d_term_notch)@", label = 25, inline_size = 50},
            {t = "    @i18n(app.modules.filters.center_freq)@", label = 26, inline_size = 50},
            {t = "    @i18n(app.modules.filters.cutoff)@", label = 27, inline_size = 50},
            -- Dynamic Notch Filter Section
            {t = "@i18n(app.modules.filters.dynamic_notch)@", label = 28, inline_size = 50},
            {t = "    @i18n(app.modules.filters.notch_count)@", label = 29, inline_size = 50},
            {t = "    @i18n(app.modules.filters.q_factor)@", label = 30, inline_size = 50},
            {t = "    @i18n(app.modules.filters.min_freq)@", label = 31, inline_size = 50},
            {t = "    @i18n(app.modules.filters.max_freq)@", label = 32, inline_size = 50},

            -- Yaw Lowpass Filter Section
            {t = "@i18n(app.modules.filters.yaw_lowpass)@", label = 33, inline_size = 50},
            {t = "    @i18n(app.modules.filters.static_cutoff)@", label = 34, inline_size = 50}
        },
        fields = {
            -- Gyro Lowpass Filters Section
            -- LPF1 
            {t = "", label = 1, inline = 1, type = 4}, -- Boolean to enable/disable Gyro LPF1
            {t = "", label = 2, inline = 1, table = filterModes, type = 1},
            {t = "", label = 3, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_lpf1_static_hz"},
            {t = "", label = 4, inline = 1, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_min_hz"},
            {t = "", label = 5, inline = 1, mspapi = 1, unit = "Hz", apikey = "gyro_lpf1_dyn_max_hz"},
            {t = "", label = 6, inline = 1, mspapi = 1, apikey = "gyro_lpf1_type", type = 1},

            -- LPF2
            {t = "", label = 7, inline = 1, type = 4}, -- Boolean to enable/disable Gyro LPF2
            {t = "", label = 8, inline = 1, mspapi = 1, unit = "Hz", apikey = "gyro_lpf2_static_hz"},
            {t = "", label = 9, inline = 1, mspapi = 1, apikey = "gyro_lpf2_type", type = 1},
            

            -- D Term Lowpass Filters Section
            -- LPF1
            {t = "", label = 10, inline = 1, type = 4}, -- Boolean to enable/disable D Term LPF1
            {t = "", label = 11, inline = 1, table = filterModes, type = 1},
            {t = "", label = 12, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_lpf1_static_hz"},
            {t = "", label = 13, inline = 1, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_min_hz"},
            {t = "", label = 14, inline = 1, mspapi = 1, unit = "Hz", apikey = "dterm_lpf1_dyn_max_hz"},
            {t = "", label = 15, inline = 1, mspapi = 1, apikey = "dterm_lpf1_type", type = 1},

            -- LPF2
            {t = "", label = 16, inline = 1, type = 4}, -- Boolean to enable/disable D Term LPF2
            {t = "", label = 17, inline = 1, mspapi = 1, unit = "Hz", apikey = "dterm_lpf2_static_hz"},
            {t = "", label = 18, inline = 1, mspapi = 1, apikey = "dterm_lpf2_type", type = 1},
            

            -- Gyro Notch Filters Section
            -- Notch 1
            {t = "", label = 19, inline = 1, type = 4}, -- Boolean to enable/disable Gyro Notch 1
            {t = "", label = 20, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_1"},
            {t = "", label = 21, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_1"},

            -- Notch 2
            {t = "", label = 22, inline = 1, type = 4}, -- Boolean to enable/disable Gyro Notch 2
            {t = "", label = 23, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_hz_2"},
            {t = "", label = 24, inline = 1, unit = "Hz", mspapi = 1, apikey = "gyro_soft_notch_cutoff_2"},


            -- D-Term Notch Filter Section
            {t = "", label = 25, inline = 1, type = 4}, -- Boolean to enable/disable D-Term Notch
            {t = "", label = 26, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_notch_hz"},
            {t = "", label = 27, inline = 1, unit = "Hz", mspapi = 1, apikey = "dterm_notch_cutoff"},


            -- Dynamic Notch Filter Section
            {t = "", label = 28, inline = 1, type = 4}, -- Boolean to enable/disable Dynamic Notch
            {t = "", label = 29, inline = 1, mspapi = 1, apikey = "dyn_notch_count"},
            {t = "", label = 30, inline = 1, unit = "Hz", mspapi = 1, apikey = "dyn_notch_q"},
            {t = "", label = 31, inline = 1, unit = "Hz", mspapi = 1, apikey = "dyn_notch_min_hz"},
            {t = "", label = 32, inline = 1, unit = "Hz", mspapi = 1, apikey = "dyn_notch_max_hz"},


            -- Yaw Lowpass Filter Section
            {t = "", label = 33, inline = 1, type = 4}, -- Boolean to enable/disable Yaw Lowpass
            {t = "", label = 34, inline = 1, unit = "Hz", mspapi = 1, apikey = "yaw_lowpass_hz"}
        }
    }
}


local function zeroOutFieldRange(startField, endField)
    for i = startField, endField do
        bfsuite.app.Page.apidata.formdata.fields[i].value = 0
    end
end

local function rangeHasNonZeroValue(startField, endField)
    for i = startField, endField do
        if bfsuite.app.Page.apidata.formdata.fields[i].value ~= 0 then
            return 1
        end
    end
    return 0
end

-- Configuration for filters: their boolean field, fields to check for non-zero values, and fields to enable/disable based on states and settings
local filterConfig = {
    {
        name = "gyro_lpf1",    -- Filter identifier
        state = nil,           -- Will hold the enabled/disabled state
        booleanField = 1,      -- Field index for the enable/disable checkbox
        modeField = 2,         -- Mode dropdown field (static=0, dynamic=1)
        checkFields = {3, 5},  -- Fields to check for non-zero values
        staticFields = {3, 3}, -- Field(s) shown in static mode
        dynamicFields = {4, 5}, -- Field(s) shown in dynamic mode
        uiFields = {2, 6}      -- All fields to enable/disable
    },
    {
        name = "gyro_lpf2",
        state = nil,
        booleanField = 7,
        checkFields = {8, 8},
        uiFields = {8, 9}
    },
    {
        name = "dterm_lpf1",
        state = nil,
        booleanField = 10,
        modeField = 11,
        checkFields = {12, 14},
        staticFields = {12, 12},
        dynamicFields = {13, 14},
        uiFields = {11, 15}
    },
    {
        name = "dterm_lpf2",
        state = nil,
        booleanField = 16,
        checkFields = {17, 17},
        uiFields = {17, 18}
    },
    {
        name = "gyro_notch1",
        state = nil,
        booleanField = 19,
        checkFields = {20, 21},
        uiFields = {20, 21}
    },
    {
        name = "gyro_notch2",
        state = nil,
        booleanField = 22,
        checkFields = {23, 24},
        uiFields = {23, 24}
    },
    {
        name = "dterm_notch",
        state = nil,
        booleanField = 25,
        checkFields = {26, 27},
        uiFields = {26, 27}
    },
    {
        name = "dynamic_notch",
        state = nil,
        booleanField = 28,
        checkFields = {29, 32},
        uiFields = {29, 32}
    },
    {
        name = "yaw_lowpass",
        state = nil,
        booleanField = 33,
        checkFields = {34, 34},
        uiFields = {34, 34}
    }
}

-- Helper function to get the initial states of the boolean or dropdown fields based on a range of value fields 
local function getInitialFieldStates()
    for _, filter in ipairs(filterConfig) do
        local hasNonZero = rangeHasNonZeroValue(filter.checkFields[1], filter.checkFields[2])
        filter.state = hasNonZero
        bfsuite.app.Page.apidata.formdata.fields[filter.booleanField].value = hasNonZero
        
        -- For filters with mode field, set initial mode based on which fields have values
        if filter.modeField and hasNonZero == 1 then
            local staticHasValue = rangeHasNonZeroValue(filter.staticFields[1], filter.staticFields[2])
            local dynamicHasValue = rangeHasNonZeroValue(filter.dynamicFields[1], filter.dynamicFields[2])
            
            if dynamicHasValue == 1 then
                bfsuite.app.Page.apidata.formdata.fields[filter.modeField].value = 1 -- Dynamic mode
            else
                bfsuite.app.Page.apidata.formdata.fields[filter.modeField].value = 0 -- Static mode
            end
        end
    end
end

local function updateFieldStates()
    for _, filter in ipairs(filterConfig) do
        local oldState = filter.state
        filter.state = bfsuite.app.Page.apidata.formdata.fields[filter.booleanField].value
        
        if filter.state == 0 then
            -- User disabled: zero out values
            zeroOutFieldRange(filter.checkFields[1], filter.checkFields[2])
        elseif oldState == 0 and filter.state == 1 then
            -- User re-enabled: set to defaults
            for i = filter.checkFields[1], filter.checkFields[2] do
                bfsuite.app.Page.apidata.formdata.fields[i].value = bfsuite.app.Page.apidata.formdata.fields[i].default
            end
        end
        
        -- Enable/disable all UI fields based on main state
        for i = filter.uiFields[1], filter.uiFields[2] do
            bfsuite.app.formFields[i]:enable(filter.state == 1)
        end
        
        -- Handle mode-based field visibility (only for filters with modeField)
        if filter.modeField and filter.state == 1 then
            local mode = bfsuite.app.Page.apidata.formdata.fields[filter.modeField].value
            if mode == 0 then
                -- Static mode: show static fields with defaults, hide and zero dynamic fields
                for i = filter.staticFields[1], filter.staticFields[2] do
                    bfsuite.app.formFields[i]:enable(true)
                    if bfsuite.app.Page.apidata.formdata.fields[i].value == 0 then
                        bfsuite.app.Page.apidata.formdata.fields[i].value = bfsuite.app.Page.apidata.formdata.fields[i].default
                    end
                end
                for i = filter.dynamicFields[1], filter.dynamicFields[2] do
                    bfsuite.app.formFields[i]:enable(false)
                    bfsuite.app.Page.apidata.formdata.fields[i].value = 0
                end
            else
                -- Dynamic mode: hide and zero static fields, show dynamic fields with defaults
                for i = filter.staticFields[1], filter.staticFields[2] do
                    bfsuite.app.formFields[i]:enable(false)
                    bfsuite.app.Page.apidata.formdata.fields[i].value = 0
                end
                for i = filter.dynamicFields[1], filter.dynamicFields[2] do
                    bfsuite.app.formFields[i]:enable(true)
                    if bfsuite.app.Page.apidata.formdata.fields[i].value == 0 then
                        bfsuite.app.Page.apidata.formdata.fields[i].value = bfsuite.app.Page.apidata.formdata.fields[i].default
                    end
                end
            end
        end
    end
end

local activateWakeup = false

local function wakeup()
    if activateWakeup then
        updateFieldStates()    
    end
end

local function postLoad()
    getInitialFieldStates()
    activateWakeup = true
    bfsuite.app.triggers.isReady = true
    bfsuite.app.triggers.closeProgressLoader = true
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.filters.name)@", "filters/filters.lua")
end

return {wakeup = wakeup, postLoad = postLoad, apidata = apidata, eepromWrite = true, reboot = true, API = {}, onNavMenu = onNavMenu}
