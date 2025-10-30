--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local render = {}

local utils = bfsuite.widgets.dashboard.utils
local getParam = utils.getParam
local resolveThemeColor = utils.resolveThemeColor
local resolveThresholdColor = utils.resolveThresholdColor
local lastDisplayValue = nil

function render.dirty(box)

    if box._lastDisplayValue == nil then
        box._lastDisplayValue = box._currentDisplayValue
        return true
    end

    if box._lastDisplayValue ~= box._currentDisplayValue then
        box._lastDisplayValue = box._currentDisplayValue
        return true
    end

    return false
end

local function drawFilledRoundedRectangle(x, y, w, h, r)
    x = math.floor(x + 0.5)
    y = math.floor(y + 0.5)
    w = math.floor(w + 0.5)
    h = math.floor(h + 0.5)
    r = r or 0
    if r > 0 then
        lcd.drawFilledRectangle(x + r, y, w - 2 * r, h)
        lcd.drawFilledRectangle(x, y + r, r, h - 2 * r)
        lcd.drawFilledRectangle(x + w - r, y + r, r, h - 2 * r)
        lcd.drawFilledCircle(x + r, y + r, r)
        lcd.drawFilledCircle(x + w - r - 1, y + r, r)
        lcd.drawFilledCircle(x + r, y + h - r - 1, r)
        lcd.drawFilledCircle(x + w - r - 1, y + h - r - 1, r)
    else
        lcd.drawFilledRectangle(x, y, w, h)
    end
end

local function drawBatteryBox(x, y, w, h, percent, gaugeorientation, batterysegments, batteryspacing, fillbgcolor, fillcolor, batteryframe, batteryframethickness, accentcolor, battery, batterysegmentpaddingtop, batterysegmentpaddingbottom, batterysegmentpaddingleft, batterysegmentpaddingright)

    local frameThickness = batteryframethickness or 4
    local segments = batterysegments or 5
    local spacing = batteryspacing or 2

    if gaugeorientation == "vertical" then
        local capH = 0
        if batteryframe then
            local maxCapH = math.floor(h * 0.5)
            capH = math.min(math.max(8, math.floor(h * 0.10)), maxCapH)

        end
        local bodyY = y + capH
        local bodyH = h - capH

        if batteryframe then
            lcd.color(accentcolor)
            local capW = math.min(math.max(4, math.floor(w * 0.40)), w)
            for i = 0, frameThickness - 1 do lcd.drawFilledRectangle(x + (w - capW) / 2 - i, y + i, capW + 2 * i, capH - i) end
        end

        if battery then
            local segCount = math.max(1, segments)
            local fillSegs = math.floor(segCount * percent + 0.5)
            local totalSpacing = (segCount - 1) * spacing
            local segH = (bodyH - totalSpacing) / segCount
            for i = 1, segCount do
                local segY = bodyY + bodyH - (segH + spacing) * i + spacing
                lcd.color(i <= fillSegs and fillcolor or fillbgcolor)
                lcd.drawFilledRectangle(x, segY, w, segH)
            end
        else
            lcd.color(fillbgcolor)
            lcd.drawFilledRectangle(x, bodyY, w, bodyH)
            if percent > 0 then
                lcd.color(fillcolor)
                local fillH = math.floor(bodyH * percent)
                local fillY = bodyY + bodyH - fillH
                lcd.drawFilledRectangle(x, fillY, w, fillH)
            end
        end

        if batteryframe then
            lcd.color(accentcolor)
            lcd.drawRectangle(x, bodyY, w, bodyH, frameThickness)
        end

    else

        local maxCapW = math.floor(w * 0.5)
        local capOffset = math.min(math.max(8, math.floor(w * 0.03)), maxCapW)
        local bodyW = w - capOffset

        if battery then
            local segCount = math.max(1, segments)
            local fillSegs = math.floor(segCount * percent + 0.5)
            local totalSpacing = (segCount - 1) * spacing
            local segW = (bodyW - totalSpacing) / segCount
            local segPadT = batterysegmentpaddingtop or 0
            local segPadB = batterysegmentpaddingbottom or 0
            local segHeight = h - segPadT - segPadB
            local segPadL = batterysegmentpaddingleft or 0
            local segPadR = batterysegmentpaddingright or 0
            local segAvailW = bodyW - segPadL - segPadR
            local segW = (segAvailW - totalSpacing) / segCount

            for i = 1, segCount do
                local segX = x + segPadL + (i - 1) * (segW + spacing)
                lcd.color(i <= fillSegs and fillcolor or fillbgcolor)
                lcd.drawFilledRectangle(segX, y + segPadT, segW, segHeight)
            end
        else
            lcd.color(fillbgcolor)
            lcd.drawFilledRectangle(x, y, bodyW, h)
            if percent > 0 then
                lcd.color(fillcolor)
                local fillW = math.floor(bodyW * percent)
                lcd.drawFilledRectangle(x, y, fillW, h)
            end
        end

        if batteryframe then
            lcd.color(accentcolor)
            lcd.drawRectangle(x, y, bodyW, h, frameThickness)
            local capW = capOffset
            local capH = math.min(math.max(4, math.floor(h * 0.33)), h)
            for i = 0, frameThickness - 1 do lcd.drawFilledRectangle(x + bodyW + i, y + (h - capH) / 2 + i, capW, capH - 2 * i) end
        end
    end
