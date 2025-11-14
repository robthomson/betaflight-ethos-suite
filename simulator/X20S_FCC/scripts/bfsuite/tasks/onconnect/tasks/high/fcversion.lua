--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local fcversion = {}

local mspCallMade = false

function fcversion.wakeup()

    if bfsuite.session.apiVersion == nil then return end
    if bfsuite.session.mspBusy then return end

    if mspCallMade == false then

        mspCallMade = true

        local API = bfsuite.tasks.msp.api.load("FC_VERSION")
        API.setCompleteHandler(function(self, buf)
            bfsuite.session.fcVersion = API.readVersion()
            bfsuite.session.rfVersion = API.readRfVersion()
            if bfsuite.session.fcVersion then bfsuite.utils.log("FC version: " .. bfsuite.session.fcVersion, "info") end
        end)
        API.setUUID("22a683cb-dj0e-439f-8d04-04687c9360fu")
        API.read()
    end
end

function fcversion.reset()
    bfsuite.session.fcVersion = nil
    bfsuite.session.rfVersion = nil
    mspCallMade = false
end

function fcversion.isComplete() if bfsuite.session.fcVersion ~= nil then return true end end

return fcversion
