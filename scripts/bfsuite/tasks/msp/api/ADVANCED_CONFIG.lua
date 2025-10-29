--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local core = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/api_core.lua"))()

local API_NAME = "ADVANCED_CONFIG"
local MSP_API_CMD_READ = 90
local MSP_API_CMD_WRITE = 91
local MSP_REBUILD_ON_WRITE = false

-- LuaFormatter off
local MSP_API_STRUCTURE_READ_DATA = {
  { field = "gyro_sync_denom",                  type = "U8",  apiVersion = 1.43, simResponse = {1} },        -- fixed 1 (legacy placeholder)
  { field = "pid_process_denom",                type = "U8",  apiVersion = 1.43, simResponse = {2} },
  { field = "useContinuousUpdate",              type = "U8",  apiVersion = 1.43, simResponse = {0} },
  { field = "motorProtocol",                    type = "U8",  apiVersion = 1.43, simResponse = {6} },
  { field = "motorPwmRate",                     type = "U16", apiVersion = 1.43, simResponse = {224, 1} },    -- 480
  { field = "motorIdle",                        type = "U16", apiVersion = 1.43, simResponse = {38, 2} },     -- 550
  { field = "gyro_use_32kHz",                   type = "U8",  apiVersion = 1.43, simResponse = {0} },         -- deprecated
  { field = "motorInversion",                   type = "U8",  apiVersion = 1.43, simResponse = {0} },
  { field = "gyro_to_use",                      type = "U8",  apiVersion = 1.43, simResponse = {0} },         -- deprecated
  { field = "gyro_high_fsr",                    type = "U8",  apiVersion = 1.43, simResponse = {0} },
  { field = "gyroMovementCalibrationThreshold", type = "U8",  apiVersion = 1.43, simResponse = {48} },
  { field = "gyroCalibrationDuration",          type = "U16", apiVersion = 1.43, simResponse = {125, 0} },    -- 125
  { field = "gyro_offset_yaw",                  type = "U16", apiVersion = 1.43, simResponse = {0, 0} },
  { field = "checkOverflow",                    type = "U8",  apiVersion = 1.43, simResponse = {2} },
  { field = "debug_mode",                       type = "U8",  apiVersion = 1.42, simResponse = {20} },
  { field = "debug_count",                      type = "U8",  apiVersion = 1.42, simResponse = {90} },
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
