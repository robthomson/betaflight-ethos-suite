--[[

 * Copyright (C) Rob Thomson
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

]] --
--
-- background processing of msp traffic
--
local arg = {...}
local config = arg[1]

local msp = {}

msp.activeProtocol = nil
msp.onConnectChecksInit = true

local protocol = assert(loadfile("tasks/msp/protocols.lua"))()


msp.mspQueue = mspQueue

-- set active protocol to use
msp.protocol = protocol.getProtocol()

-- preload all transport methods
msp.protocolTransports = {}
for i, v in pairs(protocol.getTransports()) do msp.protocolTransports[i] = assert(loadfile(v))() end

-- set active transport table to use
local transport = msp.protocolTransports[msp.protocol.mspProtocol]
msp.protocol.mspRead = transport.mspRead
msp.protocol.mspSend = transport.mspSend
msp.protocol.mspWrite = transport.mspWrite
msp.protocol.mspPoll = transport.mspPoll

msp.mspQueue = assert(loadfile("tasks/msp/mspQueue.lua"))()
msp.mspQueue.maxRetries = msp.protocol.maxRetries
msp.mspHelper = assert(loadfile("tasks/msp/mspHelper.lua"))()
msp.api = assert(loadfile("tasks/msp/api.lua"))()
msp.common = assert(loadfile("tasks/msp/common.lua"))()

local delayDuration = 2  -- seconds
local delayStartTime = nil
local delayPending = false

function msp.resetState()
    bfsuite.session.servoOverride = nil
    bfsuite.session.servoCount = nil
    bfsuite.session.tailMode = nil
    bfsuite.session.apiVersion = nil
    bfsuite.session.clockSet = nil
    bfsuite.session.clockSetAlart = nil
    bfsuite.session.craftName = nil
    bfsuite.session.modelID = nil
end

function msp.wakeup()

    if bfsuite.session.telemetrySensor == nil then return end

    if not msp.sensor then
        msp.sensor = sport.getSensor({primId = 0x32})
        msp.sensor:module(bfsuite.session.telemetrySensor:module())
    end
    
    if not msp.sensorTlm then
        msp.sensorTlm = sport.getSensor()
        msp.sensorTlm:module(bfsuite.session.telemetrySensor:module())
    end

    if bfsuite.session.resetMSP and not delayPending then
        delayStartTime = os.clock()
        delayPending = true
        bfsuite.session.resetMSP = false  -- Reset immediately
        bfsuite.utils.log("Delaying msp wakeup for " .. delayDuration .. " seconds","info")
        return  -- Exit early; wait starts now
    end

    if delayPending then
        if os.clock() - delayStartTime >= delayDuration then
            bfsuite.utils.log("Delay complete; resuming msp wakeup","info")
            delayPending = false
        else
            bfsuite.tasks.msp.mspQueue:clear()
            return  -- Still waiting; do nothing
        end
    end

   msp.activeProtocol = bfsuite.session.telemetryType

    if bfsuite.tasks.wasOn == true then bfsuite.session.telemetryTypeChanged = true end

    if bfsuite.session.telemetryTypeChanged == true then

        --bfsuite.utils.log("Switching protocol: " .. msp.activeProtocol)

        msp.protocol = protocol.getProtocol()

        -- set active transport table to use
        local transport = msp.protocolTransports[msp.protocol.mspProtocol]
        msp.protocol.mspRead = transport.mspRead
        msp.protocol.mspSend = transport.mspSend
        msp.protocol.mspWrite = transport.mspWrite
        msp.protocol.mspPoll = transport.mspPoll

        msp.resetState()
        msp.onConnectChecksInit = true
    end

    if bfsuite.session.telemetrySensor ~= nil and bfsuite.session.telemetryState == false then
        msp.resetState()
        msp.onConnectChecksInit = true
    end

    -- run the msp.checks

    local state

    if bfsuite.session.telemetrySensor then
        state = bfsuite.session.telemetryState
    else
        state = false
    end

    if state == true then
        
        msp.mspQueue:processQueue()

        -- checks that run on each connection to the fbl
        if msp.onConnectChecksInit == true then 
            if bfsuite.session.telemetrySensor then msp.sensor:module(bfsuite.session.telemetrySensor:module()) end
        end
    else
        msp.mspQueue:clear()
    end

end

return msp
