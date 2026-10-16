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
        local player_id = tonumber(src)
        if not player_id or player_id <= 0 or GetNumPlayerIdentifiers(player_id) == 0 then return '' end
        local ids = lib.Funcs:ExtractIdentifiers(player_id)
        local _discordID, _steamID, _steamURL, _ip
        if Config.Discord.Logs.discordID then if ids.discord ~= "" then _discordID ="\n**Discord ID:** <@" ..ids.discord:gsub("discord:", "")..">" else _discordID = "\n**Discord ID:** N/A" end else _discordID = "" end
        if Config.Discord.Logs.steamID then if ids.steam ~= "" then _steamID ="\n**Steam ID:** " ..ids.steam.."" else _steamID = "\n**Steam ID:** N/A" end else _steamID = "" end
        if Config.Discord.Logs.steamURL then  if ids.steam ~= "" then _steamURL ="\nhttps://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""),16).."" else _steamURL = "\n**Steam URL:** N/A" end else _steamURL = "" end
        if Config.Discord.Logs.IP then if ids.ip ~= "" then _ip ="\n**IP:** " ..ids.ip else _ip = "\n**IP :** N/A" end else _ip = "" end
        return _discordID..''.._steamID..''.._steamURL..''.._ip
    end

    function lib.Funcs:SendDiscordLog(webHook, header, message, target, color)
        if not webHook or webHook == '' then
            webHook = Config.Discord.Logs.DefaultWebhook
        end
        if not webHook or webHook == '' then
            return lib.Funcs:DebugPrint("SendDiscordLog: no webhook given and no default webhook set (convar force_lib:discordWebhook or config.server.lua)")
        end
        local resourceName = GetInvokingResource()
        if not resourceName then resourceName = GetCurrentResourceName() end
        local embeds = {
            {
                type = "rich",
                color = color or Config.Discord.Logs.LogsColor,
                title = tostring(header or ''):sub(1, 256),
                author = {
                    ["name"] = 'Force Developments - ' .. resourceName,
                    ['icon_url'] = 'https://cdn.discordapp.com/attachments/1083112303236485120/1176799520525385778/New_Project.png?ex=65702ef5&is=655db9f5&hm=2597de5b58d90a9851a115e90a598041028133fe32addbaa5405fac11d5b2206&'
                },
                description = (tostring(message or '') .. "\n " .. lib.Funcs:GetPlayerDetails(target or source)):sub(1, 4000),
                footer = {
                    icon_url = 'https://cdn.discordapp.com/attachments/1083112303236485120/1176799776965152831/Force_dev_logotyp.png?ex=65702f32&is=655dba32&hm=1286c75fe4cb7d38d409c42d79cdca030e41f202e0291fc9a728fecb7228c800&',
                    text = os.date("%d") .. "/" .. os.date("%m") .. "/" .. os.date("%Y") .. " - " .. os.date("%H") .. ":" .. os.date("%M")
                }
            }
        }

        PerformHttpRequest(webHook, function(status)
            -- Discord answers 204 on success; 429 = rate limited, 4xx = bad/deleted webhook. Logs are best effort.
            status = tonumber(status) or 0
            if status < 200 or status >= 300 then
                lib.Funcs:DebugPrint(("SendDiscordLog: Discord answered HTTP %d, log from %s dropped"):format(status, resourceName))
            end
        end, "POST", json.encode({username = "Force Lib - "..resourceName, embeds = embeds, allowed_mentions = {parse = {}}}), { ["Content-Type"] = "application/json" })
    end

    function lib.Funcs:GetFramework()
        ForceLibBridge.TryInit()
        return lib.FrameworkName
    end

    -- True once force_lib has loaded the framework (false again while the framework restarts).
    function lib.Funcs:IsReady()
        return ForceLibBridge.TryInit()
    end

    -- Waits until force_lib is ready, at most timeoutMs (default 30000). Call it from a thread. Returns IsReady().
    function lib.Funcs:AwaitReady(timeoutMs)
        return ForceLibBridge.AwaitReady(tonumber(timeoutMs) or 30000)
    end

    -- cb receives the client's answer, as in 2.1: it is only ever called with an answer. Every request has its own id,
    -- so concurrent calls of the same callback each get their own answer. A request nobody can answer (player
    -- missing or dropped, callback not registered on the client, no answer within force_lib:clientCallbackTimeout) is
    -- removed with a warning instead of being kept until the player leaves.
    function lib.Funcs:TriggerClientCallback(name, source, cb, ...)
        source = tonumber(source)
        if not source then return end
        if not DoesPlayerExist(tostring(source)) then
            return lib.ClientCallbackWarning(source, name, 'the player does not exist')
        end
        lib.ClientCallbacks[source] = lib.ClientCallbacks[source] or {}
        local requestId = lib.NextClientCallbackId()
        lib.ClientCallbacks[source][requestId] = { name = name, cb = cb }

        SetTimeout(lib.ClientCallbackTimeoutMs, function()
            local pending = lib.ClientCallbacks[source]
            if not pending or not pending[requestId] then return end
            pending[requestId] = nil
            lib.ClientCallbackWarning(source, name, ('no answer within %d ms'):format(lib.ClientCallbackTimeoutMs))
        end)

        TriggerClientEvent('force_lib:Client:TriggerClientCallback', source, name, requestId, ...)
    end
end