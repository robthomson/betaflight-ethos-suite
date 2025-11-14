local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = "KISS",
        labels = {
        },
        rows = {
            "Roll",
            "Pitch",
            "Yaw",
        },
        cols = {
            "RC Rate",
            "Rate",
            "RC Curve",
        },
        fields = {
            -- rc rate
            {row = 1, col = 1, min = 0, max = 255, default = 120, decimals = 2, scale = 100, mspapi = 1, apikey = "rcRates_1"},
            {row = 2, col = 1, min = 0, max = 255, default = 120, decimals = 2, scale = 100, mspapi = 1, apikey = "rcRates_2"},
            {row = 3, col = 1, min = 0, max = 255, default = 200, decimals = 2, scale = 100, mspapi = 1, apikey = "rcRates_3"},
            -- rate
            {row = 1, col = 2, min = 0, max = 99, default = 0, decimals = 2, scale = 100, mspapi = 1, apikey = "rates_1"},
            {row = 2, col = 2, min = 0, max = 99, default = 0, decimals = 2, scale = 100, mspapi = 1, apikey = "rates_2"},
            {row = 3, col = 2, min = 0, max = 99, default = 0, decimals = 2, scale = 100, mspapi = 1, apikey = "rates_3"},
            -- rc curve
            {row = 1, col = 3, min = 0, max = 100, decimals = 2, scale = 100, default = 0, mspapi = 1, apikey = "rcExpo_1"},
            {row = 2, col = 3, min = 0, max = 100, decimals = 2, scale = 100, default = 0, mspapi = 1, apikey = "rcExpo_2"},
            {row = 3, col = 3, min = 0, max = 100, decimals = 2, scale = 100, default = 0, mspapi = 1, apikey = "rcExpo_3"},
        }
    }                 
}


return mspapi
