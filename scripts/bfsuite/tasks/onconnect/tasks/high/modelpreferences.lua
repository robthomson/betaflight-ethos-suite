--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local modelpreferences = {}

local modelpref_defaults = {dashboard = {theme_preflight = "nil", theme_inflight = "nil", theme_postflight = "nil"}, general = {flightcount = 0, totalflighttime = 0, lastflighttime = 0, batterylocalcalculation = 1}, battery = {sag_multiplier = 0.5, calc_local = 0, alert_type = 0, becalertvalue = 6.5, rxalertvalue = 7.5, flighttime = 300}}

function modelpreferences.wakeup()

    if bfsuite.session.apiVersion == nil then
        bfsuite.session.modelPreferences = nil
        return
    end

    if bfsuite.session.mspBusy then return end

    if not bfsuite.session.mcu_id then
        bfsuite.session.modelPreferences = nil
        return
    end

    if (bfsuite.session.modelPreferences == nil) then

        if bfsuite.config.preferences and bfsuite.session.mcu_id then

            local modelpref_file = "SCRIPTS:/" .. bfsuite.config.preferences .. "/models/" .. bfsuite.session.mcu_id .. ".ini"
            bfsuite.utils.log("Preferences file: " .. modelpref_file, "info")

            os.mkdir("SCRIPTS:/" .. bfsuite.config.preferences)
            os.mkdir("SCRIPTS:/" .. bfsuite.config.preferences .. "/models")

            local slave_ini = modelpref_defaults
            local master_ini = bfsuite.ini.load_ini_file(modelpref_file) or {}

            local updated_ini = bfsuite.ini.merge_ini_tables(master_ini, slave_ini)
            bfsuite.session.modelPreferences = updated_ini
            bfsuite.session.modelPreferencesFile = modelpref_file

            if not bfsuite.ini.ini_tables_equal(master_ini, slave_ini) then bfsuite.ini.save_ini_file(modelpref_file, updated_ini) end

        end
    end

end

function modelpreferences.reset()
    bfsuite.session.modelPreferences = nil
    bfsuite.session.modelPreferencesFile = nil
end

function modelpreferences.isComplete() if bfsuite.session.modelPreferences ~= nil then return true end end

return modelpreferences
