--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local transport = {}

-- Debug helpers (opt-in)
local function LOG_ENABLED_MSP_FRAMES()
    return true -- bfsuite and bfsuite.preferences and bfsuite.preferences.developer and bfsuite.preferences.developer.logmsp
end
local function _dumpBytes(t)
    local o = {}
    for i=1,#t do o[i]=string.format('%02X', (t[i] or 0) & 0xFF) end
    return table.concat(o,' ')
end

local LOCAL_SENSOR_ID = 0x0D
local SPORT_REMOTE_SENSOR_ID = 0x1B
local FPORT_REMOTE_SENSOR_ID = 0x00
local REQUEST_FRAME_ID = 0x30
local REPLY_FRAME_ID = 0x32

local lastSensorId, lastFrameId, lastDataId, lastValue

function transport.sportTelemetryPush(sensorId, frameId, dataId, value) return bfsuite.tasks.msp.sensor:pushFrame({physId = sensorId, primId = frameId, appId = dataId, value = value}) end

function transport.sportTelemetryPop()
    local frame = bfsuite.tasks.msp.sensor:popFrame()
    if frame == nil then return nil, nil, nil, nil end
    local sid, fid, did, val = frame:physId(), frame:primId(), frame:appId(), frame:value()
    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format('SPORT POP sid=%02X fid=%02X did=%04X val=%08X', sid or 0, fid or 0, did or 0, val or 0), 'debug') end
    return sid, fid, did, val
end

transport.mspSend = function(payload)
    local dataId = (payload[1] or 0) | ((payload[2] or 0) << 8)
    local v3 = payload[3] or 0
    local v4 = payload[4] or 0
    local v5 = payload[5] or 0
    local v6 = payload[6] or 0
    local value = v3 | (v4 << 8) | (v5 << 16) | (v6 << 24)

    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format('SPORT TX sid=%02X fid=%02X did=%04X val=%08X | payload=[%s]', LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId & 0xFFFF, value & 0xFFFFFFFF, _dumpBytes(payload)), 'debug') end

    return transport.sportTelemetryPush(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
end

transport.mspRead = function(cmd) return bfsuite.tasks.msp.common.mspSendRequest(cmd, {}) end

transport.mspWrite = function(cmd, payload) return bfsuite.tasks.msp.common.mspSendRequest(cmd, payload) end

local lastSensorId, lastFrameId, lastDataId, lastValue = nil, nil, nil, nil

local function sportTelemetryPop()
    local sensorId, frameId, dataId, value = transport.sportTelemetryPop()

    if sensorId and not (sensorId == lastSensorId and frameId == lastFrameId and dataId == lastDataId and value == lastValue) then
        lastSensorId, lastFrameId, lastDataId, lastValue = sensorId, frameId, dataId, value
        return sensorId, frameId, dataId, value
    end

    return nil
end

transport.mspPoll = function()
    local sensorId, frameId, dataId, value = sportTelemetryPop()

    if not sensorId then return nil end

    if (sensorId == SPORT_REMOTE_SENSOR_ID or sensorId == FPORT_REMOTE_SENSOR_ID) and frameId == REPLY_FRAME_ID then

        local m = { dataId & 0xFF, (dataId >> 8) & 0xFF,
                 value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF }
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log('SPORT RX MSP [' .. _dumpBytes(m) .. ']', 'debug') end
        return m
    end

    return nil
end

return transport
