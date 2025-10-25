--[[
  Copyright (C) 2025 Rob Thomson Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local protocol = {}

-- LuaFormatter off
local supportedProtocols = {
  sport = {
    mspTransport     = "sp.lua",
    mspProtocol      = "sport",
    maxTxBufferSize  = 6,
    maxRxBufferSize  = 6,
    maxRetries       = 10,
    saveTimeout      = 10.0,
    cms              = {},
    pageReqTimeout   = 15,
  },

  crsf = {
    mspTransport     = "crsf.lua",
    mspProtocol      = "crsf",
    maxTxBufferSize  = 8,
    maxRxBufferSize  = 58,
    maxRetries       = 5,
    saveTimeout      = 10.0,
    cms              = {},
    pageReqTimeout   = 10,
  },
}
-- LuaFormatter on

function protocol.getProtocol()
    if bfsuite.session and bfsuite.session.telemetryType then if bfsuite.session.telemetryType == "crsf" then return supportedProtocols.crsf end end
    return supportedProtocols.sport
end

function protocol.getTransports()
    local transport = {}
    for i, v in pairs(supportedProtocols) do transport[i] = "SCRIPTS:/" .. bfsuite.config.baseDir .. "/tasks/msp/" .. v.mspTransport end
    return transport
end

return protocol
