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
-- Betaflight + ETHOS LUA configuration
local config = {}

-- LuaFormatter off

-- Configuration settings for the Betaflight Lua Ethos Suite
config.toolName = "Betaflight"                                     -- name of the tool 
config.icon = lcd.loadMask("app/gfx/icon.png")                      -- icon
config.icon_logtool = lcd.loadMask("app/gfx/icon_logtool.png")      -- icon
config.icon_unsupported = lcd.loadMask("app/gfx/unsupported.png")   -- icon
config.Version = "1.0.0"                                            -- version number of this software replace
config.ethosVersion = {1, 6, 2}                                     -- min version of ethos supported by this script                                                     
config.supportedMspApiVersion = {"1.46"}                            -- supported msp versions
config.simulatorApiVersionResponse = {0, 1, 46}                      -- version of api return by simulator
config.baseDir = "bfsuite"                                          -- base directory for the suite. This is only used by msp api to ensure correct path
config.logLevel= "info"                                             -- off | info | debug [default = info]
config.logToFile = false                                            -- log to file [default = false] (log file is in /scripts/bfsuite/logs)
config.logMSP = true                                               -- log msp messages [default =  false]
config.logMemoryUsage = false                                       -- log memory usage [default = false]
config.developerMode = false                                        -- show developer tools on main menu [default = false]


-- Betaflight + ETHOS LUA preferences
local preferences = {}

