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

end

return developer
