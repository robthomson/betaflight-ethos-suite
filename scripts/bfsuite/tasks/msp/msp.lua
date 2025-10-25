--[[
  Copyright (C) 2025 Rob Thomson Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local msp = {}

msp.activeProtocol = nil
msp.onConnectChecksInit = true

local protocol = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/protocols.lua"))()

local telemetryTypeChanged = false

msp.mspQueue = nil

msp.protocol = protocol.getProtocol()

msp.protocolTransports = {}
for i, v in pairs(protocol.getTransports()) do msp.protocolTransports[i] = assert(loadfile(v))() end

local transport = msp.protocolTransports[msp.protocol.mspProtocol]
msp.protocol.mspRead = transport.mspRead
msp.protocol.mspSend = transport.mspSend
msp.protocol.mspWrite = transport.mspWrite
msp.protocol.mspPoll = transport.mspPoll

msp.mspQueue = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/mspQueue.lua"))()
msp.mspQueue.maxRetries = msp.protocol.maxRetries
msp.mspQueue.loopInterval = 0.025
msp.mspQueue.copyOnAdd = true
msp.mspQueue.timeout = 2.0

msp.mspHelper = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/mspHelper.lua"))()
msp.api = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/api.lua"))()
msp.common = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/common.lua"))()

local delayDuration = 2
local delayStartTime = nil
local delayPending = false

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
        bfsuite.session.resetMSP = false
        bfsuite.utils.log("Delaying msp wakeup for " .. delayDuration .. " seconds", "info")
        return
    end

    if delayPending then
        if os.clock() - delayStartTime >= delayDuration then
            bfsuite.utils.log("Delay complete; resuming msp wakeup", "info")
            delayPending = false
        else
            bfsuite.tasks.msp.mspQueue:clear()
            return
        end
    end

    msp.activeProtocol = bfsuite.session.telemetryType

    if telemetryTypeChanged == true then

        msp.protocol = protocol.getProtocol()

        local transport = msp.protocolTransports[msp.protocol.mspProtocol]
        msp.protocol.mspRead = transport.mspRead
        msp.protocol.mspSend = transport.mspSend
        msp.protocol.mspWrite = transport.mspWrite
        msp.protocol.mspPoll = transport.mspPoll

        bfsuite.utils.session()
        msp.onConnectChecksInit = true
        telemetryTypeChanged = false
    end

    if bfsuite.session.telemetrySensor ~= nil and bfsuite.session.telemetryState == false then
        bfsuite.utils.session()
        msp.onConnectChecksInit = true
    end

    local state

    if bfsuite.session.telemetrySensor then
        state = bfsuite.session.telemetryState
    else
        state = false
    end

    if state == true then

        msp.mspQueue:processQueue()

        if msp.onConnectChecksInit == true then if bfsuite.session.telemetrySensor then msp.sensor:module(bfsuite.session.telemetrySensor:module()) end end
    else
        msp.mspQueue:clear()
    end

end

function msp.setTelemetryTypeChanged() telemetryTypeChanged = true end

function msp.reset()
    bfsuite.tasks.msp.mspQueue:clear()
    msp.sensor = nil
    msp.activeProtocol = nil
    msp.onConnectChecksInit = true
    delayStartTime = nil
    msp.sensorTlm = nil
    delayPending = false
end

return msp
