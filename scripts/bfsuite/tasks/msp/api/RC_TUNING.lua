--[[
 * Copyright (C) Rotorflight Project
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
 *
 * Note. Some icons have been sourced from https://www.flaticon.com/
]] --
-- Constants for MSP Commands
local API_NAME = "RC_TUNING" -- API name (must be same as filename)
local MSP_API_CMD_READ = 111 -- Command identifier 
local MSP_API_CMD_WRITE = 204 -- Command identifier 
local MSP_REBUILD_ON_WRITE = true -- Rebuild the payload on write; keep true to ensure proper defaults after changing rates type

-- Define the MSP response data structures
local MSP_API_STRUCTURE_READ_DATA = {
    { field = "rcRates_1",           type = "U8",  apiVersion = 1.45 },
    { field = "rcExpo_1",            type = "U8",  apiVersion = 1.45 },
    { field = "rates_1",             type = "U8",  apiVersion = 1.45 },
    { field = "rates_2",            type = "U8",  apiVersion = 1.45 },
    { field = "rates_3",              type = "U8",  apiVersion = 1.45 },
    { field = "tpa_rate",               type = "U8",  apiVersion = 1.45 },
    { field = "thrMid",                type = "U8", min=0, max=100, scale=100, decimals =2 ,apiVersion = 1.45},
    { field = "thrExpo",               type = "U8",  min=0, max=100, scale=100,decimals = 2, apiVersion = 1.45 },
    { field = "tpa_breakpoint",         type = "U16", apiVersion = 1.45 },
    { field = "rcExpo_3",             type = "U8",  apiVersion = 1.45 },
    { field = "rcRates_3",            type = "U8",  apiVersion = 1.45 },
    { field = "rcRates_2",          type = "U8",  apiVersion = 1.45 },
    { field = "rcExpo_2",           type = "U8",  apiVersion = 1.45 },
    { field = "throttle_limit_type",    type = "U8",  apiVersion = 1.45, tableIdxInc = -1, table = {"OFF", "SCALE", "CLIP"} },
    { field = "throttle_limit_percent", type = "U8",  min=0, max=100, default=100, apiVersion = 1.45 },
    { field = "rate_limit_Roll",        type = "U16", apiVersion = 1.45 },
    { field = "rate_limit_Pitch",       type = "U16", apiVersion = 1.45 },
    { field = "rate_limit_Yaw",         type = "U16", apiVersion = 1.45 },
    { field = "rates_type",             type = "U8",  apiVersion = 1.45 , tableIdxInc = -1, table = {"BETAFLIGHT", "RACEFLIGHT", "KISS", "ACTUAL", "QUICK"}},
}

-- Process structure in one pass
local MSP_API_STRUCTURE_READ, MSP_MIN_BYTES, MSP_API_SIMULATOR_RESPONSE =
    bfsuite.tasks.msp.api.prepareStructureData(MSP_API_STRUCTURE_READ_DATA)

-- set read structure
local MSP_API_STRUCTURE_WRITE = MSP_API_STRUCTURE_READ

-- Variable to store parsed MSP data
local mspData = nil
local mspWriteComplete = false
local payloadData = {}
local defaultData = {}

-- Create a new instance
local handlers = bfsuite.tasks.msp.api.createHandlers()

-- Variables to store optional the UUID and timeout for payload
local MSP_API_UUID
local MSP_API_MSG_TIMEOUT

-- Function to initiate MSP read operation
local function read()
    if MSP_API_CMD_READ == nil then
        bfsuite.utils.log("No value set for MSP_API_CMD_READ", "debug")
        return
    end

    local message = {
        command = MSP_API_CMD_READ,
        processReply = function(self, buf)
            local structure = MSP_API_STRUCTURE_READ
            bfsuite.tasks.msp.api.parseMSPData(buf, structure, nil, nil, function(result)
                mspData = result
                if #buf >= MSP_MIN_BYTES then
                    local completeHandler = handlers.getCompleteHandler()
                    if completeHandler then completeHandler(self, buf) end
                end
            end)
        end,
        errorHandler = function(self, buf)
            local errorHandler = handlers.getErrorHandler()
            if errorHandler then errorHandler(self, buf) end
        end,
        simulatorResponse = MSP_API_SIMULATOR_RESPONSE,
        uuid = MSP_API_UUID,
        timeout = MSP_API_MSG_TIMEOUT  
    }
    bfsuite.tasks.msp.mspQueue:add(message)
end

local function write(suppliedPayload)
    if MSP_API_CMD_WRITE == nil then
        bfsuite.utils.log("No value set for MSP_API_CMD_WRITE", "debug")
        return
    end

    local message = {
        command = MSP_API_CMD_WRITE,
        payload = suppliedPayload or bfsuite.tasks.msp.api.buildWritePayload(API_NAME, payloadData,MSP_API_STRUCTURE_WRITE, MSP_REBUILD_ON_WRITE),
        processReply = function(self, buf)
            local completeHandler = handlers.getCompleteHandler()
            if completeHandler then completeHandler(self, buf) end
            mspWriteComplete = true
        end,
        errorHandler = function(self, buf)
            local errorHandler = handlers.getErrorHandler()
            if errorHandler then errorHandler(self, buf) end
        end,
        simulatorResponse = {},
        uuid = MSP_API_UUID,
        timeout = MSP_API_MSG_TIMEOUT  
    }
    bfsuite.tasks.msp.mspQueue:add(message)
end

-- Function to get the value of a specific field from MSP data
local function readValue(fieldName)
    if mspData and mspData['parsed'][fieldName] ~= nil then return mspData['parsed'][fieldName] end
    return nil
end

-- Function to set a value dynamically
local function setValue(fieldName, value)
    payloadData[fieldName] = value
end

-- Function to check if the read operation is complete
local function readComplete()
    return mspData ~= nil and #mspData['buffer'] >= MSP_MIN_BYTES
end

-- Function to check if the write operation is complete
local function writeComplete()
    return mspWriteComplete
end

-- Function to reset the write completion status
local function resetWriteStatus()
    mspWriteComplete = false
end

-- Function to return the parsed MSP data
local function data()
    return mspData
end

-- set the UUID for the payload
local function setUUID(uuid)
    MSP_API_UUID = uuid
end

-- set the timeout for the payload
local function setTimeout(timeout)
    MSP_API_MSG_TIMEOUT = timeout
end

-- Return the module's API functions
return {
    read = read,
    write = write,
    readComplete = readComplete,
    writeComplete = writeComplete,
    readValue = readValue,
    setValue = setValue,
    resetWriteStatus = resetWriteStatus,
    setCompleteHandler = handlers.setCompleteHandler,
    setErrorHandler = handlers.setErrorHandler,
    data = data,
    setUUID = setUUID,
    setTimeout = setTimeout
}
