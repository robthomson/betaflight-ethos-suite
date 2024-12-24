--[[

 * Copyright (C) Rob Thomson
 *
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
 
 * Note.  Some icons have been sourced from https://www.flaticon.com/
 * 

]] --

if not bfsuite.utils.ethosVersionAtLeast() then
    return
end

local arg = {...}
local config = arg[1]
local currentTelemetrySensor

local tasks = {}
tasks.heartbeat = nil
tasks.init = false
tasks.wasOn = false

local tasksList = {}

bfsuite.session.telemetryTypeChanged = true

local ethosVersionGood = nil  
local telemetryCheckScheduler = os.clock()
local lastTelemetrySensorName = nil

local sportSensor 
local elrsSensor


local tlm = system.getSource({category = CATEGORY_SYSTEM_EVENT, member = TELEMETRY_ACTIVE})

if bfsuite.app.moduleList == nil then bfsuite.app.moduleList = bfsuite.utils.findModules() end

tasks._callbacks = {}

local function get_time()
    return os.clock()
end

function tasks.callbackNow(callback)
    table.insert(tasks._callbacks, {time = nil, func = callback, repeat_interval = nil})
end

function tasks.callbackInSeconds(seconds, callback)
    table.insert(tasks._callbacks, {time = get_time() + seconds, func = callback, repeat_interval = nil})
end

function tasks.callbackEvery(seconds, callback)
    table.insert(tasks._callbacks, {time = get_time() + seconds, func = callback, repeat_interval = seconds})
end

function tasks.callback()
    local now = get_time()
    local i = 1
    while i <= #tasks._callbacks do
        local entry = tasks._callbacks[i]
        if not entry.time or entry.time <= now then
            entry.func()
            if entry.repeat_interval then
                entry.time = now + entry.repeat_interval
                i = i + 1
            else
                table.remove(tasks._callbacks, i)
            end
        else
            i = i + 1
        end
    end
end

function tasks.clearCallback(callback)
    for i = #tasks._callbacks, 1, -1 do
        if tasks._callbacks[i].func == callback then
            table.remove(tasks._callbacks, i)
        end
    end
end

function tasks.clearAllCallbacks()
    tasks._callbacks = {}
end

-- Modified findTasks to return metadata for caching
function tasks.findTasks()
    local taskdir = "tasks"
    local tasks_path = "tasks/"
    local taskMetadata = {}

    for _, v in pairs(system.listFiles(tasks_path)) do
        if v ~= ".." and v ~= "tasks.lua" then
            local init_path = tasks_path .. v .. '/init.lua'
            local func, err = loadfile(init_path)

            if err then
                bfsuite.utils.log("Error loading " .. init_path .. ": " .. err, "info")
            end

            if func then
                local tconfig = func()
                if type(tconfig) ~= "table" or not tconfig.interval or not tconfig.script then
                    bfsuite.utils.log("Invalid configuration in " .. init_path, "debug")
                else
                    local task = {
                        name = v,
                        interval = tconfig.interval,
                        script = tconfig.script,
                        msp = tconfig.msp,
                        always_run = tconfig.always_run or false,
                        last_run = os.clock()
                    }
                    table.insert(tasksList, task)

                    taskMetadata[v] = {
                        interval = tconfig.interval,
                        script = tconfig.script,
                        msp = tconfig.msp,
                        always_run = tconfig.always_run or false
                    }

                    local script = tasks_path .. v .. '/' .. tconfig.script
                    local fs = io.open(script, "r")
                    if fs then
                        io.close(fs)
                        tasks[v] = assert(loadfile(script))(config)
                    end
                end
            end
        end    
    end

    return taskMetadata
end

function tasks.active()
    if tasks.heartbeat == nil then return false end
    if (os.clock() - tasks.heartbeat) >= 2 then
        tasks.wasOn = true
    else
        tasks.wasOn = false
    end
    if bfsuite.app.triggers.mspBusy == true then return true end
    if (os.clock() - tasks.heartbeat) <= 2 then return true end
    return false
end

function tasks.wakeup()
    if ethosVersionGood == nil then
        ethosVersionGood = bfsuite.utils.ethosVersionAtLeast()
    end

    if not ethosVersionGood then
        return
    end

    bfsuite.log.process()    
    tasks.callback()

    if tasks.init == false then
        local cacheFile = "tasks.cache"
        local cachePath = "cache/" .. cacheFile
        local taskMetadata

        if io.open(cachePath, "r") then
            local ok, cached = pcall(dofile, cachePath)
            if ok and type(cached) == "table" then
                taskMetadata = cached
                bfsuite.utils.log("[cache] Loaded task metadata from cache","info")
            else
                bfsuite.utils.log("[cache] Failed to load tasks cache","info")
            end
        end

        if not taskMetadata then
            taskMetadata = tasks.findTasks()
            bfsuite.utils.createCacheFile(taskMetadata, cacheFile)
            bfsuite.utils.log("[cache] Created new tasks cache file","info")
        else
            for name, meta in pairs(taskMetadata) do
                local script = "tasks/" .. name .. "/" .. meta.script
                local module = assert(loadfile(script))(config)

                tasks[name] = module
                table.insert(tasksList, {
                    name = name,
                    interval = meta.interval,
                    script = meta.script,
                    msp = meta.msp,
                    always_run = meta.always_run,
                    last_run = os.clock()
                })
            end
        end

        tasks.init = true
        return
    end

    tasks.heartbeat = os.clock()

    local now = os.clock()
    if now - (telemetryCheckScheduler or 0) >= 1 then
        telemetryState = tlm and tlm:state() or false

        if not telemetryState then
            bfsuite.session.telemetryState = false
            bfsuite.session.telemetryType = nil
            bfsuite.session.telemetryTypeChanged = false
            bfsuite.session.telemetrySensor = nil
            lastTelemetrySensorName = nil
            sportSensor = nil
            elrsSensor = nil 
            telemetryCheckScheduler = now    
        else

            -- always do a lookup.  we cannot cache this
            sportSensor = system.getSource({appId = 0xF101}) 
            elrsSensor = system.getSource({crsfId=0x14, subIdStart=0, subIdEnd=1}) 

            currentTelemetrySensor = sportSensor or elrsSensor or nil
            bfsuite.session.telemetrySensor = currentTelemetrySensor

            if currentTelemetrySensor == nil  then
                bfsuite.session.telemetryState = false
                bfsuite.session.telemetryType = nil
                bfsuite.session.telemetryTypeChanged = false
                bfsuite.session.telemetrySensor = nil
                lastTelemetrySensorName = nil
                sportSensor = nil
                elrsSensor = nil 
                telemetryCheckScheduler = now
            else
                bfsuite.session.telemetryState = true
                bfsuite.session.telemetryType = sportSensor and "sport" or elrsSensor and "crsf" or nil
                bfsuite.session.telemetryTypeChanged = currentTelemetrySensor and (lastTelemetrySensorName ~= currentTelemetrySensor:name()) or false
                lastTelemetrySensorName = currentTelemetrySensor and currentTelemetrySensor:name() or nil    
                telemetryCheckScheduler = now
            end
        end
    end

    for _, task in ipairs(tasksList) do
        if now - task.last_run >= task.interval then
            if tasks[task.name].wakeup then
                if task.always_run or telemetryState then
                    if task.msp == true then
                        tasks[task.name].wakeup()
                    else
                        if not bfsuite.app.triggers.mspBusy then
                            tasks[task.name].wakeup() 
                        end
                    end
                end
                task.last_run = now
            end
        end
    end
end

function tasks.event(widget, category, value)
    -- currently does nothing.
end

return tasks