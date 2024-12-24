--[[

 * Copyright (C) Betaflight Project
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

]]--

-- RotorFlight + ETHOS LUA configuration
local config = {}

-- LuaFormatter off
config.toolName = "Betaflight"                                     -- name of the tool
config.suiteDir = "/scripts/bfsuite/"                               -- base path the script is installed into
config.icon = lcd.loadMask("app/gfx/icon.png")   -- icon
config.Version = "1.0.0"                                            -- version number of this software release
config.ethosVersion = 1518                                          -- min version of ethos supported by this script
config.ethosVersionString = "ETHOS < V1.5.18"                       -- string to print if ethos version error occurs
config.defaultRateProfile = 0 -- BF                                 -- default rate table [default = 4]
config.supportedMspApiVersion = {"1.46"}                            -- supported msp versions
config.watchdogParam = 10                                           -- watchdog timeout for progress boxes [default = 10]

-- features
config.logEnable = false                                            -- will log to: /scripts/bfsuite/bfsuite.log [default = false]
config.logEnableScreen = false                                      -- if config.logEnable is true then also print to screen [default = false]
config.mspTxRxDebug = false                                         -- simple print of full msp payload that is sent and received [default = false]
config.reloadOnSave = false                                         -- trigger a reload on save [default = false]
config.skipRssiSensorCheck = false                                  -- skip checking for a valid rssi [ default = false]
config.enternalElrsSensors = true                                   -- disable the integrated elrs telemetry processing [default = true]
config.internalSportSensors = true                                  -- disable the integrated smart port telemetry processing [default = true]
config.adjFunctionAlerts = false                                    -- do not alert on adjfunction telemetry.  [default = false]
config.adjValueAlerts = true                                        -- play adjvalue alerts if sensor changes [default = true]  
config.saveWhenArmedWarning = true                                  -- do not display the save when armed warning. [default = true]
config.audioAlerts = 1                                              -- 0 = all, 1 = alerts, 2 = disable [default = 1]
config.profileSwitching = true                                      -- enable auto profile switching [default = true]
config.iconSize = 1                                                 -- 0 = text, 1 = small, 2 = large [default = 1]
config.developerMode = false                                        -- show developer tools on main menu [default = false]
config.soundPack = nil                                              -- use an custom sound pack. [default = nil]

-- tasks
config.bgTaskName = config.toolName .. " [Background]"              -- background task name for msp services etc
config.bgTaskKey = "bfsuite"                                          -- key id used for msp services

-- widgets
config.rf2govName = "Betaflight Governor"                          -- RF2Gov Name


-- LuaFormatter on



-- main
bfsuite = {}
bfsuite.config = config
bfsuite.app = assert(loadfile("app/app.lua"))(config)
bfsuite.utils = assert(loadfile("lib/utils.lua"))(config)



-- tasks
bfsuite.tasks = {}
bfsuite.bg = assert(loadfile("tasks/bg.lua"))(config)


-- LuaFormatter off

local function init()
        system.registerSystemTool({event = bfsuite.app.event, name = config.toolName, icon = config.icon, create = bfsuite.app.create, wakeup = bfsuite.app.wakeup, paint = bfsuite.app.paint, close = bfsuite.app.close})
        system.registerTask({name = config.bgTaskName, key = config.bgTaskKey, wakeup = bfsuite.bg.wakeup, event = bfsuite.bg.event})
end

-- LuaFormatter on

return {init = init}
