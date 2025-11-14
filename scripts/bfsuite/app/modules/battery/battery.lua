--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local enableWakeup = false
local disableMultiplier
local becAlert
local rxBattAlert

local apidata = {
    api = {[1] = 'BATTERY_CONFIG'},
    formdata = {
        labels = {},
        fields = {
            {t = "@i18n(app.modules.battery.battery_capacity)@", mspapi = 1, apikey = "batteryCapacity"},            
            {t = "@i18n(app.modules.battery.min_cell_voltage)@", mspapi = 1, apikey = "vbatmincellvoltage"},             
            {t = "@i18n(app.modules.battery.max_cell_voltage)@", mspapi = 1, apikey = "vbatmaxcellvoltage"}, 
            {t = "@i18n(app.modules.battery.warn_cell_voltage)@", mspapi = 1, apikey = "vbatwarningcellvoltage"}, 
        }
    }
}

local function postLoad(self)
    for _, f in ipairs(self.fields or (self.apidata and self.apidata.formdata.fields) or {}) do
        if f.apikey == "consumptionWarningPercentage" then
            local v = tonumber(f.value)
            if v then
                if v < 15 then
                    f.value = 35
                elseif v > 60 then
                    f.value = 35
                end
            end
        end
    end
    bfsuite.app.triggers.closeProgressLoader = true
    enableWakeup = true
end

local function wakeup(self)
    if enableWakeup == false then return end


end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openMainMenuSub('hardware')
end

return {wakeup = wakeup, onNavMenu = onNavMenu, apidata = apidata, eepromWrite = true, reboot = false, API = {}, postLoad = postLoad}
