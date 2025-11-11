--[[
  Copyright (C) 2025 Rotorflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local S_PAGES = {[1] = {name = "@i18n(app.modules.filters.menu_simple)@", script = "simple.lua", image = "simple.png"}, 
                 [2] = {name = "@i18n(app.modules.filters.menu_advanced)@", script = "advanced.lua", image = "advanced.png"}, 
}

local enableWakeup = false
local prevConnectedState = nil
local initTime = os.clock()

local function openPage(pidx, title, script)

    bfsuite.tasks.msp.protocol.mspIntervalOveride = nil

    bfsuite.app.triggers.isReady = false
    bfsuite.app.uiState = bfsuite.app.uiStatus.mainMenu

    form.clear()

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    for i in pairs(bfsuite.app.gfx_buttons) do if i ~= "filters" then bfsuite.app.gfx_buttons[i] = nil end end

    if bfsuite.preferences.general.iconsize == nil or bfsuite.preferences.general.iconsize == "" then
        bfsuite.preferences.general.iconsize = 1
    else
        bfsuite.preferences.general.iconsize = tonumber(bfsuite.preferences.general.iconsize)
    end

    local w, h = lcd.getWindowSize()
    local windowWidth = w
    local windowHeight = h
    local padding = bfsuite.app.radio.buttonPadding

    local sc
    local panel

    local buttonW = 100
    local x = windowWidth - buttonW - 10

    bfsuite.app.ui.fieldHeader("@i18n(app.modules.filters.name)@")

    local buttonW
    local buttonH
    local padding
    local numPerRow

    if bfsuite.preferences.general.iconsize == 0 then
        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = (bfsuite.app.lcdWidth - padding) / bfsuite.app.radio.buttonsPerRow - padding
        buttonH = bfsuite.app.radio.navbuttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end

    if bfsuite.preferences.general.iconsize == 1 then

        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = bfsuite.app.radio.buttonWidthSmall
        buttonH = bfsuite.app.radio.buttonHeightSmall
        numPerRow = bfsuite.app.radio.buttonsPerRowSmall
    end

    if bfsuite.preferences.general.iconsize == 2 then

        padding = bfsuite.app.radio.buttonPadding
        buttonW = bfsuite.app.radio.buttonWidth
        buttonH = bfsuite.app.radio.buttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end

    if bfsuite.app.gfx_buttons["filters"] == nil then bfsuite.app.gfx_buttons["filters"] = {} end
    if bfsuite.preferences.menulastselected["filters"] == nil then bfsuite.preferences.menulastselected["filters"] = 1 end

    local Menu = assert(loadfile("app/modules/" .. script))()
    local pages = S_PAGES
    local lc = 0
    local bx = 0
    local y = 0

    for pidx, pvalue in ipairs(S_PAGES) do

        if lc == 0 then
            if bfsuite.preferences.general.iconsize == 0 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
            if bfsuite.preferences.general.iconsize == 1 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
            if bfsuite.preferences.general.iconsize == 2 then y = form.height() + bfsuite.app.radio.buttonPadding end
        end

        if lc >= 0 then bx = (buttonW + padding) * lc end

        if bfsuite.preferences.general.iconsize ~= 0 then
            if bfsuite.app.gfx_buttons["filters"][pidx] == nil then bfsuite.app.gfx_buttons["filters"][pidx] = lcd.loadMask("app/modules/filters/gfx/" .. pvalue.image) end
        else
            bfsuite.app.gfx_buttons["filters"][pidx] = nil
        end

        bfsuite.app.formFields[pidx] = form.addButton(line, {x = bx, y = y, w = buttonW, h = buttonH}, {
            text = pvalue.name,
            icon = bfsuite.app.gfx_buttons["filters"][pidx],
            options = FONT_S,
            paint = function() end,
            press = function()
                bfsuite.preferences.menulastselected["filters"] = pidx
                bfsuite.app.ui.progressDisplay()
                local name = "@i18n(app.modules.filters.name)@" .. " / " .. pvalue.name
                bfsuite.app.ui.openPage(pidx, name, "filters/tools/" .. pvalue.script)
            end
        })

        if pvalue.disabled == true then bfsuite.app.formFields[pidx]:enable(false) end

        local currState = (bfsuite.session.isConnected and bfsuite.session.mcu_id) and true or false

        if bfsuite.preferences.menulastselected["filters"] == pidx then bfsuite.app.formFields[pidx]:focus() end

        lc = lc + 1

        if lc == numPerRow then lc = 0 end

    end

    bfsuite.app.triggers.closeProgressLoader = true

    enableWakeup = true
    return
end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openMainMenuSub(bfsuite.app.lastMenu)
        return true
    end
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay()
    bfsuite.app.ui.openMainMenu()
    return true
end

local function wakeup()
    if not enableWakeup then return end

    if os.clock() - initTime < 0.25 then return end

    local currState = (bfsuite.session.isConnected and bfsuite.session.mcu_id) and true or false

    if currState ~= prevConnectedState then

        bfsuite.app.formFields[2]:enable(currState)

        if not currState then bfsuite.app.formNavigationFields['menu']:focus() end

        prevConnectedState = currState
    end
end

bfsuite.app.uiState = bfsuite.app.uiStatus.pages

return {pages = pages, openPage = openPage, onNavMenu = onNavMenu, event = event, wakeup = wakeup, API = {}, navButtons = {menu = true, save = false, reload = false, tool = false, help = false}}
