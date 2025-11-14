--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local enableWakeup = false
local prevConnectedState = nil
local page

local function openPage(idx, title, script, source, folder, themeScript)

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages
    bfsuite.app.triggers.isReady = false
    bfsuite.app.lastLabel = nil

    local app = bfsuite.app
    if app.formFields then for i = 1, #app.formFields do app.formFields[i] = nil end end
    if app.formLines then for i = 1, #app.formLines do app.formLines[i] = nil end end

    bfsuite.app.dashboardEditingTheme = source .. "/" .. folder

    local modulePath = themeScript

    page = assert(loadfile(modulePath))(idx)

    local w, h = lcd.getWindowSize()
    local windowWidth = w
    local windowHeight = h
    local padding = bfsuite.app.radio.buttonPadding

    local sc
    local panel

    form.clear()

    form.addLine("Settings" .. " / " .. title)
    local buttonW = 100
    local x = windowWidth - (buttonW * 2) - 15

    bfsuite.app.formNavigationFields['menu'] = form.addButton(line, {x = x, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {
        text = "MENU",
        icon = nil,
        options = FONT_S,
        paint = function() end,
        press = function()
            bfsuite.app.lastIdx = nil
            bfsuite.session.lastPage = nil

            if bfsuite.app.Page and bfsuite.app.Page.onNavMenu then bfsuite.app.Page.onNavMenu(bfsuite.app.Page) end

            bfsuite.app.ui.openPage(pageIdx, "Dashboard", "settings/tools/dashboard_settings.lua")
        end
    })
    bfsuite.app.formNavigationFields['menu']:focus()

    local x = windowWidth - buttonW - 10
    bfsuite.app.formNavigationFields['save'] = form.addButton(line, {x = x, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {
        text = "SAVE",
        icon = nil,
        options = FONT_S,
        paint = function() end,
        press = function()

            local buttons = {
                {
                    label = "                OK                ",
                    action = function()
                        local msg = "Save current page to radio?"
                        bfsuite.app.ui.progressDisplaySave(msg:gsub("%?$", "."))
                        if page.write then page.write() end

                        bfsuite.widgets.dashboard.reload_themes()
                        bfsuite.app.triggers.closeSave = true
                        return true
                    end
                }, {label = "CANCEL", action = function() return true end}
            }

            form.openDialog({width = nil, title = "Save settings", message = "Save current page to radio?", buttons = buttons, wakeup = function() end, paint = function() end, options = TEXT_LEFT})

        end
    })
    bfsuite.app.formNavigationFields['menu']:focus()

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages
    enableWakeup = true

    if page.configure then
        page.configure(idx, title, script, extra1, extra2, extra3, extra5, extra6)
        bfsuite.utils.reportMemoryUsage(title)
        bfsuite.app.triggers.closeProgressLoader = true
        return
    end

end

local function event(widget, category, value, x, y)

    if category == EVT_CLOSE and value == 0 or value == 35 then
        bfsuite.app.ui.openPage(pageIdx, "Dashboard", "settings/tools/dashboard.lua")
        return true
    end

    if page.event then page.event() end

end

local function onNavMenu()
    bfsuite.app.ui.progressDisplay(nil, nil, true)
    bfsuite.app.ui.openPage(pageIdx, "Dashboard", "settings/tools/dashboard.lua")
    return true
end

local function wakeup()

    if not enableWakeup then return end

    local currState = (bfsuite.session.isConnected and bfsuite.session.mcu_id) and true or false

    if currState ~= prevConnectedState then

        if currState == false then onNavMenu() end

        prevConnectedState = currState
    end

    if page.wakeup then page.wakeup() end

end

return {pages = pages, openPage = openPage, API = {}, navButtons = {menu = true, save = false, reload = false, tool = false, help = false}, event = event, onNavMenu = onNavMenu, wakeup = wakeup}
