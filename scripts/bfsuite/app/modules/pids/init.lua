
 local bfsuite = require("bfsuite")
local init = {
    title = "@i18n(app.modules.pids.name)@", -- title of the page
    section = "flight_tuning", -- do not run if busy with msp
    script = "pids.lua", -- run this script
    image = "pids.png", -- image for the page
    order = 1, -- order in the section
    ethosversion = {1, 6, 2} -- disable button if ethos version is less than this
}

return init
