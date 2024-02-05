lib.Math = {}

function lib.Math:Init()
    ---@param val number
    function lib.Math:Trim(val)
        if not val or not tonumber(val) then return lib.Funcs:DebugPrint('Var: '..val..' is not a number or nil') end
        return string.gsub(val, '^%s*(.-)%s*$', '%1')
    end

    ---@param val number
    function lib.Math:GroupDigits(val)
        if not val or not tonumber(val) then return lib.Funcs:DebugPrint('Var: '..val..' is not a number or nil') end
        local left, num, right = string.match(val, '^([^%d]*%d)(%d*)(.-)$')
        return left..(num:reverse():gsub('(%d%d%d)', '%1,'):reverse())..right
    end

    ---@param val number
    ---@param decimal number
    function lib.Math:Round(val, decimal)
        if not val or not tonumber(val) then return lib.Funcs:DebugPrint('Var: '..val..' is not a number or nil') end
        if not decimal or not tonumber(decimal) then return lib.Funcs:DebugPrint('Var: '..decimal..' is not a number or nil') end
        if decimal and decimal ~= 0 then
            local mult = 10 ^ decimal
            return math.floor(val * mult + 0.5) / mult
        end
        return math.floor(val + 0.5)
    end
end