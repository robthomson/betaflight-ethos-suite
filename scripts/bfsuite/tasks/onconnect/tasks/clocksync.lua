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

local clocksync = {}

function clocksync.wakeup()
    -- quick exit if no apiVersion
    if bfsuite.session.apiVersion == nil then return end    

    if bfsuite.session.clockSet == nil then
        local API = bfsuite.tasks.msp.api.load("RTC", 1)
        API.setCompleteHandler(function(self, buf)
            bfsuite.session.clockSet = true
            bfsuite.utils.log("Sync clock: " .. os.clock(), "info")
        end)
        API.setUUID("eaeb0028-219b-4cec-9f57-3c7f74dd49ac")
        API.write()
    end

end

function clocksync.reset()
    bfsuite.session.clockSet = nil
end

function clocksync.isComplete()
    if bfsuite.session.clockSet ~= nil then
        return true
    end
end

return clocksync