end

function render.wakeup(box)

    local telemetry = bfsuite.tasks.telemetry

    local source = getParam(box, "source")
    local value, _, dynamicUnit

    if source == "txbatt" then
        local src = system.getSource({category = CATEGORY_SYSTEM, member = MAIN_VOLTAGE})
        value = src and src.value and src:value() or nil
        dynamicUnit = "V"
    elseif telemetry and source then
        value, _, dynamicUnit = telemetry.getSensor(source)
    else
        value = getParam(box, "value")
    end

    local getSensor = telemetry and telemetry.getSensor
    local voltage = getSensor and getSensor("voltage") or 0
    local cellCount = getSensor and getSensor("cell_count") or 0
    local consumed = getSensor and getSensor("consumption") or 0
    local perCellVoltage = (cellCount > 0) and (voltage / cellCount) or 0

    local manualUnit = getParam(box, "unit")
    local unit

    if manualUnit ~= nil then
        unit = manualUnit
    elseif dynamicUnit ~= nil then
        unit = dynamicUnit
    elseif source and telemetry and telemetry.sensorTable[source] then
        unit = telemetry.sensorTable[source].unit_string or ""
    else
        unit = ""
    end

    local displayValue
    if value ~= nil then displayValue = utils.transformValue(value, box) end

    if getParam(box, "hidevalue") == true then displayValue = nil end

    local min, max
    if source == "txbatt" then
        min = getParam(box, "min") or 7.2
        max = getParam(box, "max") or 8.4
    else
        min = getParam(box, "min") or 0
        max = getParam(box, "max") or 100
    end

    local percent = 0
    if value and max ~= min then
        percent = (value - min) / (max - min)
        percent = math.max(0, math.min(1, percent))
    end

    if value == nil then
        local maxDots = 3
        if box._dotCount == nil then box._dotCount = 0 end
        box._dotCount = (box._dotCount + 1) % (maxDots + 1)
        displayValue = string.rep(".", box._dotCount)
        if displayValue == "" then displayValue = "." end
        unit = nil
    end

    local title = getParam(box, "title")
    local titlefont = getParam(box, "titlefont")
    local titlespacing = getParam(box, "titlespacing") or 0
    local titlepos = getParam(box, "titlepos") or (title and "top" or nil)
    local title_area_top = 0
    local title_area_bottom = 0

    if title and title ~= "" then
        lcd.font(_G[titlefont] or FONT_XS)
        local _, tsizeH = lcd.getTextSize(title)
        if titlepos == "bottom" then
            title_area_bottom = (tsizeH or 0) + (getParam(box, "titlepaddingtop") or 0) + (getParam(box, "titlepaddingbottom") or 0) + titlespacing
        else
            title_area_top = (tsizeH or 0) + (getParam(box, "titlepaddingtop") or 0) + (getParam(box, "titlepaddingbottom") or 0) + titlespacing
        end
    else
        title_area_top = 0
        title_area_bottom = 0
    end

    local battadv = getParam(box, "battadv")

    if battadv then
        box._batteryLines = {line1 = string.format("%.1fv / %.2fv (%dS)", voltage, perCellVoltage, cellCount), line2 = string.format("%d mah", consumed)}
    else
        box._batteryLines = nil
    end

    if type(displayValue) == "string" and displayValue:match("^%.+$") then unit = nil end

    box._currentDisplayValue = value

    box._cache = {
        value = value,
        displayValue = displayValue,
        unit = unit,
        min = min,
        max = max,
        percent = percent,
        title = title,
        titlepos = titlepos,
        titlefont = titlefont,
        titlespacing = titlespacing,
        title_area_top = title_area_top,
        title_area_bottom = title_area_bottom,
        voltage = voltage,
        cellCount = cellCount,
        consumed = consumed,
        perCellVoltage = perCellVoltage,
        battadv = battadv,
        hidevalue = getParam(box, "hidevalue"),
        textcolor = resolveThresholdColor(value, box, "textcolor", "textcolor"),
        fillcolor = resolveThresholdColor(value, box, "fillcolor", "fillcolor"),
        fillbgcolor = resolveThemeColor("fillbgcolor", getParam(box, "fillbgcolor")),
        bgcolor = resolveThemeColor("bgcolor", getParam(box, "bgcolor")),
        titlecolor = resolveThemeColor("titlecolor", getParam(box, "titlecolor")),
        accentcolor = resolveThemeColor("accentcolor", getParam(box, "accentcolor")),
        font = getParam(box, "font") or "FONT_XL",
        titlealign = getParam(box, "titlealign"),
        titlepadding = getParam(box, "titlepadding"),
        titlepaddingleft = getParam(box, "titlepaddingleft"),
        titlepaddingright = getParam(box, "titlepaddingright"),
        titlepaddingtop = getParam(box, "titlepaddingtop"),
        titlepaddingbottom = getParam(box, "titlepaddingbottom"),
        valuealign = getParam(box, "valuealign"),
        valuepadding = getParam(box, "valuepadding"),
        valuepaddingleft = getParam(box, "valuepaddingleft"),
        valuepaddingright = getParam(box, "valuepaddingright"),
        valuepaddingtop = getParam(box, "valuepaddingtop"),
        valuepaddingbottom = getParam(box, "valuepaddingbottom"),
        gaugeorientation = getParam(box, "gaugeorientation") or "horizontal",
        gpad_left = getParam(box, "gaugepaddingleft"),
        gpad_right = getParam(box, "gaugepaddingright"),
        gpad_top = getParam(box, "gaugepaddingtop"),
        gpad_bottom = getParam(box, "gaugepaddingbottom"),
        roundradius = getParam(box, "roundradius"),
        battery = getParam(box, "battery"),
        batteryframe = getParam(box, "batteryframe"),
        batteryframethickness = getParam(box, "batteryframethickness"),
        batterysegments = getParam(box, "batterysegments"),
        batteryspacing = getParam(box, "batteryspacing"),
        batterysegmentpaddingleft = getParam(box, "batterysegmentpaddingleft") or 0,
        batterysegmentpaddingright = getParam(box, "batterysegmentpaddingright") or 0,
        batterysegmentpaddingtop = getParam(box, "batterysegmentpaddingtop") or 0,
        batterysegmentpaddingbottom = getParam(box, "batterysegmentpaddingbottom") or 0,
        battadvfont = getParam(box, "battadvfont") or "FONT_S",
        battadvblockalign = getParam(box, "battadvblockalign") or "right",
        battadvvaluealign = getParam(box, "battadvvaluealign") or "left",
        battadvpadding = getParam(box, "battadvpadding") or 4,
        battadvpaddingleft = getParam(box, "battadvpaddingleft") or 0,
        battadvpaddingright = getParam(box, "battadvpaddingright") or 0,
        battadvpaddingtop = getParam(box, "battadvpaddingtop") or 0,
        battadvpaddingbottom = getParam(box, "battadvpaddingbottom") or 0,
        battadvgap = getParam(box, "battadvgap") or 5,
        battstats = getParam(box, "battstats") or false,
        subtext = getParam(box, "subtext"),
        subtextfont = getParam(box, "subtextfont") or "FONT_XS",
        subtextalign = getParam(box, "subtextalign") or "left",
        subtextpaddingleft = getParam(box, "subtextpaddingleft") or 0,
        subtextpaddingright = getParam(box, "subtextpaddingright") or 0,
        subtextpaddingtop = getParam(box, "subtextpaddingtop") or 0,
        subtextpaddingbottom = getParam(box, "subtextpaddingbottom") or 0
    }
