-- [[ Client -> server bridge. Everything arriving here is untrusted client input. ]]

local CLIENT_LOG_LIMIT = 5          -- max client-originated logs per player...
local CLIENT_LOG_WINDOW_MS = 60000  -- ...per this window
local MAX_HEADER_LENGTH = 256
local MAX_MESSAGE_LENGTH = 1500

local clientLogHistory = {}

-- Hosts a client-supplied webhook may point at. Matched exactly, so userinfo ("discord.com@evil.tld"), ports and
-- look-alike hosts are rejected.
local DISCORD_HOSTS = {
    ['discord.com'] = true,
    ['discordapp.com'] = true,
    ['ptb.discord.com'] = true,
    ['canary.discord.com'] = true,
}

local function isDiscordWebhook(url)
    if type(url) ~= 'string' or #url > 256 then return false end
    local host, path = url:match('^https://([^/]+)(/.*)$')
    if not host or not DISCORD_HOSTS[host] then return false end
    return path:match('^/api/webhooks/%d+/[%w_%-]+$') ~= nil
end

-- Optional server convar force_lib:webhookAllowlist = "url1,url2". When set, a client may only log to those exact
-- webhooks. Server-side SendDiscordLog calls are not affected.
local function isAllowedClientWebhook(url)
    if not isDiscordWebhook(url) then return false end
    local list = GetConvar('force_lib:webhookAllowlist', '')
    if list:match('^%s*$') then return true end
    for entry in list:gmatch('[^,]+') do
        if entry:match('^%s*(.-)%s*$') == url then return true end
    end
    return false
end

local function isRateLimited(src)
    local now = GetGameTimer()
    local history = clientLogHistory[src] or {}
    local recent = {}

    for i = 1, #history do
        if now - history[i] < CLIENT_LOG_WINDOW_MS then
            recent[#recent + 1] = history[i]
        end
    end

    if #recent >= CLIENT_LOG_LIMIT then
        clientLogHistory[src] = recent
        return true
    end

    recent[#recent + 1] = now
    clientLogHistory[src] = recent
    return false
end

-- Only these event names are accepted from clients. Anything else is dropped.
local clientEvents = {
    SendDiscordLog = function(src, data)
        if Config.Discord.Logs.AllowClientLogs == false then return end
        if isRateLimited(src) then
            return lib.Funcs:DebugPrint(("Dropped client log from %s (rate limited)"):format(src))
        end

        local header = tostring(data.header or ''):sub(1, MAX_HEADER_LENGTH)
        local message = tostring(data.message or ''):sub(1, MAX_MESSAGE_LENGTH)
        -- Never let the client pick an arbitrary URL for the server to POST to.
        -- Anything else falls back to the default webhook (force_lib:discordWebhook).
        local webHook = isAllowedClientWebhook(data.webHook) and data.webHook or nil

        -- The real sender's identifiers are always appended, so client logs can't impersonate others.
        lib.Funcs:SendDiscordLog(webHook, '[Client] ' .. header, message, src)
    end,
}

RegisterNetEvent("force_lib:eventHandler", function(event, data)
    local src = source
    if type(event) ~= 'string' or type(data) ~= 'table' then return end
    if not lib.Ready then return end

    local handler = clientEvents[event]
    if handler then
        handler(src, data)
    end
end)

-- [[ Client callbacks: keyed per player so one client can't answer (or overwrite) another player's callback. ]]
-- [src] = { [requestId] = { name, cb } }
lib.ClientCallbacks = {}
lib.ClientCallbackTimeoutMs = math.max(1000, GetConvarInt('force_lib:clientCallbackTimeout', 120000))

local lastClientCallbackId = 0
function lib.NextClientCallbackId()
    lastClientCallbackId = lastClientCallbackId + 1
    return lastClientCallbackId
end

function lib.ClientCallbackWarning(src, name, reason)
    print(('^3[force_lib] WARNING: client callback \'%s\' for player %s dropped: %s^0'):format(tostring(name), tostring(src), reason))
end

-- The callback belongs to another resource: an error in it must not break force_lib's handler.
function lib.CallClientCallback(cb, ...)
    local ok, err = pcall(cb, ...)
    if not ok then print(('^1[force_lib] client callback handler failed: %s^0'):format(tostring(err))) end
end

RegisterNetEvent('force_lib:Server:TriggerClientCallback', function(name, requestId, ...)
    local src = source
    local pending = lib.ClientCallbacks[src]
    if not pending or type(name) ~= 'string' or type(requestId) ~= 'number' then return end

    local entry = pending[requestId]
    if entry and entry.name == name then
        pending[requestId] = nil
        lib.CallClientCallback(entry.cb, ...)
    end
end)

-- The client has no callback registered under that name (v2.1 never answered these).
RegisterNetEvent('force_lib:Server:ClientCallbackMissing', function(name, requestId)
    local src = source
    local pending = lib.ClientCallbacks[src]
    if not pending or type(requestId) ~= 'number' then return end
    local entry = pending[requestId]
    if entry and entry.name == name then
        pending[requestId] = nil
        lib.ClientCallbackWarning(src, name, 'not registered on the client')
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    clientLogHistory[src] = nil
    local pending = lib.ClientCallbacks[src]
    lib.ClientCallbacks[src] = nil
    local count = 0
    for _ in pairs(pending or {}) do count = count + 1 end
    if count > 0 then lib.ClientCallbackWarning(src, ('%d pending'):format(count), 'the player left') end
end)
