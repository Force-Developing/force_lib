AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if lib.Funcs:GetTableLength(lib.Streaming.CachedObjects) > 0 then
            for k,v in pairs(lib.Streaming.CachedObjects) do
                DeleteObject(k)
            end
        end

        if lib.Funcs:GetTableLength(lib.Streaming.CachedEntities) > 0 then
            for k,v in pairs(lib.Streaming.CachedEntities) do
                DeleteEntity(k)
            end
        end
    end
end)

lib.ClientCallbacks = {}

RegisterNetEvent('force_lib:Client:TriggerClientCallback', function(name, requestId, ...)
    -- Not registered here: answer right away (without values) so the server doesn't wait for nothing.
    if type(name) ~= 'string' or not lib.ClientCallbacks[name] then
        return TriggerServerEvent('force_lib:Server:TriggerClientCallback', name, requestId)
    end
    lib.Funcs:TriggerClientCallback(name, function(...)
        TriggerServerEvent('force_lib:Server:TriggerClientCallback', name, requestId, ...)
    end, ...)
end)