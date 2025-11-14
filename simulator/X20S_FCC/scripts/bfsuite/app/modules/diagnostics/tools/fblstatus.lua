--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local fields = {}
local labels = {}
local fcStatus = {}
local dataflashSummary = {}
local wakeupScheduler = os.clock()
local status = {}
local summary = {}
local triggerEraseDataFlash = false
local enableWakeup = false

local displayType = 0
local disableType = false
local firstRun = true

local w, h = lcd.getWindowSize()
local buttonW = 100
local buttonWs = buttonW - (buttonW * 20) / 100
local x = w - 15

local displayPos = {x = x - buttonW - buttonWs - 5 - buttonWs, y = bfsuite.app.radio.linePaddingTop, w = 200, h = bfsuite.app.radio.navbuttonHeight}

local apidata = {
    api = {[1] = nil},
    formdata = {
        labels = {},
        fields = {
            {t = "Date", value = "-", type = displayType, disable = disableType, position = displayPos}, {t = "Time", value = "-", type = displayType, disable = disableType, position = displayPos}, {t = "Arming Flags", value = "-", type = displayType, disable = disableType, position = displayPos},
            {t = "Dataflash Free Space", value = "-", type = displayType, disable = disableType, position = displayPos}, {t = "Real-time Load", value = "-", type = displayType, disable = disableType, position = displayPos}, {t = "CPU Load", value = "-", type = displayType, disable = disableType, position = displayPos}
        }
    }
}

local function getSimulatorTimeResponse()
    local t = os.date("*t")
    local millis = math.floor((os.clock() % 1) * 1000)

    local year = t.year
    local month = t.month
    local day = t.day
    local hour = t.hour
    local min = t.min
    local sec = t.sec

    local bytes = {year & 0xFF, (year >> 8) & 0xFF, month, day, hour, min, sec, millis & 0xFF, (millis >> 8) & 0xFF}

    return bytes
end

local function getFblTime()
    local message = {
        command = 247,
        processReply = function(self, buf)

            buf.offset = 1
            status.fblYear = bfsuite.tasks.msp.mspHelper.readU16(buf)
            buf.offset = 3
            status.fblMonth = bfsuite.tasks.msp.mspHelper.readU8(buf)
            buf.offset = 4
            status.fblDay = bfsuite.tasks.msp.mspHelper.readU8(buf)
            buf.offset = 5
            status.fblHour = bfsuite.tasks.msp.mspHelper.readU8(buf)
            buf.offset = 6
            status.fblMinute = bfsuite.tasks.msp.mspHelper.readU8(buf)
            buf.offset = 7
            status.fblSecond = bfsuite.tasks.msp.mspHelper.readU8(buf)
            buf.offset = 8
            status.fblMillis = bfsuite.tasks.msp.mspHelper.readU16(buf)

        end,
        simulatorResponse = getSimulatorTimeResponse()
    }

    bfsuite.tasks.msp.mspQueue:add(message)
end

local function getStatus()
    local message = {
        command = 101,
        processReply = function(self, buf)

            buf.offset = 12
            status.realTimeLoad = bfsuite.tasks.msp.mspHelper.readU16(buf)
            status.cpuLoad = bfsuite.tasks.msp.mspHelper.readU16(buf)
            buf.offset = 18
            status.armingDisableFlags = bfsuite.tasks.msp.mspHelper.readU32(buf)
            buf.offset = 24
            status.profile = bfsuite.tasks.msp.mspHelper.readU8(buf)
            buf.offset = 26
            status.rateProfile = bfsuite.tasks.msp.mspHelper.readU8(buf)

        end,
        simulatorResponse = {240, 1, 124, 0, 35, 0, 0, 0, 0, 0, 0, 224, 1, 10, 1, 0, 26, 0, 0, 0, 0, 0, 2, 0, 6, 0, 6, 1, 4, 1}
    }

    bfsuite.tasks.msp.mspQueue:add(message)
end

local function getDataflashSummary()
    local message = {
        command = 70,
        processReply = function(self, buf)

            local flags = bfsuite.tasks.msp.mspHelper.readU8(buf)
            summary.ready = (flags & 1) ~= 0
            summary.supported = (flags & 2) ~= 0
            summary.sectors = bfsuite.tasks.msp.mspHelper.readU32(buf)
            summary.totalSize = bfsuite.tasks.msp.mspHelper.readU32(buf)
            summary.usedSize = bfsuite.tasks.msp.mspHelper.readU32(buf)

        end,
        simulatorResponse = {3, 1, 0, 0, 0, 0, 4, 0, 0, 0, 3, 0, 0}
    }
    bfsuite.tasks.msp.mspQueue:add(message)
