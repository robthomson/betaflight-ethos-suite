local pages = {}

pages[#pages + 1] = {title = "Scorpion", folder = "scorp", image = "scorpion.png"}
pages[#pages + 1] = {title = "Hobbywing V5", folder = "hw5", image = "hobbywing.png"}
pages[#pages + 1] = {title = "YGE", folder = "yge", image = "yge.png"}
pages[#pages + 1] = {title = "FLYROTOR", folder = "flrtr", image = "flrtr.png"}
pages[#pages + 1] = {title = "XDFly", folder = "flrtr", image = "xdfly.png", disabled = true}

local function openPage(pidx, title, script)

    bfsuite.bg.msp.protocol.mspIntervalOveride = nil


    bfsuite.app.triggers.isReady = false
    bfsuite.app.uiState = bfsuite.app.uiStatus.mainMenu

    form.clear()

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script

    ESC = {}

    -- size of buttons
    if bfsuite.config.iconSize == nil or bfsuite.config.iconSize == "" then
        bfsuite.config.iconSize = 1
    else
        bfsuite.config.iconSize = tonumber(bfsuite.config.iconSize)
    end

    local w, h = bfsuite.utils.getWindowSize()
    local windowWidth = w
    local windowHeight = h
    local padding = bfsuite.app.radio.buttonPadding

    local sc
    local panel

    form.addLine(title)

    buttonW = 100
    local x = windowWidth - buttonW - 10

    bfsuite.app.formNavigationFields['menu'] = form.addButton(line, {x = x, y = bfsuite.app.radio.linePaddingTop, w = buttonW, h = bfsuite.app.radio.navbuttonHeight}, {
        text = "MENU",
        icon = nil,
        options = FONT_S,
        paint = function()
        end,
        press = function()
            bfsuite.app.lastIdx = nil
            bfsuite.lastPage = nil

            if bfsuite.app.Page and bfsuite.app.Page.onNavMenu then bfsuite.app.Page.onNavMenu(bfsuite.app.Page) end

            bfsuite.app.ui.openMainMenu()
        end
    })
    bfsuite.app.formNavigationFields['menu']:focus()

    local buttonW
    local buttonH
    local padding
    local numPerRow

    -- TEXT ICONS
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

    local ESCMenu = assert(loadfile("app/pages/" .. script))()

    local lc = 0
    local bx = 0

    if bfsuite.app.gfx_buttons["escmain"] == nil then bfsuite.app.gfx_buttons["escmain"] = {} end
    if bfsuite.app.menuLastSelected["escmain"] == nil then bfsuite.app.menuLastSelected["escmain"] = 1 end

    for pidx, pvalue in ipairs(ESCMenu.pages) do

        if lc == 0 then
            if bfsuite.config.iconSize == 0 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
            if bfsuite.config.iconSize == 1 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
            if bfsuite.config.iconSize == 2 then y = form.height() + bfsuite.app.radio.buttonPadding end
        end

        if lc >= 0 then bx = (buttonW + padding) * lc end

        if bfsuite.config.iconSize ~= 0 then
            if bfsuite.app.gfx_buttons["escmain"][pidx] == nil then bfsuite.app.gfx_buttons["escmain"][pidx] = lcd.loadMask("app/gfx/esc/" .. pvalue.image) end
        else
            bfsuite.app.gfx_buttons["escmain"][pidx] = nil
        end

        bfsuite.app.formFields[pidx] = form.addButton(line, {x = bx, y = y, w = buttonW, h = buttonH}, {
            text = pvalue.title,
            icon = bfsuite.app.gfx_buttons["escmain"][pidx],
            options = FONT_S,
            paint = function()
            end,
            press = function()
                bfsuite.app.menuLastSelected["escmain"] = pidx
                bfsuite.app.ui.progressDisplay()
                bfsuite.app.ui.openPage(pidx, pvalue.folder, "esc_tool.lua")
            end
        })

        if pvalue.disabled == true then bfsuite.app.formFields[pidx]:enable(false) end

        if bfsuite.app.menuLastSelected["escmain"] == pidx then bfsuite.app.formFields[pidx]:focus() end

        lc = lc + 1

        if lc == numPerRow then lc = 0 end

    end

    bfsuite.app.triggers.closeProgressLoader = true

    return
end

bfsuite.app.uiState = bfsuite.app.uiStatus.pages

return {title = "ESC", pages = pages, openPage = openPage}
