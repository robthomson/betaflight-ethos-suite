local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = bfsuite.i18n.get("app.modules.rates.none"),
        labels = {
        },
        rows = {
            bfsuite.i18n.get("app.modules.rates.roll"),
            bfsuite.i18n.get("app.modules.rates.pitch"),
            bfsuite.i18n.get("app.modules.rates.yaw"),
            bfsuite.i18n.get("app.modules.rates.collective")
        },
        cols = {
            bfsuite.i18n.get("app.modules.rates.rc_rate"),
            bfsuite.i18n.get("app.modules.rates.rate"),
            bfsuite.i18n.get("app.modules.rates.expo"),
        },
        fields = {
            -- rc rate
            {disable = true, row = 1, col = 1, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcRates_1"},
            {disable = true, row = 2, col = 1, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcRates_2"},
            {disable = true, row = 3, col = 1, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcRates_3"},
            {disable = true, row = 4, col = 1, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcRates_4"},
            -- rate
            {disable = true, row = 1, col = 2, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rates_1"},
            {disable = true, row = 2, col = 2, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rates_2"},
            {disable = true, row = 3, col = 2, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rates_3"},
            {disable = true, row = 4, col = 2, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rates_4"},
            -- expo
            {disable = true, row = 1, col = 3, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcExpo_1"},
            {disable = true, row = 2, col = 3, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcExpo_2"},
            {disable = true, row = 3, col = 3, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcExpo_3"},
            {disable = true, row = 4, col = 3, min = 0, max = 0, default = 0, mspapi = 1, apikey = "rcExpo_4"}
        }
    }                 
}


return mspapi
