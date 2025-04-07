local activateWakeup = false

local mspapi = {
    api = {
        [1] = 'PID',
        [2] = 'PID_ADVANCED'
    },
    formdata = {
        labels = {
        },
        rows = {
            bfsuite.i18n.get("app.modules.pids.roll"),
            bfsuite.i18n.get("app.modules.pids.pitch"),
            bfsuite.i18n.get("app.modules.pids.yaw")
        },
        cols = {
            bfsuite.i18n.get("app.modules.pids.p"),
            bfsuite.i18n.get("app.modules.pids.i"),
            bfsuite.i18n.get("app.modules.pids.dmax"),
            bfsuite.i18n.get("app.modules.pids.d"),
            bfsuite.i18n.get("app.modules.pids.f"),
        },
        fields = {
            -- P
            {row = 1, col = 1, mspapi = 1, apikey = "pid_0_P"},
            {row = 2, col = 1, mspapi = 1, apikey = "pid_1_P"},
            {row = 3, col = 1, mspapi = 1, apikey = "pid_2_P"},

            {row = 1, col = 2, mspapi = 1, apikey = "pid_0_I"},
            {row = 2, col = 2, mspapi = 1, apikey = "pid_1_I"},
            {row = 3, col = 2, mspapi = 1, apikey = "pid_2_I"},

            {row = 1, col = 3, mspapi = 1, apikey = "d_max_roll"},
            {row = 2, col = 3, mspapi = 1, apikey = "d_max_pitch"},
            {row = 3, col = 3, mspapi = 1, apikey = "d_max_yaw"},

            {row = 1, col = 4, mspapi = 1, apikey = "pid_0_D"},
            {row = 2, col = 4, mspapi = 1, apikey = "pid_1_D"},
            {row = 3, col = 4, mspapi = 1, apikey = "pid_2_D"},
            
            {row = 1, col = 5, mspapi = 2, apikey = "pid_roll_F"},
            {row = 2, col = 5, mspapi = 2, apikey = "pid_pitch_F"},
            {row = 3, col = 5, mspapi = 2, apikey = "pid_yaw_F"},
        }
    }                 
}


local function postLoad(self)
    bfsuite.app.triggers.closeProgressLoader = true
    activateWakeup = true
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
        numCols = 5
    end
    local screenWidth = bfsuite.session.lcdWidth - 10
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


    bfsuite.utils.log("Merging form data from mspapi","debug")
    bfsuite.app.Page.fields = bfsuite.app.Page.mspapi.formdata.fields
    bfsuite.app.Page.labels = bfsuite.app.Page.mspapi.formdata.labels
    bfsuite.app.Page.rows = bfsuite.app.Page.mspapi.formdata.rows
    bfsuite.app.Page.cols = bfsuite.app.Page.mspapi.formdata.cols

    local c = 1
    while loc > 0 do
        local colLabel = bfsuite.app.Page.cols[loc]

        local label_w,label_h = lcd.getTextSize(colLabel)
        pos = {x = (posX - label_w) + paddingRight/2, y = posY, w = w, h = h}
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

        bfsuite.app.formFields[i] = form.addNumberField(pidRows[f.row], pos, 0, 0, function()
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

local function wakeup()

    if activateWakeup == true and bfsuite.tasks.msp.mspQueue:isProcessed() then

        -- update active profile
        -- the check happens in postLoad          
        if bfsuite.session.activeProfile ~= nil then
            bfsuite.app.formFields['title']:value(bfsuite.app.Page.title .. " #" .. bfsuite.session.activeProfile)
        end

    end

end

return {
    mspapi = mspapi,
    title = bfsuite.i18n.get("app.modules.pids.name"),
    reboot = false,
    eepromWrite = true,
    refreshOnProfileChange = true,
    postLoad = postLoad,
    openPage = openPage,
    wakeup = wakeup,
    API = {},
    navButtons = {
        menu = true,
        save = true,
        reload = true,
        tool = false,
        help = false
    },
}
