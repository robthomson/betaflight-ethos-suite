--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local core = assert(loadfile("SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/api_core.lua"))()

local API_NAME = "PID_ADVANCED"
local MSP_API_CMD_READ = 94
local MSP_API_CMD_WRITE = 95
local MSP_REBUILD_ON_WRITE = false

-- LuaFormatter off
local MSP_API_STRUCTURE_READ_DATA = {
    { field = "reserved1",               type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "reserved2",               type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "yaw_p_limit",             type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "reserved3",               type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "vbatPidCompensation",     type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "feedforward_transition",  type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "dtermSetpointWeight_low", type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "reserved4",               type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "reserved5",               type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "reserved6",               type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "rateAccelLimit",          type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "yawRateAccelLimit",       type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "angle_limit",             type = "U8",  apiVersion = 1.45, simResponse = {60},         min = 0, max = 255,   default = 60 },
    { field = "levelSensitivity",        type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "itermThrottleThreshold",  type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "anti_gravity_gain",       type = "U16", apiVersion = 1.45, simResponse = {80, 0},      min = 0, max = 65535, default = 80 },
    { field = "dtermSetpointWeight",     type = "U16", apiVersion = 1.45, simResponse = {0, 0},       min = 0, max = 65535, default = 0 },
    { field = "iterm_rotation",          type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "smart_feedforward",       type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "iterm_relax",             type = "U8",  apiVersion = 1.45, simResponse = {1},          min = 0, max = 255,   default = 1 },
    { field = "iterm_relax_type",        type = "U8",  apiVersion = 1.45, simResponse = {1},          min = 0, max = 255,   default = 1 },
    { field = "abs_control_gain",        type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "throttle_boost",          type = "U8",  apiVersion = 1.45, simResponse = {5},          min = 0, max = 255,   default = 5 },
    { field = "acro_trainer_angle_limit", type = "U8",  apiVersion = 1.45, simResponse = {20},         min = 0, max = 255,   default = 20 },
    { field = "pid_roll_F",              type = "U16", apiVersion = 1.45, simResponse = {120, 0},     min = 0, max = 65535, default = 120 },
    { field = "pid_pitch_F",             type = "U16", apiVersion = 1.45, simResponse = {125, 0},     min = 0, max = 65535, default = 125 },
    { field = "pid_yaw_F",               type = "U16", apiVersion = 1.45, simResponse = {120, 0},     min = 0, max = 65535, default = 120 },
    { field = "antiGravityMode",         type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "d_max_roll",              type = "U8",  apiVersion = 1.45, simResponse = {30},         min = 0, max = 255,   default = 30 },
    { field = "d_max_pitch",             type = "U8",  apiVersion = 1.45, simResponse = {34},         min = 0, max = 255,   default = 34 },
    { field = "d_max_yaw",               type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "d_max_gain",              type = "U8",  apiVersion = 1.45, simResponse = {37},         min = 0, max = 255,   default = 37 },
    { field = "d_max_advance",           type = "U8",  apiVersion = 1.45, simResponse = {20},         min = 0, max = 255,   default = 20 },
    { field = "use_integrated_yaw",      type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "integrated_yaw_relax",    type = "U8",  apiVersion = 1.45, simResponse = {200},        min = 0, max = 255,   default = 200 },
    { field = "iterm_relax_cutoff",      type = "U8",  apiVersion = 1.45, simResponse = {15},         min = 0, max = 255,   default = 15 },
    { field = "motor_output_limit",      type = "U8",  apiVersion = 1.45, simResponse = {100},        min = 0, max = 255,   default = 100 },
    { field = "auto_profile_cell_count", type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "dyn_idle_min_rpm",        type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "feedforward_averaging",   type = "U8",  apiVersion = 1.45, simResponse = {1},          min = 0, max = 255,   default = 1 },
    { field = "feedforward_smooth_factor", type = "U8", apiVersion = 1.45, simResponse = {35},         min = 0, max = 255,   default = 35 },
    { field = "feedforward_boost",       type = "U8",  apiVersion = 1.45, simResponse = {18},         min = 0, max = 255,   default = 18 },
    { field = "feedforward_max_rate_limit", type = "U8", apiVersion = 1.45, simResponse = {90},         min = 0, max = 255,   default = 90 },
    { field = "feedforward_jitter_factor", type = "U8", apiVersion = 1.45, simResponse = {4},          min = 0, max = 255,   default = 4 },
    { field = "vbat_sag_compensation",   type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "thrustLinearization",     type = "U8",  apiVersion = 1.45, simResponse = {0},          min = 0, max = 255,   default = 0 },
    { field = "tpa_mode",                type = "U8",  apiVersion = 1.45, simResponse = {1},          min = 0, max = 255,   default = 1 },
    { field = "tpa_rate",                type = "U8",  apiVersion = 1.45, simResponse = {65},         min = 0, max = 255,   default = 65 },
    { field = "tpa_breakpoint",          type = "U16", apiVersion = 1.45, simResponse = {70, 5},      min = 0, max = 65535, default = 1350 },
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
