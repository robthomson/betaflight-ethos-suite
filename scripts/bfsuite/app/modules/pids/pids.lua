local bfsuite = require("bfsuite")
local activateWakeup = false

local apidata = {
    api = {
        [1] = 'PID',
        [2] = 'PID_ADVANCED',
    },
    formdata = {
        labels = {
        },
        rows = {
            "@i18n(app.modules.pids.roll)@",
            "@i18n(app.modules.pids.pitch)@",
            "@i18n(app.modules.pids.yaw)@"
        },
        cols = {
            "@i18n(app.modules.pids.p)@",
            "@i18n(app.modules.pids.i)@",
            "@i18n(app.modules.pids.dmax)@",
            "@i18n(app.modules.pids.d)@",
            "@i18n(app.modules.pids.f)@",
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

    bfsuite.app.lastIdx = idx
    bfsuite.app.lastTitle = title
    bfsuite.app.lastScript = script
    bfsuite.session.lastPage = script

    bfsuite.app.uiState = bfsuite.app.uiStatus.pages

    local longPage = false

    form.clear()

    bfsuite.app.ui.fieldHeader(title)
    local numCols
    if bfsuite.app.Page.apidata.formdata.cols ~= nil then
        numCols = #bfsuite.app.Page.apidata.formdata.cols
    else
        numCols = 6
    end
    local screenWidth = bfsuite.app.lcdWidth - 10
    local padding = 10
    local paddingTop = bfsuite.app.radio.linePaddingTop
    local h = bfsuite.app.radio.navbuttonHeight
    local w = ((screenWidth * 70 / 100) / numCols)
    local paddingRight = 20
    local positions = {}
    local positions_r = {}
    local pos

    local line = form.addLine("")

    local loc = numCols
    local posX = screenWidth - paddingRight
    local posY = paddingTop

    local c = 1
    while loc > 0 do
        local colLabel = bfsuite.app.Page.apidata.formdata.cols[loc]
        pos = {x = posX, y = posY, w = w, h = h}
        form.addStaticText(line, pos, colLabel)
        positions[loc] = posX - w + paddingRight
        positions_r[c] = posX - w + paddingRight
        posX = math.floor(posX - w)
        loc = loc - 1
        c = c + 1
    end

    local pidRows = {}
    for ri, rv in ipairs(bfsuite.app.Page.apidata.formdata.rows) do pidRows[ri] = form.addLine(rv) end

    for i = 1, #bfsuite.app.Page.apidata.formdata.fields do
        local f = bfsuite.app.Page.apidata.formdata.fields[i]
        local l = bfsuite.app.Page.apidata.formdata.labels
        local pageIdx = i
        local currentField = i

        posX = positions[f.col]

        pos = {x = posX + padding, y = posY, w = w - padding, h = h}

        bfsuite.app.formFields[i] = form.addNumberField(pidRows[f.row], pos, 0, 0, function()
            if bfsuite.app.Page.apidata.formdata.fields == nil or bfsuite.app.Page.apidata.formdata.fields[i] == nil then
                ui.disableAllFields()
                ui.disableAllNavigationFields()
                ui.enableNavigationField('menu')
                return nil
            end
            return bfsuite.app.utils.getFieldValue(bfsuite.app.Page.apidata.formdata.fields[i])
        end, function(value)
            if f.postEdit then f.postEdit(bfsuite.app.Page) end
            if f.onChange then f.onChange(bfsuite.app.Page) end

            f.value = bfsuite.app.utils.saveFieldValue(bfsuite.app.Page.apidata.formdata.fields[i], value)
        end)
    end

end

local function wakeup() if activateWakeup == true and bfsuite.tasks.msp.mspQueue:isProcessed() then if bfsuite.session.activeProfile ~= nil then bfsuite.app.formFields['title']:value(bfsuite.app.Page.title .. " #" .. bfsuite.session.activeProfile) end end end

return {apidata = apidata, title = "@i18n(app.modules.pids.name)@", reboot = false, eepromWrite = true, refreshOnProfileChange = true, postLoad = postLoad, openPage = openPage, wakeup = wakeup, API = {}}
