lib.Funcs = {}

function lib.Funcs:Init()
    function lib.Funcs:DebugPrint(text)
        if Config.Debug then
            print("^4" .. GetCurrentResourceName() .. "," .. " ^2Debug: ^3" .. text)
        end
    end

    function lib.Funcs:GetSQLInfo()
        return Config.SQL
    end

    function lib.Funcs:ExtractIdentifiers(src)
        local identifiers = {
            steam = "",
            ip = "",
            discord = "",
            xbl = "",
            live = ""
        }

        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local id = GetPlayerIdentifier(src, i)

            if string.find(id, "steam") then
                identifiers.steam = id
            elseif string.find(id, "ip") then
                identifiers.ip = id
            elseif string.find(id, "discord") then
                identifiers.discord = id
            elseif string.find(id, "xbl") then
                identifiers.xbl = id
            elseif string.find(id, "live") then
                identifiers.live = id
            end
        end

        return identifiers
    end

    function lib.Funcs:GetPlayerDetails(src)
        local player_id = src
        local ids = lib.Funcs:ExtractIdentifiers(player_id)
        if Config.Discord.Logs.discordID then if ids.discord ~= "" then _discordID ="\n**Discord ID:** <@" ..ids.discord:gsub("discord:", "")..">" else _discordID = "\n**Discord ID:** N/A" end else _discordID = "" end
        if Config.Discord.Logs.steamID then if ids.steam ~= "" then _steamID ="\n**Steam ID:** " ..ids.steam.."" else _steamID = "\n**Steam ID:** N/A" end else _steamID = "" end
        if Config.Discord.Logs.steamURL then  if ids.steam ~= "" then _steamURL ="\nhttps://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""),16).."" else _steamURL = "\n**Steam URL:** N/A" end else _steamURL = "" end
        if Config.Discord.Logs.IP then if ids.ip ~= "" then _ip ="\n**IP:** " ..ids.ip else _ip = "\n**IP :** N/A" end else _ip = "" end
        return _discordID..''.._steamID..''.._steamURL..''.._ip
    end

    function lib.Funcs:SendDiscordLog(webHook, header, message, target, color)
        if not webHook then
            webHook = Config.Discord.Logs.DefaultWebhook
        end
        local resourceName = GetInvokingResource()
        if not resourceName then resourceName = GetCurrentResourceName() end
        local embeds = {
            {
                type = "rich",
                color = color or Config.Discord.Logs.LogsColor,
                title = header,
                author = {
                    ["name"] = 'Force Developments - ' .. resourceName,
                    ['icon_url'] = 'https://cdn.discordapp.com/attachments/1083112303236485120/1176799520525385778/New_Project.png?ex=65702ef5&is=655db9f5&hm=2597de5b58d90a9851a115e90a598041028133fe32addbaa5405fac11d5b2206&'
                },
                description = message .. "\n " .. lib.Funcs:GetPlayerDetails(target or source),
                footer = {
                    icon_url = 'https://cdn.discordapp.com/attachments/1083112303236485120/1176799776965152831/Force_dev_logotyp.png?ex=65702f32&is=655dba32&hm=1286c75fe4cb7d38d409c42d79cdca030e41f202e0291fc9a728fecb7228c800&',
                    text = os.date("%d") .. "/" .. os.date("%m") .. "/" .. os.date("%Y") .. " - " .. os.date("%H") .. ":" .. os.date("%M")
                }
            }
        }

        PerformHttpRequest(webHook, function(err, text, headers) end, "POST", json.encode({username = "Force Lib - "..resourceName, embeds = embeds}), { ["Content-Type"] = "application/json" })
    end

    function lib.Funcs:GetFramework()
        return lib.FrameworkName
    end

    function lib.Funcs:TriggerClientCallback(name, source, cb, ...)
        lib.ClientCallbacks[name] = cb
        TriggerClientEvent('force_lib:Client:TriggerClientCallback', source, name, ...)
    end
end