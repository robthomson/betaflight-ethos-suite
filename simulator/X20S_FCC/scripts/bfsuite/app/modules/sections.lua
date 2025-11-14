--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local sections = {}
local tools = {}

sections[#sections + 1] = {title = "PIDs", module = "pids", script = "pids.lua", image = "app/modules/pids/pids.png", offline = false, bgtask = false}
sections[#sections + 1] = {title = "Rates", module = "rates", script = "rates.lua", image = "app/modules/rates/rates.png", offline = false, bgtask = false}
sections[#sections + 1] = {title = "Filters", module = "filters", script = "filters.lua", image = "app/modules/filters/filters.png", offline = false, bgtask = false}


sections[#sections + 1] = {title = "Hardware", id = "hardware", image = "app/gfx/hardware.png", loaderspeed = true, offline = false, bgtask = false}
sections[#sections + 1] = {newline = true, title = "Settings", module = "settings", script = "settings.lua", image = "app/modules/settings/settings.png", loaderspeed = true, offline = true, bgtask = false}
sections[#sections + 1] = {title = "Diagnostics", module = "diagnostics", script = "diagnostics.lua", image = "app/modules/diagnostics/diagnostics.png", loaderspeed = true, bgtask = true, offline = true}

return sections
