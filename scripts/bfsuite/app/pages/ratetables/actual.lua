local rTableName = "ACTUAL"
local rows = {"Roll", "Pitch", "Yaw"}
local cols

if bfsuite.app.radio.text == 2 then
    cols = {"Cntr. Sens.", "Max Rate", "Expo"}
else
    cols = {"Center Sensitivity", "Max Rate", "Expo"}
end
local fields = {}

-- rc rate
fields[#fields + 1] = {row = 1, col = 1, min = 0, max = 100, vals = {1}, default = 18, mult = 10, step = 10}
fields[#fields + 1] = {row = 2, col = 1, min = 0, max = 100, vals = {13}, default = 18, mult = 10, step = 10}
fields[#fields + 1] = {row = 3, col = 1, min = 0, max = 100, vals = {12}, default = 18, mult = 10, step = 10}

-- fc rate
fields[#fields + 1] = {row = 1, col = 2, min = 0, max = 100, vals = {3}, default = 24, mult = 10, step = 10}
fields[#fields + 1] = {row = 2, col = 2, min = 0, max = 100, vals = {4}, default = 24, mult = 10, step = 10}
fields[#fields + 1] = {row = 3, col = 2, min = 0, max = 100, vals = {5}, default = 40, mult = 10, step = 10}

--  expo
fields[#fields + 1] = {row = 1, col = 3, min = 0, max = 100, vals = {2}, decimals = 2, scale = 100, default = 0}
fields[#fields + 1] = {row = 2, col = 3, min = 0, max = 100, vals = {14}, decimals = 2, scale = 100, default = 0}
fields[#fields + 1] = {row = 3, col = 3, min = 0, max = 100, vals = {11}, decimals = 2, scale = 100, default = 0}


return {rTableName = rTableName, rows = rows, cols = cols, fields = fields}
