local labels = {}
local tables = {}

local activateWakeup = false

tables[0] = "app/modules/rates/ratetables/betaflight.lua"
tables[1] = "app/modules/rates/ratetables/raceflight.lua"
tables[2] = "app/modules/rates/ratetables/kiss.lua"
tables[3] = "app/modules/rates/ratetables/actual.lua"
tables[4] = "app/modules/rates/ratetables/quick.lua"

if bfsuite.session.activeRateTable == nil then 
    bfsuite.session.activeRateTable = bfsuite.preferences.defaultRateProfile 
end


bfsuite.utils.log("Loading Rate Table: " .. tables[bfsuite.session.activeRateTable],"debug")
local mspapi = assert(loadfile(tables[bfsuite.session.activeRateTable]))()
local mytable = mspapi.formdata



local function postLoad(self)

    local v = mspapi.values[mspapi.api[1]].rates_type
    
    bfsuite.utils.log("Active Rate Table: " .. bfsuite.session.activeRateTable,"info")

    if v ~= bfsuite.session.activeRateTable then
        bfsuite.utils.log("Switching Rate Table: " .. v,"info")
        bfsuite.app.triggers.reloadFull = true
        bfsuite.session.activeRateTable = v           
        return
    end 

    bfsuite.app.triggers.closeProgressLoader = true
    activateWakeup = true

end

function rightAlignText(width, text)
    local textWidth, _ = lcd.getTextSize(text)  -- Get the text width
    local padding = width - textWidth  -- Calculate how much padding is needed
    
    if padding > 0 then
        return string.rep(" ", math.floor(padding / lcd.getTextSize(" "))) .. text
    else
        return text  -- No padding needed if text is already wider than width
    end
end

local function openPage(idx, title, script)

    bfsuite.app.Page = assert(loadfile("app/modules/" .. script))()

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script
    bfsuite.session.lastPage = script

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages

    longPage = false

    form.clear()

    bfsuite.app.ui.fieldHeader(title)

    bfsuite.utils.log("Merging form data from mspapi","debug")
    bfsuite.app.Page.fields = bfsuite.app.Page.mspapi.formdata.fields
    bfsuite.app.Page.labels = bfsuite.app.Page.mspapi.formdata.labels
    bfsuite.app.Page.rows = bfsuite.app.Page.mspapi.formdata.rows
    bfsuite.app.Page.cols = bfsuite.app.Page.mspapi.formdata.cols

    local numCols
    if bfsuite.app.Page.cols ~= nil then
        numCols = #bfsuite.app.Page.cols
    else
        numCols = 3
    end

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

    --line = form.addLine(mspapi.formdata.name)
    line = form.addLine("")
    pos = {x = 0, y = paddingTop, w = 200, h = h}
    bfsuite.app.formFields['col_0'] = form.addStaticText(line, pos, mspapi.formdata.name)

    local loc = numCols
    local posX = screenWidth - paddingRight
    local posY = paddingTop

    bfsuite.session.colWidth = w - paddingRight

    local c = 1
    while loc > 0 do
        local colLabel = bfsuite.app.Page.cols[loc]

        positions[loc] = posX - w
        positions_r[c] = posX - w

        lcd.font(FONT_STD)
        --local tsizeW, tsizeH = lcd.getTextSize(colLabel)
        colLabel = rightAlignText(bfsuite.session.colWidth, colLabel)

        local posTxt = positions_r[c] + paddingRight 

        pos = {x = posTxt, y = posY, w = w, h = h}
        bfsuite.app.formFields['col_'..tostring(c)] = form.addStaticText(line, pos, colLabel)

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

            minValue = f.min * bfsuite.app.utils.decimalInc(f.decimals)
            maxValue = f.max * bfsuite.app.utils.decimalInc(f.decimals)
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
                if bfsuite.session.activeRateProfile == 0 then
                    value = 0
                else
                    value = bfsuite.app.utils.getFieldValue(bfsuite.app.Page.fields[i])
                end
                return value
            end, function(value)
                f.value = bfsuite.app.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
            end)
            if f.default ~= nil then
                local default = f.default * bfsuite.app.utils.decimalInc(f.decimals)
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
            if f.disable == true then 
                bfsuite.app.formFields[i]:enable(false) 
            end  
        end
    end

end

local function wakeup()

    if activateWakeup == true and bfsuite.tasks.msp.mspQueue:isProcessed() then       
        if bfsuite.session.activeRateProfile ~= nil then
            if bfsuite.app.formFields['title'] then
                bfsuite.app.formFields['title']:value(bfsuite.app.Page.title .. " #" .. bfsuite.session.activeRateProfile)
            end
        end 
    end
end

local function onHelpMenu()

    local helpPath = "app/modules/rates/help.lua"
    local help = assert(loadfile(helpPath))()

    bfsuite.app.ui.openPageHelp(help.help["table"][bfsuite.session.activeRateTable], "rates")


end    

return {
    mspapi = mspapi,
    title = bfsuite.i18n.get("app.modules.rates.name"),
    reboot = false,
    eepromWrite = true,
    refreshOnRateChange = true,
    rows = mytable.rows,
    cols = mytable.cols,
    flagRateChange = flagRateChange,
    postLoad = postLoad,
    openPage = openPage,
    wakeup = wakeup,
    onHelpMenu = onHelpMenu,
    API = {},
}
