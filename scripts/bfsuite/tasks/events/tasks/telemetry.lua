--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local telemetry = {}

local lastEventTimes = {}
local lastValues = {}
local lastPlayTime = {}

local userpref = bfsuite.preferences
local enabledEvents = (userpref and userpref.events) or {}

local eventTable = {
    {
        sensor = "voltage",
        event = function(value)
            local session = bfsuite.session
            if not session.batteryConfig then return end

            local cellCount = session.batteryConfig.batteryCellCount
            local warnVoltage = session.batteryConfig.vbatwarningcellvoltage
            local minVoltage = session.batteryConfig.vbatmincellvoltage

            local collective = session.rx.values['collective'] or 0
            local aileron = session.rx.values['aileron'] or 0
            local elevator = session.rx.values['elevator'] or 0
            local rudder = session.rx.values['rudder'] or 0

            if not (cellCount and warnVoltage and minVoltage) then return end

            local cellVoltage = value / cellCount
            if cellVoltage >= 0 and cellVoltage < (minVoltage / 2) then return end

            local suppressionPercent = userpref.general.gimbalsupression or 0.85
            local suppressionLimit = suppressionPercent * 1024

            if cellVoltage < warnVoltage then bfsuite.utils.playFile("events", "alerts/lowvoltage.wav") end
        end,
        interval = 10
    }, {sensor = "smartfuel", event = function(value) if value and value <= 10 then bfsuite.utils.playFile("events", "alerts/lowfuel.wav") end end, interval = 10}, {
        sensor = "armed",
        event = function(value)
            if value == 0 then bfsuite.utils.playFile("events", "alerts/armed.wav") end
            if value == 1 then bfsuite.utils.playFile("events", "alerts/disarmed.wav") end
        end,
        debounce = 0.25
    }, {sensor = "inflight", event = function(value) if bfsuite.tasks.telemetry.getSensorSource("armed"):value() == 0 then end end, debounce = 0.25}
}

function telemetry.wakeup()
    local now = os.clock()

    for _, item in ipairs(eventTable) do
        local key = item.sensor
        if not enabledEvents[key] then goto continue end

        local source = bfsuite.tasks.telemetry.getSensorSource(key)
        if not source then goto continue end

        local value = source:value()
        if not value then goto continue end

        local lastVal = lastValues[key]
        if lastVal and value == lastVal then goto continue end

        local lastTime = lastEventTimes[key] or 0
        local debounce = item.debounce or 0
        local interval = item.interval or 0

        if debounce > 0 and (now - lastTime) < debounce then goto continue end
        if interval > 0 and (now - lastTime) < interval then goto continue end

        item.event(value)
        lastValues[key] = value
        lastEventTimes[key] = now

        ::continue::
    end
end

telemetry.eventTable = eventTable

return telemetry
