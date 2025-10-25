 local bfsuite = require("bfsuite")
local activateWakeup = false
local extraMsgOnSave = nil
local resetRates = false
local doFullReload = false

if bfsuite.session.activeRateTable == nil then 
    bfsuite.session.activeRateTable = bfsuite.preferences.defaultRateProfile 
end

local apidata = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        labels = {
        },
        fields = {
            {t = "@i18n(app.modules.rates_advanced.rates_type)@",        apidata = 1, apikey = "rates_type", type = 1, ratetype = 1, postEdit = function(self) self.flagRateChange(self, true) end},
            {t = "@i18n(app.modules.rates_advanced.throttle_mid)@",      apidata = 1, apikey = "thrMid"},
            {t = "@i18n(app.modules.rates_advanced.throttle_expo)@",     apidata = 1, apikey = "thrExpo"},
            {t = "@i18n(app.modules.rates_advanced.throttle_limit_type)@",     apidata = 1, apikey = "throttle_limit_type", type=1},
            {t = "@i18n(app.modules.rates_advanced.throttle_limit_percentage)@",     apidata = 1, apikey = "throttle_limit_percent"},
        }
    }                 
}

local function preSave(self)
    if resetRates == true then
        bfsuite.utils.log("Resetting rates to defaults","info")

        -- selected id
        local table_id = bfsuite.app.Page.fields[1].value

        -- load the respective rate table
        local tables = {}
        tables[0] = "app/modules/rates/ratetables/betaflight.lua"
        tables[1] = "app/modules/rates/ratetables/raceflight.lua"
        tables[2] = "app/modules/rates/ratetables/kiss.lua"
        tables[3] = "app/modules/rates/ratetables/actual.lua"
        tables[4] = "app/modules/rates/ratetables/quick.lua"
        
        local mytable = assert(loadfile(tables[table_id]))()

        bfsuite.utils.log("Using defaults from table " .. tables[table_id], "info")

        -- pull all the values to the fields table as not created because not rendered!
        for _, y in pairs(mytable.formdata.fields) do
            if y.default then
                local found = false
        

                -- Check if an entry with the same apikey exists
                for i, v in ipairs(bfsuite.app.Page.fields) do
                    if v.apikey == y.apikey then
                        -- Update existing entry
                        bfsuite.app.Page.fields[i] = y
                        found = true
                        break
                    end
                end
        
                -- If no match was found, insert as a new entry and set value to default
                if not found then
                    table.insert(bfsuite.app.Page.fields, y)
                end
            end
        end

        -- save all the values
        for i,v in ipairs(bfsuite.app.Page.fields) do

                if v.apikey == "rates_type" then
                    v.value = table_id
                else 

                    local default = v.default or 0
                    default = default * bfsuite.app.utils.decimalInc(v.decimals)
                    if v.mult ~= nil then default = math.floor(default * (v.mult)) end
                    if v.scale ~= nil then default = math.floor(default / v.scale) end
                    
                    bfsuite.utils.log("Saving default value for " .. v.apikey .. " as " .. default, "debug")
                    bfsuite.app.utils.saveFieldValue(v, default)
                end    
        end    
            
    end
 
end    

local function postLoad(self)

    local v = apidata.values[apidata.api[1]].rates_type
    
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

-- enable and disable fields if rate type changes
local function flagRateChange(self)

    if math.floor(bfsuite.app.Page.fields[1].value) == math.floor(bfsuite.session.activeRateTable) then
        self.extraMsgOnSave = nil
        bfsuite.app.ui.enableAllFields()
        resetRates = false
    else
        self.extraMsgOnSave = "@i18n(app.modules.rates_advanced.msg_reset_to_defaults)@"
        resetRates = true
        bfsuite.app.ui.disableAllFields()
        bfsuite.app.formFields[1]:enable(true)
    end
end

local function postEepromWrite(self)
        -- trigger full reload after writting eeprom - needed as we are changing the rate type
        if resetRates == true then
            doFullReload = true
        end
        
end

return {
    apidata = apidata,
    title = "@i18n(app.modules.rates_advanced.name)@",
    reboot = false,
    eepromWrite = true,
    refreshOnRateChange = true,
    rTableName = rTableName,
    flagRateChange = flagRateChange,
    postLoad = postLoad,
    wakeup = wakeup,
    preSave = preSave,
    postEepromWrite = postEepromWrite,
    extraMsgOnSave = extraMsgOnSave,
    API = {},
}