end

function render.paint(x, y, w, h, box)
    x, y = utils.applyOffset(x, y, box)
    local c = box._cache or {}

    if c.bgcolor then
        lcd.color(c.bgcolor)
        lcd.drawFilledRectangle(x, y, w, h)
    end

    local gauge_x = x + (c.gpad_left or 0)
    local gauge_y = y + (c.gpad_top or 0) + (c.title_area_top or 0)
    local gauge_w = w - (c.gpad_left or 0) - (c.gpad_right or 0)
    local gauge_h = h - (c.gpad_top or 0) - (c.gpad_bottom or 0) - (c.title_area_top or 0) - (c.title_area_bottom or 0)

    if c.batteryframe or c.battery then
        drawBatteryBox(gauge_x, gauge_y, gauge_w, gauge_h, c.percent, c.gaugeorientation, c.batterysegments, c.batteryspacing, c.fillbgcolor, c.fillcolor, c.batteryframe, c.batteryframethickness, c.accentcolor, c.battery, c.batterysegmentpaddingtop, c.batterysegmentpaddingbottom,
            c.batterysegmentpaddingleft, c.batterysegmentpaddingright)
    else

        lcd.color(c.fillbgcolor)
        drawFilledRoundedRectangle(gauge_x, gauge_y, gauge_w, gauge_h, c.roundradius)

        if not c.battstats and (tonumber(c.percent) or 0) > 0 then
            lcd.color(c.fillcolor)
            if c.gaugeorientation == "vertical" then
                local fillH = math.floor(gauge_h * c.percent)
                local fillY = gauge_y + gauge_h - fillH
                lcd.setClipping(gauge_x, fillY, gauge_w, fillH)
                drawFilledRoundedRectangle(gauge_x, gauge_y, gauge_w, gauge_h, c.roundradius)
                lcd.setClipping()
            else
                local fillW = math.floor(gauge_w * c.percent)
                if fillW > 0 then
                    lcd.setClipping(gauge_x, gauge_y, fillW, gauge_h)
                    drawFilledRoundedRectangle(gauge_x, gauge_y, gauge_w, gauge_h, c.roundradius)
                    lcd.setClipping()
                end
            end
        end
    end

    if c.subtext and c.subtext ~= "" then
        lcd.font(_G[c.subtextfont] or FONT_XS)
        lcd.color(c.textcolor)
        local textW, textH = lcd.getTextSize(c.subtext)
        local sy = gauge_y + gauge_h - textH - c.subtextpaddingbottom
        local sx
        if c.subtextalign == "right" then
            sx = gauge_x + gauge_w - textW - c.subtextpaddingright
        elseif c.subtextalign == "center" then
            sx = gauge_x + math.floor((gauge_w - textW) / 2 + 0.5)
        else
            sx = gauge_x + c.subtextpaddingleft
        end
        sy = sy + c.subtextpaddingtop
        lcd.drawText(sx, sy, c.subtext)
    end

    local boxValue = c.displayValue
    local boxUnit = c.unit
    if c.hidevalue then
        boxValue = nil
        boxUnit = nil
    end
    utils.box(x, y, w, h, c.title, c.titlepos, c.titlealign, c.titlefont, c.titlespacing, c.titlecolor, c.titlepadding, c.titlepaddingleft, c.titlepaddingright, c.titlepaddingtop, c.titlepaddingbottom, boxValue, boxUnit, c.font, c.valuealign, c.textcolor, c.valuepadding, c.valuepaddingleft,
        c.valuepaddingright, c.valuepaddingtop, c.valuepaddingbottom, nil)

    c.battadvpaddingleft = tonumber(c.battadvpaddingleft) or 0
    c.battadvpaddingright = tonumber(c.battadvpaddingright) or 0
    c.battadvpaddingtop = tonumber(c.battadvpaddingtop) or 0
    c.battadvpaddingbottom = tonumber(c.battadvpaddingbottom) or 0
    c.battadvgap = tonumber(c.battadvgap) or 5

    if c.battadv and box._batteryLines then
        local textColor = c.textcolor
        local line1 = box._batteryLines.line1 or ""
        local line2 = box._batteryLines.line2 or ""

        lcd.font(_G[c.battadvfont] or FONT_S)
        local w1, h1 = lcd.getTextSize(line1)
        local w2, h2 = lcd.getTextSize(line2)
        local blockW = math.max(w1, w2) + c.battadvpaddingleft + c.battadvpaddingright
        local blockH = h1 + h2 + c.battadvpaddingtop + c.battadvpaddingbottom + c.battadvgap

        local startY = y + math.max(0, math.floor((h - blockH) / 2 + 0.5))
        local startX
        if c.battadvblockalign == "left" then
            startX = x
        elseif c.battadvblockalign == "center" then
            startX = x + math.floor((w - blockW) / 2 + 0.5)
        else
            startX = x + w - blockW
        end

        utils.box(startX + c.battadvpaddingleft, startY + c.battadvpaddingtop, blockW - c.battadvpaddingleft - c.battadvpaddingright, h1, nil, nil, c.battadvvaluealign, c.battadvfont, 0, textColor, 0, 0, 0, 0, 0, line1, nil, c.battadvfont, c.battadvvaluealign, textColor, 0, 0, 0, 0, 0, nil)

        utils.box(startX + c.battadvpaddingleft, startY + c.battadvpaddingtop + h1 + c.battadvgap, blockW - c.battadvpaddingleft - c.battadvpaddingright, h2, nil, nil, c.battadvvaluealign, c.battadvfont, 0, textColor, 0, 0, 0, 0, 0, line2, nil, c.battadvfont, c.battadvvaluealign, textColor, 0, 0, 0,
            0, 0, nil)
    end
end

return render
