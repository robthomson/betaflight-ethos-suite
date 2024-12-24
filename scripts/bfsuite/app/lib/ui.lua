--[[

 * Copyright (C) Betaflight Project
 *
 *
 * License GPLv3: https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * Note.  Some icons have been sourced from https://www.flaticon.com/
 * 

]]--

local ui = {}

local arg = {...}
local config = arg[1]


function ui.progressDisplay(title, message)

    if bfsuite.app.dialogs.progressDisplay == true then return end

    bfsuite.app.audio.playLoading = true

    if title == nil then title = "Loading" end
    if message == nil then message = "Loading data from flight controller..." end

    bfsuite.app.dialogs.progressDisplay = true
    bfsuite.app.dialogs.progressWatchDog = os.clock()
    bfsuite.app.dialogs.progress = form.openProgressDialog(title, message)
    bfsuite.app.dialogs.progressDisplay = true
    bfsuite.app.dialogs.progressCounter = 0
    if bfsuite.app.dialogs.progress ~= nil then
        bfsuite.app.dialogs.progress:value(0)
        bfsuite.app.dialogs.progress:closeAllowed(false)
    end
end

function ui.progressNolinkDisplay()
    bfsuite.app.dialogs.nolinkDisplay = true
    bfsuite.app.dialogs.noLink = form.openProgressDialog("Connecting", "Connecting...")
    bfsuite.app.dialogs.noLink:closeAllowed(false)
    bfsuite.app.dialogs.noLink:value(0)
end

function ui.progressDisplaySave()
    bfsuite.app.dialogs.saveDisplay = true
    bfsuite.app.dialogs.saveWatchDog = os.clock()
    bfsuite.app.dialogs.save = form.openProgressDialog("Saving", "Saving data...")
    bfsuite.app.dialogs.save:value(0)
    bfsuite.app.dialogs.save:closeAllowed(false)
end

-- we wrap a simple rate limiter into this to prevent cpu overload when handling msp
function ui.progressDisplayValue(value, message)

    -- if bfsuite.app.triggers.mspBusy == true then return end

    if value >= 100 then
        bfsuite.app.dialogs.progress:value(value)
        if message ~= nil then bfsuite.app.dialogs.progress:message(message) end
        return
    end

    local now = os.clock()
    if (now - bfsuite.app.dialogs.progressRateLimit) >= bfsuite.app.dialogs.progressRate then
        bfsuite.app.dialogs.progressRateLimit = now
        bfsuite.app.dialogs.progress:value(value)
        if message ~= nil then bfsuite.app.dialogs.progress:message(message) end
    end

end

-- we wrap a simple rate limiter into this to prevent cpu overload when handling msp
function ui.progressDisplaySaveValue(value, message)

    -- if bfsuite.app.triggers.mspBusy == true then return end

    if value >= 100 then
        bfsuite.app.dialogs.save:value(value)
        if message ~= nil then bfsuite.app.dialogs.save:message(message) end
        return
    end

    local now = os.clock()
    if (now - bfsuite.app.dialogs.saveRateLimit) >= bfsuite.app.dialogs.saveRate then
        bfsuite.app.dialogs.saveRateLimit = now
        bfsuite.app.dialogs.save:value(value)
        if message ~= nil then bfsuite.app.dialogs.save:message(message) end
    end

end

function ui.progressDisplayClose()
    if bfsuite.app.dialogs.progress ~= nil then bfsuite.app.dialogs.progress:close() end
    bfsuite.app.dialogs.progressDisplay = false
end

function ui.progressDisplayCloseAllowed(status)
    if bfsuite.app.dialogs.progress ~= nil then bfsuite.app.dialogs.progress:closeAllowed(status) end
end

function ui.progressDisplayMessage(message)
    if bfsuite.app.dialogs.progress ~= nil then bfsuite.app.dialogs.progress:message(message) end
end

function ui.progressDisplaySaveClose()
    if bfsuite.app.dialogs.progress ~= nil then bfsuite.app.dialogs.save:close() end
    bfsuite.app.dialogs.saveDisplay = false
end

