--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local smart = {}

local smartfuel = assert(loadfile("tasks/sensors/lib/smartfuel.lua"))()
local smartfuelvoltage = assert(loadfile("tasks/sensors/lib/smartfuelvoltage.lua"))()

local log
local tasks

local interval = 1
local lastWake = os.clock()

local firstWakeup = true

local function calculateFuel()

    if bfsuite.session.modelPreferences and bfsuite.session.modelPreferences.battery and bfsuite.session.modelPreferences.battery.calc_local then

        if bfsuite.session.modelPreferences.battery.calc_local == 1 or not bfsuite.tasks.telemetry.getSensorSource("consumption") then
            return smartfuelvoltage.calculate()
        else
            return smartfuel.calculate()
        end
    else
        return smartfuel.calculate()
    end

end

local function calculateConsumption()

    if bfsuite.session.modelPreferences and bfsuite.session.modelPreferences.battery and bfsuite.session.modelPreferences.battery.calc_local then
        if bfsuite.session.modelPreferences.battery.calc_local == 1 or not bfsuite.tasks.telemetry.getSensorSource("consumption") then
            local capacity = (bfsuite.session.batteryConfig and bfsuite.session.batteryConfig.batteryCapacity) or 1000
            local smartfuelPct = bfsuite.tasks.telemetry.getSensor("smartfuel")
            local warningPercentage = (bfsuite.session.batteryConfig and bfsuite.session.batteryConfig.consumptionWarningPercentage) or 30
            if smartfuelPct then
                local usableCapacity = capacity * (1 - warningPercentage / 100)
                local usedPercent = 100 - smartfuelPct
                return (usedPercent / 100) * usableCapacity
            end
        else

            return bfsuite.tasks.telemetry.getSensor("consumption") or 0
        end
    else

        return bfsuite.tasks.telemetry.getSensor("consumption") or 0
    end
end

local switchCache = {}

local smart_sensors = {
    armed = {
        name = "Armed",
        appId = 0x5FE0,
        unit = UNIT_RAW,
        minimum = 0,
        maximum = 1,
        value = function()
            if bfsuite.session.modelPreferences.model then
                local settings = bfsuite.session.modelPreferences.model
                if settings.armswitch then
                    local category, member, options = settings.armswitch:match("([^:]+):([^:]+):([^:]+)")

                    if not switchCache["armed"] then switchCache["armed"] = system.getSource({category = category, member = member, options = options}) end
                    local state = switchCache["armed"]:state()

                    return (state and 0 or 1)
                end
            end
            return false
        end
    },
    inflight = {
        name = "Inflight",
        appId = 0x5FDF,
        unit = UNIT_RAW,
        minimum = 0,
        maximum = 1,
        value = function()
            if bfsuite.session.modelPreferences.model then
                local settings = bfsuite.session.modelPreferences.model
                if settings.inflightswitch then
                    local category, member, options = settings.inflightswitch:match("([^:]+):([^:]+):([^:]+)")

                    if not switchCache["inflight"] then switchCache["inflight"] = system.getSource({category = category, member = member, options = options}) end
                    local state = switchCache["inflight"]:state()
                    return (state and 0 or 1)
                end
            end
            return false
        end
    },
    smartfuel = {name = "Smart Fuel", appId = 0x5FE1, unit = UNIT_PERCENT, minimum = 0, maximum = 100, value = calculateFuel},

    smartconsumption = {name = "Smart Consumption", appId = 0x5FDE, unit = UNIT_MILLIAMPERE_HOUR, minimum = 0, maximum = 1000000000, value = calculateConsumption}
}

smart.sensors = msp_sensors
local sensorCache = {}

local function createOrUpdateSensor(appId, fieldMeta, value)
    if not sensorCache[appId] then
        local existingSensor = system.getSource({category = CATEGORY_TELEMETRY_SENSOR, appId = appId})

        if existingSensor then
            sensorCache[appId] = existingSensor
        else
            local sensor = model.createSensor({type = SENSOR_TYPE_DIY})
            sensor:name(fieldMeta.name)
            sensor:appId(appId)
            sensor:physId(0)
            sensor:module(bfsuite.session.telemetrySensor:module())

            if fieldMeta.unit then
                sensor:unit(fieldMeta.unit)
                sensor:protocolUnit(fieldMeta.unit)
            end
            sensor:minimum(fieldMeta.minimum or -1000000000)
            sensor:maximum(fieldMeta.maximum or 1000000000)

            sensorCache[appId] = sensor
        end
    end

    if value then
        sensorCache[appId]:value(value)
    else
        sensorCache[appId]:reset()
    end
end

local lastWakeupTime = 0
function smart.wakeup()

    if firstWakeup then
        log = bfsuite.utils.log
        tasks = bfsuite.tasks
        firstWakeup = false
    end

    if (os.clock() - lastWake) < interval then return end
    lastWake = os.clock()

    for name, meta in pairs(smart_sensors) do
        local value
        if type(meta.value) == "function" then
            value = meta.value()
        else
            value = meta.value
        end
        createOrUpdateSensor(meta.appId, meta, value)
    end
end

function smart.reset()
    sensorCache = {}
    switchCache = {}
end

return smart
