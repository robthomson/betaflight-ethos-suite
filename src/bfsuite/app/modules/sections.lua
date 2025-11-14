--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local sections = {}
local tools = {}

sections[#sections + 1] = {title = "@i18n(app.modules.pids.name)@", module = "pids", script = "pids.lua", image = "app/modules/pids/pids.png", offline = false, bgtask = false}
sections[#sections + 1] = {title = "@i18n(app.modules.rates.name)@", module = "rates", script = "rates.lua", image = "app/modules/rates/rates.png", offline = false, bgtask = false}
sections[#sections + 1] = {title = "@i18n(app.modules.filters.name)@", module = "filters", script = "filters.lua", image = "app/modules/filters/filters.png", offline = false, bgtask = false}


sections[#sections + 1] = {title = "@i18n(app.menu_section_hardware)@", id = "hardware", image = "app/gfx/hardware.png", loaderspeed = true, offline = false, bgtask = false}
sections[#sections + 1] = {newline = true, title = "@i18n(app.modules.settings.name)@", module = "settings", script = "settings.lua", image = "app/modules/settings/settings.png", loaderspeed = true, offline = true, bgtask = false}
sections[#sections + 1] = {title = "@i18n(app.modules.diagnostics.name)@", module = "diagnostics", script = "diagnostics.lua", image = "app/modules/diagnostics/diagnostics.png", loaderspeed = true, bgtask = true, offline = true}

return sections
