--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local init = {title = "@i18n(app.modules.settings.name)@", section = "footer", script = "settings.lua", image = "settings.png", order = 10, offline = true, ethosversion = {1, 6, 2}}

return init
