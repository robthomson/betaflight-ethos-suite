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

local function drawArc(cx, cy, radius, thickness, startAngle, endAngle, color)
    lcd.color(color)
    local outer = radius
    local inner = math.max(1, radius - (thickness or 6))

    startAngle = startAngle % 360
    endAngle = endAngle % 360
    if endAngle <= startAngle then endAngle = endAngle + 360 end

    local sweep = endAngle - startAngle
    if sweep <= 180 then
        lcd.drawAnnulusSector(cx, cy, inner, outer, startAngle, endAngle)
    else
        local mid = startAngle + sweep / 2
        lcd.drawAnnulusSector(cx, cy, inner, outer, startAngle, mid)
        lcd.drawAnnulusSector(cx, cy, inner, outer, mid, endAngle)
    end
end

function render.wakeup(box)

    local telemetry = bfsuite.tasks.telemetry

    local source = getParam(box, "source")
    local value, _, dynamicUnit
    if telemetry and source then value, _, dynamicUnit = telemetry.getSensor(source) end

    local arcmax = getParam(box, "arcmax") == true
    local maxval = nil
    if arcmax and source then
        local stats = bfsuite.tasks.telemetry.getSensorStats(source)
        local currentMax = stats and stats.max or nil
        local prevMax = box._cache and box._cache.maxval or nil
        maxval = currentMax or prevMax
    end

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

    local min = getParam(box, "min") or 0
    local max = getParam(box, "max") or 100

    local isFahrenheit = unit and unit:match("F$") ~= nil
    local isFeet = unit and unit:lower():match("ft$") ~= nil

    if isFahrenheit then
        min = min * 9 / 5 + 32
        max = max * 9 / 5 + 32
        if arcmax and maxval then maxval = maxval * 9 / 5 + 32 end
    elseif isFeet then
        min = min * 3.28084
        max = max * 3.28084
        if arcmax and maxval then maxval = maxval * 3.28084 end
    end

    local thresholds = getParam(box, "thresholds")
    local adjustedThresholds = thresholds

    if thresholds and (isFahrenheit or isFeet) then
        adjustedThresholds = {}
        for i, t in ipairs(thresholds) do
            local newT = {}
            for k, v in pairs(t) do newT[k] = v end
            if type(newT.value) == "number" then
                if isFahrenheit then
                    newT.value = newT.value * 9 / 5 + 32
                elseif isFeet then
                    newT.value = newT.value * 3.28084
                end
            end
            table.insert(adjustedThresholds, newT)
        end
    end

    local percent = 0
    if value and max ~= min then
        percent = (value - min) / (max - min)
        percent = math.max(0, math.min(1, percent))
    end
    local maxPercent = 0
    if arcmax and maxval and max ~= min then
        maxPercent = (maxval - min) / (max - min)
        maxPercent = math.max(0, math.min(1, maxPercent))
    end

    local displayValue
    if value ~= nil then displayValue = utils.transformValue(value, box) end

    local displayMaxValue = nil
    if arcmax and maxval ~= nil then displayMaxValue = utils.transformValue(maxval, box) end

    if value == nil then
        local maxDots = 3
        if box._dotCount == nil then box._dotCount = 0 end
        box._dotCount = (box._dotCount + 1) % (maxDots + 1)
        displayValue = string.rep(".", box._dotCount)
        if displayValue == "" then displayValue = "." end
        unit = nil
    end

    if type(displayValue) == "string" and displayValue:match("^%.+$") then unit = nil end

    box._currentDisplayValue = value

    box._cache = {
        value = value,
        maxval = maxval,
        displayValue = displayValue,
        displayMaxValue = displayMaxValue,
        arcmax = arcmax,
        min = min,
        max = max,
        percent = percent,
        maxPercent = maxPercent,
        unit = unit,
        textcolor = resolveThresholdColor(value, box, "textcolor", "textcolor", adjustedThresholds),
        maxtextcolor = resolveThresholdColor(maxval, box, "maxtextcolor", "textcolor", adjustedThresholds),
        fillcolor = resolveThresholdColor(value, box, "fillcolor", "fillcolor", adjustedThresholds),
        maxfillcolor = resolveThresholdColor(maxval, box, "fillcolor", "fillcolor", adjustedThresholds),
        fillbgcolor = resolveThemeColor("fillbgcolor", getParam(box, "fillbgcolor")),
        bgcolor = resolveThemeColor("bgcolor", getParam(box, "bgcolor")),
        titlecolor = resolveThemeColor("titlecolor", getParam(box, "titlecolor")),
        title = getParam(box, "title"),
        titlepos = getParam(box, "titlepos") or (getParam(box, "title") and "top"),
        titlealign = getParam(box, "titlealign"),
        titlefont = getParam(box, "titlefont"),
        titlespacing = getParam(box, "titlespacing") or 0,
        titlepadding = getParam(box, "titlepadding"),
        titlepaddingleft = getParam(box, "titlepaddingleft"),
        titlepaddingright = getParam(box, "titlepaddingright"),
        titlepaddingtop = getParam(box, "titlepaddingtop"),
        titlepaddingbottom = getParam(box, "titlepaddingbottom"),
        font = getParam(box, "font") or "FONT_M",
        maxfont = getParam(box, "maxfont") or "FONT_S",
        decimals = getParam(box, "decimals"),
        valuealign = getParam(box, "valuealign"),
        valuepadding = getParam(box, "valuepadding"),
        valuepaddingleft = getParam(box, "valuepaddingleft"),
        valuepaddingright = getParam(box, "valuepaddingright"),
        valuepaddingtop = getParam(box, "valuepaddingtop") or 18,
        valuepaddingbottom = getParam(box, "valuepaddingbottom"),
        thickness = getParam(box, "thickness"),
        maxprefix = getParam(box, "maxprefix") or "+",
        maxpadding = getParam(box, "maxpadding") or 0,
        maxpaddingleft = getParam(box, "maxpaddingleft") or 0,
        maxpaddingtop = getParam(box, "maxpaddingtop") or 0,
        gaugepadding = getParam(box, "gaugepadding") or 0,
        gaugepaddingbottom = getParam(box, "gaugepaddingbottom") or 0
    }
