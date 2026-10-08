lib.Admin = {};

-- Returns whether the LOCAL player is an admin. `id` is kept for backwards compatibility but the
-- server always checks the calling player only.
local ADMIN_CHECK_TIMEOUT_MS = 15000 -- the server gives up on Discord after 10 s
local inFlight -- one request at a time: QB/ESX key callbacks by name, a second request would replace the first

-- Never waits forever: no answer (server not ready, framework restarting, network) counts as false.
function lib.Admin:CheckAdmin(id)
    if not id or not tonumber(id) then id = GetPlayerServerId(PlayerId()) end

    if not inFlight then
        local p = promise.new()
        inFlight = p
        -- resolving a settled promise is a no-op
        SetTimeout(ADMIN_CHECK_TIMEOUT_MS, function() p:resolve(false) end)
        CreateThread(function()
            local ok, res = pcall(lib.TriggerCallbackTimeout, 'force_lib:admin:CheckAdmin', ADMIN_CHECK_TIMEOUT_MS, id)
            p:resolve(ok and res == true)
        end)
        p:next(function() if inFlight == p then inFlight = nil end end)
    end

    return Citizen.Await(inFlight) == true
end

if Config.AdminManager.Enabled then
    -- The F in the end of the command is for Force, so it doesn't conflict with other resources.
    -- Checked on use (the server caches the answer), so a check that failed at startup doesn't lock admins out.
    RegisterCommand('clearobjectsF', function(source, args)
        if lib.Admin:CheckAdmin(nil) then
            lib.Streaming:ClearObjects(tonumber(args[1]))
        end
    end, false)

    RegisterCommand('clearentitiesF', function(source, args)
        if lib.Admin:CheckAdmin(nil) then
            lib.Streaming:ClearEntities(tonumber(args[1]))
        end
    end, false)
end