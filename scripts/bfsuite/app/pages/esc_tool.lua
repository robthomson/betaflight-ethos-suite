local pages = {}

local mspSignature
local mspHeaderBytes
local mspBytes
local simulatorResponse
local escDetails = {}
local foundESC = false
local foundESCupdateTag = false
local showPowerCycleLoader = false
local showPowerCycleLoaderInProgress = false
local ESC
local powercycleLoader
local powercycleLoaderCounter = 0
local powercycleLoaderRateLimit = 2
local showPowerCycleLoaderFinished = false

local modelField
local versionField
local firmwareField

local findTimeoutClock = os.clock()
local findTimeout = math.floor(bfsuite.bg.msp.protocol.pageReqTimeout * 0.5)

local modelLine
local modelText
local modelTextPos = {x = 0, y = bfsuite.app.radio.linePaddingTop, w = bfsuite.config.lcdWidth, h = bfsuite.app.radio.navbuttonHeight}

local function getESCDetails()
    local message = {
        command = 217, -- MSP_STATUS
        processReply = function(self, buf)

            if buf[1] == mspSignature then

                escDetails.model = ESC.getEscModel(buf)
                escDetails.version = ESC.getEscVersion(buf)
                escDetails.firmware = ESC.getEscFirmware(buf)

                foundESC = true

            end

        end,
        simulatorResponse = simulatorResponse
    }

    bfsuite.bg.msp.mspQueue:add(message)
end

