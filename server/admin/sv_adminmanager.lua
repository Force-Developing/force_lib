CreateThread(function()
    local function GetPlayerIdentifierId(id, idType)
        for i = 0, GetNumPlayerIdentifiers(id) do
            if GetPlayerIdentifier(id, i) ~= nil then
                if string.match(GetPlayerIdentifier(id, i), idType) then
                    return GetPlayerIdentifier(id, i):sub(#idType + 2)
                end
            end
        end
    end

    local function GetAllPlayerIdentifiers(id)
        local identifiers = {}

        for i = 0, GetNumPlayerIdentifiers(id) do
            if GetPlayerIdentifier(id, i) ~= nil then
                table.insert(identifiers, GetPlayerIdentifier(id, i))
            end
        end

        return identifiers
    end

    lib.FrameworkBased:CreateCallback('force_lib:admin:CheckAdmin', function(source, cb, id)
        local adminsTable = Config.AdminManager.Admins
        for _,identifiers in pairs(GetAllPlayerIdentifiers(id)) do
            for _,admins in pairs(adminsTable) do
                if admins == identifiers then
                    lib.Funcs:DebugPrint("^1Admin Manager^0: Found "..id.." in the admin table!")
                    return cb(true)
                end
            end
        end

        local discordRoles = {}
        for _,admins in pairs(adminsTable) do
            if string.match(admins, "role") then
                table.insert(discordRoles, admins:sub(6))
            end
        end
        if #discordRoles > 0 then
            local discordId = GetPlayerIdentifierId(id, 'discord')
            if discordId ~= nil then
                PerformHttpRequest("https://discord.com/api/v8/guilds/"..Config.Discord.ServerGuild.."/members/"..discordId, function(code, data, headers)
                    if code == 200 or code == "200" then
                        for _,roles in pairs(json.decode(data).roles) do
                            for _,discordRoles in pairs(discordRoles) do
                                if tonumber(roles) == tonumber(discordRoles) then
                                    lib.Funcs:DebugPrint("^1Admin Manager^0: Found "..id.." in the discord roles table!")
                                    return cb(true)
                                end
                            end
                        end
                    else
                        lib.Funcs:DebugPrint("^1Admin Manager^0: Failed to get discord roles for "..id.."!")
                        return cb(false)
                    end
                end, "GET", "", {
                    ['Content-Type'] = 'application/json',
                    ["Authorization"] = "Bot " .. Config.Discord.ServerToken
                })
            else
                lib.Funcs:DebugPrint("^1Admin Manager^0: Failed to get discord id for "..id.."!")
                return cb(false)
            end
        end

        if #discordRoles > 0 then -- Saftey for the slow ass httpRequest. Couldn't use promise unfortunetly :(
            Wait(500 * #discordRoles)
        end
        return cb(false)
    end)
end)