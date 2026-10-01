local CACHE_TTL_MS = 60000         -- how long an admin result is reused (avoids Discord API rate limits)
local HTTP_TIMEOUT_MS = 10000      -- give up on Discord after this long

local cache = {}   -- [src] = { value = bool, expires = ms }
local pending = {} -- [src] = { cb, cb, ... } while a lookup is in flight

local function getIdentifiers(src)
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier then identifiers[#identifiers + 1] = identifier end
    end
    return identifiers
end

local function getIdentifierValue(src, idType)
    local prefix = idType .. ':'
    for _, identifier in ipairs(getIdentifiers(src)) do
        if identifier:sub(1, #prefix) == prefix then
            return identifier:sub(#prefix + 1)
        end
    end
end

local function checkDiscordRoles(src, roleSet, done)
    local discordId = getIdentifierValue(src, 'discord')
    if not discordId then
        lib.Funcs:DebugPrint("^1Admin Manager^0: No discord identifier for " .. src)
        return done(false, true)
    end

    local token, guild = Config.Discord.ServerToken or '', Config.Discord.ServerGuild or ''
    if token == '' or guild == '' then
        lib.Funcs:DebugPrint("^1Admin Manager^0: role: admins configured but Discord token (force_lib:discordToken / config.server.lua) or Config.Discord.ServerGuild is missing")
        return done(false, true)
    end

    PerformHttpRequest(("https://discord.com/api/v10/guilds/%s/members/%s"):format(guild, discordId), function(code, data)
        if tonumber(code) ~= 200 or not data then
            lib.Funcs:DebugPrint(("^1Admin Manager^0: Failed to get discord roles for %s (HTTP %s)"):format(src, tostring(code)))
            -- 404 = not a guild member: a definitive answer. Anything else (rate limit, outage) is not cached.
            return done(false, tonumber(code) == 404)
        end

        local ok, member = pcall(json.decode, data)
        if ok and type(member) == 'table' and type(member.roles) == 'table' then
            for _, role in ipairs(member.roles) do
                if roleSet[tostring(role)] then
                    lib.Funcs:DebugPrint("^1Admin Manager^0: Found " .. src .. " in the discord roles table!")
                    return done(true, true)
                end
            end
        end
        done(false, true)
    end, "GET", "", {
        ['Content-Type'] = 'application/json',
        ["Authorization"] = "Bot " .. token
    })
end

-- Resolves cb(isAdmin) exactly once per call. Concurrent lookups for the same player share one request.
local function isAdmin(src, cb)
    local cached = cache[src]
    if cached and cached.expires > GetGameTimer() then return cb(cached.value) end

    if pending[src] then
        table.insert(pending[src], cb)
        return
    end
    pending[src] = { cb }

    local resolved = false
    local function done(value, cacheable)
        if resolved then return end
        resolved = true
        value = value == true
        if cacheable then
            cache[src] = { value = value, expires = GetGameTimer() + CACHE_TTL_MS }
        end
        local callbacks = pending[src] or {}
        pending[src] = nil
        for _, callback in ipairs(callbacks) do callback(value) end
    end

    local admins = Config.AdminManager.Admins or {}
    local adminSet, roleSet, hasRoles = {}, {}, false
    for _, entry in pairs(admins) do
        if entry:sub(1, 5) == 'role:' then
            roleSet[entry:sub(6)] = true
            hasRoles = true
        else
            adminSet[entry] = true
        end
    end

    for _, identifier in ipairs(getIdentifiers(src)) do
        if adminSet[identifier] then
            lib.Funcs:DebugPrint("^1Admin Manager^0: Found " .. src .. " in the admin table!")
            return done(true, true)
        end
    end

    if not hasRoles then return done(false, true) end

    SetTimeout(HTTP_TIMEOUT_MS, function() done(false, false) end)
    checkDiscordRoles(src, roleSet, done)
end

AddEventHandler('playerDropped', function()
    cache[source] = nil
end)

CreateThread(function()
    while not lib.Ready do Wait(250) end -- framework detection may still be waiting for the framework

    -- Only ever checks the calling player. Any id the client sends is ignored.
    lib.FrameworkBased:CreateCallback('force_lib:admin:CheckAdmin', function(source, cb)
        local src = tonumber(source)
        if not src then return cb(false) end
        isAdmin(src, cb)
    end)
end)