function ui.progressDisplaySaveMessage(message)
    if bfsuite.app.dialogs.save ~= nil then bfsuite.app.dialogs.save:message(message) end
end

function ui.progressDisplaySaveCloseAllowed(status)
    if bfsuite.app.dialogs.save ~= nil then bfsuite.app.dialogs.save:closeAllowed(status) end
end

function ui.progressNolinkDisplayClose()
    bfsuite.app.dialogs.noLink:close()
end

-- we wrap a simple rate limiter into this to prevent cpu overload when handling msp
function ui.progressDisplayNoLinkValue(value, message)

    -- if bfsuite.app.triggers.mspBusy == true then return end

    if value >= 100 then
        bfsuite.app.dialogs.noLink:value(value)
        if message ~= nil then bfsuite.app.dialogs.noLink:message(message) end
        return
    end

    local now = os.clock()
    if (now - bfsuite.app.dialogs.nolinkRateLimit) >= bfsuite.app.dialogs.nolinkRate then
        bfsuite.app.dialogs.nolinkRateLimit = now
        bfsuite.app.dialogs.noLink:value(value)
        if message ~= nil then bfsuite.app.dialogs.noLink:message(message) end
    end

end

function ui.openMainMenu()

    local MainMenu = assert(loadfile("app/pages.lua"))()


    -- clear all nav vars
    bfsuite.app.lastIdx = nil
    bfsuite.app.lastTitle = nil
    bfsuite.app.lastScript = nil
    bfsuite.lastPage = nil

    -- bfsuite.bg.msp.protocol.mspIntervalOveride = nil

    bfsuite.app.triggers.isReady = false
    bfsuite.app.uiState = bfsuite.app.uiStatus.mainMenu
    bfsuite.app.triggers.disableRssiTimeout = false

    -- size of buttons
    if config.iconSize == nil or config.iconSize == "" then
        config.iconSize = 1
    else
        config.iconSize = tonumber(config.iconSize)
    end

    local buttonW
    local buttonH
    local padding
    local numPerRow

    -- TEXT ICONS
    if config.iconSize == 0 then
        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = (config.lcdWidth - padding) / bfsuite.app.radio.buttonsPerRow - padding
        buttonH = bfsuite.app.radio.navbuttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end
    -- SMALL ICONS
    if config.iconSize == 1 then

        padding = bfsuite.app.radio.buttonPaddingSmall
        buttonW = bfsuite.app.radio.buttonWidthSmall
        buttonH = bfsuite.app.radio.buttonHeightSmall
        numPerRow = bfsuite.app.radio.buttonsPerRowSmall
    end
    -- LARGE ICONS
    if config.iconSize == 2 then

        padding = bfsuite.app.radio.buttonPadding
        buttonW = bfsuite.app.radio.buttonWidth
        buttonH = bfsuite.app.radio.buttonHeight
        numPerRow = bfsuite.app.radio.buttonsPerRow
    end

    local sc
    local panel

    form.clear()

    if bfsuite.app.gfx_buttons["mainmenu"] == nil then bfsuite.app.gfx_buttons["mainmenu"] = {} end
    if bfsuite.app.menuLastSelected["mainmenu"] == nil then bfsuite.app.menuLastSelected["mainmenu"] = 1 end


    
    local hideSection = false
    for idx, value in ipairs(MainMenu.sections) do
    
        if (value.ethosversion ~= nil and bfsuite.config.ethosRunningVersion < value.ethosversion) then hideSection = true else hideSection = false end
        if (value.developer ~= nil and bfsuite.config.developerMode == false) then hideSection = true else hideSection = false end

        if hideSection == false then

                local sc = value.section

                form.addLine(value.title)

                lc = 0
                local hideEntry = false
                
                for pidx, pvalue in ipairs(MainMenu.pages) do
                    if pvalue.section == value.section then

                        -- do not show icon if not supported by ethos version
                        if (pvalue.ethosversion ~= nil and bfsuite.config.ethosRunningVersion < pvalue.ethosversion) then hideEntry = true else hideEntry = false end
                        if (pvalue.developer ~= nil and bfsuite.config.developerMode == false) then hideEntry = true else hideEntry = false end

                        if hideEntry == false then

                                if lc == 0 then
                                    if config.iconSize == 0 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
                                    if config.iconSize == 1 then y = form.height() + bfsuite.app.radio.buttonPaddingSmall end
                                    if config.iconSize == 2 then y = form.height() + bfsuite.app.radio.buttonPadding end
                                end

                                if lc >= 0 then x = (buttonW + padding) * lc end

                                if config.iconSize ~= 0 then
                                    if bfsuite.app.gfx_buttons["mainmenu"][pidx] == nil then
                                        bfsuite.app.gfx_buttons["mainmenu"][pidx] = lcd.loadMask("app/gfx/menu/" .. pvalue.image)
                                    end
                                else
                                    bfsuite.app.gfx_buttons["mainmenu"][pidx] = nil
                                end



                                bfsuite.app.formFields[pidx] = form.addButton(line, {x = x, y = y, w = buttonW, h = buttonH}, {
                                    text = pvalue.title,
                                    icon = bfsuite.app.gfx_buttons["mainmenu"][pidx],
                                    options = FONT_S,
                                    paint = function()
                                    end,
                                    press = function()
                                        bfsuite.app.menuLastSelected["mainmenu"] = pidx
                                        bfsuite.app.ui.progressDisplay()
                                        bfsuite.app.ui.openPage(pidx, pvalue.title, pvalue.script)
                                    end
                                })
                                
                                

                                --if pvalue.ethosversion ~= nil and bfsuite.config.ethosRunningVersion < pvalue.ethos then bfsuite.app.formFields[pidx]:enable(false) end

                                if bfsuite.app.menuLastSelected["mainmenu"] == pidx then bfsuite.app.formFields[pidx]:focus() end

                                lc = lc + 1

                                if lc == numPerRow then lc = 0 end
                        
                        end
                            
             
                    end
                end
        
        end

    end

