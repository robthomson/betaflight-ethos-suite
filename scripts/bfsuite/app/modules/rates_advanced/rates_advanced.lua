
local activateWakeup = false
local extraMsgOnSave = nil
local resetRates = false
local doFullReload = false

if bfsuite.session.activeRateTable == nil then 
    bfsuite.session.activeRateTable = bfsuite.preferences.defaultRateProfile 
end

local rows
if bfsuite.session.apiVersion >= 12.08 then
    rows = {
        bfsuite.i18n.get("app.modules.rates_advanced.response_time"),
        bfsuite.i18n.get("app.modules.rates_advanced.acc_limit"),
        bfsuite.i18n.get("app.modules.rates_advanced.setpoint_boost_gain"),
        bfsuite.i18n.get("app.modules.rates_advanced.setpoint_boost_cutoff"),
        bfsuite.i18n.get("app.modules.rates_advanced.dyn_ceiling_gain"),
        bfsuite.i18n.get("app.modules.rates_advanced.dyn_deadband_gain"),
        bfsuite.i18n.get("app.modules.rates_advanced.dyn_deadband_filter"),
    }
else
    rows = {
        bfsuite.i18n.get("app.modules.rates_advanced.response_time"),
        bfsuite.i18n.get("app.modules.rates_advanced.acc_limit"),
    }
