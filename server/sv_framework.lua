if Config.ESX then
    ESX = nil 
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj  
    end)
    Funcs.DebugPrint("ESX is running")
elseif Config.QBCORE then
    QBCore = exports["qb-core"]:GetCoreObject()
    Funcs.DebugPrint("QBCORE is running")
elseif Config.REVOKED then
    ESX = nil 
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj  
    end)  
    Funcs.DebugPrint("REVOKED is running")
end