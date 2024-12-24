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
-- background processing of msp traffic
--
local arg = {...}
local config = arg[1]


local msp = {}

msp.activeProtocol = nil
msp.onConnectChecksInit = true

local protocol = assert(loadfile("tasks/msp/protocols.lua"))()

msp.sensor = sport.getSensor({primId = 0x32})
msp.mspQueue = mspQueue
if bfsuite.rssiSensor then bfsuite.sensor:module(bfsuite.rssiSensor:module()) end
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
assert(loadfile("tasks/msp/common.lua"))()

-- BACKGROUND checks
function msp.onConnectBgChecks()

    if msp.mspQueue ~= nil and msp.mspQueue:isProcessed() then

        if bfsuite.config.apiVersion == nil and msp.mspQueue:isProcessed() then

            local message = {
                command = 1, -- MIXER
                processReply = function(self, buf)
                    if #buf >= 3 then
                        local version = buf[2] + buf[3] / 100
                        bfsuite.config.apiVersion = version
                        bfsuite.utils.log("MSP Version: " .. bfsuite.config.apiVersion)
                    end
                end,
                simulatorResponse = {0, 1, 46}
            }
            msp.mspQueue:add(message)
        elseif bfsuite.config.clockSet == nil and msp.mspQueue:isProcessed() then

            bfsuite.utils.log("Sync clock: " .. os.clock())

            local message = {
                command = 246, -- MSP_SET_RTC
                payload = {},
                processReply = function(self, buf)
                    bfsuite.utils.log("RTC set.")

                    if #buf >= 0 then
                        bfsuite.config.clockSet = true
                        -- we do the beep later to avoid a double beep
                    end

                end,
                simulatorResponse = {}
            }

            -- generate message to send
            local now = os.time()
            -- format: seconds after the epoch / milliseconds
            for i = 1, 4 do
                bfsuite.bg.msp.mspHelper.writeU8(message.payload, now & 0xFF)
                now = now >> 8
            end
            bfsuite.bg.msp.mspHelper.writeU16(message.payload, 0)

            -- add msg to queue
            bfsuite.bg.msp.mspQueue:add(message)
        elseif bfsuite.config.clockSet == true and bfsuite.config.clockSetAlart ~= true then
            -- this is unsual but needed because the clock sync does not return anything usefull
            -- to confirm its done! 
            bfsuite.utils.playFileCommon("beep.wav")
            bfsuite.config.clockSetAlart = true
        elseif (bfsuite.config.activeProfile == nil or bfsuite.config.activeRateProfile == nil) then

            bfsuite.utils.getCurrentProfile()
            -- do this at end of last one
            msp.onConnectChecksInit = false
        end
    end

end

function msp.resetState()
    bfsuite.config.apiVersion = nil
    bfsuite.config.clockSet = nil
    bfsuite.config.clockSetAlart = nil
end

function msp.wakeup()

    -- check what protocol is in use
    local telemetrySOURCE = system.getSource("Rx RSSI1")
    if telemetrySOURCE ~= nil then
        msp.activeProtocol = "crsf"
    else
        msp.activeProtocol = "smartPort"
    end

    if bfsuite.bg.wasOn == true then bfsuite.rssiSensorChanged = true end

    if bfsuite.rssiSensorChanged == true then

        bfsuite.utils.log("Switching protocol: " .. msp.activeProtocol)

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

    if bfsuite.rssiSensor ~= nil and bfsuite.bg.telemetry.active() == false then
        msp.resetState()
        msp.onConnectChecksInit = true
    end

    -- run the msp.checks

    local state

    if system:getVersion().simulation == true then
        state = true
    elseif bfsuite.rssiSensor then
        state = bfsuite.bg.telemetry.active()
    else
        state = false
    end

    if state == true then
        msp.mspQueue:processQueue()

        -- checks that run on each connection to the fbl
        if msp.onConnectChecksInit == true then msp.onConnectBgChecks() end
    else
        msp.mspQueue:clear()
    end
end

return msp
