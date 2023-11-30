RegisterServerEvent("force_lib:eventHandler")
AddEventHandler("force_lib:eventHandler", function(func, data)
    if func == "SendDiscordLog" then
        Funcs.SendDiscordLog(data.webHook, data.header, data.message)
    elseif func == "" then

    end
end)