-- Configuration options that adjust behavior of the script (will be moved to a settings menu in the future)
preferences.flightLog = true                                        -- will write a flight log into /scripts/bfsuite/logs/<modelname>/*.log
preferences.reloadOnSave = false                                    -- trigger a reload on save [default = false]
preferences.internalElrsSensors = true                              -- disable the integrated elrs telemetry processing [default = true]
preferences.internalSportSensors = true                             -- disable the integrated smart port telemetry processing [default = true]
preferences.internalSimSensors = true                               -- disable the integrated simulator telemetry processing [default = true]
preferences.adjFunctionAlerts = false                               -- do not alert on adjfunction telemetry.  [default = false]
preferences.adjValueAlerts = true                                   -- play adjvalue alerts if sensor changes [default = true]  
preferences.saveWhenArmedWarning = true                             -- do not display the save when armed warning. [default = true]
preferences.audioAlerts = 1                                         -- 0 = all, 1 = alerts, 2 = disable [default = 1]
preferences.profileSwitching = true                                 -- enable auto profile switching [default = true]
preferences.iconSize = 1                                            -- 0 = text, 1 = small, 2 = large [default = 1]
preferences.syncCraftName = false                                   -- sync the craft name with the model name [default = false]
preferences.mspExpBytes = 8                                         -- number of bytes for msp_exp [default = 8] 
preferences.defaultRateProfile = 4 -- ACTUAL                        -- default rate table [default = 4]
preferences.watchdogParam = 10                                      -- watchdog timeout for progress boxes [default = 10]


-- tasks
config.bgTaskName = config.toolName .. " [Background]"              -- background task name for msp services etc
config.bgTaskKey = "bfbg"                                          -- key id used for msp services

-- LuaFormatter on

-- main
-- bfsuite: Main table for the Betaflight-lua-ethos-suite script.
-- bfsuite.config: Configuration table for the suite.
-- bfsuite.session: Session table for the suite.
-- bfsuite.app: Application module loaded from "app/app.lua" with the provided configuration.
bfsuite = {}
bfsuite.config = config
bfsuite.preferences = preferences
bfsuite.session = {}
bfsuite.app = assert(loadfile("app/app.lua"))(config)

-- 
-- This script initializes the logging configuration for the bfsuite module.
-- 
-- The logging configuration is loaded from the "lib/log.lua" file and is 
-- customized based on the provided configuration (`config`).
-- 
-- The log file is named using the current date and time in the format 
-- "logs/bfsuite_YYYY-MM-DD_HH-MM-SS.log".
-- 
-- The minimum print level for logging is set from `config.logLevel`.
-- 
-- The option to log to a file is set from `config.logToFile`.
-- 
-- If the system is running in simulation mode, the log print interval is 
-- set to 0.1 seconds.
-- logging
os.mkdir("LOGS:")
os.mkdir("LOGS:/bfsuite")
os.mkdir("LOGS:/bfsuite/logs")
bfsuite.log = assert(loadfile("lib/log.lua"))(config)
bfsuite.log.config.log_file = "LOGS:/bfsuite/logs/bfsuite_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".log"
bfsuite.log.config.min_print_level  = config.logLevel
bfsuite.log.config.log_to_file = config.logToFile


-- library with utility functions used throughou the suite
bfsuite.utils = assert(loadfile("lib/utils.lua"))(config)


-- Load the i18n system
bfsuite.i18n  = assert(loadfile("lib/i18n.lua"))(config)
bfsuite.i18n.load()     

-- 
-- This script initializes the `bfsuite` tasks and background task.
-- 
-- The `bfsuite.tasks` table is created to hold various tasks.
-- The `bfsuite.tasks` is assigned the result of executing the "tasks/tasks.lua" file with the `config` parameter.
-- The `loadfile` function is used to load the "tasks/tasks.lua" file, and `assert` ensures that the file is loaded successfully.
-- The loaded file is then executed with the `config` parameter, and its return value is assigned to `bfsuite.tasks`.
-- tasks
bfsuite.tasks = assert(loadfile("tasks/tasks.lua"))(config)

-- LuaFormatter off


--[[
This script initializes various session parameters for the bfsuite application to nil.
The parameters include:
- tailMode: Mode for the tail rotor.
- swashMode: Mode for the swashplate.
- activeProfile: Currently active profile.
- activeRateProfile: Currently active rate profile.
- activeProfileLast: Last active profile.
- activeRateLast: Last active rate profile.
- servoCount: Number of servos.
- servoOverride: Override setting for servos.
- clockSet: Clock setting.
- apiVersion: Version of the API.
- lastLabel: Last label used.
- rssiSensor: RSSI sensor value.
- formLineCnt: Form line count.
- rateProfile: Rate profile.
- governorMode: Mode for the governor.
- ethosRunningVersion: Version of the Ethos running.
- lcdWidth: Width of the LCD.
- lcdHeight: Height of the LCD.
- mspSignature - uses for mostly in sim to save esc type
- telemetryType = sport or crsf
- repairSensors: makes the background task repair sensors
- lastMemoryUsage.  Used to track memory usage for debugging
- 

-- Every attempt should be made if using session vars to record them here with a nil
-- to prevent conflicts with other scripts that may use the same session vars.
]]
bfsuite.session.tailMode = nil
bfsuite.session.swashMode = nil
bfsuite.session.activeProfile = nil
bfsuite.session.activeRateProfile = nil
bfsuite.session.activeProfileLast = nil
bfsuite.session.activeRateLast = nil
bfsuite.session.servoCount = nil
bfsuite.session.servoOverride = nil
bfsuite.session.clockSet = nil
bfsuite.session.apiVersion = nil
bfsuite.session.activeProfile = nil
bfsuite.session.activeRateProfile = nil
bfsuite.session.activeProfileLast = nil
bfsuite.session.activeRateLast = nil
bfsuite.session.servoCount = nil
bfsuite.session.servoOverride = nil
bfsuite.session.clockSet = nil
bfsuite.session.lastLabel = nil
bfsuite.session.tailMode = nil
bfsuite.session.swashMode = nil
bfsuite.session.formLineCnt = nil
bfsuite.session.rateProfile = nil
bfsuite.session.governorMode = nil
bfsuite.session.servoOverride = nil
bfsuite.session.ethosRunningVersion = nil
bfsuite.session.lcdWidth = nil
bfsuite.session.lcdHeight = nil
bfsuite.session.mspSignature = nil
bfsuite.session.telemetryState = nil
bfsuite.session.telemetryType = nil
bfsuite.session.telemetryTypeChanged = nil
bfsuite.session.telemetrySensor = nil
bfsuite.session.repairSensors = false
bfsuite.session.locale = system.getLocale()
bfsuite.session.lastMemoryUsage = nil


--[[
    Initializes the main script for the Betaflight-lua-ethos-suite.

    This function performs the following tasks:
    1. Checks if the Ethos version is supported using `bfsuite.utils.ethosVersionAtLeast()`.
       If the version is not supported, it raises an error and stops execution.
    2. Registers system tools using `system.registerSystemTool()` with configurations from `config`.
    3. Registers a background task using `system.registerTask()` with configurations from `config`.
    4. Dynamically loads and registers widgets:
       - Finds widget scripts using `bfsuite.utils.findWidgets()`.
       - Loads each widget script dynamically using `loadfile()`.
       - Assigns the loaded script to a variable inside the `bfsuite` table.
       - Registers each widget with `system.registerWidget()` using the dynamically assigned module.

    Note:
    - Assumes `v.name` is a valid Lua identifier-like string (without spaces or special characters).
    - Each widget script is expected to have functions like `event`, `create`, `paint`, `wakeup`, `close`, `configure`, `read`, `write`, and optionally `persistent` and `menu`.

    Throws:
    - Error if the Ethos version is not supported.

    Dependencies:
    - `bfsuite.utils.ethosVersionAtLeast()`
    - `system.registerSystemTool()`
    - `system.registerTask()`
    - `bfsuite.utils.findWidgets()`
    - `loadfile()`
    - `system.registerWidget()`
]]
local function init()

    -- prevent this even getting close to running if version is not good
    if not bfsuite.utils.ethosVersionAtLeast() then

        system.registerSystemTool({
            name = config.toolName,
            icon = config.icon_unsupported ,
            create = function () end,
            wakeup = function () 
                        lcd.invalidate()
                        return
                     end,
            paint = function () 
                        local w, h = lcd.getWindowSize()
                        local textColor = lcd.RGB(255, 255, 255, 1) 
                        lcd.color(textColor)
                        lcd.font(FONT_STD)
                        local badVersionMsg = string.format("ETHOS < V%d.%d.%d", table.unpack(config.ethosVersion))
                        local textWidth, textHeight = lcd.getTextSize(badVersionMsg)
                        local x = (w - textWidth) / 2
                        local y = (h - textHeight) / 2
                        lcd.drawText(x, y, badVersionMsg)
                        return 
                    end,
            close = function () end,
        })
        return
    end

    -- Registers the main system tool with the specified configuration.
    -- This tool handles events, creation, wakeup, painting, and closing.
    system.registerSystemTool({
        event = bfsuite.app.event,
        name = config.toolName,
        icon = config.icon,
        create = bfsuite.app.create,
        wakeup = bfsuite.app.wakeup,
        paint = bfsuite.app.paint,
        close = bfsuite.app.close
    })


    -- Registers a background task with the specified configuration.
    -- This task handles wakeup and event processing.
    system.registerTask({
        name = config.bgTaskName,
        key = config.bgTaskKey,
        wakeup = bfsuite.tasks.wakeup,
        event = bfsuite.tasks.event
    })

    -- widgets are loaded dynamically
    local cacheFile = "widgets.cache"
    local cachePath = "cache/" .. cacheFile
    local widgetList
    
    -- Try to load from cache if it exists
    if io.open(cachePath, "r") then
        local ok, cached = pcall(dofile, cachePath)
        if ok and type(cached) == "table" then
            widgetList = cached
            bfsuite.utils.log("[cache] Loaded widget list from cache","info")
        else
            bfsuite.utils.log("[cache] Failed to load cache, rebuilding...","info")
        end
    end
    
    -- If no valid cache, build and write new one
    if not widgetList then
        widgetList = bfsuite.utils.findWidgets()
        bfsuite.utils.createCacheFile(widgetList, cacheFile, true)
        bfsuite.utils.log("[cache] Created new widgets cache file","info")
    end

    -- Iterates over the widgetList table and dynamically loads and registers widget scripts.
    -- For each widget in the list:
    -- 1. Checks if the widget has a script defined.
    -- 2. Loads the script file from the specified folder and assigns it to a variable inside the bfsuite table.
    -- 3. Uses the script name (or a provided variable name) as a key to store the loaded script module in the bfsuite table.
    -- 4. Registers the widget with the system using the dynamically assigned module's functions and properties.
    -- 
    -- Parameters:
    -- widgetList - A table containing widget definitions. Each widget should have the following fields:
    --   - script: The filename of the widget script to load.
    --   - folder: The folder where the widget script is located.
    --   - name: The name of the widget.
    --   - key: A unique key for the widget.
    --   - varname (optional): A custom variable name to use for storing the script module in the bfsuite table.
    -- 
    -- The loaded script module should define the following functions and properties (if applicable):
    --   - event: Function to handle events.
    --   - create: Function to create the widget.
    --   - paint: Function to paint the widget.
    --   - wakeup: Function to handle wakeup events.
    --   - close: Function to handle widget closure.
    --   - configure: Function to configure the widget.
    --   - read: Function to read data.
    --   - write: Function to write data.
    --   - persistent: Boolean indicating if the widget is persistent (default is false).
    --   - menu: Menu definition for the widget.
    --   - title: Title of the widget.
    bfsuite.widgets = {}

        for i, v in ipairs(widgetList) do
            if v.script then
                -- Load the script dynamically
                local scriptModule = assert(loadfile("widgets/" .. v.folder .. "/" .. v.script))(config)
        
                -- Use the script filename (without .lua) as the key, or v.varname if provided
                local varname = v.varname or v.script:gsub("%.lua$", "")
        
                -- Store the module inside bfsuite.widgets
                bfsuite.widgets[varname] = scriptModule
        
                -- Register the widget with the system
                system.registerWidget({
                    name = v.name,
                    key = v.key,
                    event = scriptModule.event,
                    create = scriptModule.create,
                    paint = scriptModule.paint,
                    wakeup = scriptModule.wakeup,
                    close = scriptModule.close,
                    configure = scriptModule.configure,
                    read = scriptModule.read,
                    write = scriptModule.write,
                    persistent = scriptModule.persistent or false,
                    menu = scriptModule.menu,
                    title = scriptModule.title
                })
            end
        end
    
end    

-- LuaFormatter on

return {init = init}
