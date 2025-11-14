--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local line = {}
local fields = {}

local formLoaded = false
local startTestTime = os.clock()
local startTestLength = 0

local testLoader = nil

local mspQueryStartTime
local mspQueryTimeCount = 0
local getMSPCount = 0
local doNextMsp = true

local mspSpeedTestStats

local maxQueryTime = 0
local minQueryTime = 1000

local function resetStats()
    getMSPCount = 0
    mspQueryTimeCount = 0

    mspSpeedTestStats = {total = 0, success = 0, retries = 0, timeouts = 0, checksum = 0}
end

resetStats()

local RateLimit = os.clock()
local Rate = 0.25

local function getMSPFCVERSION()
    local API = bfsuite.tasks.msp.api.load("FC_VERSION")
    API.setCompleteHandler(function(self, buf) doNextMsp = true end)
    API.setUUID("a3f9c2b4-5d7e-4e8a-9c3b-2f6d8e7a1b2d")
    API.read()
end


local function getMSPPID()
    local API = bfsuite.tasks.msp.api.load("PID")
    API.setCompleteHandler(function(self, buf) doNextMsp = true end)
    API.setUUID("fbccd634-c9b7-4b48-8c02-08ef560dc515")
    API.read()
end

local function getMSP()

    if getMSPCount == 0 then
        getMSPPID()
        getMSPCount = 1
    else     
        getMSPFCVERSION()
        getMSPCount = 0
    end

    local avgQueryTime = bfsuite.utils.round(mspQueryTimeCount / mspSpeedTestStats['total'], 2) .. "s"

end

local function updateStats()

    fields['runtime']:value(startTestLength)

    fields['total']:value(tostring(mspSpeedTestStats['total']))

    fields['retries']:value(tostring(mspSpeedTestStats['retries']))

    fields['timeouts']:value(tostring(mspSpeedTestStats['timeouts']))

    fields['checksum']:value(tostring(mspSpeedTestStats['checksum']))

    fields['mintime']:value(tostring(minQueryTime) .. "s")
    fields['maxtime']:value(tostring(maxQueryTime) .. "s")

    if (mspSpeedTestStats['success'] == mspSpeedTestStats['total'] - 1) and mspSpeedTestStats['timeouts'] == 0 then
        fields['success']:value(tostring(mspSpeedTestStats['success']))
    else
        fields['success']:value(tostring(mspSpeedTestStats['success']))
    end

    local avgQueryTime = bfsuite.utils.round(mspQueryTimeCount / mspSpeedTestStats['total'], 2) .. "s"
    fields['time']:value(tostring(avgQueryTime))

end

local function startTest(duration)
    startTestLength = duration
    startTestTime = os.clock()

    testLoader = form.openProgressDialog({
        title = "Testing",
        message = "Testing MSP performance...",
        close = function()
            updateStats()
            testLoader = nil
        end,
        wakeup = function()
            local now = os.clock()

            if bfsuite.session.telemetryState == false and startTest == true and system:getVersion().simulation ~= true then
                if testLoader then
                    testLoader:close()
                    testLoader = nil
                end
            end

            if formLoaded == true then
                bfsuite.app.triggers.closeProgressLoader = true
                formLoaded = false
            end

            testLoader:value((now - startTestTime) * 100 / startTestLength)

            if (now - startTestLength) > startTestTime then
                testLoader:close()
                testLoader = nil
                updateStats()
            end

            if bfsuite.tasks.msp.mspQueue:isProcessed() and ((now - RateLimit) >= Rate) then
                RateLimit = now
                mspSpeedTestStats['total'] = mspSpeedTestStats['total'] + 1
                mspQueryStartTime = os.clock()

                if doNextMsp == true then
                    doNextMsp = false
                    getMSP()
                end
            end
        end
    })

    testLoader:value(0)

    resetStats()

    doNextMsp = true
end

local function openSpeedTestDialog()
    local buttons = {
        {
            label = "  600S  ",
            action = function()
                startTest(600)
                return true
            end
        }, {
            label = "  300S  ",
            action = function()
                startTest(300)
                return true
            end
        }, {
            label = "  120S  ",
            action = function()
                startTest(120)
                return true
            end
        }, {
            label = "  30S  ",
            action = function()
                startTest(30)
                return true
            end
        }
    }
    form.openDialog({title = "Start", message = "Would you like to start the test? Choose the test run time below.", buttons = buttons, options = TEXT_LEFT})
