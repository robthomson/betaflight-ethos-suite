--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local sensors = {}
local loadedSensorModule = nil

local delayDuration = 2
local delayStartTime = nil
local delayPending = false

local smart = assert(loadfile("tasks/sensors/smart.lua"))(config)

local log = bfsuite.utils.log
local tasks = bfsuite.tasks

local telemetryStartTime = os.clock()
local TELEMETRY_TIMEOUT = 20

local function loadSensorModule()
    if not tasks.active() then return nil end
    if not bfsuite.session.apiVersion then return nil end

    local protocol = bfsuite.session.telemetryType or "sport"

    if system:getVersion().simulation == true then
        if not loadedSensorModule or loadedSensorModule.name ~= "sim" then loadedSensorModule = {name = "sim", module = assert(loadfile("tasks/sensors/sim.lua"))(config)} end
    elseif protocol == "sport" then
        if not loadedSensorModule or loadedSensorModule.name ~= "frsky" then loadedSensorModule = {name = "frsky", module = assert(loadfile("tasks/sensors/frsky.lua"))(config)} end
    else
        loadedSensorModule = nil
    end
end

function sensors.wakeup()

    if bfsuite.session.resetSensors and not delayPending then
        delayStartTime = os.clock()
        delayPending = true
        bfsuite.session.resetSensors = false
        log("Delaying sensor wakeup for " .. delayDuration .. " seconds", "info")
        return
    end

    if delayPending then
        if os.clock() - delayStartTime >= delayDuration then
            log("Delay complete; resuming sensor wakeup", "info")
            delayPending = false
        else
            local module = model.getModule(bfsuite.session.telemetrySensor:module())
            if module ~= nil and module.muteSensorLost ~= nil then module:muteSensorLost(5.0) end
            return
        end
    end

    loadSensorModule()
    if loadedSensorModule and loadedSensorModule.module.wakeup then loadedSensorModule.module.wakeup() end

    if smart and smart.wakeup then if bfsuite.session.isConnected then smart.wakeup() end end

end

function sensors.reset()

    if loadedSensorModule and loadedSensorModule.module and loadedSensorModule.module.reset then loadedSensorModule.module.reset() end

    smart.reset()

    loadedSensorModule = nil

end

return sensors
