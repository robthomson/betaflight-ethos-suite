--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local sensorTlm

local frsky = {}

frsky.name = "frsky"

local MAX_FRAMES_PER_WAKEUP = 32
local MAX_TIME_BUDGET = 0.004

local telemetryStartTime = os.clock()
local TELEMETRY_TIMEOUT = 20

local createSensorList = {}
createSensorList[0x0430] = {name = "Pitch", unit = UNIT_DEGREE, decimals = 1}
createSensorList[0x0440] = {name = "Roll", unit = UNIT_DEGREE, decimals = 1}
createSensorList[0x0480] = {name = "GPS Sats", unit = UNIT_RAW, decimals = 0}

local dropSensorList = {}
dropSensorList[0x0400] = {name = "Temp1"}
dropSensorList[0x0410] = {name = "Temp1"}

local renameSensorList = {}

frsky.createSensorCache = {}
frsky.dropSensorCache = {}
frsky.renameSensorCache = {}

frsky.renamed = {}
frsky.dropped = {}

local function createSensor(physId, primId, appId, frameValue)
    if bfsuite.session.apiVersion == nil then return "skip" end
    local v = createSensorList[appId]
    if not v then return "skip" end

    if frsky.createSensorCache[appId] == nil then
        frsky.createSensorCache[appId] = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = appId})
        if frsky.createSensorCache[appId] == nil then
            local s = model.createSensor()
            s:name(v.name)
            s:appId(appId)
            s:physId(physId)
            s:module(bfsuite.session.telemetrySensor:module())
            s:minimum(min or -1000000000)
            s:maximum(max or 2147483647)
            if v.unit then
                s:unit(v.unit);
                s:protocolUnit(v.unit)
            end
            if v.decimals then
                s:decimals(v.decimals);
                s:protocolDecimals(v.decimals)
            end
            if v.minimum then s:minimum(v.minimum) end
            if v.maximum then s:maximum(v.maximum) end
            frsky.createSensorCache[appId] = s
            return "created"
        end
    end

    return "noop"
end

local function dropSensor(physId, primId, appId, frameValue)
    if bfsuite.session.apiVersion == nil then return "skip" end
    if not dropSensorList or not dropSensorList[appId] then return "skip" end

    if frsky.dropSensorCache[appId] == nil then
        local src = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = appId})
        frsky.dropSensorCache[appId] = src or false
    end
    local src = frsky.dropSensorCache[appId]
    if src and src ~= false then
        if not frsky.dropped[appId] then
            src:drop()
            frsky.dropped[appId] = true
            return "dropped"
        end
        return "noop"
    end
    return "skip"
end

local function renameSensor(physId, primId, appId, frameValue)
    if bfsuite.session.apiVersion == nil then return "skip" end
    local v = renameSensorList[appId]
    if not v then return "skip" end
    if frsky.renamed[appId] then return "noop" end

    if frsky.renameSensorCache[appId] == nil then
        local src = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = appId})
        frsky.renameSensorCache[appId] = src or false
    end
    local src = frsky.renameSensorCache[appId]
    if src and src ~= false then
        if src:name() == v.onlyifname then
            src:name(v.name)
            frsky.renamed[appId] = true
            return "renamed"
        end
        return "noop"
    end
    return "skip"
end

local function telemetryPop()

    if not sensorTlm then return false end

    local frame = sensorTlm:popFrame()
    if frame == nil then return false end
    if not frame.physId or not frame.primId then return false end

    local physId, primId, appId, value = frame:physId(), frame:primId(), frame:appId(), frame:value()

    local cs = createSensor(physId, primId, appId, value)
    if cs ~= "skip" then return true end

    local ds = dropSensor(physId, primId, appId, value)
    if ds ~= "skip" then return true end

    renameSensor(physId, primId, appId, value)
    return true
end

function frsky.wakeup()

    if not sensorTlm then sensorTlm = sport.getSensor() end

    local function clearCaches()
        frsky.createSensorCache = {}
        frsky.renameSensorCache = {}
        frsky.dropSensorCache = {}
    end

    if not bfsuite.session.telemetryState or not bfsuite.session.telemetrySensor then
        clearCaches()
        return
    end

    if not bfsuite.tasks and bfsuite.tasks.telemetry then return end

    if os.clock() - telemetryStartTime > TELEMETRY_TIMEOUT then

        clearCaches()
        return
    end

    if (bfsuite.app and bfsuite.app.guiIsRunning == false) or bfsuite.tasks.telemetry then

        local start = os.clock()
        local count = 0
        while count < MAX_FRAMES_PER_WAKEUP and (os.clock() - start) <= MAX_TIME_BUDGET do
            if not telemetryPop() then break end
            count = count + 1
        end
    end
end

function frsky.reset()
    frsky.createSensorCache = {}
    frsky.renameSensorCache = {}
    frsky.dropSensorCache = {}
    frsky.renamed = {}
    frsky.dropped = {}
end

return frsky
