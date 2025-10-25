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

local CRSF_ADDRESS_BETAFLIGHT = 0xC8
local CRSF_ADDRESS_RADIO_TRANSMITTER = 0xEA

local CRSF_FRAMETYPE_MSP_REQ = 0x7A
local CRSF_FRAMETYPE_MSP_RESP = 0x7B
local CRSF_FRAMETYPE_MSP_WRITE = 0x7C

local crsfMspCmd = 0

if crsf.getSensor ~= nil then
    local sensor = crsf.getSensor()
    transport.popFrame = function() return sensor:popFrame() end
    transport.pushFrame = function(x, y) return sensor:pushFrame(x, y) end
else
    transport.popFrame = function() return crsf.popFrame() end
    transport.pushFrame = function(x, y) return crsf.pushFrame(x, y) end
end

transport.mspSend = function(payload)
    local payloadOut = {CRSF_ADDRESS_BETAFLIGHT, CRSF_ADDRESS_RADIO_TRANSMITTER}
    for i = 1, #(payload) do payloadOut[i + 2] = payload[i] end
    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format('CRSF TX type=0x%02X bytes=[%s]', crsfMspCmd, _dumpBytes(payloadOut)), 'debug') end
    return transport.pushFrame(crsfMspCmd, payloadOut)
end

transport.mspRead = function(cmd)
    crsfMspCmd = CRSF_FRAMETYPE_MSP_REQ
    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log('CRSF mspRead cmd='..tostring(cmd),'debug') end
    return bfsuite.tasks.msp.common.mspSendRequest(cmd, {})
end

transport.mspWrite = function(cmd, payload)
    crsfMspCmd = CRSF_FRAMETYPE_MSP_WRITE
    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log('CRSF mspWrite cmd='..tostring(cmd)..' len='..tostring((payload and #payload) or 0),'debug') end
    return bfsuite.tasks.msp.common.mspSendRequest(cmd, payload)
end

transport.mspPoll = function()
    while true do
        local cmd, data = transport.popFrame()
        if cmd == nil then return nil end
        if LOG_ENABLED_MSP_FRAMES() and data then bfsuite.utils.log(string.format('CRSF RX type=0x%02X raw=[%s]', cmd, _dumpBytes(data)), 'debug') end
        if cmd == CRSF_FRAMETYPE_MSP_RESP and data[1] == CRSF_ADDRESS_RADIO_TRANSMITTER and data[2] == CRSF_ADDRESS_BETAFLIGHT then
            local mspData = {}
            for i = 3, #data do mspData[i - 2] = data[i] end
            return mspData
        end
    end
end

return transport
