--[[
 * Copyright (C) Rotorflight Project
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

local apiversion = {}

function apiversion.wakeup()
    if bfsuite.session.apiVersion == nil then
        local API = bfsuite.tasks.msp.api.load("API_VERSION")
        API.setCompleteHandler(function(self, buf)
            bfsuite.session.apiVersion = API.readVersion()
            bfsuite.utils.log("API version: " .. bfsuite.session.apiVersion, "info")
        end)
        API.setUUID("22a683cb-db0e-439f-8d04-04687c9360f3")
        API.read()
    end    
end

function apiversion.reset()
    bfsuite.session.apiVersion = nil
end

function apiversion.isComplete()
    if bfsuite.session.apiVersion ~= nil then
        return true
    end
end

return apiversion