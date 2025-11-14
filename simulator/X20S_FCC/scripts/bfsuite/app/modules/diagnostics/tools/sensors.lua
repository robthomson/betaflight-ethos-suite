--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local fields = {}
local labels = {}

local enableWakeup = false

local w, h = lcd.getWindowSize()
local buttonW = 100
local buttonWs = buttonW - (buttonW * 20) / 100
local x = w - 15

local displayPos = {x = x - buttonW - buttonWs - 5 - buttonWs, y = bfsuite.app.radio.linePaddingTop, w = 100, h = bfsuite.app.radio.navbuttonHeight}

local invalidSensors = bfsuite.tasks.telemetry.validateSensors()

local repairSensors = false

local progressLoader
local progressLoaderCounter = 0
local doDiscoverNotify = false

local function sortSensorListByName(sensorList)
    table.sort(sensorList, function(a, b) return a.name:lower() < b.name:lower() end)
    return sensorList
end

local sensorList = sortSensorListByName(bfsuite.tasks.telemetry.listSensors())

local function openPage(pidx, title, script)
    enableWakeup = false
    bfsuite.app.triggers.closeProgressLoader = true

    form.clear()

    bfsuite.app.lastIdx = pidx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("Diagnostics" .. " / " .. "Sensors")

    bfsuite.app.formLineCnt = 0

    local app = bfsuite.app
    if app.formFields then for i = 1, #app.formFields do app.formFields[i] = nil end end
    if app.formLines then for i = 1, #app.formLines do app.formLines[i] = nil end end

    local posText = {x = x - 5 - buttonW - buttonWs, y = bfsuite.app.radio.linePaddingTop, w = 200, h = bfsuite.app.radio.navbuttonHeight}
    for i, v in ipairs(sensorList or {}) do
        bfsuite.app.formLineCnt = bfsuite.app.formLineCnt + 1
        bfsuite.app.formLines[bfsuite.app.formLineCnt] = form.addLine(v.name)
        bfsuite.app.formFields[v.key] = form.addStaticText(bfsuite.app.formLines[bfsuite.app.formLineCnt], posText, "-")
    end

    enableWakeup = true
end

local function sensorKeyExists(searchKey, sensorTable)
    if type(sensorTable) ~= "table" then return false end

    for _, sensor in pairs(sensorTable) do if sensor['key'] == searchKey then return true end end

    return false
end

local function postLoad(self) bfsuite.utils.log("postLoad", "debug") end

local function postRead(self) bfsuite.utils.log("postRead", "debug") end

local function rebootFC()

    local RAPI = bfsuite.tasks.msp.api.load("REBOOT")
    RAPI.setUUID("123e4567-e89b-12d3-a456-426614174000")
    RAPI.setCompleteHandler(function(self)
        bfsuite.utils.log("Rebooting FC", "info")

        bfsuite.utils.onReboot()

    end)
    RAPI.write()

end

local function applySettings()
    local EAPI = bfsuite.tasks.msp.api.load("EEPROM_WRITE")
    EAPI.setUUID("550e8400-e29b-41d4-a716-446655440000")
    EAPI.setCompleteHandler(function(self)
        bfsuite.utils.log("Writing to EEPROM", "info")
        rebootFC()
    end)
    EAPI.write()

end