end

   
local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = bfsuite.i18n.get("app.modules.rates_advanced.dynamics"),
        labels = {
        },
        rows = rows,
        cols = {
            bfsuite.i18n.get("app.modules.rates_advanced.roll"),
            bfsuite.i18n.get("app.modules.rates_advanced.pitch"),
            bfsuite.i18n.get("app.modules.rates_advanced.yaw"),
            bfsuite.i18n.get("app.modules.rates_advanced.col")
        },
        fields = {
            -- response time
            {row = 1, col = 1, mspapi = 1, apikey = "response_time_1"},
            {row = 1, col = 2, mspapi = 1, apikey = "response_time_2"},
            {row = 1, col = 3, mspapi = 1, apikey = "response_time_3"},
            {row = 1, col = 4, mspapi = 1, apikey = "response_time_4"},

            {row = 2, col = 1, mspapi = 1, apikey = "accel_limit_1"},
            {row = 2, col = 2, mspapi = 1, apikey = "accel_limit_2"},
            {row = 2, col = 3, mspapi = 1, apikey = "accel_limit_3"},
            {row = 2, col = 4, mspapi = 1, apikey = "accel_limit_4"},

            {row = 3, col = 1, mspapi = 1, apikey = "setpoint_boost_gain_1", apiversiongte = 12.08},
            {row = 3, col = 2, mspapi = 1, apikey = "setpoint_boost_gain_2", apiversiongte = 12.08},
            {row = 3, col = 3, mspapi = 1, apikey = "setpoint_boost_gain_3", apiversiongte = 12.08},
            {row = 3, col = 4, mspapi = 1, apikey = "setpoint_boost_gain_4", apiversiongte = 12.08},
            
            {row = 4, col = 1, mspapi = 1, apikey = "setpoint_boost_cutoff_1", apiversiongte = 12.08},
            {row = 4, col = 2, mspapi = 1, apikey = "setpoint_boost_cutoff_2", apiversiongte = 12.08},
            {row = 4, col = 3, mspapi = 1, apikey = "setpoint_boost_cutoff_3", apiversiongte = 12.08},
            {row = 4, col = 4, mspapi = 1, apikey = "setpoint_boost_cutoff_4", apiversiongte = 12.08},

            {row = 5, col = 3, mspapi = 1, apikey = "yaw_dynamic_ceiling_gain", apiversiongte = 12.08},
            {row = 6, col = 3, mspapi = 1, apikey = "yaw_dynamic_deadband_gain", apiversiongte = 12.08},
            {row = 7, col = 3, mspapi = 1, apikey = "yaw_dynamic_deadband_filter", apiversiongte = 12.08},

        }
    }                 
}

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

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages
    bfsuite.app.triggers.isReady = false

    bfsuite.app.Page = assert(loadfile("app/modules/" .. script))()
    -- collectgarbage()

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script
    bfsuite.session.lastPage = script

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages

    longPage = false

    form.clear()

    bfsuite.app.ui.fieldHeader(title)
    local numCols
    if bfsuite.app.Page.cols ~= nil then
        numCols = #bfsuite.app.Page.cols
    else
        numCols = 4
    end
    local screenWidth = bfsuite.session.lcdWidth - 10
    local padding = 10
    local paddingTop = bfsuite.app.radio.linePaddingTop
    local h = bfsuite.app.radio.navbuttonHeight
    local w = ((screenWidth * 60 / 100) / numCols)
    local paddingRight = 20
    local positions = {}
    local positions_r = {}
    local pos

    line = form.addLine("")

    local loc = numCols
    local posX = screenWidth - paddingRight
    local posY = paddingTop


    bfsuite.utils.log("Merging form data from mspapi","debug")
    bfsuite.app.Page.fields = bfsuite.app.Page.mspapi.formdata.fields
    bfsuite.app.Page.labels = bfsuite.app.Page.mspapi.formdata.labels
    bfsuite.app.Page.rows = bfsuite.app.Page.mspapi.formdata.rows
    bfsuite.app.Page.cols = bfsuite.app.Page.mspapi.formdata.cols

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
    local fieldRows = {}
    for ri, rv in ipairs(bfsuite.app.Page.rows) do fieldRows[ri] = form.addLine(rv) end

    for i = 1, #bfsuite.app.Page.fields do
        local f = bfsuite.app.Page.fields[i]

        local version = bfsuite.utils.round(bfsuite.session.apiVersion,2)
        local valid = (f.apiversion    == nil or bfsuite.utils.round(f.apiversion,2)    <= version) and
        (f.apiversionlt  == nil or bfsuite.utils.round(f.apiversionlt,2)  >  version) and
        (f.apiversiongt  == nil or bfsuite.utils.round(f.apiversiongt,2)  <  version) and
        (f.apiversionlte == nil or bfsuite.utils.round(f.apiversionlte,2) >= version) and
        (f.apiversiongte == nil or bfsuite.utils.round(f.apiversiongte,2) <= version) and
        (f.enablefunction == nil or f.enablefunction())

        
        if f.row and f.col and valid then
            local l = bfsuite.app.Page.labels
            local pageIdx = i
            local currentField = i

            posX = positions[f.col]

            pos = {x = posX + padding, y = posY, w = w - padding, h = h}

            bfsuite.app.formFields[i] = form.addNumberField(fieldRows[f.row], pos, 0, 0, function()
                if bfsuite.app.Page.fields == nil or bfsuite.app.Page.fields[i] == nil then
                    ui.disableAllFields()
                    ui.disableAllNavigationFields()
                    ui.enableNavigationField('menu')
                    return nil
                end
                return bfsuite.app.utils.getFieldValue(bfsuite.app.Page.fields[i])
            end, function(value)
                if f.postEdit then f.postEdit(bfsuite.app.Page) end
                if f.onChange then f.onChange(bfsuite.app.Page) end
        
                f.value = bfsuite.app.utils.saveFieldValue(bfsuite.app.Page.fields[i], value)
            end)
        end
    end
    
end



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

local function wakeup()
    if activateWakeup and bfsuite.tasks.msp.mspQueue:isProcessed() then
        -- update active profile
        -- the check happens in postLoad          
        if bfsuite.session.activeRateProfile then
            bfsuite.app.formFields['title']:value(bfsuite.app.Page.title .. " #" .. bfsuite.session.activeRateProfile)
        end

        -- reload the page
        if doFullReload == true then
            bfsuite.utils.log("Reloading full after rate type change","info")
            bfsuite.app.triggers.reload = true
            doFullReload = false
        end    
    end
end

local function onToolMenu()
        
end



return {
    mspapi = mspapi,
    title = bfsuite.i18n.get("app.modules.rates_advanced.name"),
    reboot = false,
    openPage = openPage,
    eepromWrite = true,
    refreshOnRateChange = true,
    rTableName = rTableName,
    postLoad = postLoad,
    wakeup = wakeup,
    API = {},
    onToolMenu = onToolMenu,
    navButtons = {
        menu = true,
        save = true,
        reload = true,
        tool = false,
        help = true
    },
}
