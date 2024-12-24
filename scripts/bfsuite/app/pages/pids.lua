local fields = {}
local rows = {}
local cols = {}

local activateWakeup = false
local currentProfileChecked = false

rows = {"Roll", "Pitch", "Yaw"}
-- cols = {"P", "I", "O", "D", "F", "B"}
-- cols = {"D", "P", "I", "F", "O", "B"}
cols = {"P", "I", "D"}

-- P
fields[1] = {help = "profilesProportional", row = 1, col = 1, min = 0, max = 1000, default = 50, vals = {1}}
fields[2] = {help = "profilesProportional", row = 2, col = 1, min = 0, max = 1000, default = 50, vals = {4}}
fields[3] = {help = "profilesProportional", row = 3, col = 1, t = "PY", min = 0, max = 1000, default = 80, vals = {7}}

-- I
fields[4] = {help = "profilesIntegral", row = 1, col = 2, min = 0, max = 1000, default = 100, vals = {2}}
fields[5] = {help = "profilesIntegral", row = 2, col = 2, min = 0, max = 1000, default = 100, vals = {5}}
fields[6] = {help = "profilesIntegral", row = 3, col = 2, min = 0, max = 1000, default = 120, vals = {8}}

-- D
fields[7] = {help = "profilesDerivative", row = 1, col = 3, min = 0, max = 1000, default = 20, vals = {3}}
fields[8] = {help = "profilesDerivative", row = 2, col = 3, min = 0, max = 1000, default = 50, vals = {6}}
fields[9] = {help = "profilesDerivative", row = 3, col = 3, min = 0, max = 1000, default = 40, vals = {9}}


local function postLoad(self)
    bfsuite.app.triggers.isReady = true
    activateWakeup = true
end

local function openPage(idx, title, script)

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages
    bfsuite.app.triggers.isReady = false

    bfsuite.app.Page = assert(loadfile("app/pages/" .. script))()
    -- collectgarbage()

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script
    bfsuite.lastPage = script

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages

    longPage = false

    form.clear()

    bfsuite.app.ui.fieldHeader(title)
    local numCols
    if bfsuite.app.Page.cols ~= nil then
        numCols = #bfsuite.app.Page.cols
    else
        numCols = 6
    end
    local screenWidth = bfsuite.config.lcdWidth - 10
    local padding = 10
    local paddingTop = bfsuite.app.radio.linePaddingTop
    local h = bfsuite.app.radio.navbuttonHeight
    local w = ((screenWidth * 70 / 100) / numCols)
    local paddingRight = 20
    local positions = {}
    local positions_r = {}
    local pos

    line = form.addLine("")

    local loc = numCols
    local posX = screenWidth - paddingRight
    local posY = paddingTop

    local c = 1
    while loc > 0 do
        local colLabel = bfsuite.app.Page.cols[loc]
        pos = {x = posX, y = posY, w = w, h = h}
        form.addStaticText(line, pos, colLabel)
        positions[loc] = posX - w + paddingRight
        positions_r[c] = posX - w + paddingRight
        posX = math.floor(posX - w)
        loc = loc - 1
        c = c + 1
    end

    -- display each row
    local pidRows = {}
    for ri, rv in ipairs(bfsuite.app.Page.rows) do pidRows[ri] = form.addLine(rv) end

    for i = 1, #bfsuite.app.Page.fields do
        local f = bfsuite.app.Page.fields[i]
        local l = bfsuite.app.Page.labels
        local pageIdx = i
        local currentField = i

        posX = positions[f.col]

        pos = {x = posX + padding, y = posY, w = w - padding, h = h}

        minValue = f.min * bfsuite.utils.decimalInc(f.decimals)
        maxValue = f.max * bfsuite.utils.decimalInc(f.decimals)
        if f.mult ~= nil then
            minValue = minValue * f.mult
            maxValue = maxValue * f.mult
        end

        bfsuite.app.formFields[i] = form.addNumberField(pidRows[f.row], pos, minValue, maxValue, function()
            local value = bfsuite.utils.getFieldValue(bfsuite.app.Page.fields[i])
            return value
        end, function(value)
            f.value = bfsuite.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
            bfsuite.app.saveValue(i)
        end)
        if f.default ~= nil then
            local default = f.default * bfsuite.utils.decimalInc(f.decimals)
            if f.mult ~= nil then default = default * f.mult end
            bfsuite.app.formFields[i]:default(default)
        else
            bfsuite.app.formFields[i]:default(0)
        end
        if f.decimals ~= nil then bfsuite.app.formFields[i]:decimals(f.decimals) end
        if f.unit ~= nil then bfsuite.app.formFields[i]:suffix(f.unit) end
        if f.help ~= nil then
            if bfsuite.app.fieldHelpTxt[f.help]['t'] ~= nil then
                local helpTxt = bfsuite.app.fieldHelpTxt[f.help]['t']
                bfsuite.app.formFields[i]:help(helpTxt)
            end
        end
    end

end

local function wakeup()

    if activateWakeup == true and currentProfileChecked == false and bfsuite.bg.msp.mspQueue:isProcessed() then

        -- update active profile
        -- the check happens in postLoad          
        if bfsuite.config.activeProfile ~= nil then
            bfsuite.app.formFields['title']:value(bfsuite.app.Page.title .. " #" .. bfsuite.config.activeProfile)
            currentProfileChecked = true
        end

    end

end

return {
    read = 112, -- msp_PID_TUNING
    write = 202, -- msp_SET_PID_TUNING
    title = "PIDs",
    reboot = false,
    eepromWrite = true,
    refreshOnProfileChange = true,
    minBytes = 9,
    simulatorResponse = {45, 80, 40, 47, 84, 46, 45, 80, 0, 50, 75, 75, 40, 0, 0},
    fields = fields,
    rows = rows,
    cols = cols,
    postLoad = postLoad,
    openPage = openPage,
    wakeup = wakeup
}
