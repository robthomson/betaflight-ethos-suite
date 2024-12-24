local fields = {}
local rows = {}
local cols = {}


local total_bytes = 16


-- generate rows
for i=0, total_bytes - 1 do
    rows[i + 1] = tostring(i)
end

cols = {"UINT8", "INT8"}


-- uint8 fields
for i=0, total_bytes - 1 do
    fields[#fields + 1] = {col=1, row=i + 1, min = 0, max = 255, vals = { #fields + 1 } }
end

-- int8 fields
for i=0, total_bytes - 1 do
    fields[#fields + 1] = {col=2, row=i + 1, min = 0, max = 255, vals = { #fields + 1 } }
end


local function postLoad(self)
    bfsuite.app.triggers.isReady = true
end

local function openPage(idx, title, script)

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages
    bfsuite.app.triggers.isReady = false

    bfsuite.app.Page = assert(loadfile("app/pages/" .. script))()


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
        numCols = 2
    end
    local screenWidth = bfsuite.config.lcdWidth - 10
    local padding = 10
    local paddingTop = bfsuite.app.radio.linePaddingTop
    local h = bfsuite.app.radio.navbuttonHeight
    local w = ((screenWidth * 50 / 100) / numCols)
    local paddingRight = 0
    local positions = {}
    local positions_r = {}
    local pos

    line = form.addLine("Byte")

    local loc = numCols
    local posX = screenWidth - paddingRight
    local posY = paddingTop

    local c = 1
    while loc > 0 do
        local colLabel = bfsuite.app.Page.cols[loc]

        positions[loc] = posX - w + paddingRight
        positions_r[c] = posX - w + paddingRight
        posX = math.floor(posX - w)

        pos = {x = positions[loc] + padding, y = posY, w = w, h = h}
        form.addStaticText(line, pos, colLabel)

        loc = loc - 1
        c = c + 1
    end

    -- display each row
    local byteRows = {}
    for ri, rv in ipairs(bfsuite.app.Page.rows) do byteRows[ri] = form.addLine(rv) end

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

        bfsuite.app.formFields[i] = form.addNumberField(byteRows[f.row], pos, minValue, maxValue, function()
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

    bfsuite.app.triggers.closeProgressLoader = true

end



return {
    read =  158, -- MSP_EXPERIMENTAL
    write = 159, -- MSP_SET_EXPERIMENTAL
    title       = "Experimental",
    navButtons = {menu = true, save = true, reload = false, help = true},
    minBytes    = 0,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,
    simulatorResponse = {},
    rows = rows,
    cols = cols,    
    openPage = openPage,
    postLoad = postLoad
}
