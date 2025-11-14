--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local logger = {}

os.mkdir("LOGS:")
os.mkdir("LOGS:/bfsuite")
os.mkdir("LOGS:/bfsuite/logs")
logger.queue = assert(loadfile("tasks/logger/lib/log.lua"))(config)
logger.queue.config.log_file = "LOGS:/bfsuite/logs/bfsuite_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log"
logger.queue.config.min_print_level = bfsuite.preferences.developer.loglevel
local logtofile = bfsuite.preferences.developer.logtofile
logger.queue.config.log_to_file = (logtofile == true or logtofile == "true")

function logger.wakeup()
    if bfsuite.session.mspBusy then return end
    logger.queue.process()
end

function logger.reset() end

function logger.add(message, level)
    logger.queue.config.min_print_level = bfsuite.preferences.developer.loglevel
    local logtofile = bfsuite.preferences.developer.logtofile
    logger.queue.config.log_to_file = (logtofile == true or logtofile == "true")
    logger.queue.config.prefix = function() return string.format("[%.2f] ", os.clock()) end
    logger.queue.add(message, level)
end

return logger
