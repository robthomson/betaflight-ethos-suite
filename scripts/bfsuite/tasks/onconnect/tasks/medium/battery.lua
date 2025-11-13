--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local battery = {}

local mspCallMade = false
local mspCall2Made = false
local mspCallComplete = false
local mspCall2Complete = false

function battery.wakeup()

    if bfsuite.session.apiVersion == nil then return end

    if bfsuite.session.mspBusy then return end

    if (bfsuite.session.batteryConfig == nil) and mspCallMade == false then
        mspCallMade = true

        local API = bfsuite.tasks.msp.api.load("BATTERY_STATE")
        API.setCompleteHandler(function(self, buf)

            local batteryCapacity = API.readValue("batteryCapacity")
            local batteryCellCount = API.readValue("batteryCellCount")
           
            bfsuite.session.batteryConfig = {}
            bfsuite.session.batteryConfig.batteryCapacity = batteryCapacity
            bfsuite.session.batteryConfig.batteryCellCount = batteryCellCount

            bfsuite.utils.log("Capacity: " .. batteryCapacity .. "mAh", "info")
            bfsuite.utils.log("Cell Count: " .. batteryCellCount, "info")
            bfsuite.utils.log("Battery State Complete", "info")
            mspCallComplete = true
        end)
        API.setUUID("a3f9c2b4-5d7e-4e8a-9c3b-2f6d8e7a1b3d")
        API.read()
    end

    if (mspCall2Made == false and mspCallComplete == true) then
        mspCall2Made = true

        local API = bfsuite.tasks.msp.api.load("BATTERY_CONFIG")
        API.setCompleteHandler(function(self, buf)

            local vbatwarningcellvoltage = API.readValue("vbatwarningcellvoltage") / 100
            local vbatmincellvoltage = API.readValue("vbatmincellvoltage") / 100
            local vbatmaxcellvoltage = API.readValue("vbatmaxcellvoltage") / 100
            local voltageMeterSource = API.readValue("voltageMeterSource")
            local vbatfullcellvoltage = vbatmaxcellvoltage + 0.4
            local consumptionWarningPercentage = 30

            bfsuite.session.batteryConfig.voltageMeterSource = voltageMeterSource
            bfsuite.session.batteryConfig.vbatwarningcellvoltage = vbatwarningcellvoltage
            bfsuite.session.batteryConfig.vbatmincellvoltage = vbatmincellvoltage
            bfsuite.session.batteryConfig.vbatmaxcellvoltage = vbatmaxcellvoltage
            bfsuite.session.batteryConfig.vbatfullcellvoltage = vbatmaxcellvoltage + 0.4
            bfsuite.session.batteryConfig.consumptionWarningPercentage = consumptionWarningPercentage

            bfsuite.utils.log("Warning Voltage: " .. vbatwarningcellvoltage .. "V", "info")
            bfsuite.utils.log("Min Voltage: " .. vbatmincellvoltage .. "V", "info")
            bfsuite.utils.log("Max Voltage: " .. vbatmaxcellvoltage .. "V", "info")
            bfsuite.utils.log("Full Cell Voltage: " .. vbatfullcellvoltage .. "V", "info")
            bfsuite.utils.log("Consumption Warning Percentage: " .. consumptionWarningPercentage .. "%", "info")
            bfsuite.utils.log("Battery Config Complete", "info")
            mspCall2Complete = true
        end)
        API.setUUID("a3f9c2b4-5d7e-4e8a-8c3b-2f6dde7a1b3d")
        API.read()
    end



end

function battery.reset()
    bfsuite.session.batteryConfig = nil
    mspCallMade = false
    mspCall2Made = false
    mspCallComplete = false
    mspCall2Complete = false
end

function battery.isComplete() 
    if mspCall2Complete == true then 
        return true 
    end 
end

return battery
