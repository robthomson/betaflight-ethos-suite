--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local apiversion = {}

local mspCallMade = false

function apiversion.wakeup()
    if bfsuite.session.apiVersion == nil and mspCallMade == false then

        mspCallMade = true

        local API = bfsuite.tasks.msp.api.load("API_VERSION")
        API.setCompleteHandler(function(self, buf)
            local version = API.readVersion()

            if version then
                local apiVersionString = tostring(version)
                if not bfsuite.utils.stringInArray(bfsuite.config.supportedMspApiVersion, apiVersionString) then
                    bfsuite.utils.log("Incompatible API version detected: " .. apiVersionString, "info")
                    bfsuite.session.apiVersionInvalid = true
                    return
                end
            end

            bfsuite.session.apiVersion = version
            bfsuite.session.apiVersionInvalid = false

            if bfsuite.session.apiVersion then bfsuite.utils.log("API version: " .. bfsuite.session.apiVersion, "info") end
        end)
        API.setUUID("22a683cb-db0e-439f-8d04-04687c9360f3")
        API.read()
    end
end

function apiversion.reset()
    bfsuite.session.apiVersion = nil
    bfsuite.session.apiVersionInvalid = nil
    mspCallMade = false
end

function apiversion.isComplete() if bfsuite.session.apiVersion ~= nil then return true end end

return apiversion
