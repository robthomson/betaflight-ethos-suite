--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local S_PAGES = {[1] = {name = "@i18n(app.modules.settings.dashboard_theme)@", script = "dashboard_theme.lua", image = "dashboard_theme.png"}, [2] = {name = "@i18n(app.modules.settings.dashboard_settings)@", script = "dashboard_settings.lua", image = "dashboard_settings.png"}}

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

    for i in pairs(bfsuite.app.gfx_buttons) do if i ~= "settings_dashboard" then bfsuite.app.gfx_buttons[i] = nil end end

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

    bfsuite.app.ui.fieldHeader("@i18n(app.modules.settings.name)@" .. " / " .. "@i18n(app.modules.settings.dashboard)@")

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

    if bfsuite.app.gfx_buttons["settings_dashboard"] == nil then bfsuite.app.gfx_buttons["settings_dashboard"] = {} end
    if bfsuite.preferences.menulastselected["settings_dashboard"] == nil then bfsuite.preferences.menulastselected["settings_dashboard"] = 1 end

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
            if bfsuite.app.gfx_buttons["settings_dashboard"][pidx] == nil then bfsuite.app.gfx_buttons["settings_dashboard"][pidx] = lcd.loadMask("app/modules/settings/gfx/" .. pvalue.image) end
        else
            bfsuite.app.gfx_buttons["settings_dashboard"][pidx] = nil
        end

        bfsuite.app.formFields[pidx] = form.addButton(line, {x = bx, y = y, w = buttonW, h = buttonH}, {
            text = pvalue.name,
            icon = bfsuite.app.gfx_buttons["settings_dashboard"][pidx],
            options = FONT_S,
            paint = function() end,
            press = function()
                bfsuite.preferences.menulastselected["settings_dashboard"] = pidx
                bfsuite.app.ui.progressDisplay(nil, nil, true)
                bfsuite.app.ui.openPage(pidx, pvalue.folder, "settings/tools/" .. pvalue.script)
            end
        })

        if pvalue.disabled == true then bfsuite.app.formFields[pidx]:enable(false) end

        local currState = (bfsuite.session.isConnected and bfsuite.session.mcu_id) and true or false

        if bfsuite.preferences.menulastselected["settings_dashboard"] == pidx then bfsuite.app.formFields[pidx]:focus() end

        lc = lc + 1

        if lc == numPerRow then lc = 0 end

    end

    bfsuite.app.triggers.closeProgressLoader = true

    enableWakeup = true
    return
end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.name)@", "settings/settings.lua")
        return true
    end
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.name)@", "settings/settings.lua")
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
