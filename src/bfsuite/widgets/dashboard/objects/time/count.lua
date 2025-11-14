--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local render = {}

local utils = bfsuite.widgets.dashboard.utils
local getParam = utils.getParam
local resolveThemeColor = utils.resolveThemeColor
local lastDisplayValue = nil

function render.dirty(box)
    if not bfsuite.session.telemetryState then return false end

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

function render.wakeup(box)
    local value = bfsuite.ini.getvalue(bfsuite.session.modelPreferences, "general", "flightcount")
    local unit = getParam(box, "unit")
    local displayValue

    local telemetryActive = bfsuite.session and bfsuite.session.isConnected

    if type(value) == "number" and telemetryActive then box._lastValidFlightCount = value end

    if type(value) == "number" then
        displayValue = tostring(value)
    elseif box._lastValidFlightCount ~= nil then
        displayValue = tostring(box._lastValidFlightCount)
    else

        local maxDots = 3
        if box._dotCount == nil then box._dotCount = 0 end
        box._dotCount = (box._dotCount + 1) % (maxDots + 1)
        displayValue = string.rep(".", box._dotCount)
        if displayValue == "" then displayValue = "." end
        unit = nil
    end

    box._currentDisplayValue = displayValue

    box._cache = {
        title = getParam(box, "title"),
        titlepos = getParam(box, "titlepos"),
        titlealign = getParam(box, "titlealign"),
        titlefont = getParam(box, "titlefont"),
        titlespacing = getParam(box, "titlespacing"),
        titlecolor = resolveThemeColor("titlecolor", getParam(box, "titlecolor")),
        titlepadding = getParam(box, "titlepadding"),
        titlepaddingleft = getParam(box, "titlepaddingleft"),
        titlepaddingright = getParam(box, "titlepaddingright"),
        titlepaddingtop = getParam(box, "titlepaddingtop"),
        titlepaddingbottom = getParam(box, "titlepaddingbottom"),
        displayValue = displayValue,
        unit = unit,
        font = getParam(box, "font"),
        valuealign = getParam(box, "valuealign"),
        textcolor = resolveThemeColor("textcolor", getParam(box, "textcolor")),
        valuepadding = getParam(box, "valuepadding"),
        valuepaddingleft = getParam(box, "valuepaddingleft"),
        valuepaddingright = getParam(box, "valuepaddingright"),
        valuepaddingtop = getParam(box, "valuepaddingtop"),
        valuepaddingbottom = getParam(box, "valuepaddingbottom"),
        bgcolor = resolveThemeColor("bgcolor", getParam(box, "bgcolor"))
    }
end

function render.paint(x, y, w, h, box)
    x, y = utils.applyOffset(x, y, box)
    local c = box._cache or {}

    utils.box(x, y, w, h, c.title, c.titlepos, c.titlealign, c.titlefont, c.titlespacing, c.titlecolor, c.titlepadding, c.titlepaddingleft, c.titlepaddingright, c.titlepaddingtop, c.titlepaddingbottom, c.displayValue, c.unit, c.font, c.valuealign, c.textcolor, c.valuepadding, c.valuepaddingleft,
        c.valuepaddingright, c.valuepaddingtop, c.valuepaddingbottom, c.bgcolor)
end

return render
