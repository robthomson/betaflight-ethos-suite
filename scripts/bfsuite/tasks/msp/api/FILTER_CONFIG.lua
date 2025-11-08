--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local core = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/api_core.lua"))()

local API_NAME = "FILTER_CONFIG"
local MSP_API_CMD_READ = 92
local MSP_API_CMD_WRITE = 93
local MSP_REBUILD_ON_WRITE = false

local gyroFilterType = {[0] = "PT1", [1] = "BIQUAD", [2] = "PT2", [3] = "PT3"}

-- LuaFormatter off
local MSP_API_STRUCTURE_READ_DATA = {
    -- pre-1.41 block (baseline 1.40)
    { field = "gyro_lpf1_static_hz_legacy", type = "U8",  apiVersion = 1.40, simResponse = {250}, min = 0, max = 1000, default = 0 },      -- first U8 legacy encoding
    { field = "dterm_lpf1_static_hz",       type = "U16", apiVersion = 1.40, simResponse = {75, 0}, min = 0, max = 1000, default = 75 },
    { field = "yaw_lowpass_hz",             type = "U16", apiVersion = 1.40, simResponse = {100, 0}, min = 0, max = 500, default = 100 },
    { field = "gyro_soft_notch_hz_1",       type = "U16", apiVersion = 1.40, simResponse = {0, 0}, min = nil, max = nil, default = nil },
    { field = "gyro_soft_notch_cutoff_1",   type = "U16", apiVersion = 1.40, simResponse = {0, 0}, min = nil, max = nil, default = nil },
    { field = "dterm_notch_hz",             type = "U16", apiVersion = 1.40, simResponse = {0, 0}, min = 0, max = 1000, default = 0 },
    { field = "dterm_notch_cutoff",         type = "U16", apiVersion = 1.40, simResponse = {0, 0}, min = 0, max = 1000, default = 0 },
    { field = "gyro_soft_notch_hz_2",       type = "U16", apiVersion = 1.40, simResponse = {0, 0}, min = nil, max = nil, default = nil },
    { field = "gyro_soft_notch_cutoff_2",   type = "U16", apiVersion = 1.40, simResponse = {0, 0}, min = nil, max = nil, default = nil },
    { field = "dterm_lpf1_type",            type = "U8",  apiVersion = 1.40, simResponse = {0}, min = 0, max = 3, default = 0, table = gyroFilterType },
    { field = "gyro_hardware_lpf",          type = "U8",  apiVersion = 1.40, simResponse = {0}, min = 0, max = 3, default = 0, table = gyroFilterType },
    { field = "gyro_32khz_hardware_lpf",    type = "U8",  apiVersion = 1.40, simResponse = {0}, min = nil, max = nil, default = nil },        -- deprecated
    { field = "gyro_lpf1_static_hz",        type = "U16", apiVersion = 1.40, simResponse = {250, 0}, min = 0, max = 1000, default = 250 },   -- new 16-bit encoding
    { field = "gyro_lpf2_static_hz",        type = "U16", apiVersion = 1.40, simResponse = {244, 1}, min = 0, max = 1000, default = 500 },
    { field = "gyro_lpf1_type",             type = "U8",  apiVersion = 1.40, simResponse = {0}, min = 0, max = 3, default = 0, table = gyroFilterType },
    { field = "gyro_lpf2_type",             type = "U8",  apiVersion = 1.40, simResponse = {0}, min = 0, max = 3, default = 0, table = gyroFilterType },
    { field = "dterm_lpf2_static_hz",       type = "U16", apiVersion = 1.40, simResponse = {150, 0}, min = 0, max = 1000, default = 75 },

    -- Added in MSP API 1.41
    { field = "dterm_lpf2_type",            type = "U8",  apiVersion = 1.41, simResponse = {0}, min = 0, max = 3, default = 0, table = gyroFilterType },

    -- USE_DYN_LPF (exists irrespective of compile flags in this API layout)
    { field = "gyro_lpf1_dyn_min_hz",       type = "U16", apiVersion = 1.40, simResponse = {250, 0}, min = 0, max = 1000, default = 250 },
    { field = "gyro_lpf1_dyn_max_hz",       type = "U16", apiVersion = 1.40, simResponse = {244, 1}, min = 0, max = 1000, default = 500 },
    { field = "dterm_lpf1_dyn_min_hz",      type = "U16", apiVersion = 1.40, simResponse = {75, 0}, min = 0, max = 1000, default = 75 },
    { field = "dterm_lpf1_dyn_max_hz",      type = "U16", apiVersion = 1.40, simResponse = {150, 0}, min = 0, max = 1000, default = 150 },

    -- Added in MSP API 1.42 (dyn notch)
    { field = "dyn_notch_range",            type = "U8",  apiVersion = 1.42, simResponse = {0}, min = nil, max = nil, default = nil },        -- deprecated in 1.43
    { field = "dyn_notch_width_percent",    type = "U8",  apiVersion = 1.42, simResponse = {0}, min = nil, max = nil, default = nil },        -- deprecated in 1.44
    { field = "dyn_notch_q",                type = "U16", apiVersion = 1.42, simResponse = {44, 1}, min = 1, max = 1000, default = 300 },
    { field = "dyn_notch_min_hz",           type = "U16", apiVersion = 1.42, simResponse = {100, 0}, min = 20, max = 250, default = 100 },

    -- RPM filter (present in this layout; baseline kept at 1.42 since it follows the 1.42 block)
    { field = "rpm_filter_harmonics",       type = "U8",  apiVersion = 1.42, simResponse = {3}, min = nil, max = nil, default = nil },
    { field = "rpm_filter_min_hz",          type = "U8",  apiVersion = 1.42, simResponse = {100}, min = nil, max = nil, default = nil },

    -- Added in MSP API 1.43
    { field = "dyn_notch_max_hz",           type = "U16", apiVersion = 1.43, simResponse = {88, 2}, min = 200, max = 1000, default = 600 },

    -- Added in MSP API 1.44
    { field = "dterm_lpf1_dyn_expo",        type = "U8",  apiVersion = 1.44, simResponse = {5}, min = 0, max = 10, default = 5 },

    -- dyn notch count (in same final block; keep baseline at 1.44 here)
    { field = "dyn_notch_count",            type = "U8",  apiVersion = 1.44, simResponse = {0}, min = 0, max = 5, default = 3 },
}

