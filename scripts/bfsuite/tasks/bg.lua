--[[

 * Copyright (C) Betaflight Project
 *
 *
 * License GPLv3: https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * Note.  Some icons have been sourced from https://www.flaticon.com/
 * 

]]--
--
-- background processing of system tasks
--
local arg = {...}
local config = arg[1]


-- declare vars
local bg = {}
bg.init = true

bg.heartbeat = nil

bg.init = false
-- tasks
bg.telemetry = assert(loadfile("tasks/telemetry/telemetry.lua"))(config)
bg.msp = assert(loadfile("tasks/msp/msp.lua"))(config)


bfsuite.rssiSensorChanged = true

local rssiCheckScheduler = os.clock()
local lastRssiSensorName = nil

bg.wasOn = false

function bg.active()

    if bg.heartbeat == nil then return false end

    if bg.heartbeat ~= nil and (os.clock() - bg.heartbeat) >= 2 then
        bg.wasOn = true
    else
        bg.wasOn = false
    end

    -- if msp is busy.. we are 100% ok
    if bfsuite.app.triggers.mspBusy == true then return true end

    -- if we have not run within 2 seconds.. notify that bg script is down
    if (os.clock() - bg.heartbeat) <= 2 then
        return true
    else
        return false
    end

end

function bg.wakeup()

    bg.heartbeat = os.clock()

    -- this should be before msp.hecks
    -- doing this is heavy - lets run it every few seconds only
    local now = os.clock()
    if rssiCheckScheduler ~= nil and (now - rssiCheckScheduler) >= 2 then
        local currentRssiSensor = bfsuite.utils.getRssiSensor()

        if currentRssiSensor ~= nil then

            if lastRssiSensorName ~= currentRssiSensor.name then
                bfsuite.rssiSensorChanged = true
            else
                bfsuite.rssiSensorChanged = false
            end

            lastRssiSensorName = currentRssiSensor.name
            bfsuite.rssiSensor = currentRssiSensor.sensor
        else
            bfsuite.rssiSensorChanged = false
        end
        rssiCheckScheduler = now
    end
    if system:getVersion().simulation == true then bfsuite.rssiSensorChanged = false end

    -- high priority and must alway run regardless of tlm state
    bg.msp.wakeup()
    bg.telemetry.wakeup()


end

function bg.event(widget, category, value)
    if bg.msp.event then bg.msp.event(widget, category, value) end
end

return bg