end

function ui.progressDisplayIsActive()

    if bfsuite.app.dialogs.progressDisplay == true then return true end
    if bfsuite.app.dialogs.saveDisplay == true then return true end
    if bfsuite.app.dialogs.progressDisplayEsc == true then return true end
    if bfsuite.app.dialogs.nolinkDisplay == true then return true end
    if bfsuite.app.dialogs.badversionDisplay == true then return true end

    return false
end

function ui.getLabel(id, page)
    for i, v in ipairs(page) do if id ~= nil then if v.label == id then return v end end end
end

function ui.fieldChoice(i)

    local f = bfsuite.app.Page.fields[i]

    if f.inline ~= nil and f.inline >= 1 and f.label ~= nil then

        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        local p = bfsuite.utils.getInlinePositions(f, bfsuite.app.Page)
        posText = p.posText
        posField = p.posField

        field = form.addStaticText(bfsuite.app.formLines[formLineCnt], posText, f.t)
    else
        if f.t ~= nil then
            if f.t2 ~= nil then f.t = f.t2 end

            if f.label ~= nil then f.t = "        " .. f.t end
        end
        formLineCnt = formLineCnt + 1
        bfsuite.app.formLines[formLineCnt] = form.addLine(f.t)
        if f.position ~= nil then
            posField = f.position
        else
            posField = nil
        end
        postText = nil
    end

    bfsuite.app.formFields[i] = form.addChoiceField(bfsuite.app.formLines[formLineCnt], posField, bfsuite.utils.convertPageValueTable(f.table, f.tableIdxInc), function()
        local value = bfsuite.utils.getFieldValue(bfsuite.app.Page.fields[i])

        return value
    end, function(value)
        -- we do this hook to allow rates to be reset
        if f.postEdit then f.postEdit(bfsuite.app.Page, value) end
        if f.onChange then f.onChange(bfsuite.app.Page, value) end
        f.value = bfsuite.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
        bfsuite.app.saveValue(i)
    end)

    if f.disable == true then bfsuite.app.formFields[i]:enable(false) end
end

