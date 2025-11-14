--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local utils = bfsuite.utils
local log = utils.log

local nextUiTask = 1
local taskAccumulator = 0
local uiTaskPercent = 100

local function exitApp()
    local app = bfsuite.app
    if app.triggers.exitAPP then
        app.triggers.exitAPP = false
        form.invalidate()
        system.exit()
    end
end

local function profileRateChangeDetection()
    local app = bfsuite.app
    if not (app.Page and (app.Page.refreshOnProfileChange or app.Page.refreshOnRateChange or app.Page.refreshFullOnProfileChange or app.Page.refreshFullOnRateChange) and app.uiState == app.uiStatus.pages and not app.triggers.isSaving and not app.dialogs.saveDisplay and not app.dialogs.progressDisplay and bfsuite.tasks.msp.mspQueue:isProcessed()) then return end

    local now = os.clock()
    local interval = (bfsuite.tasks.telemetry.getSensorSource("pid_profile") and bfsuite.tasks.telemetry.getSensorSource("rate_profile")) and 0.1 or 1.5

    if (now - (app.profileCheckScheduler or 0)) >= interval then
        app.profileCheckScheduler = now
        app.utils.getCurrentProfile()
        if bfsuite.session.activeProfileLast and app.Page.refreshOnProfileChange and bfsuite.session.activeProfile ~= bfsuite.session.activeProfileLast then
            app.triggers.reload = not app.Page.refreshFullOnProfileChange
            app.triggers.reloadFull = app.Page.refreshFullOnProfileChange
            return
        end
        if bfsuite.session.activeRateProfileLast and app.Page.refreshOnRateChange and bfsuite.session.activeRateProfile ~= bfsuite.session.activeRateProfileLast then
            app.triggers.reload = not app.Page.refreshFullOnRateChange
            app.triggers.reloadFull = app.Page.refreshFullOnRateChange
            return
        end
    end
end

local function mainMenuIconEnableDisable()
    local app = bfsuite.app
    if app.uiState ~= app.uiStatus.mainMenu and app.uiState ~= app.uiStatus.pages then return end

    if bfsuite.session.mspBusy then return end

    if app.uiState == app.uiStatus.mainMenu then
        local apiV = tostring(bfsuite.session.apiVersion)
        if not bfsuite.tasks.active() then
            for i, v in pairs(app.formFieldsBGTask) do
                if v == false and app.formFields[i] then
                    app.formFields[i]:enable(false)
                elseif v == false then
                    log("Main Menu Icon " .. i .. " not found in formFields", "info")
                end
            end
        elseif not bfsuite.session.isConnected then
            for i, v in pairs(app.formFieldsOffline) do
                if v == false and app.formFields[i] then
                    app.formFields[i]:enable(false)
                elseif v == false then
                    log("Main Menu Icon " .. i .. " not found in formFields", "info")
                end
            end
        elseif bfsuite.session.apiVersion and bfsuite.utils.stringInArray(bfsuite.config.supportedMspApiVersion, apiV) then
            app.offlineMode = false
            for i in pairs(app.formFieldsOffline) do
                if app.formFields[i] then
                    app.formFields[i]:enable(true)
                else
                    log("Main Menu Icon " .. i .. " not found in formFields", "info")
                end
            end
        end
    elseif not app.isOfflinePage then
        if not bfsuite.session.isConnected then app.ui.openMainMenu() end
    end
end

local function noLinkProgressUpdate()
    local app = bfsuite.app
    if bfsuite.session.telemetryState ~= 1 or not app.triggers.disableRssiTimeout then
        if not app.dialogs.nolinkDisplay and not app.triggers.wasConnected then
            if app.dialogs.progressDisplay and app.dialogs.progress then app.dialogs.progress:close() end
            if app.dialogs.saveDisplay and app.dialogs.save then app.dialogs.save:close() end
            app.ui.progressDisplay("Connecting", "Connecting to flight controller...", true)
            app.dialogs.nolinkDisplay = true
        end
    end
end

local function triggerSaveDialogs()
    local app = bfsuite.app
    if app.triggers.triggerSave then
        app.triggers.triggerSave = false
        form.openDialog({
            width = nil,
            title = "Save settings",
            message = (app.Page.extraMsgOnSave and "Save current page to flight controller?" .. "\n\n" .. app.Page.extraMsgOnSave or "Save current page to flight controller?"),
            buttons = {
                {
                    label = "          OK           ",
                    action = function()
                        app.PageTmp = app.Page
                        app.triggers.isSaving = true
                        app.ui.saveSettings()
                        return true
                    end
                }, {label = "CANCEL", action = function() return true end}
            },
            wakeup = function() end,
            paint = function() end,
            options = TEXT_LEFT
        })
    elseif app.triggers.triggerSaveNoProgress then
        app.triggers.triggerSaveNoProgress = false
        app.PageTmp = app.Page
        app.ui.saveSettings()
    end

    if app.triggers.isSaving then
        if app.pageState >= app.pageStatus.saving and not app.dialogs.saveDisplay then
            app.triggers.saveFailed = false
            app.dialogs.saveProgressCounter = 0
            app.ui.progressDisplaySave()
            bfsuite.tasks.msp.mspQueue.retryCount = 0
        end
    end
end

