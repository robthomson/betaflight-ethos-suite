--[[
  Copyright (C) 2025 Rob Thomson
  GPLv3 — https://www.gnu.org/licenses/gpl-3.0.en.html
]] --

local bfsuite = require("bfsuite")

local data = {}

data['help'] = {}

data['help']['default'] = {"The accelerometer is used to measure the angle of the flight controller in relation to the horizon. This data is used to stabilize the aircraft and provide self-leveling functionality."}

data['fields'] = {}

return data
