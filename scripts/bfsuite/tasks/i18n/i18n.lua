--[[

 * Copyright (C) Rob Thomson
 *
 *
 * License GPLv3: https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 
 * Note.  Some icons have been sourced from https://www.flaticon.com/
 * 

]] --
local arg = {...}

local i18n = {}

local locale = system.getLocale()

function i18n.wakeup()

    bfsuite.session.locale = system.getLocale()

    -- lets reload the language file
    if bfsuite.session.locale ~= locale then
        bfsuite.utils.log("i18n: Switching locale to: " .. bfsuite.session.locale, "info")
        bfsuite.i18n.load(bfsuite.session.locale)
        locale = bfsuite.session.locale

        -- step through and fire language swap events
        for i,v in pairs(bfsuite.widgets) do
            if v.i18n then
                bfsuite.utils.log("i18n: Running i18n event for widget: " .. i, "info")
                v.i18n()
            end
        end



    end

end

return i18n