function ui.fieldNumber(i)

    local f = bfsuite.app.Page.fields[i]

    if f.inline ~= nil and f.inline >= 1 and f.label ~= nil then
        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        local p = bfsuite.utils.getInlinePositions(f, bfsuite.app.Page)
        posText = p.posText
        posField = p.posField

        field = form.addStaticText(bfsuite.app.formLines[formLineCnt], posText, f.t)
    else
        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        if f.t ~= nil then

            if f.label ~= nil then f.t = "        " .. f.t end
        else
            f.t = ""
        end

        formLineCnt = formLineCnt + 1

        bfsuite.app.formLines[formLineCnt] = form.addLine(f.t)

        if f.position ~= nil then
            posField = f.position
        else
            posField = nil
        end
        postText = nil
    end

    if f.offset ~= nil then
        if f.min ~= nil then f.min = f.min + f.offset end
        if f.max ~= nil then f.max = f.max + f.offset end
    end

    minValue = bfsuite.utils.scaleValue(f.min, f)
    maxValue = bfsuite.utils.scaleValue(f.max, f)

    if f.mult ~= nil then
        minValue = minValue * f.mult
        maxValue = maxValue * f.mult
    end

    if minValue == nil then minValue = 0 end
    if maxValue == nil then maxValue = 0 end
    bfsuite.app.formFields[i] = form.addNumberField(bfsuite.app.formLines[formLineCnt], posField, minValue, maxValue, function()

        local value = bfsuite.utils.getFieldValue(bfsuite.app.Page.fields[i])

        return value
    end, function(value)
        if f.postEdit then f.postEdit(bfsuite.app.Page) end
        if f.onChange then f.onChange(bfsuite.app.Page) end

        f.value = bfsuite.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
        bfsuite.app.saveValue(i)
    end)

    if config.ethosRunningVersion >= 1514 then
        if f.onFocus ~= nil then
            bfsuite.app.formFields[i]:onFocus(function()
                f.onFocus(bfsuite.app.Page)
            end)
        end
    end

    if f.default ~= nil then
        if f.offset ~= nil then f.default = f.default + f.offset end
        local default = f.default * bfsuite.utils.decimalInc(f.decimals)
        if f.mult ~= nil then default = default * f.mult end
        bfsuite.app.formFields[i]:default(default)
    else
        bfsuite.app.formFields[i]:default(0)
    end

    if f.decimals ~= nil then bfsuite.app.formFields[i]:decimals(f.decimals) end
    if f.unit ~= nil then bfsuite.app.formFields[i]:suffix(f.unit) end
    if f.step ~= nil then bfsuite.app.formFields[i]:step(f.step) end
    if f.disable == true then bfsuite.app.formFields[i]:enable(false) end

    if f.help ~= nil then
        if bfsuite.app.fieldHelpTxt[f.help]['t'] ~= nil then
            local helpTxt = bfsuite.app.fieldHelpTxt[f.help]['t']
            bfsuite.app.formFields[i]:help(helpTxt)
        end
    end

end

function ui.fieldStaticText(i)

    local f = bfsuite.app.Page.fields[i]

    if f.inline ~= nil and f.inline >= 1 and f.label ~= nil then
        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        local p = bfsuite.utils.getInlinePositions(f, bfsuite.app.Page)
        posText = p.posText
        posField = p.posField

        field = form.addStaticText(bfsuite.app.formLines[formLineCnt], posText, f.t)
    else
        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        if f.t ~= nil then

            if f.label ~= nil then f.t = "        " .. f.t end
        else
            f.t = ""
        end

        formLineCnt = formLineCnt + 1

        bfsuite.app.formLines[formLineCnt] = form.addLine(f.t)

        if f.position ~= nil then
            posField = f.position
        else
            posField = nil
        end
        postText = nil
    end

    if HideMe == true then
        -- posField = {x = 2000, y = 0, w = 20, h = 20}
    end

    bfsuite.app.formFields[i] = form.addStaticText(bfsuite.app.formLines[formLineCnt], posField, bfsuite.utils.getFieldValue(bfsuite.app.Page.fields[i]))

    if config.ethosRunningVersion >= 1514 then
        if f.onFocus ~= nil then
            bfsuite.app.formFields[i]:onFocus(function()
                f.onFocus(bfsuite.app.Page)
            end)
        end
    end

    if f.decimals ~= nil then bfsuite.app.formFields[i]:decimals(f.decimals) end
    if f.unit ~= nil then bfsuite.app.formFields[i]:suffix(f.unit) end
    if f.step ~= nil then bfsuite.app.formFields[i]:step(f.step) end

