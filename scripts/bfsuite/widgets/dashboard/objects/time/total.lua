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
    local value = bfsuite.ini.getvalue(bfsuite.session.modelPreferences, "general", "totalflighttime")
    local unit = getParam(box, "unit")
    local displayValue

    if type(value) == "number" and value > 0 then
        local hours = math.floor(value / 3600)
        local minutes = math.floor((value % 3600) / 60)
        local seconds = math.floor(value % 60)
        displayValue = string.format("%02d:%02d:%02d", hours, minutes, seconds)

        box._lastDisplayValue = displayValue

    else
        displayValue = getParam(box, "novalue") or "00:00:00"
        unit = nil
    end

    if displayValue == "00:00:00" and box._lastDisplayValue ~= nil then displayValue = box._lastDisplayValue end

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

render.scheduler = 0.5

return render
