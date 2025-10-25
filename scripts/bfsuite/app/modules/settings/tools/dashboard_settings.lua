--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")
local themesBasePath = "SCRIPTS:/" .. bfsuite.config.baseDir .. "/widgets/dashboard/themes/"
local themesUserPath = "SCRIPTS:/" .. bfsuite.config.preferences .. "/dashboard/"

local enableWakeup = false
local prevConnectedState = nil

local function openPage(pidx, title, script)

    local themeList = bfsuite.widgets.dashboard.listThemes()

    bfsuite.app.dashboardEditingTheme = nil
    enableWakeup = true
    bfsuite.app.triggers.closeProgressLoader = true
    form.clear()

    for i in pairs(bfsuite.app.gfx_buttons) do if i ~= "settings_dashboard_themes" then bfsuite.app.gfx_buttons[i] = nil end end

    bfsuite.app.lastIdx = pageIdx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    bfsuite.app.ui.fieldHeader("@i18n(app.modules.settings.name)@" .. " / " .. "@i18n(app.modules.settings.dashboard)@" .. " / " .. "@i18n(app.modules.settings.dashboard_settings)@")

    local buttonW, buttonH, padding, numPerRow
    if bfsuite.preferences.general.iconsize == 0 then
        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = (bfsuite.app.lcdWidth - padding) / bfsuite.app.radio.buttonsPerRow - padding
        buttonH = bfsuite.app.radio.navbuttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    elseif bfsuite.preferences.general.iconsize == 1 then
        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = bfsuite.app.radio.buttonWidthSmall
        buttonH = bfsuite.app.radio.buttonHeightSmall
        numPerRow = bfsuite.app.radio.buttonsPerRowSmall
    else
        padding = bfsuite.app.radio.buttonPadding
        buttonW = bfsuite.app.radio.buttonWidth
        buttonH = bfsuite.app.radio.buttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end

    if bfsuite.app.gfx_buttons["settings_dashboard_themes"] == nil then bfsuite.app.gfx_buttons["settings_dashboard_themes"] = {} end
    if bfsuite.preferences.menulastselected["settings_dashboard_themes"] == nil then bfsuite.preferences.menulastselected["settings_dashboard_themes"] = 1 end

    local lc, bx, y = 0, 0, 0

    local n = 0

    for idx, theme in ipairs(themeList) do

        if theme.configure then

            if lc == 0 then
                if bfsuite.preferences.general.iconsize == 0 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
                if bfsuite.preferences.general.iconsize == 1 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
                if bfsuite.preferences.general.iconsize == 2 then y = form.height() + bfsuite.app.radio.buttonPadding end
            end
            if lc >= 0 then bx = (buttonW + padding) * lc end

            if bfsuite.app.gfx_buttons["settings_dashboard_themes"][idx] == nil then

                local icon
                if theme.source == "system" then
                    icon = themesBasePath .. theme.folder .. "/icon.png"
                else
                    icon = themesUserPath .. theme.folder .. "/icon.png"
                end
                bfsuite.app.gfx_buttons["settings_dashboard_themes"][idx] = lcd.loadMask(icon)
            end

            bfsuite.app.formFields[idx] = form.addButton(nil, {x = bx, y = y, w = buttonW, h = buttonH}, {
                text = theme.name,
                icon = bfsuite.app.gfx_buttons["settings_dashboard_themes"][idx],
                options = FONT_S,
                paint = function() end,
                press = function()

                    bfsuite.preferences.menulastselected["settings_dashboard_themes"] = idx
                    bfsuite.app.ui.progressDisplay(nil, nil, true)
                    local configure = theme.configure
                    local source = theme.source
                    local folder = theme.folder

                    local themeScript
                    if theme.source == "system" then
                        themeScript = themesBasePath .. folder .. "/" .. configure
                    else
                        themeScript = themesUserPath .. folder .. "/" .. configure
                    end

                    local wrapperScript = "settings/tools/dashboard_settings_theme.lua"

                    bfsuite.app.ui.openPage(idx, theme.name, wrapperScript, source, folder, themeScript)
                end
            })

            if not theme.configure then bfsuite.app.formFields[idx]:enable(false) end

            if bfsuite.preferences.menulastselected["settings_dashboard_themes"] == idx then bfsuite.app.formFields[idx]:focus() end

            lc = lc + 1
            n = lc + 1
            if lc == numPerRow then lc = 0 end
        end
    end

    if n == 0 then
        local w, h = lcd.getWindowSize()
        local msg = "@i18n(app.modules.settings.no_themes_available_to_configure)@"
        local tw, th = lcd.getTextSize(msg)
        local x = w / 2 - tw / 2
        local y = h / 2 - th / 2
        local btnH = bfsuite.app.radio.navbuttonHeight
        form.addStaticText(nil, {x = x, y = y, w = tw, h = btnH}, msg)
    end

    bfsuite.app.triggers.closeProgressLoader = true

    enableWakeup = true
    return
end

bfsuite.app.uiState = bfsuite.app.uiStatus.pages

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.dashboard)@", "settings/tools/dashboard.lua")
        return true
    end
end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "@i18n(app.modules.settings.dashboard)@", "settings/tools/dashboard.lua")
    return true
end

local function wakeup()
    if not enableWakeup then return end

    local currState = (bfsuite.session.isConnected and bfsuite.session.mcu_id) and true or false

    if currState ~= prevConnectedState then

        if currState == false then onNavMenu() end

        prevConnectedState = currState
    end
end

return {pages = pages, openPage = openPage, API = {}, navButtons = {menu = true, save = false, reload = false, tool = false, help = false}, event = event, onNavMenu = onNavMenu, wakeup = wakeup}
