--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local API_NAME = "TEST_API"

local API_STRUCTURE = {{field = "pitch", min = -300, max = 300, default = 0, unit = "°"}, {field = "roll", min = -300, max = 300, default = 0, unit = "°"}}

return {API_STRUCTURE = API_STRUCTURE}
