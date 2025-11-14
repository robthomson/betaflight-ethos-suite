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

    bfsuite.app.ui.fieldHeader("Settings" .. " / " .. "Dashboard" .. " / " .. "Localization")
    bfsuite.app.formLineCnt = 0
    local formFieldCount = 0

    local saved = bfsuite.preferences.localizations or {}
    for k, v in pairs(saved) do config[k] = v end

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("Temperature Unit")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"Celsius", 0}, {"Fahrenheit", 1}}, function() return config.temperature_unit or 0 end, function(newValue) config.temperature_unit = newValue end)

    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine("Altitude Unit")
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, {{"Meters", 0}, {"Feet", 1}}, function() return config.altitude_unit or 0 end, function(newValue) config.altitude_unit = newValue end)

    for i, field in ipairs(bfsuite.app.formFields) do if field and field.enable then field:enable(true) end end
    bfsuite.app.navButtons.save = true
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "Settings", "settings/settings.lua")
    return true
end

local function onSaveMenu()
    local buttons = {
        {
            label = "                OK                ",
            action = function()
                local msg = "Save current page to radio?"
                bfsuite.app.ui.progressDisplaySave(msg:gsub("%?$", "."))
                for key, value in pairs(config) do bfsuite.preferences.localizations[key] = value end
                bfsuite.ini.save_ini_file("SCRIPTS:/" .. bfsuite.config.preferences .. "/preferences.ini", bfsuite.preferences)

                bfsuite.widgets.dashboard.reload_themes()

                bfsuite.app.triggers.closeSave = true
                return true
            end
        }, {label = "CANCEL", action = function() return true end}
    }

    form.openDialog({width = nil, title = "Save settings", message = "Save current page to radio?", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})
end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Settings", "settings/settings.lua")
        return true
    end
end

return {event = event, openPage = openPage, onNavMenu = onNavMenu, onSaveMenu = onSaveMenu, navButtons = {menu = true, save = true, reload = false, tool = false, help = false}, API = {}}