local function openPage(pidx, title, script)

    bfsuite.app.lastIdx = pidx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    local folder = title

    ESC = assert(loadfile("app/pages/esc/" .. folder .. "/init.lua"))()

    mspSignature = ESC.mspSignature
    mspHeaderBytes = ESC.mspHeaderBytes
    mspBytes = ESC.mspBytes
    simulatorResponse = ESC.simulatorResponse

    bfsuite.app.formFields = {}
    bfsuite.app.formLines = {}
    -- bfsuite.utils.log("ui.openPageEscTool")

    local windowWidth = bfsuite.config.lcdWidth
    local windowHeight = bfsuite.config.lcdHeight

    local y = bfsuite.app.radio.linePaddingTop

    form.clear()

    line = form.addLine("ESC" .. ' / ' .. ESC.toolName)

    buttonW = 100
    local x = windowWidth - buttonW

    bfsuite.app.formNavigationFields['menu'] = form.addButton(line, {x = x - buttonW - 5, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {
        text = "MENU",
        icon = nil,
        options = FONT_S,
        paint = function()
        end,
        press = function()
            bfsuite.app.ui.openPage(pidx, "ESC", "esc.lua")

        end
    })
    bfsuite.app.formNavigationFields['menu']:focus()

    bfsuite.app.formNavigationFields['refresh'] = form.addButton(line, {x = x, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {
        text = "RELOAD",
        icon = nil,
        options = FONT_S,
        paint = function()
        end,
        press = function()
            -- bfsuite.app.ui.openPage(pidx, folder, "esc_tool.lua")
            bfsuite.app.Page = nil
            local foundESC = false
            local foundESCupdateTag = false
            local showPowerCycleLoader = false
            local showPowerCycleLoaderInProgress = false
            bfsuite.app.triggers.triggerReload = true
        end
    })
    bfsuite.app.formNavigationFields['menu']:focus()

    ESC.pages = assert(loadfile("app/pages/esc/" .. folder .. "/pages.lua"))()

    modelLine = form.addLine("")
    modelText = form.addStaticText(modelLine, modelTextPos, "")

    local buttonW
    local buttonH
    local padding
    local numPerRow



    if bfsuite.config.iconSize == nil or bfsuite.config.iconSize == "" then
        bfsuite.config.iconSize = 1
    else
        bfsuite.config.iconSize = tonumber(bfsuite.config.iconSize)
    end

    -- TEXT ICONS
    if bfsuite.config.iconSize == 0 then
        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = (bfsuite.config.lcdWidth - padding) / bfsuite.app.radio.buttonsPerRow - padding
        buttonH = bfsuite.app.radio.navbuttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end
    -- SMALL ICONS
    if bfsuite.config.iconSize == 1 then

        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = bfsuite.app.radio.buttonWidthSmall
        buttonH = bfsuite.app.radio.buttonHeightSmall
        numPerRow = bfsuite.app.radio.buttonsPerRowSmall
    end
    -- LARGE ICONS
    if bfsuite.config.iconSize == 2 then

        padding = bfsuite.app.radio.buttonPadding
        buttonW = bfsuite.app.radio.buttonWidth
        buttonH = bfsuite.app.radio.buttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end

    local lc = 0
    local bx = 0

    if bfsuite.app.gfx_buttons["esctool"] == nil then bfsuite.app.gfx_buttons["esctool"] = {} end
    if bfsuite.app.menuLastSelected["esctool"] == nil then bfsuite.app.menuLastSelected["esctool"] = 1 end

    for pidx, pvalue in ipairs(ESC.pages) do

        if lc == 0 then
            if bfsuite.config.iconSize == 0 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
            if bfsuite.config.iconSize == 1 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
            if bfsuite.config.iconSize == 2 then y = form.height() + bfsuite.app.radio.buttonPadding end
        end

        if lc >= 0 then bx = (buttonW + padding) * lc end

        if bfsuite.config.iconSize ~= 0 then
            if bfsuite.app.gfx_buttons["esctool"][pvalue.image] == nil then
                bfsuite.app.gfx_buttons["esctool"][pvalue.image] = lcd.loadMask("app/gfx/esc/" .. pvalue.image)
            end
        else
            bfsuite.app.gfx_buttons["esctool"][pvalue.image] = nil
        end

        -- bfsuite.utils.log("x = " .. bx .. ", y = " .. y .. ", w = " .. buttonW .. ", h = " .. buttonH)
        bfsuite.app.formFields[pidx] = form.addButton(nil, {x = bx, y = y, w = buttonW, h = buttonH}, {
            text = pvalue.title,
            icon = bfsuite.app.gfx_buttons["esctool"][pvalue.image],
            options = FONT_S,
            paint = function()
            end,
            press = function()
                bfsuite.app.menuLastSelected["esctool"] = pidx
                bfsuite.app.ui.progressDisplay()

                -- bfsuite.app.ui.openPage(pidx, folder, "esc_form.lua",pvalue.script)
                bfsuite.app.ui.openPage(pidx, title, "esc/" .. folder .. "/pages/" .. pvalue.script)

            end
        })

        if bfsuite.app.menuLastSelected["esctool"] == pidx then bfsuite.app.formFields[pidx]:focus() end

        if bfsuite.app.triggers.escToolEnableButtons == true then
            bfsuite.app.formFields[pidx]:enable(true)
        else
            bfsuite.app.formFields[pidx]:enable(false)
        end

        lc = lc + 1

        if lc == numPerRow then lc = 0 end

    end

    bfsuite.app.triggers.escToolEnableButtons = false
    getESCDetails()

end

local function wakeup()

    -- enable the form
    if foundESC == true and foundESCupdateTag == false then
        foundESCupdateTag = true

        if escDetails.model ~= nil and escDetails.model ~= nil and escDetails.firmware ~= nil then
            local text = escDetails.model .. " " .. escDetails.version .. " " .. escDetails.firmware
            bfsuite.escHeaderLineText = text
            modelText = form.addStaticText(modelLine, modelTextPos, text)
        end

        for i, v in ipairs(bfsuite.app.formFields) do bfsuite.app.formFields[i]:enable(true) end

        if ESC and ESC.powerCycle == true and showPowerCycleLoader == true then
            powercycleLoader:close()
            powercycleLoaderCounter = 0
            showPowerCycleLoaderInProgress = false
            showPowerCycleLoader = false
            showPowerCycleLoaderFinished = true
            bfsuite.app.triggers.isReady = true
        end

        bfsuite.app.triggers.closeProgressLoader = true

    end

    if showPowerCycleLoaderFinished == false and foundESCupdateTag == false and showPowerCycleLoader == false and
        ((findTimeoutClock <= os.clock() - findTimeout) or bfsuite.app.dialogs.progressCounter >= 101) then
        bfsuite.app.ui.progressDisplayClose()
        bfsuite.app.dialogs.progressDisplay = false
        bfsuite.app.triggers.isReady = true

        if ESC and ESC.powerCycle ~= true then modelText = form.addStaticText(modelLine, modelTextPos, "UNKNOWN") end

        if ESC and ESC.powerCycle == true then showPowerCycleLoader = true end

    end

    if showPowerCycleLoaderInProgress == true then

        local now = os.clock()
        if (now - powercycleLoaderRateLimit) >= 2 then

            getESCDetails()

            powercycleLoaderRateLimit = now
            powercycleLoaderCounter = powercycleLoaderCounter + 5
            powercycleLoader:value(powercycleLoaderCounter)

            if powercycleLoaderCounter >= 100 then
                powercycleLoader:close()
                modelText = form.addStaticText(modelLine, modelTextPos, "UNKNOWN")
                showPowerCycleLoaderInProgress = false
                bfsuite.app.triggers.disableRssiTimeout = false
                showPowerCycleLoader = false
                bfsuite.app.audio.playTimeout = true
                showPowerCycleLoaderFinished = true
                bfsuite.app.triggers.isReady = false
            end

        end

    end

    if showPowerCycleLoader == true then
        if showPowerCycleLoaderInProgress == false then
            showPowerCycleLoaderInProgress = true
            bfsuite.app.audio.playEscPowerCycle = true
            bfsuite.app.triggers.disableRssiTimeout = true
            powercycleLoader = form.openProgressDialog("Searching", "Please power cycle the ESC...")
            powercycleLoader:value(0)
            powercycleLoader:closeAllowed(false)
        end
    end

end

local function event(widget, category, value, x, y)

    -- print("Event received:" .. ", " .. category .. "," .. value .. "," .. x .. "," .. y)

    if category == 5 or value == 35 then
        if powercycleLoader then powercycleLoader:close() end
        bfsuite.app.ui.openPage(pidx, "ESC", "esc.lua")
        return true
    end

    return false
end

return {title = "ESC", openPage = openPage, wakeup = wakeup, event = event}
