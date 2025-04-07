local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = bfsuite.i18n.get("app.modules.rates.raceflight"),
        labels = {
        },
        rows = {
            bfsuite.i18n.get("app.modules.rates.roll"),
            bfsuite.i18n.get("app.modules.rates.pitch"),
            bfsuite.i18n.get("app.modules.rates.yaw"),
        },
        cols = {
            bfsuite.i18n.get("app.modules.rates.rc_rate"),
            bfsuite.i18n.get("app.modules.rates.acroplus"),
            bfsuite.i18n.get("app.modules.rates.expo")
        },
        fields = {
            -- rc rate
            {row = 1, col = 1, min = 0, max = 100, default = 37, mult = 10, step = 10, mspapi = 1, apikey = "rcRates_1"},
            {row = 2, col = 1, min = 0, max = 100, default = 37, mult = 10, step = 10, mspapi = 1, apikey = "rcRates_2"},
            {row = 3, col = 1, min = 0, max = 100, default = 37, mult = 10, step = 10, mspapi = 1, apikey = "rcRates_3"},

            -- acro+
            {row = 1, col = 2, min = 0, max = 255, default = 80, mspapi = 1, apikey = "rates_1"},
            {row = 2, col = 2, min = 0, max = 255, default = 80, mspapi = 1, apikey = "rates_2"},
            {row = 3, col = 2, min = 0, max = 255, default = 80, mspapi = 1, apikey = "rates_3"},

            -- expo
            {row = 1, col = 3, min = 0, max = 100, default = 50, mspapi = 1, apikey = "rcExpo_1"},
            {row = 2, col = 3, min = 0, max = 100, default = 50, mspapi = 1, apikey = "rcExpo_2"},
            {row = 3, col = 3, min = 0, max = 100, default = 50, mspapi = 1, apikey = "rcExpo_3"},

        }
    }                 
}


return mspapi