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

local app = {}

local arg = {...}

local config = arg[1]


local triggers = {}
triggers.exitAPP = false
triggers.noRFMsg = false
triggers.triggerSave = false
triggers.triggerReload = false
triggers.triggerReloadNoPrompt = false
triggers.reloadFull = false
triggers.isReady = false
triggers.isSaving = false
triggers.isSavingFake = false
triggers.saveFailed = false
triggers.telemetryState = nil
triggers.profileswitchLast = nil
triggers.rateswitchLast = nil
triggers.closeSave = false
triggers.closeSaveFake = false
triggers.badMspVersion = false
triggers.badMspVersionDisplay = false
triggers.closeProgressLoader = false
triggers.mspBusy = false
triggers.disableRssiTimeout = false
triggers.timeIsSet = false
triggers.invalidConnectionSetup = false
triggers.wasConnected = false
triggers.isArmed = false
triggers.showSaveArmedWarning = false



bfsuite.config = {}
bfsuite.config = config
bfsuite.config.tailMode = nil
bfsuite.config.swashMode = nil
bfsuite.config.activeProfile = nil
bfsuite.config.activeRateProfile = nil
bfsuite.config.activeProfileLast = nil
bfsuite.config.activeRateLast = nil
bfsuite.config.servoCount = nil
bfsuite.config.servoOverride = nil
bfsuite.config.clockSet = nil

app.triggers = {}
app.triggers = triggers

app.ui = {}
app.ui = assert(loadfile("app/lib/ui.lua"))(config)

app.sensors = {}
app.formFields = {}
app.formNavigationFields = {}
app.PageTmp = {}
app.Page = {}
app.saveTS = 0
app.lastPage = nil
app.lastSection = nil
app.lastIdx = nil
app.lastTitle = nil
app.lastScript = nil
app.gfx_buttons = {}
app.uiStatus = {init = 1, mainMenu = 2, pages = 3, confirm = 4}
app.pageStatus = {display = 1, editing = 2, saving = 3, eepromWrite = 4, rebooting = 5}
app.telemetryStatus = {ok = 1, noSensor = 2, noTelemetry = 3}
app.uiState = app.uiStatus.init
app.pageState = app.pageStatus.display
app.lastLabel = nil
app.NewRateTable = nil
app.RateTable = nil
app.fieldHelpTxt = nil
app.protocol = {}
app.protocolTransports = {}
app.radio = {}
app.sensor = {}
app.init = nil
app.guiIsRunning = false
app.menuLastSelected = {}
app.adjfunctions = nil
app.profileCheckScheduler = os.clock()

app.audio = {}
app.audio.playDemo = false
app.audio.playConnecting = false
app.audio.playConnected = false
app.audio.playTimeout = false
app.audio.playSaving = false
app.audio.playLoading = false
app.audio.playEscPowerCycle = false
app.audio.playServoOverideDisable = false
app.audio.playServoOverideEnable = false
app.audio.playMixerOverideDisable = false
app.audio.playMixerOverideEnable = false
app.audio.playEraseFlash = false

app.dialogs = {}
app.dialogs.progress = false
app.dialogs.progressDisplay = false
app.dialogs.progressWatchDog = nil
app.dialogs.progressCounter = 0
app.dialogs.progressRateLimit = os.clock()
app.dialogs.progressRate = 0.2 -- how many times per second we can change dialog value

app.dialogs.progressESC = false
app.dialogs.progressDisplayEsc = false
app.dialogs.progressWatchDogESC = nil
app.dialogs.progressCounterESC = 0
app.dialogs.progressESCRateLimit = os.clock()
app.dialogs.progressESCRate = 2.5 -- how many times per second we can change dialog value

app.dialogs.save = false
app.dialogs.saveDisplay = false
app.dialogs.saveWatchDog = nil
app.dialogs.saveProgressCounter = 0
app.dialogs.saveRateLimit = os.clock()
app.dialogs.saveRate = 0.2 -- how many times per second we can change dialog value

app.dialogs.nolink = false
app.dialogs.nolinkDisplay = false
app.dialogs.nolinkValueCounter = 0
app.dialogs.nolinkRateLimit = os.clock()
app.dialogs.nolinkRate = 0.2 -- how many times per second we can change dialog value

app.dialogs.badversion = false
app.dialogs.badversionDisplay = false

bfsuite.config.saveTimeout = nil
bfsuite.config.requestTimeout = nil
bfsuite.config.maxRetries = nil
bfsuite.config.lcdWidth = nil
bfsuite.config.lcdHeight = nil
bfsuite.config.ethosRunningVersion = nil

