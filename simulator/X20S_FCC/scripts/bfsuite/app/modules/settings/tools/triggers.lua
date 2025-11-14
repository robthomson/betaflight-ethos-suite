--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local enableWakeup = false

local function openPage(pageIdx, title, script)
    enableWakeup = true
    bfsuite.app.triggers.closeProgressLoader = true
    form.clear()

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("Settings" .. " / " .. "Triggers")

    local formFieldCount = 0
    local formLineCnt = 0
    bfsuite.app.formLines = {}
    bfsuite.app.formFields = {}

    formFieldCount = formFieldCount + 1
    formLineCnt = formLineCnt + 1
    bfsuite.app.formLines[formLineCnt] = form.addLine(" Arm Switch")
    bfsuite.app.formFields[formFieldCount] = form.addSwitchField(bfsuite.app.formLines[formLineCnt], nil, function()
        if bfsuite.session.modelPreferences  and bfsuite.session.modelPreferences.model and bfsuite.session.modelPreferences.model.armswitch then
            local category, member, options = bfsuite.session.modelPreferences.model.armswitch:match("([^:]+):([^:]+):([^:]+)")
            if category and member then return system.getSource({category = category, member = member, options = options}) end
        end
        return nil
    end, function(newValue)
        if bfsuite.session.modelPreferences then
            local member = newValue:member()
            local category = newValue:category()
            local options = newValue:options()
            if bfsuite.session.modelPreferences.model then
                bfsuite.session.modelPreferences.model.armswitch = category .. ":" .. member .. ":" .. options
            end
        end
    end)

    formFieldCount = formFieldCount + 1
    formLineCnt = formLineCnt + 1
    bfsuite.app.formLines[formLineCnt] = form.addLine("Inflight Switch")
    bfsuite.app.formFields[formFieldCount] = form.addSwitchField(bfsuite.app.formLines[formLineCnt], nil, function()
        if bfsuite.session.modelPreferences and bfsuite.session.modelPreferences.model and bfsuite.session.modelPreferences.model.inflightswitch then
            local category, member, options = bfsuite.session.modelPreferences.model.inflightswitch:match("([^:]+):([^:]+):([^:]+)")
            if category and member then return system.getSource({category = category, member = member, options = options}) end
        end
        return nil
    end, function(newValue)
        if bfsuite.session.modelPreferences then
            local member = newValue:member()
            local category = newValue:category()
            local options = newValue:options()
            if bfsuite.session.modelPreferences.model then
                bfsuite.session.modelPreferences.model.inflightswitch = category .. ":" .. member .. ":" .. options
            end
        end
    end)

    formFieldCount = formFieldCount + 1
    formLineCnt = formLineCnt + 1
    bfsuite.app.formLines[formLineCnt] = form.addLine("Inflight Delay")
    bfsuite.app.formFields[formFieldCount] = form.addNumberField(bfsuite.app.formLines[formLineCnt], nil, 0, 120, function()
        if bfsuite.session.modelPreferences and bfsuite.session.modelPreferences.model and bfsuite.session.modelPreferences.model.inflightswitch_delay then return bfsuite.session.modelPreferences.model.inflightswitch_delay end
        return nil
    end, function(newValue) if bfsuite.session.modelPreferences and bfsuite.session.modelPreferences.model then 
        bfsuite.session.modelPreferences.model.inflightswitch_delay = newValue end 
    end)
    bfsuite.app.formFields[formFieldCount]:suffix("s")
    bfsuite.app.formFields[formFieldCount]:default(20)

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

                if bfsuite.session.mcu_id and bfsuite.session.modelPreferencesFile then bfsuite.ini.save_ini_file(bfsuite.session.modelPreferencesFile, bfsuite.session.modelPreferences) end

                bfsuite.app.triggers.closeSave = true

                if bfsuite.tasks and bfsuite.tasks.sensors then bfsuite.tasks.sensors.reset() end

                return true
            end
        }, {label = "CANCEL", action = function() return true end}
    }

    form.openDialog({width = nil, title = "@i18n(app.modules.profile_select.save_dashx.preferences.model)@", message = "Save current page to radio?", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})
end

local function event(widget, category, value, x, y)

    if (category == EVT_CLOSE and value == 0) or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Settings", "model/model.lua")
        return true
    end
end

local function wakeup() if enableWakeup then if not bfsuite.session.isConnected then bfsuite.app.ui.openMainMenu() end end end

return {event = event, openPage = openPage, wakeup = wakeup, onNavMenu = onNavMenu, onSaveMenu = onSaveMenu, navButtons = {menu = true, save = true, reload = false, tool = false, help = false}, API = {}}
