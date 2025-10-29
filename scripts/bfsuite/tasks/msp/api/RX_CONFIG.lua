--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local core = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/api_core.lua"))()

local API_NAME = "RX_CONFIG"
local MSP_API_CMD_READ = 44
local MSP_API_CMD_WRITE = 45
local MSP_REBUILD_ON_WRITE = false

-- LuaFormatter off
local MSP_API_STRUCTURE_READ_DATA = {
  { field = "serialrx_provider",                 type = "U8",  apiVersion = 1.41, simResponse = {9} },
  { field = "maxcheck",                          type = "U16", apiVersion = 1.41, simResponse = {108,7} },     -- 1900
  { field = "midrc",                             type = "U16", apiVersion = 1.41, simResponse = {220,5} },     -- 1500
  { field = "mincheck",                          type = "U16", apiVersion = 1.41, simResponse = {26,4} },      -- 1050
  { field = "spektrum_sat_bind",                 type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rx_min_usec",                       type = "U16", apiVersion = 1.41, simResponse = {117,3} },     -- 885
  { field = "rx_max_usec",                       type = "U16", apiVersion = 1.41, simResponse = {67,8} },      -- 2115

  { field = "rcInterpolation_deprecated",        type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rcInterpolationInterval_deprecated",type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "airModeActivateThresholdX10p1000",  type = "U16", apiVersion = 1.41, simResponse = {226,4} },     -- 1250 (threshold ≈ 25)

  { field = "rx_spi_protocol",                   type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rx_spi_id",                         type = "U32", apiVersion = 1.41, simResponse = {0,0,0,0} },
  { field = "rx_spi_rf_channel_count",           type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "fpvCamAngleDegrees",                type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rcSmoothingChannels_deprecated",    type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rc_smoothing_type_deprecated",      type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rc_smoothing_setpoint_cutoff",      type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rc_smoothing_throttle_cutoff",      type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rc_smoothing_auto_factor_throttle", type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "rc_smoothing_derivative_type_depr", type = "U8",  apiVersion = 1.41, simResponse = {0} },
  { field = "usb_hid_type",                      type = "U8",  apiVersion = 1.41, simResponse = {0} },

  { field = "rc_smoothing_auto_factor_rpy",      type = "U8",  apiVersion = 1.42, simResponse = {30} },
  { field = "rc_smoothing_enable",               type = "U8",  apiVersion = 1.44, simResponse = {1} },

  -- ELRS UID (added in 1.45)
  { field = "elrs_uid_0",                        type = "U8",  apiVersion = 1.45, simResponse = {0} },
  { field = "elrs_uid_1",                        type = "U8",  apiVersion = 1.45, simResponse = {0} },
  { field = "elrs_uid_2",                        type = "U8",  apiVersion = 1.45, simResponse = {0} },
  { field = "elrs_uid_3",                        type = "U8",  apiVersion = 1.45, simResponse = {0} },
  { field = "elrs_uid_4",                        type = "U8",  apiVersion = 1.45, simResponse = {0} },
  { field = "elrs_uid_5",                        type = "U8",  apiVersion = 1.45, simResponse = {0} },
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