end

local function eraseDataflash()
    local message = {
        command = 72,
        processReply = function(self, buf)

            summary = {}

            bfsuite.app.formFields[1]:value("")
            bfsuite.app.formFields[2]:value("")
            bfsuite.app.formFields[3]:value("")
            bfsuite.app.formFields[4]:value("")
            bfsuite.app.formFields[5]:value("")
            bfsuite.app.formFields[6]:value("")
        end,
        simulatorResponse = {}
    }
    bfsuite.tasks.msp.mspQueue:add(message)
end

local function postLoad(self)

    getStatus()
    getDataflashSummary()
    getFblTime()
    bfsuite.app.triggers.isReady = true
    enableWakeup = true

    bfsuite.app.triggers.closeProgressLoader = true
end

local function postRead(self) bfsuite.utils.log("postRead", "debug") end

local function getFreeDataflashSpace()
    if not summary.supported then return "Unsupported" end
    local freeSpace = summary.totalSize - summary.usedSize
    return string.format("%.1f " .. "MB", freeSpace / (1024 * 1024))
end

local function wakeup()

    if enableWakeup == false then return end

    if triggerEraseDataFlash == true then
        bfsuite.app.audio.playEraseFlash = true
        triggerEraseDataFlash = false

        bfsuite.app.ui.progressDisplay("Erasing", "Erasing dataflash...")
        bfsuite.app.Page.eraseDataflash()
        bfsuite.app.triggers.isReady = true
    end

    if triggerEraseDataFlash == false then
        local now = os.clock()
        if (now - wakeupScheduler) >= 2 then
            wakeupScheduler = now
            firstRun = false
            if bfsuite.tasks.msp.mspQueue:isProcessed() then

                getStatus()
                getDataflashSummary()
                getFblTime()

                if status.fblYear ~= nil and status.fblMonth ~= nil and status.fblDay ~= nil then
                    local value = string.format("%04d-%02d-%02d", status.fblYear, status.fblMonth, status.fblDay)
                    bfsuite.app.formFields[1]:value(value)
                end

                if status.fblHour ~= nil and status.fblMinute ~= nil and status.fblSecond ~= nil then
                    local value = string.format("%02d:%02d:%02d", status.fblHour, status.fblMinute, status.fblSecond)
                    bfsuite.app.formFields[2]:value(value)
                end

                if status.armingDisableFlags ~= nil then
                    local value = bfsuite.utils.armingDisableFlagsToString(status.armingDisableFlags)
                    bfsuite.app.formFields[3]:value(value)
                end

                if summary.supported == true then
                    local value = getFreeDataflashSpace()
                    bfsuite.app.formFields[4]:value(value)
                end

                if status.realTimeLoad ~= nil then
                    local value = math.floor(status.realTimeLoad / 10)
                    bfsuite.app.formFields[5]:value(tostring(value) .. "%")
                    if value >= 60 then bfsuite.app.formFields[4]:color(RED) end
                end
                if status.cpuLoad ~= nil then
                    local value = status.cpuLoad / 10
                    bfsuite.app.formFields[6]:value(tostring(value) .. "%")
                    if value >= 60 then bfsuite.app.formFields[4]:color(RED) end
                end

            end
        end
        if (now - wakeupScheduler) >= 1 then bfsuite.app.triggers.closeProgressLoader = true end
    end

end

local function onToolMenu(self)

    local buttons = {
        {
            label = "                OK                ",
            action = function()

                triggerEraseDataFlash = true
                return true
            end
        }, {label = "CANCEL", action = function() return true end}
    }
    local message
    local title

    title = "Erase"
    message = "Would you like to erase the dataflash?"

    form.openDialog({width = nil, title = title, message = message, buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})

end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Diagnostics", "diagnostics/diagnostics.lua")
        return true
    end
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "Diagnostics", "diagnostics/diagnostics.lua")
end

return {apidata = apidata, reboot = false, eepromWrite = false, minBytes = 0, wakeup = wakeup, refreshswitch = false, simulatorResponse = {}, postLoad = postLoad, postRead = postRead, eraseDataflash = eraseDataflash, onToolMenu = onToolMenu, onNavMenu = onNavMenu, event = event, navButtons = {menu = true, save = false, reload = false, tool = true, help = false}, API = {}}