local function armedSaveWarning()
    local app = bfsuite.app
    if not app.triggers.showSaveArmedWarning or app.triggers.closeSave then return end
    if not app.dialogs.progressDisplay then
        app.audio.playSaveArmed = true
        app.dialogs.progressCounter = 0
        local key = (bfsuite.utils.apiVersionCompare(">=", "1.46") and "Settings will only be saved to eeprom on disarm" or "Please disarm to save")

        app.ui.progressDisplay("Save not committed to EEPROM", key)
    end
    if app.dialogs.progressCounter >= 100 then
        app.triggers.showSaveArmedWarning = false
        app.dialogs.progressDisplay = false
        app.dialogs.progress:close()
    end
end

local function triggerReloadDialogs()
    local app = bfsuite.app
    if app.triggers.triggerReloadNoPrompt then
        app.triggers.triggerReloadNoPrompt = false
        app.triggers.reload = true
        return
    end
    if app.triggers.triggerReload then
        app.triggers.triggerReload = false
        form.openDialog({
            title = "reload",
            message = "Reload data from flight controller?",
            buttons = {
                {
                    label = "          OK           ",
                    action = function()
                        app.triggers.reload = true;
                        return true
                    end
                }, {label = "CANCEL", action = function() return true end}
            },
            options = TEXT_LEFT
        })
    elseif app.triggers.triggerReloadFull then
        app.triggers.triggerReloadFull = false
        form.openDialog({
            title = "reload",
            message = "Reload data from flight controller?",
            buttons = {
                {
                    label = "          OK           ",
                    action = function()
                        app.triggers.reloadFull = true;
                        return true
                    end
                }, {label = "CANCEL", action = function() return true end}
            },
            options = TEXT_LEFT
        })
    end
end

local function telemetryAndPageStateUpdates()
    local app = bfsuite.app
    if app.uiState == app.uiStatus.mainMenu then
        app.utils.invalidatePages()
    elseif app.triggers.isReady and (bfsuite.tasks and bfsuite.tasks.msp and bfsuite.tasks.msp.mspQueue:isProcessed()) and app.Page and app.Page.values then
        app.triggers.isReady = false
        app.triggers.closeProgressLoader = true
    end
end

local function performReloadActions()
    local app = bfsuite.app
    if app.triggers.reload then
        app.triggers.reload = false
        app.ui.progressDisplay()
        app.ui.openPageRefresh(app.lastIdx, app.lastTitle, app.lastScript)
    end
    if app.triggers.reloadFull then
        app.triggers.reloadFull = false
        app.ui.progressDisplay()
        app.ui.openPage(app.lastIdx, app.lastTitle, app.lastScript)
    end
end

local function playPendingAudioAlerts()
    local app = bfsuite.app
    if app.audio then
        local a = app.audio
        if a.playEraseFlash then
            utils.playFile("app", "eraseflash.wav");
            a.playEraseFlash = false
        end
        if a.playTimeout then
            utils.playFile("app", "timeout.wav");
            a.playTimeout = false
        end
        if a.playEscPowerCycle then
            utils.playFile("app", "powercycleesc.wav");
            a.playEscPowerCycle = false
        end
        if a.playServoOverideEnable then
            utils.playFile("app", "soverideen.wav");
            a.playServoOverideEnable = false
        end
        if a.playServoOverideDisable then
            utils.playFile("app", "soveridedis.wav");
            a.playServoOverideDisable = false
        end
        if a.playMixerOverideEnable then
            utils.playFile("app", "moverideen.wav");
            a.playMixerOverideEnable = false
        end
        if a.playMixerOverideDisable then
            utils.playFile("app", "moveridedis.wav");
            a.playMixerOverideDisable = false
        end
        if a.playSaveArmed then
            utils.playFileCommon("warn.wav");
            a.playSaveArmed = false
        end
        if a.playBufferWarn then
            utils.playFileCommon("warn.wav");
            a.playBufferWarn = false
        end
    end
end

local function wakeupUITasks()
    local app = bfsuite.app
    if app.Page and app.uiState == app.uiStatus.pages and app.Page.wakeup then app.Page.wakeup(app.Page) end
end

local function requestPage()
    local app = bfsuite.app

    if app.uiState == app.uiStatus.pages then
        if not app.Page and app.PageTmp then app.Page = app.PageTmp end
        if app.ui and app.Page and app.Page.apidata and app.pageState == app.pageStatus.display and not app.triggers.isReady then app.ui.requestPage() end
    end
end

local tasks = {}

tasks.list = {exitApp, noLinkProgressUpdate, triggerSaveDialogs, armedSaveWarning, triggerReloadDialogs, telemetryAndPageStateUpdates, performReloadActions, playPendingAudioAlerts, wakeupUITasks, mainMenuIconEnableDisable, requestPage}

function tasks.wakeup()

    local list = tasks.list
    local total = #list
    if total == 0 then return end

    local perTick = (total * uiTaskPercent) / 100
    if perTick < 1 then perTick = 1 end

    taskAccumulator = taskAccumulator + perTick

    if nextUiTask > total then nextUiTask = 1 end

    while taskAccumulator >= 1 do
        list[nextUiTask]()
        nextUiTask = (nextUiTask % total) + 1
        taskAccumulator = taskAccumulator - 1
    end

end

return tasks
