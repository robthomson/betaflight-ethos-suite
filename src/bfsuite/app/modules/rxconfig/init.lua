--[[
  Copyright (C) 2025 Betaflight Project
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local init = {
    title = "Receiver", -- title of the page
    section = "hardware", -- section category
    script = "rxconfig.lua", -- run this script
    image = "rxconfig.png", -- image for the page (optional)
    order = 10, -- order in the section
    ethosversion = {1, 6, 2} -- disable button if ethos version is less than this
}

return init