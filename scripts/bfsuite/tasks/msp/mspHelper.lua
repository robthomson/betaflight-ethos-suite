--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local mspHelper = {}

-- CRC8 DVB-S2 used by MSP v2
function mspHelper.crc8_dvb_s2(crc, a)
    crc = bit32 and bit32.bxor(crc, a) or (crc ~ a)
    for _ = 1, 8 do
        local msb = (crc & 0x80) ~= 0
        crc = (crc << 1) & 0xFF
        if msb then crc = (crc ~ 0xD5) & 0xFF end
    end
    return crc & 0xFF
end


mspHelper.readUInt = function(buf, numBytes, byteorder)
    local offset = buf.offset or 1
    if not buf[offset] or not buf[offset + numBytes - 1] then return nil end

    local value = 0
    if byteorder == "big" then
        for i = 0, numBytes - 1 do value = value * 256 + (buf[offset + i] or 0) end
    else
        for i = numBytes - 1, 0, -1 do value = value * 256 + (buf[offset + i] or 0) end
    end

    buf.offset = offset + numBytes
    return value
end

mspHelper.readSInt = function(buf, numBytes, byteorder)
    local value = mspHelper.readUInt(buf, numBytes, byteorder)
    if value == nil then return nil end

    local maxUnsigned = 2 ^ (8 * numBytes)
    local maxSigned = maxUnsigned / 2
    if value >= maxSigned then value = value - maxUnsigned end

    return value
end

mspHelper.writeUInt = function(buf, value, numBytes, byteorder)
    for i = 0, numBytes - 1 do
        local shift = (byteorder == "big") and (8 * (numBytes - 1 - i)) or (8 * i)
        buf[#buf + 1] = math.floor(value / 2 ^ shift) % 256
    end
end

mspHelper.writeSInt = function(buf, value, numBytes, byteorder)
    if value < 0 then value = value + 2 ^ (8 * numBytes) end
    mspHelper.writeUInt(buf, value, numBytes, byteorder)
end

for bits = 8, 512, 8 do
    local bytes = bits / 8
    mspHelper["readU" .. bits] = function(buf, byteorder) return mspHelper.readUInt(buf, bytes, byteorder) end
    mspHelper["readS" .. bits] = function(buf, byteorder) return mspHelper.readSInt(buf, bytes, byteorder) end
    mspHelper["writeU" .. bits] = function(buf, value, byteorder) mspHelper.writeUInt(buf, value, bytes, byteorder) end
    mspHelper["writeS" .. bits] = function(buf, value, byteorder) mspHelper.writeSInt(buf, value, bytes, byteorder) end
end

mspHelper.writeRAW = function(buf, value) buf[#buf + 1] = value end

return mspHelper

