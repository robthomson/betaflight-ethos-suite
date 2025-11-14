--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]
local timer = {}

local triggered = false
local lastBeepTime = nil

function timer.wakeup()
    local session = bfsuite.session
    local modelFlightTime = session and session.modelFlightTime
    local batteryConfig = session and session.batteryConfig
    local targetSeconds = batteryConfig and batteryConfig.modelFlightTime or 0

    if not targetSeconds or targetSeconds == 0 or not modelFlightTime or modelFlightTime == 0 then
        triggered = false
        lastBeepTime = nil
        return
    end

    if bfsuite.flightmode.current ~= "inflight" then
        triggered = false
        lastBeepTime = nil
        return
    end

    if modelFlightTime >= targetSeconds then
        local now = os.clock()
        if not triggered then
            bfsuite.utils.playFileCommon("beep.wav")
            triggered = true
            lastBeepTime = now
        elseif lastBeepTime and (now - lastBeepTime) >= 10 then
            bfsuite.utils.playFileCommon("beep.wav")
            lastBeepTime = now
        end
    else
        triggered = false
        lastBeepTime = nil
    end
end

function timer.reset()
    triggered = false
    lastBeepTime = nil
end

return timer
