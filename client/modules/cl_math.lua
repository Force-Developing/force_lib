lib.Math = {}

local function invalid(name, val)
    return lib.Funcs:DebugPrint(('Math:%s: %s is not a number'):format(name, tostring(val)))
end

function lib.Math:Init()
    -- Trims surrounding whitespace. Accepts text too: GetVehicleProperties trims the plate with it, and the old
    -- number-only check turned every plate with letters into nil.
    ---@param val number|string
    function lib.Math:Trim(val)
        if type(val) ~= 'string' and type(val) ~= 'number' then return invalid('Trim', val) end
        return string.gsub(val, '^%s*(.-)%s*$', '%1')
    end

    ---@param val number
    function lib.Math:GroupDigits(val)
        if not val or not tonumber(val) then return invalid('GroupDigits', val) end
        local left, num, right = string.match(val, '^([^%d]*%d)(%d*)(.-)$')
        return left..(num:reverse():gsub('(%d%d%d)', '%1,'):reverse())..right
    end

    ---@param val number
    ---@param decimal number
    function lib.Math:Round(val, decimal)
        if not val or not tonumber(val) then return invalid('Round', val) end
        if not decimal or not tonumber(decimal) then return invalid('Round', decimal) end
        if decimal and decimal ~= 0 then
            local mult = 10 ^ decimal
            return math.floor(val * mult + 0.5) / mult
        end
        return math.floor(val + 0.5)
    end
end
