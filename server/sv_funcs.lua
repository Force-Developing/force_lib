Funcs = {}

Funcs.getIdentifier = function()
    return ESX.GetPlayerFromId(source).getIdentifier() -- Change this to you're function for getting the player Identifier
end

Funcs.DebugPrint = function(text)
    if Config.Debug then
        print("^4" .. GetCurrentResourceName() .. "," .. " ^2Debug: ^3" .. text)
    end
end

exports("DrawMissionText", Funcs.getIdentifier)