Citizen.CreateThread(function()
    if Config.ESX then
        while ESX == nil do
            Citizen.Wait(1);

            ESX = exports["es_extended"]:getSharedObject()
            Funcs.DebugPrint("ESX is running")
        end 

        if ESX.IsPlayerLoaded() then
            ESX.PlayerData = ESX.GetPlayerData()
        end
    elseif Config.QBCORE then
        QBCore = exports["qb-core"]:GetCoreObject()
        Funcs.DebugPrint("QBCORE is running")
    end
end)