end

function ui.fieldText(i)

    local f = bfsuite.app.Page.fields[i]

    if f.inline ~= nil and f.inline >= 1 and f.label ~= nil then
        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        local p = bfsuite.utils.getInlinePositions(f, bfsuite.app.Page)
        posText = p.posText
        posField = p.posField

        field = form.addStaticText(bfsuite.app.formLines[formLineCnt], posText, f.t)
    else
        if bfsuite.app.radio.text == 2 then if f.t2 ~= nil then f.t = f.t2 end end

        if f.t ~= nil then

            if f.label ~= nil then f.t = "        " .. f.t end
        else
            f.t = ""
        end

        formLineCnt = formLineCnt + 1

        bfsuite.app.formLines[formLineCnt] = form.addLine(f.t)

        if f.position ~= nil then
            posField = f.position
        else
            posField = nil
        end
        postText = nil
    end

    if HideMe == true then
        -- posField = {x = 2000, y = 0, w = 20, h = 20}
    end

    bfsuite.app.formFields[i] = form.addTextField(bfsuite.app.formLines[formLineCnt], posField, function()
        local value = bfsuite.utils.getFieldValue(bfsuite.app.Page.fields[i])
        return value
    end, function(value)
        if f.postEdit then f.postEdit(bfsuite.app.Page) end
        if f.onChange then f.onChange(bfsuite.app.Page) end

        f.value = bfsuite.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
        bfsuite.app.saveValue(i)
    end)

    if config.ethosRunningVersion >= 1514 then
        if f.onFocus ~= nil then
            bfsuite.app.formFields[i]:onFocus(function()
                f.onFocus(bfsuite.app.Page)
            end)
        end
    end

    if f.disable == true then bfsuite.app.formFields[i]:enable(false) end

    if f.help ~= nil then
        if bfsuite.app.fieldHelpTxt[f.help]['t'] ~= nil then
            local helpTxt = bfsuite.app.fieldHelpTxt[f.help]['t']
            bfsuite.app.formFields[i]:help(helpTxt)
        end
    end

end

function ui.fieldLabel(f, i, l)

    if f.t ~= nil then
        if f.t2 ~= nil then f.t = f.t2 end

        if f.label ~= nil then f.t = "        " .. f.t end
    end

    if f.label ~= nil then
        local label = bfsuite.app.ui.getLabel(f.label, l)

        local labelValue = label.t
        local labelID = label.label

        if label.t2 ~= nil then labelValue = label.t2 end
        if f.t ~= nil then
            labelName = labelValue
        else
            labelName = "unknown"
        end

        if f.label ~= bfsuite.lastLabel then
            if label.type == nil then label.type = 0 end

            formLineCnt = formLineCnt + 1
            bfsuite.app.formLines[formLineCnt] = form.addLine(labelName)
            form.addStaticText(bfsuite.app.formLines[formLineCnt], nil, "")

            bfsuite.lastLabel = f.label
        end
    else
        labelID = nil
    end
end

function ui.fieldHeader(title)
    local w, h = bfsuite.utils.getWindowSize()
    -- column starts at 59.4% of w
    padding = 5
    colStart = math.floor(((w) * 59.4) / 100)
    if bfsuite.app.radio.navButtonOffset ~= nil then colStart = colStart - bfsuite.app.radio.navButtonOffset end

    if bfsuite.app.radio.buttonWidth == nil then
        buttonW = (w - colStart) / 3 - padding
    else
        buttonW = bfsuite.app.radio.menuButtonWidth
    end
    buttonH = bfsuite.app.radio.navbuttonHeight

    bfsuite.app.formFields['menu'] = form.addLine("")

    bfsuite.app.formFields['title'] = form.addStaticText(bfsuite.app.formFields['menu'], {x = 0, y = bfsuite.app.radio.linePaddingTop, w = config.lcdWidth, h = bfsuite.app.radio.navbuttonHeight},
                                                         title)

    bfsuite.app.ui.navigationButtons(w - 5, bfsuite.app.radio.linePaddingTop, buttonW, buttonH)
