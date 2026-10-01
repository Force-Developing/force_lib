-- [[ Client -> server bridge. Everything arriving here is untrusted client input. ]]

local CLIENT_LOG_LIMIT = 5          -- max client-originated logs per player...
local CLIENT_LOG_WINDOW_MS = 60000  -- ...per this window
local MAX_HEADER_LENGTH = 256
local MAX_MESSAGE_LENGTH = 1500

local clientLogHistory = {}

local function isDiscordWebhook(url)
    if type(url) ~= 'string' then return false end
    return url:match('^https://discord%.com/api/webhooks/%d+/[%w_%-]+$') ~= nil
        or url:match('^https://discordapp%.com/api/webhooks/%d+/[%w_%-]+$') ~= nil
        or url:match('^https://ptb%.discord%.com/api/webhooks/%d+/[%w_%-]+$') ~= nil
        or url:match('^https://canary%.discord%.com/api/webhooks/%d+/[%w_%-]+$') ~= nil
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
        local webHook = isDiscordWebhook(data.webHook) and data.webHook or nil

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
lib.ClientCallbacks = {}

RegisterNetEvent('force_lib:Server:TriggerClientCallback', function(name, ...)
    local src = source
    local pending = lib.ClientCallbacks[src]
    if not pending or type(name) ~= 'string' then return end

    local cb = pending[name]
    if cb then
        pending[name] = nil
        cb(...)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    clientLogHistory[src] = nil
    lib.ClientCallbacks[src] = nil
end)
