local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = bfsuite.i18n.get("app.modules.rates.quick"),
        labels = {
        },
        rows = {
            bfsuite.i18n.get("app.modules.rates.roll"),
            bfsuite.i18n.get("app.modules.rates.pitch"),
            bfsuite.i18n.get("app.modules.rates.yaw"),
        },
        cols = {
            bfsuite.i18n.get("app.modules.rates.rc_rate"),
            bfsuite.i18n.get("app.modules.rates.max_rate"),
            bfsuite.i18n.get("app.modules.rates.expo")
        },
        fields = {
            {row = 1, col = 1, min = 0, max = 2550, default = 120, decimals = 2, scale = 100, mspapi = 1, apikey = "rcRates_1"},
            {row = 2, col = 1, min = 0, max = 2550, default = 120, decimals = 2, scale = 100, mspapi = 1, apikey = "rcRates_2"},
            {row = 3, col = 1, min = 0, max = 2550, default = 200, decimals = 2, scale = 100, mspapi = 1, apikey = "rcRates_3"},

            {row = 1, col = 2, min = 0, max = 1000, default = 24, mult = 10, step = 10, mspapi = 1, apikey = "rates_1"},
            {row = 2, col = 2, min = 0, max = 1000, default = 24, mult = 10, step = 10, mspapi = 1, apikey = "rates_2"},
            {row = 3, col = 2, min = 0, max = 1000, default = 40, mult = 10, step = 10, mspapi = 1, apikey = "rates_3"},

            {row = 1, col = 3, min = 0, max = 1000, decimals = 2, scale = 100, default = 0, mspapi = 1, apikey = "rcExpo_1"},
            {row = 2, col = 3, min = 0, max = 1000, decimals = 2, scale = 100, default = 0, mspapi = 1, apikey = "rcExpo_2"},
            {row = 3, col = 3, min = 0, max = 1000, decimals = 2, scale = 100, default = 0, mspapi = 1, apikey = "rcExpo_3"},

        }
    }                 
}


return mspapi
