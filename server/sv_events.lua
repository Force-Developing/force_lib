RegisterServerEvent("force_lib:eventHandler")
AddEventHandler("force_lib:eventHandler", function(event, data)
    if not (event or data) then return end -- If no event or data is passed, return
    if event == "SendDiscordLog" then
        Funcs.SendDiscordLog(data.webHook, data.header, data.message)
    elseif event == "" then

    end
end)

lib.ClientCallbacks = {}

RegisterNetEvent('force_lib:Server:TriggerClientCallback', function(name, ...)
    if lib.ClientCallbacks[name] then
        lib.ClientCallbacks[name](...)
        lib.ClientCallbacks[name] = nil
    end
end)