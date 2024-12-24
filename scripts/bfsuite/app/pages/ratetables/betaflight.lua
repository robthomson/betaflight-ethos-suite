local rTableName = "BETAFLIGHT"
local rows = {"Roll", "Pitch", "Yaw"}
local cols = {"RC Rate", "SuperRate", "Expo"}
local fields = {}

-- rc rate
fields[#fields + 1] = {row = 1, col = 1, min = 0, max = 255, vals = {1}, default = 180, decimals = 2, scale = 100}
fields[#fields + 1] = {row = 2, col = 1, min = 0, max = 255, vals = {13}, default = 180, decimals = 2, scale = 100}
fields[#fields + 1] = {row = 3, col = 1, min = 0, max = 255, vals = {12}, default = 180, decimals = 2, scale = 100} 

-- fc rate
fields[#fields + 1] = {row = 1, col = 2, min = 0, max = 100, vals = {3}, default = 0, decimals = 2, scale = 100} 
fields[#fields + 1] = {row = 2, col = 2, min = 0, max = 100, vals = {4}, default = 0, decimals = 2, scale = 100}
fields[#fields + 1] = {row = 3, col = 2, min = 0, max = 100, vals = {5}, default = 0, decimals = 2, scale = 100}

--  expo
fields[#fields + 1] = {row = 1, col = 3, min = 0, max = 100, vals = {2}, decimals = 2, scale = 100, default = 0, decimals = 2}
fields[#fields + 1] = {row = 2, col = 3, min = 0, max = 100, vals = {14}, decimals = 2, scale = 100, default = 0, decimals = 2}
fields[#fields + 1] = {row = 3, col = 3, min = 0, max = 100, vals = {11}, decimals = 2, scale = 100, default = 0, decimals = 2}


return {rTableName = rTableName, rows = rows, cols = cols, fields = fields}
