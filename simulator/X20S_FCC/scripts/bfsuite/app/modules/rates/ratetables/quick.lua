local mspapi = {
    api = {
        [1] = 'RC_TUNING',
    },
    formdata = {
        name = "QUICK",
        labels = {
        },
        rows = {
            "Roll",
            "Pitch",
            "Yaw",
        },
        cols = {
            "RC Rate",
            "Max Rate",
            "Expo"
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
