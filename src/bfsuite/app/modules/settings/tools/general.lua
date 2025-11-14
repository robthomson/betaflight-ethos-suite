--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local enableWakeup = false

local config = {}

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function openPage(pageIdx, title, script)
    enableWakeup = true
    if not bfsuite.app.navButtons then bfsuite.app.navButtons = {} end
    bfsuite.app.triggers.closeProgressLoader = true
    form.clear()

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("@i18n(app.modules.settings.name)@" .. " / " .. "@i18n(app.modules.settings.txt_general)@")
    bfsuite.app.formLineCnt = 0
    local formFieldCount = 0

    local saved = bfsuite.preferences.general or {}
    for k, v in pairs(saved) do config[k] = v end

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.txt_iconsize)@")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"@i18n(app.modules.settings.txt_text)@", 0}, {"@i18n(app.modules.settings.txt_small)@", 1}, {"@i18n(app.modules.settings.txt_large)@", 2}}, function() return config.iconsize ~= nil and config.iconsize or 1 end, function(newValue) config.iconsize = newValue end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.txt_hs_loader)@")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"@i18n(app.modules.settings.txt_hs_loader_fastclose)@", 0}, {"@i18n(app.modules.settings.txt_hs_loader_wait)@", 1}}, function() return config.hs_loader ~= nil and config.hs_loader or 1 end, function(newValue) config.hs_loader = newValue end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.txt_syncname)@")
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function() return config.syncname or false end, function(newValue) config.syncname = newValue end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("@i18n(app.modules.settings.txt_batttype)@")
    local txbattChoices = {{"@i18n(app.modules.settings.txt_battdef)@", 0}, {"@i18n(app.modules.settings.txt_batttext)@", 1}, {"@i18n(app.modules.settings.txt_battdig)@", 2}}
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, txbattChoices, function() return config.txbatt_type ~= nil and config.txbatt_type or 0 end, function(newValue)
        config.txbatt_type = newValue
        if bfsuite.preferences and bfsuite.preferences.general then bfsuite.preferences.general.txbatt_type = newValue end
    end)

    for i, field in ipairs(bfsuite.app.formFields) do if field and field.enable then field:enable(true) end end
    bfsuite.app.navButtons.save = true
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
                for key, value in pairs(config) do bfsuite.preferences.general[key] = value end
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

return {event = event, openPage = openPage, onNavMenu = onNavMenu, onSaveMenu = onSaveMenu, navButtons = {menu = true, save = true, reload = false, tool = false, help = false}, API = {}}
