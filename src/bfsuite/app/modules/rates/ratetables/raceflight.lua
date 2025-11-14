local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = "@i18n(app.modules.rates.raceflight)@",
        labels = {
        },
        rows = {
            "@i18n(app.modules.rates.roll)@",
            "@i18n(app.modules.rates.pitch)@",
            "@i18n(app.modules.rates.yaw)@",
        },
        cols = {
            "@i18n(app.modules.rates.rc_rate)@",
            "@i18n(app.modules.rates.acroplus)@",
            "@i18n(app.modules.rates.expo)@"
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