--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local S_PAGES = {
    {
        name = "General",
        script = "general.lua",
        image = "general.png"
    },
    {
        name = "Dashboard",
        script = "dashboard.lua",
        image = "dashboard.png"
    },
    {
        name = "Localization",
        script = "localizations.lua",
        image = "localizations.png"
    },
    {
        name = "Audio",
        script = "audio.lua",
        image = "audio.png"
    },
    {
        name = "Triggers",
        script = "triggers.lua",
        image = "triggers.png"
    },
    {
        name = "Development",
        script = "development.lua",
        image = "development.png"
    }
}

local function openPage(pidx, title, script)

    bfsuite.tasks.msp.protocol.mspIntervalOveride = nil

    bfsuite.app.triggers.isReady = false
    bfsuite.app.uiState = bfsuite.app.uiStatus.mainMenu

    form.clear()

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    for i in pairs(bfsuite.app.gfx_buttons) do if i ~= "settings" then bfsuite.app.gfx_buttons[i] = nil end end

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

    form.addLine(title)

    local buttonW = 100
    local x = windowWidth - buttonW - 10

    bfsuite.app.formNavigationFields['menu'] = form.addButton(line, {x = x, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {
        text = "MENU",
        icon = nil,
        options = FONT_S,
        paint = function() end,
        press = function()
            bfsuite.app.lastIdx = nil
            bfsuite.session.lastPage = nil

            if bfsuite.app.Page and bfsuite.app.Page.onNavMenu then
                bfsuite.app.Page.onNavMenu(bfsuite.app.Page)
            else
                bfsuite.app.ui.progressDisplay(nil, nil, true)
            end
            bfsuite.app.ui.openMainMenu()
        end
    })
    bfsuite.app.formNavigationFields['menu']:focus()

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

    if bfsuite.app.gfx_buttons["settings"] == nil then bfsuite.app.gfx_buttons["settings"] = {} end
    if bfsuite.preferences.menulastselected["settings"] == nil then bfsuite.preferences.menulastselected["settings"] = 1 end

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
            if bfsuite.app.gfx_buttons["settings"][pidx] == nil then bfsuite.app.gfx_buttons["settings"][pidx] = lcd.loadMask("app/modules/settings/gfx/" .. pvalue.image) end
        else
            bfsuite.app.gfx_buttons["settings"][pidx] = nil
        end

        bfsuite.app.formFields[pidx] = form.addButton(line, {x = bx, y = y, w = buttonW, h = buttonH}, {
            text = pvalue.name,
            icon = bfsuite.app.gfx_buttons["settings"][pidx],
            options = FONT_S,
            paint = function() end,
            press = function()
                bfsuite.preferences.menulastselected["settings"] = pidx
                bfsuite.app.ui.progressDisplay(nil, nil, true)
                bfsuite.app.ui.openPage(pidx, pvalue.folder, "settings/tools/" .. pvalue.script)
            end
        })

        if pvalue.disabled == true then bfsuite.app.formFields[pidx]:enable(false) end

        if bfsuite.preferences.menulastselected["settings"] == pidx then bfsuite.app.formFields[pidx]:focus() end

        lc = lc + 1

        if lc == numPerRow then lc = 0 end

    end

    bfsuite.app.triggers.closeProgressLoader = true

    return
end

bfsuite.app.uiState = bfsuite.app.uiStatus.pages

return {pages = pages, openPage = openPage, API = {}}
