framework = nil
CreateThread(function()
    if Config.ESX then
        ESX = nil 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj  
        end)
        framework = ESX
        Funcs.DebugPrint("ESX is running")
    elseif Config.QBCORE then
        QBCore = exports["qb-core"]:GetCoreObject()
        framework = QBCore
        Funcs.DebugPrint("QBCORE is running")
    end
end)