--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local config = {}
local enableWakeup = false

local function sensorNameMap(sensorList)
    local nameMap = {}
    for _, sensor in ipairs(sensorList) do nameMap[sensor.key] = sensor.name end
    return nameMap
end

local function openPage(pageIdx, title, script)
    enableWakeup = true
    if not bfsuite.app.navButtons then bfsuite.app.navButtons = {} end
    bfsuite.app.triggers.closeProgressLoader = true
    form.clear()

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("Settings" .. " / " .. "Audio" .. " / " .. "Switches")
    bfsuite.app.formLineCnt = 0

    local formFieldCount = 0

    local function sortSensorListByName(sensorList)
        table.sort(sensorList, function(a, b) return a.name:lower() < b.name:lower() end)
        return sensorList
    end

    local sensorList = sortSensorListByName(bfsuite.tasks.telemetry.listSwitchSensors())

    local saved = bfsuite.preferences.switches or {}
    for k, v in pairs(saved) do config[k] = v end

    for i, v in ipairs(sensorList) do
        formFieldCount = formFieldCount + 1
        bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
        bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine(v.name or "unknown")

        bfsuite.app.formFields[formFieldCount] = form.addSwitchField(bfsuite.app.formLines[bfsuite.app.formLineCnt], nil, function()
            local value = config[v.key]
            if value then
                local scategory, smember = value:match("([^,]+),([^,]+)")
                if scategory and smember then
                    local source = system.getSource({category = tonumber(scategory), member = tonumber(smember)})
                    return source
                end
            end
            return nil
        end, function(newValue)
            if newValue then
                local cat_member = newValue:category() .. "," .. newValue:member()
                config[v.key] = cat_member
            else
                config[v.key] = nil
            end
        end)
    end

    for i, field in ipairs(bfsuite.app.formFields) do if field and field.enable then field:enable(true) end end
    bfsuite.app.navButtons.save = true
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "Settings", "settings/tools/audio.lua")
end

local function onSaveMenu()
    local buttons = {
        {
            label = "                OK                ",
            action = function()
                local msg = "Save current page to radio?"
                bfsuite.app.ui.progressDisplaySave(msg:gsub("%?$", "."))
                for key, value in pairs(config) do bfsuite.preferences.switches[key] = value end
                bfsuite.ini.save_ini_file("SCRIPTS:/" .. bfsuite.config.preferences .. "/preferences.ini", bfsuite.preferences)
                bfsuite.tasks.events.switches.resetSwitchStates()
                bfsuite.app.triggers.closeSave = true
                return true
            end
        }, {label = "CANCEL", action = function() return true end}
    }

    form.openDialog({width = nil, title = "Save settings", message = "Save current page to radio?", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})
end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Settings", "settings/tools/audio.lua")
        return true
    end
end

return {event = event, openPage = openPage, onNavMenu = onNavMenu, onSaveMenu = onSaveMenu, navButtons = {menu = true, save = true, reload = false, tool = false, help = false}, API = {}}