end

function ui.openPageRefresh(idx, title, script, extra1, extra2, extra3, extra5, extra5)

    bfsuite.app.triggers.isReady = false
    if script ~= nil then bfsuite.app.Page = assert(loadfile("app/pages/" .. script))() end

end

function ui.openPage(idx, title, script, extra1, extra2, extra3, extra5, extra5)

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages
    bfsuite.app.triggers.isReady = false
    bfsuite.app.formFields = {}
    bfsuite.app.formLines = {}

    bfsuite.app.Page = assert(loadfile("app/pages/" .. script))()

    if bfsuite.app.Page.openPage then
        bfsuite.app.Page.openPage(idx, title, script, extra1, extra2, extra3, extra5, extra5)
    else

        bfsuite.app.lastIdx = idx
        bfsuite.app.lastTitle = title
        bfsuite.app.lastScript = script

        local fieldAR = {}

        bfsuite.app.uiState = bfsuite.app.uiStatus.pages
        bfsuite.app.triggers.isReady = false

        longPage = false

        form.clear()

        bfsuite.lastPage = script

        if bfsuite.app.Page.pageTitle ~= nil then
            bfsuite.app.ui.fieldHeader(bfsuite.app.Page.pageTitle)
        else
            bfsuite.app.ui.fieldHeader(title)
        end

        if bfsuite.app.Page.headerLine ~= nil then
            local headerLine = form.addLine("")
            local headerLineText =
                form.addStaticText(headerLine, {x = 0, y = bfsuite.app.radio.linePaddingTop, w = config.lcdWidth, h = bfsuite.app.radio.navbuttonHeight}, bfsuite.app.Page.headerLine)
        end

        formLineCnt = 0

        for i = 1, #bfsuite.app.Page.fields do
            local f = bfsuite.app.Page.fields[i]
            local l = bfsuite.app.Page.labels
            local pageValue = f
            local pageIdx = i
            local currentField = i

            bfsuite.app.ui.fieldLabel(f, i, l)

            if f.hidden ~= true then

                if f.type == 0 then
                    bfsuite.app.ui.fieldStaticText(i)
                elseif f.table or f.type == 1 then
                    bfsuite.app.ui.fieldChoice(i)
                elseif f.type == 2 then
                    bfsuite.app.ui.fieldNumber(i)
                elseif f.type == 3 then
                    bfsuite.app.ui.fieldText(i)
                else
                    bfsuite.app.ui.fieldNumber(i)
                end

            end
        end
    end

end

