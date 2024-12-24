local labels = {}
local tables = {}

local activateWakeup = false
local currentProfileChecked = false

tables[0] = "app/pages/ratetables/betaflight.lua"
tables[1] = "app/pages/ratetables/raceflight.lua"
tables[2] = "app/pages/ratetables/kiss.lua"
tables[3] = "app/pages/ratetables/actual.lua"
tables[4] = "app/pages/ratetables/quick.lua"

if bfsuite.rateProfile == nil then bfsuite.rateProfile = bfsuite.config.defaultRateProfile end


local mytable = assert(loadfile(tables[bfsuite.rateProfile]))()

local fields = mytable.fields

fields[10] = {t = "Rates Type", hidden = true, ratetype = 0, min = 0, max = 4, vals = {23}}

local function postLoad(self)
    -- if the activeRateProfile is not what we are displaying
    -- then we need to trigger a reload of the page
    local v = bfsuite.app.Page.values[23]
    if v ~= nil then bfsuite.activeRateProfile = math.floor(v) end

  
    if bfsuite.activeRateProfile ~= nil then
        if bfsuite.activeRateProfile ~= bfsuite.rateProfile then
            bfsuite.rateProfile = bfsuite.activeRateProfile
            bfsuite.app.triggers.reloadFull = true
            return
        end
    end
    
   
  
    bfsuite.app.triggers.isReady = true

    activateWakeup = true

end

local function flagRateChange(self)
    bfsuite.app.triggers.resetRates = true
end

local function openPage(idx, title, script)

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

    local numCols = #bfsuite.app.Page.cols

    -- we dont use the global due to scrollers
    local screenWidth, screenHeight = bfsuite.app.getWindowSize()

    local padding = 10
    local paddingTop = bfsuite.app.radio.linePaddingTop
    local h = bfsuite.app.radio.navbuttonHeight
    local w = ((screenWidth * 70 / 100) / numCols)
    local paddingRight = 10
    local positions = {}
    local positions_r = {}
    local pos

    line = form.addLine(bfsuite.app.Page.rTableName)

    local loc = numCols
    local posX = screenWidth - paddingRight
    local posY = paddingTop

    local c = 1
    while loc > 0 do
        local colLabel = bfsuite.app.Page.cols[loc]

        positions[loc] = posX - w
        positions_r[c] = posX - w

        lcd.font(FONT_STD)
        local tsizeW, tsizeH = lcd.getTextSize(colLabel)

        local posTxt = (positions_r[c] + w) - tsizeW

        pos = {x = posTxt, y = posY, w = w, h = h}
        form.addStaticText(line, pos, colLabel)

        posX = math.floor(posX - w)

        loc = loc - 1
        c = c + 1
    end

    -- display each row
    local rateRows = {}
    for ri, rv in ipairs(bfsuite.app.Page.rows) do rateRows[ri] = form.addLine(rv) end

    for i = 1, #bfsuite.app.Page.fields do
        local f = bfsuite.app.Page.fields[i]
        local l = bfsuite.app.Page.labels
        local pageIdx = i
        local currentField = i

        if f.hidden == nil or f.hidden == false then
            posX = positions[f.col]

            pos = {x = posX + padding, y = posY, w = w - padding, h = h}



            minValue = f.min * bfsuite.utils.decimalInc(f.decimals)
            maxValue = f.max * bfsuite.utils.decimalInc(f.decimals)
            

            if f.mult ~= nil then
                minValue = minValue * f.mult
                maxValue = maxValue * f.mult
            end
            if f.scale ~= nil then
                minValue = minValue / f.scale
                maxValue = maxValue / f.scale
            end

            bfsuite.app.formFields[i] = form.addNumberField(rateRows[f.row], pos, minValue, maxValue, function()
                local value
                --if bfsuite.activeRateProfile == 0 then
                --    value = 0
                --else
                    value = bfsuite.utils.getFieldValue(bfsuite.app.Page.fields[i])
                --end
                return value
            end, function(value)
                f.value = bfsuite.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
                bfsuite.app.saveValue(i)
            end)
            if f.default ~= nil then
                local default = f.default * bfsuite.utils.decimalInc(f.decimals)
                if f.mult ~= nil then default = math.floor(default * f.mult) end
                if f.scale ~= nil then default = math.floor(default / f.scale) end
                bfsuite.app.formFields[i]:default(default)
            else
                bfsuite.app.formFields[i]:default(0)
            end
            if f.decimals ~= nil then bfsuite.app.formFields[i]:decimals(f.decimals) end
            if f.unit ~= nil then bfsuite.app.formFields[i]:suffix(f.unit) end
            if f.step ~= nil then bfsuite.app.formFields[i]:step(f.step) end
            if f.help ~= nil then
                if bfsuite.app.fieldHelpTxt[f.help]['t'] ~= nil then
                    local helpTxt = bfsuite.app.fieldHelpTxt[f.help]['t']
                    bfsuite.app.formFields[i]:help(helpTxt)
                end
            end
            if f.disable == true then bfsuite.app.formFields[i]:enable(false) end
        end
    end

end

local function wakeup()

    if activateWakeup == true and currentProfileChecked == false and bfsuite.bg.msp.mspQueue:isProcessed() then

        -- update active profile
        -- the check happens in postLoad          
        if bfsuite.config.activeProfile ~= nil then
            bfsuite.app.formFields['title']:value(bfsuite.app.Page.title .. " #" .. bfsuite.config.activeRateProfile)
            currentProfileChecked = true
        end

    end

end

return {
    read = 111, -- msp_RC_TUNING
    write = 204, -- msp_SET_RC_TUNING
    title = "Rates",
    reboot = false,
    eepromWrite = true,
    minBytes = 23,
    labels = labels,
    fields = fields,
    refreshOnRateChange = true,
    rows = mytable.rows,
    cols = mytable.cols,
    simulatorResponse = {7, 0, 67, 67, 67, 0, 50, 0, 0, 0, 0, 7, 7, 0, 0, 100, 206, 7, 206, 7, 206, 7, 3},
    rTableName = mytable.rTableName,
    flagRateChange = flagRateChange,
    postLoad = postLoad,
    openPage = openPage,
    wakeup = wakeup

}
