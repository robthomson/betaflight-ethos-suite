--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]
local events = {}
local telemetryStartTime = nil
local wakeupStep = 0
local wakeupHandlers = {}

local taskNames = {"telemetry", "switches", "flightmode", "stats", "rxmap", "timer"}
local taskExecutionPercent = 50

for _, name in ipairs(taskNames) do
    events[name] = assert(loadfile("tasks/events/tasks/" .. name .. ".lua"))(bfsuite.config)
    table.insert(wakeupHandlers, function() events[name].wakeup() end)
end

function events.wakeup()
    local currentTime = os.clock()

    if bfsuite.session.isConnected and bfsuite.session.telemetryState then
        if telemetryStartTime == nil then telemetryStartTime = currentTime end

        if (currentTime - telemetryStartTime) < 2.5 then return end

        local percent = taskExecutionPercent or 25
        local tasksPerWakeup = math.max(1, math.floor((percent / 100) * #wakeupHandlers))

        for i = 1, tasksPerWakeup do
            wakeupStep = (wakeupStep % #wakeupHandlers) + 1
            wakeupHandlers[wakeupStep]()
        end
    else
        telemetryStartTime = nil
        wakeupStep = 0
    end
end

function events.reset() telemetryStartTime = nil end

return events

