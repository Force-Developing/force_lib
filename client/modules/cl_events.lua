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

RegisterNetEvent('force_lib:Client:TriggerClientCallback', function(name, ...)
    lib.Funcs:TriggerClientCallback(name, function(...)
        TriggerServerEvent('force_lib:Server:TriggerClientCallback', name, ...)
    end, ...)
end)