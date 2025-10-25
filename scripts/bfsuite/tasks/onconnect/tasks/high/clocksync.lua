--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local clocksync = {}

function clocksync.wakeup()

    if bfsuite.session.apiVersion == nil then return end

    if bfsuite.session.mspBusy then return end

    if bfsuite.session.clockSet == nil then

        local API = bfsuite.tasks.msp.api.load("RTC", 1)
        API.setCompleteHandler(function(self, buf)
            bfsuite.session.clockSet = true
            bfsuite.utils.log("Sync clock: " .. os.date("%c"), "info")
        end)
        API.setUUID("eaeb0028-219b-4cec-9f57-3c7f74dd49ac")
        API.setValue("seconds", os.time())
        API.setValue("milliseconds", 0)
        API.write()
    end

end

function clocksync.reset() bfsuite.session.clockSet = nil end

function clocksync.isComplete() if bfsuite.session.clockSet ~= nil then return true end end

return clocksync
