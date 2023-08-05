RegisterServerEvent("force_lib:eventHandler")
AddEventHandler("force_lib:eventHandler", function(func, data)
    Funcs.FunctionHandler(func, data)
end)