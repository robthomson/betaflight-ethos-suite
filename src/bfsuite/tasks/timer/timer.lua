--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}
local config = arg[1]

local timer = {}
local lastFlightMode = nil

function timer.reset()
    bfsuite.utils.log("Resetting flight timers", "info")
    lastFlightMode = nil

    local timerSession = {}
    bfsuite.session.timer = timerSession
    bfsuite.session.flightCounted = false

    timerSession.baseLifetime = tonumber(bfsuite.ini.getvalue(bfsuite.session.modelPreferences, "general", "totalflighttime")) or 0

    timerSession.session = 0
    timerSession.lifetime = timerSession.baseLifetime
end

function timer.save()
    local prefs = bfsuite.session.modelPreferences
    local prefsFile = bfsuite.session.modelPreferencesFile

    if not prefsFile then
        bfsuite.utils.log("No model preferences file set, cannot save flight timers", "info")
        return
    end

    bfsuite.utils.log("Saving flight timers to INI: " .. prefsFile, "info")

    if prefs then
        bfsuite.ini.setvalue(prefs, "general", "totalflighttime", bfsuite.session.timer.baseLifetime or 0)
        bfsuite.ini.setvalue(prefs, "general", "lastflighttime", bfsuite.session.timer.session or 0)
        bfsuite.ini.save_ini_file(prefsFile, prefs)
    end
end

local function finalizeFlightSegment(now)
    local timerSession = bfsuite.session.timer
    local prefs = bfsuite.session.modelPreferences

    local segment = now - timerSession.start
    timerSession.session = (timerSession.session or 0) + segment
    timerSession.start = nil

    if timerSession.baseLifetime == nil then timerSession.baseLifetime = tonumber(bfsuite.ini.getvalue(prefs, "general", "totalflighttime")) or 0 end

    timerSession.baseLifetime = timerSession.baseLifetime + segment
    timerSession.lifetime = timerSession.baseLifetime

    timer.save()
end

function timer.wakeup()
    local now = os.time()
    local timerSession = bfsuite.session.timer
    local prefs = bfsuite.session.modelPreferences
    local flightMode = bfsuite.flightmode.current

    lastFlightMode = flightMode

    if flightMode == "inflight" then
        if not timerSession.start then timerSession.start = now end

        local currentSegment = now - timerSession.start
        timerSession.live = (timerSession.session or 0) + currentSegment

        local computedLifetime = (timerSession.baseLifetime or 0) + currentSegment
        timerSession.lifetime = computedLifetime

        if prefs then bfsuite.ini.setvalue(prefs, "general", "totalflighttime", computedLifetime) end

        if timerSession.live >= 25 and not bfsuite.session.flightCounted then
            bfsuite.session.flightCounted = true

            if prefs and bfsuite.ini.section_exists(prefs, "general") then
                local count = bfsuite.ini.getvalue(prefs, "general", "flightcount") or 0
                bfsuite.ini.setvalue(prefs, "general", "flightcount", count + 1)
                bfsuite.ini.save_ini_file(bfsuite.session.modelPreferencesFile, prefs)
            end
        end

    else
        timerSession.live = timerSession.session or 0
    end

    if flightMode == "postflight" and timerSession.start then finalizeFlightSegment(now) end
end

return timer