end

function render.paint(x, y, w, h, box)
    x, y = utils.applyOffset(x, y, box)
    local c = box._cache or {}

    local titleHeight = 0
    if c.title then
        lcd.font(_G[c.titlefont] or FONT_XS)
        local _, th = lcd.getTextSize(c.title)
        titleHeight = (th or 0) + (c.titlespacing or 0) + (c.titlepaddingtop or 0) + (c.titlepaddingbottom or 0)
    end

    local arcRegionY, arcRegionH, cy, radius
    local thickness, maxRadius

    if c.titlepos == "top" then
        arcRegionY = y + titleHeight
        arcRegionH = h - titleHeight - (c.gaugepaddingbottom or 0)
        cy = arcRegionY + arcRegionH * 0.5
    elseif c.titlepos == "bottom" then
        arcRegionY = y
        arcRegionH = h - titleHeight - (c.gaugepaddingbottom or 0)
        cy = arcRegionY + arcRegionH * 0.6
    else
        arcRegionY = y
        arcRegionH = h - (c.gaugepaddingbottom or 0)
        cy = arcRegionY + arcRegionH * 0.55
    end

    thickness = c.thickness or math.max(6, math.min(w, arcRegionH) * 0.07)
    local gaugepadding = c.gaugepadding or 0
    maxRadius = (arcRegionH / 2) - (thickness / 2)
    radius = math.min((w / 2) - gaugepadding, maxRadius + 8)

    if c.bgcolor then
        lcd.color(c.bgcolor)
        lcd.drawFilledRectangle(x, y, w, h)
    end

    local cx = x + w / 2
    local startAngle = 225
    local endAngle = (startAngle + 270) % 360

    drawArc(cx, cy, radius, thickness, startAngle, endAngle, c.fillbgcolor)

    if c.percent and c.percent > 0 then
        local valueEndAngle = (startAngle + 270 * c.percent) % 360
        drawArc(cx, cy, radius, thickness, startAngle, valueEndAngle, c.fillcolor)
    end

    if c.arcmax and c.maxval and c.max ~= c.min and c.maxPercent > 0 then
        local innerRadius = radius * 0.74
        local innerThickness = thickness * 0.8
        local maxEndAngle = (startAngle + 270 * c.maxPercent) % 360
        drawArc(cx, cy, innerRadius, innerThickness, startAngle, maxEndAngle, c.maxfillcolor)
    end

    utils.box(x, y, w, h, c.title, c.titlepos, c.titlealign, c.titlefont, c.titlespacing, c.titlecolor, c.titlepadding, c.titlepaddingleft, c.titlepaddingright, c.titlepaddingtop, c.titlepaddingbottom, c.displayValue, c.unit, c.font, c.valuealign, c.textcolor, c.valuepadding, c.valuepaddingleft,
        c.valuepaddingright, c.valuepaddingtop, c.valuepaddingbottom, nil)

    if c.arcmax and c.maxval then
        local maxStr = tostring(c.maxprefix or "") .. (c.displayMaxValue or c.maxval) .. (c.unit or "")
        local maxTextColor = c.maxtextcolor or c.textcolor
        lcd.color(maxTextColor)
        lcd.font(_G[c.maxfont] or FONT_S)
        local tw2, th2 = lcd.getTextSize(maxStr)
        lcd.drawText(cx - tw2 / 2 + (c.maxpaddingleft or 0), cy + radius * 0.25 + (c.maxpadding or 0) + (c.maxpaddingtop or 0), maxStr)
    end
end

return render
