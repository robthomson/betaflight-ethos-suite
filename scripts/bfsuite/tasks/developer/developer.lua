--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local arg = {...}

local developer = {}

function developer.wakeup()

    --[[
    if bfsuite.session.mcu_id and bfsuite.config.preferences then
        local iniName = "SCRIPTS:/" .. bfsuite.config.preferences .. "/models/" .. bfsuite.session.mcu_id .. ".ini"
        local api = bfsuite.tasks.ini.api.load("api_template")
        api.setIniFile(iniName)
        local pitch = api.readValue("pitch")

        print(pitch)
    end
    ]]--
    --[[
    if bfsuite.session.mcu_id and bfsuite.config.preferences then
        local iniName = "SCRIPTS:/" .. bfsuite.config.preferences .. "/models/" .. bfsuite.session.mcu_id .. ".ini"
        local api = bfsuite.tasks.ini.api.load("api_template")
        api.setIniFile(iniName)

        api.setValue("pitch", math.random(-300, 300))

        local ok, err = api.write()
        if not ok then error("Failed to save INI: " .. err) end
    end
    ]]--


        -- Enable log to file in developer options and turn on msp data logging
        -- Outcome is this byte string is logged to the bfsuite log file
        -- {250, 75 , 0  , 100, 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 0  , 250, 0  , 244, 1  , 0  , 0  , 150, 0  , 0  , 250, 0  , 244, 1  , 75 , 0  , 150, 0  , 0  , 0  , 44 , 1  , 100, 0  , 3  , 100, 88 , 2  , 5  , 0  }
        local API = bfsuite.tasks.msp.api.load("FILTER_CONFIG")
        API.setCompleteHandler(function(self, buf)
            --bfsuite.session.fcVersion = API.readVersion()
            --bfsuite.session.rfVersion = API.readRfVersion()
        end)
        API.setUUID("uid-filter_config-example-001")
        API.read()    

end

return developer
