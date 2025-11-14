--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local switches = {}

local switchTable = {switches = {}, units = {}}

local lastPlayTime = {}
local lastSwitchState = {}
local switchStartTime = nil

local function initializeSwitches()
    local prefs = bfsuite.preferences.switches
    if not prefs then return end

    for key, v in pairs(prefs) do
        if v then
            local scategory, smember = v:match("([^,]+),([^,]+)")
            scategory = tonumber(scategory)
            smember = tonumber(smember)
            if scategory and smember then switchTable.switches[key] = system.getSource({category = scategory, member = smember}) end
        end
    end

    switchTable.units = bfsuite.tasks.telemetry.listSensorAudioUnits()
end

function switches.wakeup()
    local now = os.clock()

    if next(switchTable.switches) == nil then initializeSwitches() end

    if not switchStartTime then switchStartTime = now end

    if (now - switchStartTime) <= 5 then return end

    for key, sensor in pairs(switchTable.switches) do
        local currentState = sensor:state()
        if currentState == nil then goto continue end

        local prevState = lastSwitchState[key] or false
        local lastTime = lastPlayTime[key] or 0
        local playNow = false

        if not currentState then
            goto skip_play
        elseif not prevState or (now - lastTime) >= 10 then
            playNow = true
        end

        if playNow then
            local sensorSrc = bfsuite.tasks.telemetry.getSensorSource(key)
            if sensorSrc then
                local value = sensorSrc:value()
                if value and type(value) == "number" then
                    local unit = switchTable.units[key]
                    local decimals = tonumber(sensorSrc:decimals())
                    system.playNumber(value, unit, decimals)
                    lastPlayTime[key] = now
                end
            end
        end

        ::skip_play::
        lastSwitchState[key] = currentState
        ::continue::
    end
end

function switches.resetSwitchStates()
    switchTable.switches = {}
    lastPlayTime = {}
    lastSwitchState = {}
    switchStartTime = nil
end

switches.switchTable = switchTable

return switches
