--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local enableWakeup = false

local config = {}

local function openPage(pageIdx, title, script)
    enableWakeup = true
    if not bfsuite.app.navButtons then bfsuite.app.navButtons = {} end
    bfsuite.app.triggers.closeProgressLoader = true

    form.clear()

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("@i18n(app.modules.settings.name)@" .. " / " .. "@i18n(app.modules.settings.audio)@" .. " / " .. "@i18n(app.modules.settings.txt_audio_timer)@")

    bfsuite.app.formLineCnt = 0
    local formFieldCount = 0

    local saved = bfsuite.preferences.timer or {}
    for k, v in pairs(saved) do config[k] = v end

    local intervalChoices = {{"10s", 10}, {"15s", 15}, {"30s", 30}}
    local periodChoices = {{"30s", 30}, {"60s", 60}, {"90s", 90}}

    local idxAudio, idxChoice, idxPre, idxPrePeriod, idxPreInterval, idxPost, idxPostPeriod, idxPostInterval

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.timer_alerting)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() return config.timeraudioenable or false end, function(newValue)
        config.timeraudioenable = newValue
        bfsuite.app.formFields[idxChoice]:enable(newValue)
        bfsuite.app.formFields[idxPre]:enable(newValue)
        bfsuite.app.formFields[idxPost]:enable(newValue)
        bfsuite.app.formFields[idxPrePeriod]:enable(newValue and (config.prealerton or false))
        bfsuite.app.formFields[idxPreInterval]:enable(newValue and (config.prealerton or false))
        bfsuite.app.formFields[idxPostPeriod]:enable(newValue and (config.postalerton or false))
        bfsuite.app.formFields[idxPostInterval]:enable(newValue and (config.postalerton or false))
    end)
    idxAudio = formFieldCount

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.timer_elapsed_alert_mode)@")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"Beep", 0}, {"Multi Beep", 1}, {"Timer Elapsed", 2}, {"Timer Seconds", 3}}, function() return config.elapsedalertmode or 0 end, function(newValue) config.elapsedalertmode = newValue end)
    idxChoice = formFieldCount

    local prePanel = form.addExpansionPanel("@i18n(app.modules.settings.timer_prealert_options)@")
    prePanel:open(config.prealerton or false)

    formFieldCount = formFieldCount + 1
    idxPre = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(prePanel:addLine("@i18n(app.modules.settings.timer_prealert)@"), nil, function() return config.prealerton or false end, function(newValue)
        config.prealerton = newValue
        local audioEnabled = config.timeraudioenable or false
        bfsuite.app.formFields[idxPrePeriod]:enable(audioEnabled and newValue)
        bfsuite.app.formFields[idxPreInterval]:enable(audioEnabled and newValue)
    end)

    formFieldCount = formFieldCount + 1
    idxPrePeriod = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(prePanel:addLine("@i18n(app.modules.settings.timer_alert_period)@"), nil, periodChoices, function() return config.prealertperiod or 30 end, function(newValue) config.prealertperiod = newValue end)
    bfsuite.app.formFields[formFieldCount]:enable((config.timeraudioenable or false) and (config.prealerton or false))

    formFieldCount = formFieldCount + 1
    idxPreInterval = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(prePanel:addLine("Alert Interval"), nil, intervalChoices, function() return config.prealertinterval or 10 end, function(newValue) config.prealertinterval = newValue end)
    bfsuite.app.formFields[formFieldCount]:enable((config.timeraudioenable or false) and (config.prealerton or false))

    local postPanel = form.addExpansionPanel("@i18n(app.modules.settings.timer_postalert_options)@")
    postPanel:open(config.postalerton or false)

    formFieldCount = formFieldCount + 1
    idxPost = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(postPanel:addLine("@i18n(app.modules.settings.timer_postalert)@"), nil, function() return config.postalerton or false end, function(newValue)
        config.postalerton = newValue
        local audioEnabled = config.timeraudioenable or false
        bfsuite.app.formFields[idxPostPeriod]:enable(audioEnabled and newValue)
        bfsuite.app.formFields[idxPostInterval]:enable(audioEnabled and newValue)
    end)

    formFieldCount = formFieldCount + 1
    idxPostPeriod = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(postPanel:addLine("@i18n(app.modules.settings.timer_alert_period)@"), nil, periodChoices, function() return config.postalertperiod or 60 end, function(newValue) config.postalertperiod = newValue end)
    bfsuite.app.formFields[formFieldCount]:enable((config.timeraudioenable or false) and (config.postalerton or false))

    formFieldCount = formFieldCount + 1
    idxPostInterval = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(postPanel:addLine("@i18n(app.modules.settings.timer_postalert_interval)@"), nil, intervalChoices, function() return config.postalertinterval or 10 end, function(newValue) config.postalertinterval = newValue end)
    bfsuite.app.formFields[formFieldCount]:enable((config.timeraudioenable or false) and (config.postalerton or false))

    bfsuite.app.formFields[idxChoice]:enable(config.timeraudioenable or false)
    bfsuite.app.formFields[idxPre]:enable(config.timeraudioenable or false)
    bfsuite.app.formFields[idxPrePeriod]:enable((config.timeraudioenable or false) and (config.prealerton or false))
    bfsuite.app.formFields[idxPreInterval]:enable((config.timeraudioenable or false) and (config.prealerton or false))
    bfsuite.app.formFields[idxPost]:enable(config.timeraudioenable or false)
    bfsuite.app.formFields[idxPostPeriod]:enable((config.timeraudioenable or false) and (config.postalerton or false))
    bfsuite.app.formFields[idxPostInterval]:enable((config.timeraudioenable or false) and (config.postalerton or false))
    bfsuite.app.navButtons.save = true
end

local function onSaveMenu()
    local buttons = {
        {
            label = "@i18n(app.btn_ok_long)@",
            action = function()
                local msg = "@i18n(app.modules.profile_select.save_prompt_local)@"
                bfsuite.app.ui.progressDisplaySave(msg:gsub("%?$", "."))
                for key, value in pairs(config) do bfsuite.preferences.timer[key] = value end
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
        bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.name)@", "settings/tools/audio.lua")
        return true
    end
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.name)@", "settings/tools/audio.lua")
end

return {event = event, openPage = openPage, onNavMenu = onNavMenu, onSaveMenu = onSaveMenu, navButtons = {menu = true, save = true, reload = false, tool = false, help = false}, API = {}}
