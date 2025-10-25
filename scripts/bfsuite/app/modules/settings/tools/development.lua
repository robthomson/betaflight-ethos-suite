--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local settings = {}
local enableWakeup = false

local function openPage(pageIdx, title, script)
    enableWakeup = true
    bfsuite.app.triggers.closeProgressLoader = true
    form.clear()

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("@i18n(app.modules.settings.name)@" .. " / " .. "@i18n(app.modules.settings.txt_development)@")
    bfsuite.app.formLineCnt = 0

    local formFieldCount = 0

    settings = bfsuite.preferences.developer

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.txt_devtools)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['devtools'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.devtools = newValue end end)

    if system.getVersion().simulation then
        formFieldCount = formFieldCount + 1
        bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
        bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.txt_apiversion)@")
        bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, bfsuite.utils.msp_version_array_to_indexed(), function() return settings.apiversion end, function(newValue) settings.apiversion = newValue end)
    end

    local logpanel = form.addExpansionPanel("@i18n(app.modules.settings.txt_logging)@")
    logpanel:open(false)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_loglocation)@")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"@i18n(app.modules.settings.txt_console)@", 0}, {"@i18n(app.modules.settings.txt_consolefile)@", 1}}, function()
        if bfsuite.preferences and bfsuite.preferences.developer then
            if bfsuite.preferences.developer.logtofile == false then
                return 0
            else
                return 1
            end
        end
    end, function(newValue)
        if bfsuite.preferences and bfsuite.preferences.developer then
            local value
            if newValue == 0 then
                value = false
            else
                value = true
            end
            settings.logtofile = value
        end
    end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_loglevel)@")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"@i18n(app.modules.settings.txt_off)@", 0}, {"@i18n(app.modules.settings.txt_info)@", 1}, {"@i18n(app.modules.settings.txt_debug)@", 2}}, function()
        if bfsuite.preferences and bfsuite.preferences.developer then
            if settings['loglevel'] == "off" then
                return 0
            elseif settings['loglevel'] == "info" then
                return 1
            else
                return 2
            end
        end
    end, function(newValue)
        if bfsuite.preferences and bfsuite.preferences.developer then
            local value
            if newValue == 0 then
                value = "off"
            elseif newValue == 1 then
                value = "info"
            else
                value = "debug"
            end
            settings['loglevel'] = value
        end
    end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_mspdata)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['logmsp'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.logmsp = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_queuesize)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['logmspQueue'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.logmspQueue = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_memusage)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['memstats'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.memstats = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_taskprofiler)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['taskprofiler'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.taskprofiler = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_objectprofiler)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['logobjprof'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.logobjprof = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_overlaygrid)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['overlaygrid'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.overlaygrid = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_overlaystats)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['overlaystats'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.overlaystats = newValue end end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = logpanel:addLine("@i18n(app.modules.settings.txt_overlaystatsadmin)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() if bfsuite.preferences and bfsuite.preferences.developer then return settings['overlaystatsadmin'] end end, function(newValue) if bfsuite.preferences and bfsuite.preferences.developer then settings.overlaystatsadmin = newValue end end)

end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.name)@", "settings/settings.lua")
end

local function onSaveMenu()
    local buttons = {
        {
            label = "@i18n(app.btn_ok_long)@",
            action = function()
                local msg = "@i18n(app.modules.profile_select.save_prompt_local)@"
                bfsuite.app.ui.progressDisplaySave(msg:gsub("%?$", "."))
                for key, value in pairs(settings) do bfsuite.preferences.developer[key] = value end
                bfsuite.ini.save_ini_file("SCRIPTS:/" .. bfsuite.config.preferences .. "/preferences.ini", bfsuite.preferences)

                bfsuite.app.triggers.closeSave = true
                return true
            end
        }, {label = "@i18n(app.modules.profile_select.cancel)@", action = function() return true end}
    }

    form.openDialog({width = nil, title = "@i18n(app.modules.profile_select.save_settings)@", message = "@i18n(app.modules.profile_select.save_prompt_local)@", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})
end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.name)@", "settings/settings.lua")
        return true
    end
end

return {event = event, openPage = openPage, wakeup = wakeup, onNavMenu = onNavMenu, onSaveMenu = onSaveMenu, navButtons = {menu = true, save = true, reload = false, tool = false, help = false}, API = {}}