function ui.navigationButtons(x, y, w, h)

    local xOffset = 0
    local padding = 5
    local wS = w - (w * 20) / 100
    local helpOffset = 0
    local toolOffset = 0
    local reloadOffset = 0
    local saveOffset = 0
    local menuOffset = 0

    local navButtons
    if bfsuite.app.Page.navButtons == nil then
        navButtons = {menu = true, save = true, reload = true, help = true}
    else
        navButtons = bfsuite.app.Page.navButtons
    end

    -- calc all offsets
    -- these are done 'early' to enable the actual placement of the buttons on
    -- display to be rendered by ethos in the right order - for scrolling via
    -- keypad to work.
    if navButtons.help ~= nil and navButtons.help == true then xOffset = xOffset + wS + padding end
    helpOffset = x - xOffset

    if navButtons.tool ~= nil and navButtons.tool == true then xOffset = xOffset + wS + padding end
    toolOffset = x - xOffset

    if navButtons.reload ~= nil and navButtons.reload == true then xOffset = xOffset + w + padding end
    reloadOffset = x - xOffset

    if navButtons.save ~= nil and navButtons.save == true then xOffset = xOffset + w + padding end
    saveOffset = x - xOffset

    if navButtons.menu ~= nil and navButtons.menu == true then xOffset = xOffset + w + padding end
    menuOffset = x - xOffset

    -- MENU BTN
    if navButtons.menu ~= nil and navButtons.menu == true then

        bfsuite.app.formNavigationFields['menu'] = form.addButton(line, {x = menuOffset, y = y, w = w, h = h}, {
            text = "MENU",
            icon = nil,
            options = FONT_S,
            paint = function()
            end,
            press = function()
                if bfsuite.app.Page and bfsuite.app.Page.onNavMenu then
                    bfsuite.app.Page.onNavMenu(bfsuite.app.Page)
                else
                    bfsuite.app.ui.openMainMenu()
                end
            end
        })
        bfsuite.app.formNavigationFields['menu']:focus()
    end

    -- SAVE BTN
    if navButtons.save ~= nil and navButtons.save == true then

        bfsuite.app.formNavigationFields['save'] = form.addButton(line, {x = saveOffset, y = y, w = w, h = h}, {
            text = "SAVE",
            icon = nil,
            options = FONT_S,
            paint = function()
            end,
            press = function()
                if bfsuite.app.Page and bfsuite.app.Page.onSaveMenu then
                    bfsuite.app.Page.onSaveMenu(bfsuite.app.Page)
                else
                    bfsuite.app.triggers.triggerSave = true
                end
            end
        })
    end

    -- RELOAD BTN
    if navButtons.reload ~= nil and navButtons.reload == true then

        bfsuite.app.formNavigationFields['reload'] = form.addButton(line, {x = reloadOffset, y = y, w = w, h = h}, {
            text = "RELOAD",
            icon = nil,
            options = FONT_S,
            paint = function()
            end,
            press = function()

                if bfsuite.app.Page and bfsuite.app.Page.onReloadMenu then
                    bfsuite.app.Page.onReloadMenu(bfsuite.app.Page)
                else
                    bfsuite.app.triggers.triggerReload = true
                end
                return true
            end
        })
    end

    -- TOOL BUTTON
    if navButtons.tool ~= nil and navButtons.tool == true then
        bfsuite.app.formNavigationFields['tool'] = form.addButton(line, {x = toolOffset, y = y, w = wS, h = h}, {
            text = "*",
            icon = nil,
            options = FONT_S,
            paint = function()
            end,
            press = function()
                bfsuite.app.Page.onToolMenu()
            end
        })
    end

    -- HELP BUTTON
    if navButtons.help ~= nil and navButtons.help == true then

        local help = assert(loadfile("app/help/pages.lua"))()
        local section = string.gsub(bfsuite.app.lastScript, ".lua", "") -- remove .lua

        bfsuite.app.formNavigationFields['help'] = form.addButton(line, {x = helpOffset, y = y, w = wS, h = h}, {
            text = "?",
            icon = nil,
            options = FONT_S,
            paint = function()
            end,
            press = function()
                if bfsuite.app.Page and bfsuite.app.Page.onHelpMenu then
                    bfsuite.app.Page.onHelpMenu(bfsuite.app.Page)
                else
                    bfsuite.app.ui.openPageHelp(help.data, section)
                end
            end
        })
    end

end

function ui.openPageHelp(helpdata, section)
    local txtData
    local qr

    if section == "rates" then
        txtData = helpdata[section]["table"][bfsuite.rateProfile]
    else
        txtData = helpdata[section]["TEXT"]
    end


    local message = ""

    -- wrap text because of image on right
    for k, v in ipairs(txtData) do
        message = message .. v .. "\r\n\r\n"
    end


    local buttons = {
        {
            label = "CLOSE",
            action = function()
                return true
            end
        }
    }

    form.openDialog({
        width = config.lcdWidth,
        title = "Help - " .. bfsuite.app.lastTitle,
        message = message,
        buttons = buttons,
        wakeup = function()
        end,
        paint = function()

            local w = config.lcdWidth
            local h = config.lcdHeight
            local left = w * 0.75

        end,
        options = TEXT_LEFT
    })

end

return ui