end

local function openPage(pidx, title, script)
    bfsuite.app.lastIdx = pidx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script
    bfsuite.app.triggers.closeProgressLoader = true

    local w, h = lcd.getWindowSize()

    local y = bfsuite.app.radio.linePaddingTop

    form.clear()

    local titleline = form.addLine("Diagnostics" .. " / " .. "MSP Speed")

    local buttonW = 100
    local buttonWs = buttonW - (buttonW * 20) / 100
    local x = w - 10

    bfsuite.app.formNavigationFields['menu'] = form.addButton(line, {x = x - 5 - buttonW - buttonWs, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {text = "MENU", icon = nil, options = FONT_S, press = function() bfsuite.app.ui.openPage(pageIdx, "Diagnostics", "diagnostics/diagnostics.lua") end})
    bfsuite.app.formNavigationFields['menu']:focus()

    bfsuite.app.formNavigationFields['tool'] = form.addButton(line, {x = x - buttonWs, y = bfsuite.app.radio.linePaddingTop, w = buttonWs, h = bfsuite.app.radio.navbuttonHeight}, {text = "*", icon = nil, options = FONT_S, press = function() openSpeedTestDialog() end})

    local posText = {x = x - 5 - buttonW - buttonWs - 5 - buttonWs, y = bfsuite.app.radio.linePaddingTop, w = 200, h = bfsuite.app.radio.navbuttonHeight}

    line['rf'] = form.addLine("RF protocol")
    fields['rf'] = form.addStaticText(line['rf'], posText, string.upper(bfsuite.tasks.msp.protocol.mspProtocol))

    line['runtime'] = form.addLine("Test length")
    fields['runtime'] = form.addStaticText(line['runtime'], posText, "-")

    line['total'] = form.addLine("Total queries")
    fields['total'] = form.addStaticText(line['total'], posText, "-")

    line['success'] = form.addLine("Successful queries")
    fields['success'] = form.addStaticText(line['success'], posText, "-")

    line['timeouts'] = form.addLine("Timeouts")
    fields['timeouts'] = form.addStaticText(line['timeouts'], posText, "-")

    line['retries'] = form.addLine("Retries")
    fields['retries'] = form.addStaticText(line['retries'], posText, "-")

    line['checksum'] = form.addLine("Checksum errors")
    fields['checksum'] = form.addStaticText(line['checksum'], posText, "-")

    line['mintime'] = form.addLine("Minimum query time")
    fields['mintime'] = form.addStaticText(line['mintime'], posText, "-")

    line['maxtime'] = form.addLine("Maximum query time")
    fields['maxtime'] = form.addStaticText(line['maxtime'], posText, "-")

    line['time'] = form.addLine("Average query time")
    fields['time'] = form.addStaticText(line['time'], posText, "-")

    formLoaded = true
end

local function mspSuccess(self)
    if testLoader then
        mspQueryTimeCount = mspQueryTimeCount + os.clock() - mspQueryStartTime
        mspSpeedTestStats['success'] = mspSpeedTestStats['success'] + 1

        local queryTime = os.clock() - mspQueryStartTime

        if queryTime ~= 0 then
            if queryTime > maxQueryTime then maxQueryTime = queryTime end

            if queryTime < minQueryTime then minQueryTime = queryTime end
        end

    end
end

local function mspTimeout(self) if testLoader then mspSpeedTestStats['timeouts'] = mspSpeedTestStats['timeouts'] + 1 end end

local function mspRetry(self) if testLoader then mspSpeedTestStats['retries'] = mspSpeedTestStats['retries'] + (self.retryCount - 1) end end

local function mspChecksum(self) if testLoader then mspSpeedTestStats['checksum'] = mspSpeedTestStats['checksum'] + 1 end end

local function close()
    if testLoader then
        testLoader:close()
        testLoader = nil
    end
end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Diagnostics", "diagnostics/diagnostics.lua")
        return true
    end
end

return {openPage = openPage, onNavMenu = onNavMenu, mspRetry = mspRetry, mspSuccess = mspSuccess, mspTimeout = mspTimeout, mspChecksum = mspChecksum, event = event, close = close, API = {}}