-- RETURN THE CURRENT RSSI SENSOR VALUE 
function app.getRSSI()
    if system:getVersion().simulation == true or bfsuite.config.skipRssiSensorCheck == true then return 100 end

    -- if bfsuite.rssiSensor ~= nil then

    if bfsuite.bg.telemetry.active() == true then
        return 100
    else
        return 0
    end
    -- end
    -- return 0
end

-- RESET ALL VALUES TO DEFAULTS. FUNCTION IS CALLED WHEN THE CLOSE EVENT RUNS
function app.resetState()

    config.useCompiler = true
    bfsuite.config.useCompiler = true
    pageLoaded = 100
    pageTitle = nil
    pageFile = nil
    app.triggers.exitAPP = false
    app.triggers.noRFMsg = false
    app.dialogs.nolinkDisplay = false
    app.dialogs.nolinkValueCounter = 0
    app.triggers.telemetryState = nil
    app.dialogs.progressDisplayEsc = false
    ELRS_PAUSE_TELEMETRY = false
    CRSF_PAUSE_TELEMETRY = false
    app.audio = {}
    app.triggers.wasConnected = false
    app.triggers.invalidConnectionSetup = false

end

-- SAVE FIELD VALUE FOR ETHOS FROM ETHOS FORMS INTO THE ACTUAL FORMAT THAT 
-- WILL BE TRANSMITTED OVER MSP
function app.saveValue(currentField)

    local f = app.Page.fields[currentField]
    local scale = f.scale or 1
    local step = f.step or 1

    for idx = 1, #f.vals do app.Page.values[f.vals[idx]] = math.floor(f.value * scale + 0.5) >> ((idx - 1) * 8) end
    if f.upd and app.Page.values then f.upd(app.Page) end
end

-- ITERATE OVER THE FIELD DATA AND UPDATE ALL VALUES FOR DISPLAY PURPOSES
function app.dataBindFields()
    if app.Page.fields then
        for i = 1, #app.Page.fields do

            if app.Page.values and #app.Page.values >= app.Page.minBytes then
                local f = app.Page.fields[i]
                if f.vals then
                    f.value = 0
                    for idx = 1, #f.vals do
                        local raw_val = app.Page.values[f.vals[idx]] or 0
                        raw_val = raw_val << ((idx - 1) * 8)
                        f.value = f.value | raw_val
                    end
                    local bits = #f.vals * 8
                    if f.min and f.min < 0 and (f.value & (1 << (bits - 1)) ~= 0) then f.value = f.value - (2 ^ bits) end
                    f.value = f.value / (f.scale or 1)
                end
            end
        end
    else
        bfsuite.utils.log("Unable to bind fields as app.Page.fields does not exist")
    end
end

-- RETURN CURRENT LCD SIZE
function app.getWindowSize()
    return lcd.getWindowSize()
end

-- INAVALIDATE THE PAGES VARIABLE. TYPICALLY CALLED AFTER WRITING MSP DATA
local function invalidatePages()
    app.Page = nil
    app.pageState = app.pageStatus.display
    app.saveTS = 0
    -- collectgarbage()
end

-- ISSUE AN MSP COMNMAND TO REBOOT THE FBL UNIT
local function rebootFc()

    app.pageState = app.pageStatus.rebooting
    bfsuite.bg.msp.mspQueue:add({
        command = 68, -- MSP_REBOOT
        processReply = function(self, buf)
            invalidatePages()
        end,
        simulatorResponse = {}
    })
end

-- ISSUE AN MSP COMMAND TO TELL THE FBL TO WRITE THE DATA TO EPPROM
local mspEepromWrite = {
    command = 250, -- MSP_EEPROM_WRITE, fails when armed
    processReply = function(self, buf)
        app.triggers.closeSave = true
        if app.Page.reboot then
            -- app.audio.playSaveArmed = true
            rebootFc()
        else
            invalidatePages()
        end

    end,
    errorHandler = function(self)
        app.triggers.closeSave = true
        app.audio.playSaveArmed = true
        if config.saveWhenArmedWarning == true then app.triggers.showSaveArmedWarning = true end
    end,
    simulatorResponse = {}
}

-- SAVE ALL SETTINGS 
function app.settingsSaved()

    -- check if this page requires writing to eeprom to save (most do)
    if app.Page and app.Page.eepromWrite then
        -- don't write again if we're already responding to earlier page.write()s
        if app.pageState ~= app.pageStatus.eepromWrite then
            app.pageState = app.pageStatus.eepromWrite
            bfsuite.bg.msp.mspQueue:add(mspEepromWrite)
            -- app.audio.playSave = true
        end
    elseif app.pageState ~= app.pageStatus.eepromWrite then
        -- If we're not already trying to write to eeprom from a previous save, then we're done.
        invalidatePages()
        app.triggers.closeSave = true
        -- app.audio.playSave = true
    end
