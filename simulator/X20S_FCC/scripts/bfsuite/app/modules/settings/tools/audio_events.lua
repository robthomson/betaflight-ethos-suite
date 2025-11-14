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

local function setFieldEnabled(field, enabled) if field and field.enable then field:enable(enabled) end end

local function openPage(pageIdx, title, script)
    enableWakeup = true
    if not bfsuite.app.navButtons then bfsuite.app.navButtons = {} end
    bfsuite.app.triggers.closeProgressLoader = true
    form.clear()

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("Settings" .. " / " .. "Audio" .. " / " .. "Events")
    bfsuite.app.formLineCnt = 0

    local formFieldCount = 0

    local app = bfsuite.app
    if app.formFields then for i = 1, #app.formFields do app.formFields[i] = nil end end
    if app.formLines then for i = 1, #app.formLines do app.formLines[i] = nil end end

    local eventList = bfsuite.tasks.events.telemetry.eventTable
    local eventNames = sensorNameMap(bfsuite.tasks.telemetry.listSensors())

    local savedEvents = bfsuite.preferences.events or {}
    for k, v in pairs(savedEvents) do config[k] = v end

    local escFields, becFields, fuelFields = {}, {}, {}

    local armEnabled = config.armflags == true
    local armPanel = form.addExpansionPanel("Arming Flags")
    armPanel:open(armEnabled)
    local armLine = armPanel:addLine("Arming Flags")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(armLine, nil, function() return config.armflags end, function(val) config.armflags = val end)

    local govEnabled = config.governor == true
    local govPanel = form.addExpansionPanel("Governor State")
    govPanel:open(govEnabled)
    local govLine = govPanel:addLine("Governor State")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(govLine, nil, function() return config.governor end, function(val) config.governor = val end)

    local voltEnabled = config.voltage == true
    local voltPanel = form.addExpansionPanel("Voltage")
    voltPanel:open(voltEnabled)
    local voltLine = voltPanel:addLine("Voltage")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(voltLine, nil, function() return config.voltage end, function(val) config.voltage = val end)

    local ratesEnabled = (config.pid_profile == true) or (config.rate_profile == true)
    local ratesPanel = form.addExpansionPanel("PID/Rates Profile")
    ratesPanel:open(ratesEnabled)
    local pidLine = ratesPanel:addLine("PID Profile")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(pidLine, nil, function() return config.pid_profile end, function(val) config.pid_profile = val end)
    local rateLine = ratesPanel:addLine("Rate Profile")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(rateLine, nil, function() return config.rate_profile end, function(val) config.rate_profile = val end)

    local escEnabled = config.temp_esc == true
    local escPanel = form.addExpansionPanel("ESC Temperature")
    escPanel:open(escEnabled)
    local escEnable = escPanel:addLine("ESC Temperature")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    escFields.enable = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(escEnable, nil, function() return config.temp_esc end, function(val)
        config.temp_esc = val
        setFieldEnabled(bfsuite.app.formFields[escFields.thresh], val)
    end)
    local escThresh = escPanel:addLine("Threshold (°)")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    escFields.thresh = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addNumberField(escThresh, nil, 60, 300, function() return config.escalertvalue or 90 end, function(val) config.escalertvalue = val end, 1)
    bfsuite.app.formFields[formFieldCount]:suffix("°")
    setFieldEnabled(bfsuite.app.formFields[escFields.thresh], escEnabled)

    local adjEnabled = (config.adj_f == true) or (config.adj_v == true)
    local adjPanel = form.addExpansionPanel("Adjustment Callouts")
    adjPanel:open(adjEnabled)

    local adjFuncLine = adjPanel:addLine("Adjustment Function")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(adjFuncLine, nil, function() return config.adj_f == true end, function(val) config.adj_f = val end)

    local adjValueLine = adjPanel:addLine("Adjustment Value")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(adjValueLine, nil, function() return config.adj_v == true end, function(val) config.adj_v = val end)

    local fuelEnabled = config.smartfuel == true
    local fuelPanel = form.addExpansionPanel("Fuel")
    fuelPanel:open(fuelEnabled)
    local fuelEnable = fuelPanel:addLine("Fuel")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    fuelFields.enable = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(fuelEnable, nil, function() return config.smartfuel end, function(val)
        config.smartfuel = val
        setFieldEnabled(bfsuite.app.formFields[fuelFields.callout], val)
        setFieldEnabled(bfsuite.app.formFields[fuelFields.repeats], val)
        setFieldEnabled(bfsuite.app.formFields[fuelFields.haptic], val)
    end)
    local calloutChoices = {{"Default (Only at 10%)", 0}, {"50% and 5%", 5}, {"Every 10%", 10}, {"Every 20%", 20}, {"Every 25%", 25}, {"Every 50%", 50}}
    local fuelThresh = fuelPanel:addLine("Callout %")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    fuelFields.callout = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addChoiceField(fuelThresh, nil, calloutChoices, function()
        local v = config.smartfuelcallout
        if v == nil or v == false then return 10 end
        return v
    end, function(val) config.smartfuelcallout = val end)
    setFieldEnabled(bfsuite.app.formFields[fuelFields.callout], fuelEnabled)

    local fuelRepeats = fuelPanel:addLine("Repeats below 0%")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    fuelFields.repeats = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addNumberField(fuelRepeats, nil, 1, 10, function() return config.smartfuelrepeats or 1 end, function(val) config.smartfuelrepeats = val end, 1)
    bfsuite.app.formFields[formFieldCount]:suffix("x")
    setFieldEnabled(bfsuite.app.formFields[fuelFields.repeats], fuelEnabled)

    local fuelHaptic = fuelPanel:addLine("Haptic below 0%")
    formFieldCount = formFieldCount + 1
    bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
    fuelFields.haptic = formFieldCount
    bfsuite.app.formFields[formFieldCount] = form.addBooleanField(fuelHaptic, nil, function() return config.smartfuelhaptic == true end, function(val) config.smartfuelhaptic = val end)
    setFieldEnabled(bfsuite.app.formFields[fuelFields.haptic], fuelEnabled)

    setFieldEnabled(bfsuite.app.formFields[escFields.enable], true)
    setFieldEnabled(bfsuite.app.formFields[becFields.enable], true)
    setFieldEnabled(bfsuite.app.formFields[fuelFields.enable], true)

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
                for key, value in pairs(config) do bfsuite.preferences.events[key] = value end
                bfsuite.ini.save_ini_file("SCRIPTS:/" .. bfsuite.config.preferences .. "/preferences.ini", bfsuite.preferences)
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
