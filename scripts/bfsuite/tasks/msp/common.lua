--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

-- Debug helpers (opt-in)
local function LOG_ENABLED_MSP_FRAMES()
    return true -- bfsuite and bfsuite.preferences and bfsuite.preferences.developer and bfsuite.preferences.developer.logmsp
end
local function _hx(b) return string.format("%02X", (b or 0) & 0xFF) end
local function _dump(tab)
    local t = {}
    for i = 1, #tab do t[i] = _hx(tab[i]) end
    return table.concat(t, " ")
end

local MSP_VERSION = (1 << 5)
local MSP_STARTFLAG = (1 << 4)

local mspSeq = 0
local mspRemoteSeq = 0
local mspRxBuf = {}
local mspRxError = false
local mspRxSize = 0
local mspRxCRC = 0
local mspRxReq = 0
local mspStarted = false
local mspLastReq = 0
local mspTxBuf = {}
local mspTxIdx = 1
local mspTxCRC = 0

local function writeLE16(buf, v)
    buf[#buf+1] = v & 0xFF
    buf[#buf+1] = (v >> 8) & 0xFF
end

local function buildV2Body(cmd16, payload)
    local crc8_dvb_s2 = bfsuite.tasks.msp.mspHelper.crc8_dvb_s2
    local inner, crc = {}, 0
    local flags = 0x00
    inner[#inner+1] = flags;      crc = crc8_dvb_s2(crc, flags)
    inner[#inner+1] = cmd16 & 0xFF; crc = crc8_dvb_s2(crc, inner[#inner])
    inner[#inner+1] = (cmd16>>8) & 0xFF; crc = crc8_dvb_s2(crc, inner[#inner])
    local sz = #payload
    inner[#inner+1] = sz & 0xFF;  crc = crc8_dvb_s2(crc, inner[#inner])
    inner[#inner+1] = (sz>>8)&0xFF; crc = crc8_dvb_s2(crc, inner[#inner])
    for i=1, sz do inner[#inner+1] = payload[i] & 0xFF; crc = crc8_dvb_s2(crc, inner[#inner]) end
    inner[#inner+1] = crc & 0xFF
    return inner
end

local function parseV2Inner(buf)
    local crc8_dvb_s2 = bfsuite.tasks.msp.mspHelper.crc8_dvb_s2
    if #buf < 6 then return nil end
    local ofs, crc = 1, 0
    local function get() local b=buf[ofs]; ofs=ofs+1; return b end
    local flags = get();                  crc = crc8_dvb_s2(crc, flags)
    local fnLo = get();                   crc = crc8_dvb_s2(crc, fnLo)
    local fnHi = get();                   crc = crc8_dvb_s2(crc, fnHi)
    local szLo = get();                   crc = crc8_dvb_s2(crc, szLo)
    local szHi = get();                   crc = crc8_dvb_s2(crc, szHi)
    local size = (szLo or 0) | ((szHi or 0) << 8)
    local func = (fnLo or 0) | ((fnHi or 0) << 8)
    local payload = {}
    for i=1,size do local b = get(); if b==nil then return nil end; payload[i]=b; crc = crc8_dvb_s2(crc, b) end
    local recvCrc = get(); if recvCrc==nil then return nil end
    if ((crc & 0xFF) ~= (recvCrc & 0xFF)) then return nil end
    return func, payload
end

local function mspProcessTxQ()
    if #mspTxBuf == 0 then return false end

    bfsuite.utils.log("Sending mspTxBuf size " .. tostring(#mspTxBuf) .. " at Idx " .. tostring(mspTxIdx) .. " for cmd: " .. tostring(mspLastReq), "info")

    local payload = {}
    payload[1] = mspSeq + MSP_VERSION
    mspSeq = (mspSeq + 1) & 0x0F
    if mspTxIdx == 1 then payload[1] = payload[1] + MSP_STARTFLAG end

    local i = 2
    while (i <= bfsuite.tasks.msp.protocol.maxTxBufferSize) and mspTxIdx <= #mspTxBuf do
        payload[i] = mspTxBuf[mspTxIdx]
        mspTxIdx = mspTxIdx + 1
        mspTxCRC = mspTxCRC ~ payload[i]
        i = i + 1
    end

    if i <= bfsuite.tasks.msp.protocol.maxTxBufferSize then
        payload[i] = mspTxCRC
        for j = i + 1, bfsuite.tasks.msp.protocol.maxTxBufferSize do payload[j] = 0 end
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP TX CHUNK seq=%d start=%s idx=%d/%d | bytes=[%s] (runningXOR=%02X)", (payload[1] or 0) & 0x0F, (mspTxIdx == 1) and "yes" or "no", mspTxIdx, #mspTxBuf, _dump(payload), mspTxCRC), "info") end
        mspTxBuf = {}
        mspTxIdx = 1
        mspTxCRC = 0
        bfsuite.tasks.msp.protocol.mspSend(payload)
        return false
    end
    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP TX CHUNK seq=%d start=%s idx=%d/%d | bytes=[%s] (runningXOR=%02X)", (payload[1] or 0) & 0x0F, (mspTxIdx == 1) and "yes" or "no", mspTxIdx, #mspTxBuf, _dump(payload), mspTxCRC), "info") end
    bfsuite.tasks.msp.protocol.mspSend(payload)
    return true
end

local function mspSendRequest(cmd, payload)
    if not cmd or type(payload) ~= "table" then
        bfsuite.utils.log("Invalid command or payload", "info")
        return nil
    end
    if #mspTxBuf ~= 0 then
        bfsuite.utils.log("Existing mspTxBuf still sending, failed to send cmd: " .. tostring(cmd), "info")
        return nil
    end
    if cmd <= 255 and #payload <= 255 then
        mspTxBuf[1] = #payload
        mspTxBuf[2] = cmd & 0xFF
        for i = 1, #payload do mspTxBuf[i + 2] = payload[i] & 0xFF end
        mspLastReq = cmd
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP TX v1  cmd=%d len=%d | body=[%s]", cmd, #payload, _dump(mspTxBuf)), "info") end
    else
        local inner = buildV2Body(cmd & 0xFFFF, payload)
        mspTxBuf[1] = #inner
        mspTxBuf[2] = 255
        for i = 1, #inner do mspTxBuf[i + 2] = inner[i] end
        mspLastReq = cmd
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP TX v2enc func=%d len=%d | inner=[%s] | outer=[%s]", cmd & 0xFFFF, #payload, _dump(inner), _dump(mspTxBuf)), "info") end
    end
end

local function mspReceivedReply(payload)
    local idx = 1
    local status = payload[idx]
    local version = (status & 0x60) >> 5
    local start = (status & 0x10) ~= 0
    local seq = status & 0x0F
    idx = idx + 1

    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX CHUNK ver=%d start=%s seq=%d | raw=[%s]", version, start and "yes" or "no", seq, _dump(payload)), "info") end
    if start then
        mspRxBuf = {}
        mspRxError = (status & 0x80) ~= 0
        mspRxSize = payload[idx]
        mspRxReq = mspLastReq
        idx = idx + 1
        if version == 1 then
            mspRxReq = payload[idx]
            idx = idx + 1
        end
        mspRxCRC = mspRxSize ~ mspRxReq
        -- Accept start for pure v1 or v2-in-v1 envelope
        if (mspRxReq == mspLastReq) or (version == 1 and mspRxReq == 255 and mspLastReq > 255) then
            mspStarted = true
            mspRemoteSeq = seq
        else
            if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX START ignored: outerCmd=%d lastReq=%d ver=%d", mspRxReq, mspLastReq, version), "info") end
            mspStarted = false
            return nil
        end
    elseif not mspStarted or ((mspRemoteSeq + 1) & 0x0F) ~= seq then
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX DROP reason=%s | started=%s expectSeq=%d gotSeq=%d", (not mspStarted) and "not-started" or "seq-mismatch", tostring(mspStarted), ((mspRemoteSeq + 1) & 0x0F), seq), "info") end
        mspStarted = false
        return nil
    end

    while (idx <= bfsuite.tasks.msp.protocol.maxRxBufferSize) and (#mspRxBuf < mspRxSize) do
        mspRxBuf[#mspRxBuf + 1] = payload[idx]
        local value = tonumber(payload[idx])
        if value then
            mspRxCRC = mspRxCRC ~ value
        else
            bfsuite.utils.log("Non-numeric value at payload index " .. idx, "info")
        end
        idx = idx + 1
    end

    if idx > bfsuite.tasks.msp.protocol.maxRxBufferSize then
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX CONTINUE seq=%d | assembled=%d/%d bytes so far", seq, #mspRxBuf, mspRxSize), "info") end
        mspRemoteSeq = seq
        return false
    end

    mspStarted = false
    if mspRxCRC ~= payload[idx] and version == 0 then
        if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX CHECKSUM FAIL ver=0 calc=%02X recv=%02X", mspRxCRC & 0xFF, (payload[idx] or 0) & 0xFF), "info") end
        return nil
    end

    if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX DONE ver=%d outerCmd=%d size=%d outerCRC=%02X ok | data=[%s]", version, mspRxReq, mspRxSize, payload[idx] or 0, _dump(mspRxBuf)), "info") end

    if version == 1 and mspRxReq == 255 then
        local v2func, v2payload = parseV2Inner(mspRxBuf)
        if v2func then
            if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log(string.format("MSP RX v2enc func=%d size=%d | payload=[%s]", v2func, #v2payload, _dump(v2payload)), "info") end
            mspRxReq, mspRxBuf, mspRxSize = v2func, v2payload, #v2payload
        else
            if LOG_ENABLED_MSP_FRAMES() then bfsuite.utils.log("MSP RX v2enc parse FAILED (CRC or length)", "info") end
            return nil
        end
    end

    return true
end

local function mspPollReply()
    local startTime = os.clock()

    while os.clock() - startTime < 0.05 do
        local mspData = bfsuite.tasks.msp.protocol.mspPoll()
        if mspData and mspReceivedReply(mspData) then
            mspLastReq = 0
            return mspRxReq, mspRxBuf, mspRxError
        end
    end
    if LOG_ENABLED_MSP_FRAMES() and mspLastReq ~= 0 then bfsuite.utils.log("MSP POLL TIMEOUT waiting for cmd "..tostring(mspLastReq), "info") end
    return nil, nil, nil
end

local function mspClearTxBuf() mspTxBuf = {} end

return {mspProcessTxQ = mspProcessTxQ, mspSendRequest = mspSendRequest, mspPollReply = mspPollReply, mspClearTxBuf = mspClearTxBuf}