end

-- WRAPPER FUNCTION USED TO TRIGGER SAVE SETTINGS
local mspSaveSettings = {
    processReply = function(self, buf)
        app.settingsSaved()
    end
}

-- WRAPPER FUNCTION USED TO TRIGGER LOAD SETTINGS
local mspLoadSettings = {
    processReply = function(self, buf)

        if app.Page.minBytes == nil then app.Page.minBytes = 0 end
        bfsuite.utils.log("app.Page is processing reply for cmd " .. tostring(self.command) .. " len buf: " .. #buf .. " expected: " .. app.Page.minBytes)
        if app.Page ~= nil then
            app.Page.values = buf
            if app.Page.postRead then app.Page.postRead(app.Page) end
            app.dataBindFields()
            if app.Page.postLoad then app.Page.postLoad(app.Page) end
            if form then form.invalidate() end
            bfsuite.utils.log("app.triggers.isReady")
        else
            bfsuite.utils.log("app.triggers.isReady app.Page is nil?")
        end

    end
}

-- READ AN MSP PAGE
function app.readPage()
    if type(app.Page.read) == "function" then
        app.Page.read(app.Page)
    else
        mspLoadSettings.command = app.Page.read
        mspLoadSettings.simulatorResponse = app.Page.simulatorResponse
        bfsuite.bg.msp.mspQueue:add(mspLoadSettings)
    end
end

-- SAVE ALL SETTINGS 
local function saveSettings()

    if app.pageState ~= app.pageStatus.saving then
        app.pageState = app.pageStatus.saving
        app.saveTS = os.clock()

        if app.Page.values then
            local payload = app.Page.values

            if app.Page.preSave then payload = app.Page.preSave(app.Page) end
            if app.Page.preSavePayload then payload = app.Page.preSavePayload(payload) end

            if bfsuite.config.mspTxRxDebug == true or bfsuite.config.logEnable == true then

                local logData = "Saving:                {" .. bfsuite.utils.joinTableItems(payload, ", ") .. "}"

                bfsuite.utils.log(logData)

                if bfsuite.config.mspTxRxDebug == true then print(logData) end

            end

            mspSaveSettings.command = app.Page.write
            mspSaveSettings.payload = payload
            mspSaveSettings.simulatorResponse = {}
            bfsuite.bg.msp.mspQueue:add(mspSaveSettings)
            bfsuite.bg.msp.mspQueue.errorHandler = function()
                print("Save failed")
                app.triggers.saveFailed = true
            end
        elseif type(app.Page.write) == "function" then
            app.Page.write(app.Page)
        end

    end
end

-- REQUEST A PAGE OVER MSP. THIS RUNS ON MOST CLOCK CYCLES WHEN DATA IS BEING REQUESTED
local function requestPage()

    if not app.Page.reqTS or app.Page.reqTS + bfsuite.bg.msp.protocol.pageReqTimeout <= os.clock() then

        app.Page.reqTS = os.clock()
        if app.Page.read then app.readPage() end
    end
end

-- UPDATE CURRENT TELEMETRY STATE - RUNS MOST CLOCK CYCLES
function app.updateTelemetryState()

    if system:getVersion().simulation ~= true then
        if not bfsuite.rssiSensor then
            app.triggers.telemetryState = app.telemetryStatus.noSensor
        elseif app.getRSSI() == 0 then
            app.triggers.telemetryState = app.telemetryStatus.noTelemetry
        else
            app.triggers.telemetryState = app.telemetryStatus.ok
        end
    else
        app.triggers.telemetryState = app.telemetryStatus.ok
    end

end

-- PAINT.  HOOK INTO PAINT FUNCTION TO ALLOW lcd FUNCTIONS TO BE USED
-- NOTE. this function will only be called if lcd.refesh is triggered. it is not a wakeup function
function app.paint()

    -- run the modules paint function if it exists
    if app.Page ~= nil then if app.Page.paint then app.Page.paint(app.Page) end end
end

-- MAIN WAKEUP FUNCTION. THIS SIMPLY FARMS OUT AT DIFFERING SCHEDULES TO SUB FUNCTIONS
function app.wakeup(widget)

    app.guiIsRunning = true

    app.wakeupUI()
    app.wakeupForm()

end

-- WAKEUPFORM.  RUN A FUNCTION CALLED wakeup THAT IS RETURNED WHEN REQUESTING A PAGE
-- THIS ESSENTIALLY GIVES US A TIMER THAT CAN BE USED BY A PAGE THAT HAS LOADED TO
-- HANDLE BACKGROUND PROCESSING
function app.wakeupForm()
    if app.Page ~= nil and app.uiState == app.uiStatus.pages then
        if app.Page.wakeup then
            -- run the pages wakeup function if it exists
            app.Page.wakeup(app.Page)
        end
    end
end

-- WAKUP UI.  UI RUNS AT LOWER INTERVAL, TO SAVE CPU POWER.
-- THE GUTS OF ETHOS FORMS IS HANDLED WITHIN THIS FUNCTION
function app.wakeupUI()

    -- exit app called : quick abort
    -- as we dont need to run the rest of the stuff
    if app.triggers.exitAPP == true then
        app.triggers.exitAPP = false
        form.invalidate()
        system.exit()
        return
    end

    -- close progress loader.  this essentially just accelerates 
    -- the close of the progress bar once the data is loaded.
    -- so if not yet at 100%.. it says.. move there quickly
    if app.triggers.closeProgressLoader == true then
        if app.dialogs.progressCounter >= 90 then
            app.dialogs.progressCounter = app.dialogs.progressCounter + 0.5
            if app.dialogs.progress ~= nil then app.ui.progressDisplayValue(app.dialogs.progressCounter) end
        else
            app.dialogs.progressCounter = app.dialogs.progressCounter + 10
            if app.dialogs.progress ~= nil then app.ui.progressDisplayValue(app.dialogs.progressCounter) end
        end

        if app.dialogs.progressCounter >= 101 then
            app.dialogs.progressWatchDog = nil
            app.dialogs.progressDisplay = false
            if app.dialogs.progress ~= nil then app.ui.progressDisplayClose() end
            app.dialogs.progressCounter = 0
            app.triggers.closeProgressLoader = false
        end
    end

    -- close save loader.  this essentially just accelerates 
    -- the close of the progress bar once the data is loaded.
    -- so if not yet at 100%.. it says.. move there quickly
    if app.triggers.closeSave == true then
        app.triggers.isSaving = false

        if bfsuite.bg.msp.mspQueue:isProcessed() then
            if (app.dialogs.saveProgressCounter > 40 and app.dialogs.saveProgressCounter <= 80) then
                app.dialogs.saveProgressCounter = app.dialogs.saveProgressCounter + 5
            elseif (app.dialogs.saveProgressCounter > 90) then
                app.dialogs.saveProgressCounter = app.dialogs.saveProgressCounter + 2
            else
                app.dialogs.saveProgressCounter = app.dialogs.saveProgressCounter + 5
            end
        end

        if app.dialogs.save ~= nil then app.ui.progressDisplaySaveValue(app.dialogs.saveProgressCounter) end

        if app.dialogs.saveProgressCounter >= 100 and bfsuite.bg.msp.mspQueue:isProcessed() then
            app.triggers.closeSave = false
            app.dialogs.saveProgressCounter = 0
            app.dialogs.saveDisplay = false
            app.dialogs.saveWatchDog = nil
            if app.dialogs.save ~= nil then

                app.ui.progressDisplaySaveClose()

                if bfsuite.config.reloadOnSave == true then app.triggers.triggerReloadNoPrompt = true end

            end
        end
    end

    -- close progress loader when in sim.  
    -- the simulator cannot save - so we fake the whole process
    if app.triggers.closeSaveFake == true then
        app.triggers.isSaving = false

        app.dialogs.saveProgressCounter = app.dialogs.saveProgressCounter + 5

        if app.dialogs.save ~= nil then app.ui.progressDisplaySaveValue(app.dialogs.saveProgressCounter) end

        if app.dialogs.saveProgressCounter >= 100 then
            app.triggers.closeSaveFake = false
            app.dialogs.saveProgressCounter = 0
            app.dialogs.saveDisplay = false
            app.dialogs.saveWatchDog = nil
            app.ui.progressDisplaySaveClose()
        end
    end


    -- profile switching - trigger a reload when profile changes
    if bfsuite.config.profileSwitching == true and app.Page ~= nil and (app.Page.refreshOnProfileChange == true or app.Page.refreshOnRateChange == true) and app.uiState == app.uiStatus.pages and
        app.triggers.isSaving == false and bfsuite.app.dialogs.progressDisplay ~= true and bfsuite.bg.msp.mspQueue:isProcessed() then

        local now = os.clock()
        local profileCheckInterval

        -- alter the interval for checking profile changes depenant of if using msp or not
        if (bfsuite.bg.telemetry.getSensorSource("pidProfile") ~= nil and bfsuite.bg.telemetry.getSensorSource("rateProfile") ~= nil) then
            profileCheckInterval = 0.1   
        else
            profileCheckInterval = 1.5
        end

        if (now - app.profileCheckScheduler) >= profileCheckInterval then
            app.profileCheckScheduler = now

            bfsuite.utils.getCurrentProfile()

            if bfsuite.config.activeProfile ~= nil and bfsuite.config.activeProfileLast ~= nil then

                if app.Page.refreshOnProfileChange == true then
                    if bfsuite.config.activeProfile ~= bfsuite.config.activeProfileLast and bfsuite.config.activeProfileLast ~= nil then
                        if app.ui.progressDisplayIsActive() then
                            -- switch has been toggled mid flow - this is bad.. clean upd
                            form.clear()
                            app.triggers.triggerReloadNoPrompt = true

                        else
                            -- trigger RELOAD
                            app.triggers.triggerReloadNoPrompt = true
                            return true
                        end
                    end
                end

            end

            if bfsuite.config.activeRateProfile ~= nil and bfsuite.config.activeRateProfileLast ~= nil then

                if app.Page.refreshOnRateChange == true then
                    if bfsuite.config.activeRateProfile ~= bfsuite.config.activeRateProfileLast and bfsuite.config.activeRateProfileLast ~= nil then
                        if app.ui.progressDisplayIsActive() then
                            -- switch has been toggled mid flow - this is bad.. clean upd
                            form.clear()
                            app.triggers.triggerReloadNoPrompt = true

                        else
                            -- trigger RELOAD
                            app.triggers.triggerReloadNoPrompt = true
                            return true
                        end
                    end
                end
            end

        end

    end
  

    if app.triggers.telemetryState ~= 1 and app.triggers.disableRssiTimeout == false then
        if bfsuite.app.dialogs.progressDisplay == true then app.ui.progressDisplayClose() end
        if bfsuite.app.dialogs.saveDisplay == true then app.ui.progressDisplaySaveClose() end

        if app.dialogs.nolinkDisplay == false and app.dialogs.nolinkDisplayErrorDialog ~= true then app.ui.progressNolinkDisplay() end
    end
    if (app.dialogs.nolinkDisplay == true) and app.triggers.disableRssiTimeout == false then

        app.dialogs.nolinkValueCounter = app.dialogs.nolinkValueCounter + 10

        if app.dialogs.nolinkValueCounter >= 101 then

            app.ui.progressNolinkDisplayClose()

            if app.guiIsRunning == true and app.triggers.invalidConnectionSetup ~= true and app.triggers.wasConnected == false then

                local buttons = {
                    {
                        label = "   OK   ",
                        action = function()

                            app.triggers.exitAPP = true
                            app.dialogs.nolinkDisplayErrorDialog = false
                            return true
                        end
                    }
                }

                local message
                local apiVersionAsString = tostring(bfsuite.config.apiVersion)
                if bfsuite.config.ethosRunningVersion < config.ethosVersion then
                    message = config.ethosVersionString
                    app.triggers.invalidConnectionSetup = true
                elseif not bfsuite.bg.active() then
                    message = "Please enable the background task."
                    app.triggers.invalidConnectionSetup = true
                elseif app.getRSSI() == 0 then
                    message = "Please check your heli is powered on and telemetry is running."
                    app.triggers.invalidConnectionSetup = true
                elseif bfsuite.config.apiVersion == nil then
                    message = "Unable to determine MSP version in use."
                    app.triggers.invalidConnectionSetup = true
                elseif not bfsuite.utils.stringInArray(bfsuite.config.supportedMspApiVersion, apiVersionAsString) then
                    message = "This version of the Lua script \ncan't be used with the selected model (" .. bfsuite.config.apiVersion .. ")."
                    app.triggers.invalidConnectionSetup = true
                end

                -- display message and abort if error occured
                if app.triggers.invalidConnectionSetup == true and app.triggers.wasConnected == false then

                    form.openDialog({
                        width = nil,
                        title = "Error",
                        message = message,
                        buttons = buttons,
                        wakeup = function()
                        end,
                        paint = function()
                        end,
                        options = TEXT_LEFT
                    })

                    app.dialogs.nolinkDisplayErrorDialog = true

                end

                app.dialogs.nolinkValueCounter = 0
                app.dialogs.nolinkDisplay = false

            else
                app.triggers.wasConnected = true
            end

        end
        app.ui.progressDisplayNoLinkValue(app.dialogs.nolinkValueCounter)
    end

    -- a watchdog to enable the close button when saving data if we exheed the save timout
    if bfsuite.config.watchdogParam ~= nil and bfsuite.config.watchdogParam ~= 1 then app.protocol.saveTimeout = bfsuite.config.watchdogParam end
    if app.dialogs.saveDisplay == true then
        if app.dialogs.saveWatchDog ~= nil then
            if (os.clock() - app.dialogs.saveWatchDog) > (tonumber(app.protocol.saveTimeout + 5)) or (app.dialogs.saveProgressCounter > 120 and bfsuite.bg.msp.mspQueue:isProcessed()) then
                app.audio.playTimeout = true
                app.ui.progressDisplaySaveMessage("Error: timed out")
                app.ui.progressDisplaySaveCloseAllowed(true)
                app.dialogs.save:value(100)
                app.dialogs.saveProgressCounter = 0
                app.dialogs.saveDisplay = false
                app.triggers.isSaving = false

                app.Page = app.PageTmp
                app.PageTmp = {}
            end
        end
    end

    -- a watchdog to enable the close button on a progress box dialog when loading data from the fbl
    if app.dialogs.progressDisplay == true and app.dialogs.progressWatchDog ~= nil then

        app.dialogs.progressCounter = app.dialogs.progressCounter + 2
        app.ui.progressDisplayValue(app.dialogs.progressCounter)

        if (os.clock() - app.dialogs.progressWatchDog) > (tonumber(bfsuite.bg.msp.protocol.pageReqTimeout)) then

            app.audio.playTimeout = true

            if app.dialogs.progress ~= nil then
                app.ui.progressDisplayMessage("Error: timed out")
                app.ui.progressDisplayCloseAllowed(true)
            end

            -- switch back to original page values
            app.Page = app.PageTmp
            app.PageTmp = {}
            app.dialogs.progressCounter = 0
            app.dialogs.progressDisplay = false
        end

    end

    -- a save was triggered - popup a box asking to save the data
    if app.triggers.triggerSave == true then
        local buttons = {
            {
                label = "                OK                ",
                action = function()

                    app.audio.playSaving = true

                    -- we have to fake a save dialog in sim as its not actually possible 
                    -- to save in sim!
                    if system:getVersion().simulation ~= true then
                        app.PageTmp = {}
                        app.PageTmp = app.Page
                        app.triggers.isSaving = true
                        app.triggers.triggerSave = false
                        saveSettings()
                    else
                        -- when in sim we fake a save as not possible to really do
                        -- this involves tricking the progress dialog into thinking
                        app.triggers.isSavingFake = true
                        app.triggers.triggerSave = false
                    end
                    return true
                end
            }, {
                label = "CANCEL",
                action = function()
                    app.triggers.triggerSave = false
                    return true
                end
            }
        }
        local theTitle = "Save settings"
        local theMsg = "Save current page to flight controller?"

        form.openDialog({
            width = nil,
            title = theTitle,
            message = theMsg,
            buttons = buttons,
            wakeup = function()
            end,
            paint = function()
            end,
            options = TEXT_LEFT
        })

        app.triggers.triggerSave = false
    end

    -- a reload that is pretty much instant with no prompt to ask them
    if app.triggers.triggerReloadNoPrompt == true then
        app.triggers.triggerReloadNoPrompt = false
        app.triggers.reload = true
    end

    -- a reload was triggered - popup a box asking for the reload to be done
    if app.triggers.triggerReload == true then
        local buttons = {
            {
                label = "                OK                ",
                action = function()
                    -- trigger RELOAD
                    app.triggers.reload = true
                    return true
                end
            }, {
                label = "CANCEL",
                action = function()
                    return true
                end
            }
        }
        form.openDialog({
            width = nil,
            title = "Reload",
            message = "Reload data from flight controller?",
            buttons = buttons,
            wakeup = function()
            end,
            paint = function()
            end,
            options = TEXT_LEFT
        })

        app.triggers.triggerReload = false
    end

    -- a save was triggered - lets display a progress box
    if app.triggers.isSaving then
        app.dialogs.saveProgressCounter = app.dialogs.saveProgressCounter + 5
        if app.pageState >= app.pageStatus.saving then
            if app.dialogs.saveDisplay == false then
                app.triggers.saveFailed = false
                app.dialogs.saveProgressCounter = 0
                app.ui.progressDisplaySave()
                bfsuite.bg.msp.mspQueue.retryCount = 0
            end
            if app.pageState == app.pageStatus.saving then
                app.ui.progressDisplaySaveValue(app.dialogs.saveProgressCounter, "Saving data...")
            elseif app.pageState == app.pageStatus.eepromWrite then
                app.ui.progressDisplaySaveValue(app.dialogs.saveProgressCounter, "Saving data...")
            elseif app.pageState == app.pageStatus.rebooting then
                app.ui.progressDisplaySaveValue(app.dialogs.saveProgressCounter, "Rebooting...")
            end

        else
            app.triggers.isSaving = false
            app.dialogs.saveDisplay = false
            app.dialogs.saveWatchDog = nil
        end
    elseif app.triggers.isSavingFake == true then

        if app.dialogs.saveDisplay == false then
            app.triggers.saveFailed = false
            app.dialogs.saveProgressCounter = 0
            app.ui.progressDisplaySave()
            bfsuite.bg.msp.mspQueue.retryCount = 0
            app.triggers.closeSaveFake = true
            app.triggers.isSavingFake = false
        end
    end

    -- after saving show brief warning if armed (we only show this if feature it turned on as default option is to not allow save when armed for safety.
    if config.saveWhenArmedWarning == true then
        if app.triggers.showSaveArmedWarning == true and app.triggers.closeSave == false then
            if app.dialogs.progressDisplay == false then
                app.dialogs.progressCounter = 0
                app.ui.progressDisplay('Save not committed to EEPROM', 'Please disarm to save to ensure data integrity when saving.')
            end
            if app.dialogs.progressCounter >= 100 then
                app.triggers.showSaveArmedWarning = false
                app.ui.progressDisplayClose()
            end
        end
    end

    -- check we have telemetry
    app.updateTelemetryState()

    -- if we are on the home page - then ensure pages are invalidated
    if app.uiState == app.uiStatus.mainMenu then
        invalidatePages()
    else
        -- detect page data loaded and ready to move onto rendering the page
        if (app.triggers.isReady == true and bfsuite.bg.msp.mspQueue:isProcessed() and (app.Page and app.Page.values)) then
            app.triggers.isReady = false

            app.triggers.closeProgressLoader = true

        end
    end

    -- if we are viewing a page with form data then we need to run some stuff USED
    -- by the msp processing
    if app.uiState == app.uiStatus.pages then

        -- rebind fields if needed
        if app.pageState == app.pageStatus.saving then if (app.saveTS + app.protocol.saveTimeout) < os.clock() then app.dataBindFields() end end

        -- intercept and populate app.Page if its empty
        -- this simply catches scenarious where we save the page AND
        -- other parts of the script fail for the few ms where the app.Page
        -- var is not populated
        if not app.Page and app.PageTmp then app.Page = app.PageTmp end

        -- we have a page waiting to be retrieved - trigger a request page
        if app.Page ~= nil then if not (app.Page.values or app.triggers.isReady) and app.pageState == app.pageStatus.display then requestPage() end end

    end

    -- capture a reload request and load respective Page
    -- this needs to be done a little better as there is no need FOR
    -- all the menu case checks - we should just be able to do as a task
    -- when viewing the page
    if app.triggers.reload == true then
        app.ui.progressDisplay()
        app.triggers.reload = false
        app.ui.openPageRefresh(app.lastIdx, app.lastTitle, app.lastScript)
    end

    if app.triggers.reloadFull == true then
        app.ui.progressDisplay()
        app.triggers.reloadFull = false
        app.ui.openPage(app.lastIdx, app.lastTitle, app.lastScript)
    end

    -- play audio
    -- alerts 
    if bfsuite.config.audioAlerts== 0 or bfsuite.config.audioAlerts== 1 then

        if app.audio.playEraseFlash == true then
            bfsuite.utils.playFile("app","eraseflash.wav")
            app.audio.playEraseFlash = false
        end

        if app.audio.playConnected == true then
            bfsuite.utils.playFile("app","connected.wav")
            app.audio.playConnected = false
        end

        if app.audio.playConnecting == true then
            bfsuite.utils.playFile("app","connecting.wav")
            app.audio.playConnecting = false
        end

        if app.audio.playDemo == true then
            bfsuite.utils.playFile("app","demo.wav")
            app.audio.playDemo = false
        end

        if app.audio.playTimeout == true then
            bfsuite.utils.playFile("app","timeout.wav")
            app.audio.playTimeout = false
        end

        if app.audio.playEscPowerCycle == true then
            bfsuite.utils.playFile("app","powercycleesc.wav")
            app.audio.playEscPowerCycle = false
        end

        if app.audio.playServoOverideEnable == true then
            bfsuite.utils.playFile("app","soverideen.wav")
            app.audio.playServoOverideEnable = false
        end

        if app.audio.playServoOverideDisable == true then
            bfsuite.utils.playFile("app","soveridedis.wav")
            app.audio.playServoOverideDisable = false
        end

        if app.audio.playMixerOverideEnable == true then
            bfsuite.utils.playFile("app","moverideen.wav")
            app.audio.playMixerOverideEnable = false
        end

        if app.audio.playMixerOverideDisable == true then
            bfsuite.utils.playFile("app","moveridedis.wav")
            app.audio.playMixerOverideDisable = false
        end

        if app.audio.playSaving == true and bfsuite.config.audioAlerts== 0 then
            bfsuite.utils.playFile("app","saving.wav")
            app.audio.playSaving = false
        end

        if app.audio.playLoading == true and bfsuite.config.audioAlerts== 0 then
            bfsuite.utils.playFile("app","loading.wav")
            app.audio.playLoading = false
        end

        if app.audio.playSave == true then
            bfsuite.utils.playFile("app","save.wav")
            app.audio.playSave = false
        end

        if app.audio.playSaveArmed == true then
            bfsuite.utils.playFileCommon("warn.wav")
            app.audio.playSaveArmed = false
        end

    else
        app.audio.playLoading = false
        app.audio.playSaving = false
        app.audio.playTimeout = false
        app.audio.playDemo = false
        app.audio.playConnecting = false
        app.audio.playConnected = false
        app.audio.playEscPowerCycle = false
        app.audio.playServoOverideDisable = false
        app.audio.playServoOverideEnable = false
    end

end

function app.create()


    -- config.apiVersion = nil
    config.environment = system.getVersion()
    config.ethosRunningVersion = bfsuite.utils.ethosVersion()

    bfsuite.config.lcdWidth, bfsuite.config.lcdHeight = bfsuite.utils.getWindowSize()
    app.radio = assert(loadfile("app/radios.lua"))().msp

    app.fieldHelpTxt = assert(loadfile("app/help/fields.lua"))()

    app.uiState = app.uiStatus.init

    -- overide developermode if file exists.
    if bfsuite.config.developerMode ~= true then
        if bfsuite.utils.file_exists("/scripts/developermode") then
                bfsuite.config.developerMode = true
        end
    end


    app.ui.openMainMenu()


end

-- EVENT:  Called for button presses, scroll events, touch events, etc.
function app.event(widget, category, value, x, y)

     --print("Event received:" .. ", " .. category .. "," .. value .. "," .. x .. "," .. y)

    if value == EVT_VIRTUAL_PREV_LONG then
        print("Forcing exit")
        invalidatePages()
        system.exit()
        return 0
    end

    if app.Page ~= nil and (app.uiState == app.uiStatus.pages or app.uiState == app.uiStatus.mainMenu) then
        if app.Page.event then
            -- run the pages wakeup function if it exists
            return app.Page.event(widget, category, value, x, y)
        end
    end

    if app.uiState == app.uiStatus.pages then

        if category == EVT_CLOSE and value == 0 then
            if app.dialogs.progressDisplay == true then app.ui.progressDisplayClose() end
            if app.dialogs.saveDisplay == true then app.ui.progressDisplaySaveClose() end
            if app.Page.onNavMenu then app.Page.onNavMenu(app.Page) end
            app.ui.openMainMenu()
            return true
        end
        if value == 35 then
            if app.dialogs.progressDisplay == true then app.ui.progressDisplayClose() end
            if app.dialogs.saveDisplay == true then app.ui.progressDisplaySaveClose() end
            if app.Page.onNavMenu then app.Page.onNavMenu(app.Page) end
            app.ui.openMainMenu()
            return true
        end
        if value == KEY_ENTER_LONG then
            if app.dialogs.progressDisplay == true then app.ui.progressDisplayClose() end
            if app.dialogs.saveDisplay == true then app.ui.progressDisplaySaveClose() end
            -- if triggers.isArmed == false then
            app.triggers.triggerSave = true
            system.killEvents(KEY_ENTER_BREAK)
            -- end
            return true
        end

    end

    if app.uiState == app.uiStatus.MainMenu then
        if value == KEY_ENTER_LONG then
            if app.dialogs.progressDisplay == true then app.ui.progressDisplayClose() end
            if app.dialogs.saveDisplay == true then app.ui.progressDisplaySaveClose() end
            system.killEvents(KEY_ENTER_BREAK)
            return true
        end
    end

    return false
end

function app.close()

    app.guiIsRunning = false

    if app.Page ~= nil and (app.uiState == app.uiStatus.pages or app.uiState == app.uiStatus.mainMenu) then if app.Page.close then app.Page.close() end end

    if app.dialogs.progress then app.ui.progressDisplayClose() end
    if app.dialogs.save then app.ui.progressDisplaySaveClose() end
    if app.dialogs.noLink then app.ui.progressNolinkDisplayClose() end
    invalidatePages()
    app.resetState()
    -- collectgarbage()
    system.exit()
    return true
end

return app