-- LuaFormatter on

local MSP_API_STRUCTURE_READ, MSP_MIN_BYTES, MSP_API_SIMULATOR_RESPONSE = core.prepareStructureData(MSP_API_STRUCTURE_READ_DATA)

local MSP_API_STRUCTURE_WRITE = MSP_API_STRUCTURE_READ

local mspData = nil
local mspWriteComplete = false
local payloadData = {}
local defaultData = {}

local handlers = core.createHandlers()

local MSP_API_UUID
local MSP_API_MSG_TIMEOUT

local lastWriteUUID = nil

local writeDoneRegistry = setmetatable({}, {__mode = "kv"})

local function processReplyStaticRead(self, buf)
    core.parseMSPData(API_NAME, buf, self.structure, nil, nil, function(result)
        mspData = result
        if #buf >= (self.minBytes or 0) then
            local getComplete = self.getCompleteHandler
            if getComplete then
                local complete = getComplete()
                if complete then complete(self, buf) end
            end
        end
    end)
end

local function processReplyStaticWrite(self, buf)
    mspWriteComplete = true

    if self.uuid then writeDoneRegistry[self.uuid] = true end

    local getComplete = self.getCompleteHandler
    if getComplete then
        local complete = getComplete()
        if complete then complete(self, buf) end
    end
end

local function errorHandlerStatic(self, buf)
    local getError = self.getErrorHandler
    if getError then
        local err = getError()
        if err then err(self, buf) end
    end
end

local function read()
    if MSP_API_CMD_READ == nil then
        bfsuite.utils.log("No value set for MSP_API_CMD_READ", "debug")
        return
    end

    local message = {command = MSP_API_CMD_READ, structure = MSP_API_STRUCTURE_READ, minBytes = MSP_MIN_BYTES, processReply = processReplyStaticRead, errorHandler = errorHandlerStatic, simulatorResponse = MSP_API_SIMULATOR_RESPONSE, uuid = MSP_API_UUID, timeout = MSP_API_MSG_TIMEOUT, getCompleteHandler = handlers.getCompleteHandler, getErrorHandler = handlers.getErrorHandler, mspData = nil}
    bfsuite.tasks.msp.mspQueue:add(message)
end

local function write(suppliedPayload)
    if MSP_API_CMD_WRITE == nil then
        bfsuite.utils.log("No value set for MSP_API_CMD_WRITE", "debug")
        return
    end

    local payload = suppliedPayload or core.buildWritePayload(API_NAME, payloadData, MSP_API_STRUCTURE_WRITE, MSP_REBUILD_ON_WRITE)

    local uuid = MSP_API_UUID or bfsuite.utils and bfsuite.utils.uuid and bfsuite.utils.uuid() or tostring(os.clock())
    lastWriteUUID = uuid

    local message = {command = MSP_API_CMD_WRITE, payload = payload, processReply = processReplyStaticWrite, errorHandler = errorHandlerStatic, simulatorResponse = {}, uuid = uuid, timeout = MSP_API_MSG_TIMEOUT, getCompleteHandler = handlers.getCompleteHandler, getErrorHandler = handlers.getErrorHandler}

    bfsuite.tasks.msp.mspQueue:add(message)
end

local function readValue(fieldName)
    if mspData and mspData['parsed'][fieldName] ~= nil then return mspData['parsed'][fieldName] end
    return nil
end

local function setValue(fieldName, value) payloadData[fieldName] = value end

local function readComplete() return mspData ~= nil and #mspData['buffer'] >= MSP_MIN_BYTES end

local function writeComplete() return mspWriteComplete end

local function resetWriteStatus() mspWriteComplete = false end

local function data() return mspData end

local function setUUID(uuid) MSP_API_UUID = uuid end

local function setTimeout(timeout) MSP_API_MSG_TIMEOUT = timeout end

return {read = read, write = write, readComplete = readComplete, writeComplete = writeComplete, readValue = readValue, setValue = setValue, resetWriteStatus = resetWriteStatus, setCompleteHandler = handlers.setCompleteHandler, setErrorHandler = handlers.setErrorHandler, data = data, setUUID = setUUID, setTimeout = setTimeout}