local function runRepair(data)

    local sensorList = bfsuite.tasks.telemetry.listSensors()
    local newSensorList = {}

    local count = 1
    for _, v in pairs(sensorList) do
        local sensor_id = v['set_telemetry_sensors']
        if sensor_id ~= nil and not newSensorList[sensor_id] then
            newSensorList[sensor_id] = true
            count = count + 1
        end
    end

    for i, v in pairs(data['parsed']) do
        if string.match(i, "^telem_sensor_slot_%d+$") and v ~= 0 then
            local sensor_id = v
            if sensor_id ~= nil and not newSensorList[sensor_id] then
                newSensorList[sensor_id] = true
                count = count + 1
            end
        end
    end

    local WRITEAPI = bfsuite.tasks.msp.api.load("TELEMETRY_CONFIG")
    WRITEAPI.setUUID("123e4567-e89b-12d3-a456-426614174000")
    WRITEAPI.setCompleteHandler(function(self, buf) applySettings() end)

    local buffer = data['buffer']
    local sensorIndex = 13

    local sortedSensorIds = {}
    for sensor_id, _ in pairs(newSensorList) do table.insert(sortedSensorIds, sensor_id) end

    table.sort(sortedSensorIds)

    for _, sensor_id in ipairs(sortedSensorIds) do
        if sensorIndex <= 52 then
            buffer[sensorIndex] = sensor_id
            sensorIndex = sensorIndex + 1
        else
            break
        end
    end

    for i = sensorIndex, 52 do buffer[i] = 0 end

    WRITEAPI.write(buffer)

end

local function wakeup()

    if enableWakeup == false then return end

    if doDiscoverNotify == true then

        doDiscoverNotify = false

        local buttons = {{label = "          OK           ", action = function() return true end}}

        if bfsuite.utils.ethosVersionAtLeast({1, 6, 3}) then
            bfsuite.utils.log("Starting discover sensors", "info")
            bfsuite.tasks.msp.sensorTlm:discover()
        else
            form.openDialog({width = nil, title = "Sensors", message = "The flight controller has been configured? You may need to perform a discover sensors to see the changes.", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})
        end
    end

    invalidSensors = bfsuite.tasks.telemetry.validateSensors()

    for i, v in ipairs(sensorList) do

        local field = bfsuite.app.formFields and bfsuite.app.formFields[v.key]
        if field then
            if sensorKeyExists(v.key, invalidSensors) then
                if v.mandatory == true then
                    field:value("INVALID")
                    field:color(ORANGE)
                else
                    field:value("INVALID")
                    field:color(RED)
                end
            else
                field:value("OK")
                field:color(GREEN)
            end
        end
    end

    if repairSensors == true then

        progressLoader = form.openProgressDialog("Saving...", "Saving data to flight controller...")
        progressLoader:closeAllowed(false)
        progressLoaderCounter = 0

        API = bfsuite.tasks.msp.api.load("TELEMETRY_CONFIG")
        API.setUUID("550e8400-e29b-41d4-a716-446655440000")
        API.setCompleteHandler(function(self, buf)
            local data = API.data()
            if data['parsed'] then runRepair(data) end
        end)
        API.read()
        repairSensors = false
    end

    if bfsuite.app.formNavigationFields['tool'] then
        if bfsuite.session and bfsuite.session.apiVersion and bfsuite.utils.apiVersionCompare("<", "1.46") then
            bfsuite.app.formNavigationFields['tool']:enable(false)
        else
            bfsuite.app.formNavigationFields['tool']:enable(true)
        end
    end

    if progressLoader then
        if progressLoaderCounter < 100 then
            progressLoaderCounter = progressLoaderCounter + 5
            progressLoader:value(progressLoaderCounter)
        else
            progressLoader:close()
            progressLoader = nil

            doDiscoverNotify = true

        end
    end

end

local function onToolMenu(self)

    local buttons = {
        {
            label = "          OK           ",
            action = function()

                repairSensors = true
                writePayload = nil
                return true
            end
        }, {label = "CANCEL", action = function() return true end}
    }

    form.openDialog({width = nil, title = "Sensors", message = "Enable required sensors on flight controller?", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})

end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Diagnostics", "diagnostics/diagnostics.lua")
        return true
    end
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "Diagnostics", "diagnostics/diagnostics.lua")
end

return {reboot = false, eepromWrite = false, minBytes = 0, wakeup = wakeup, refreshswitch = false, simulatorResponse = {}, postLoad = postLoad, postRead = postRead, openPage = openPage, onNavMenu = onNavMenu, event = event, navButtons = {menu = true, save = false, reload = false, tool = false, help = false}, API = {}}
