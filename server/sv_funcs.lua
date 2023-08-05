Funcs = {}

Funcs.GetPlayer = function(id)
    if Config.ESX then
        return ESX.GetPlayerFromId(id)
    elseif Config.QBCORE then
        return QBCore.Functions.GetPlayer(id)
    end
end

Funcs.AddInventoryItem = function(id, item, count)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.addInventoryItem({
            item = item,
            count = count
        })
    elseif Config.QBCORE then
        player.Functions.AddItem(item, count)
    end
end

Funcs.ShowNotification = function(id, text)
    TriggerClientEvent("esx:showNotification", id, text)
end

Funcs.GiveMoney = function(id, amount)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.addMoney(amount)
    elseif Config.QBCORE then
        player.AddMoney("cash", amount)
    end
end

Funcs.RemoveMoney = function(id, amount)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.removeMoney(amount)
    elseif Config.QBCORE then
        player.Functions.RemoveMoney(amount)
    end
end

Funcs.RemoveInventoryItem = function(id, item, count)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.removeInventoryItem(item, count)
    elseif Config.QBCORE then
        player.Functions.RemoveItem(item, count)
    end
end

Funcs.GetIdentifier = function(id)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        return player.getIdentifier()
    elseif Config.QBCORE then
        return player.PlayerData.citizenid
    end
end

Funcs.DebugPrint = function(text)
    if Config.Debug then
        print("^4" .. GetCurrentResourceName() .. "," .. " ^2Debug: ^3" .. text)
    end
end

Funcs.CreateCallback = function(name, passed)
    CreateThread(function()
        while (framework == nil) do Wait(100) end

        if Config.QBCORE then
            QBCore.Functions.CreateCallback(name, passed)
        elseif Config.ESX then
            ESX.RegisterServerCallback(name, passed)
        end
    end)
end

Funcs.FetchSQLInfo = function(typ, data)
    if typ == "Columns" then
        if data == "identifier" then
            return Config.SQL.Columns.identifier
        elseif data == "owner" then
            return Config.SQL.Columns.owner
        elseif data == "vehicleinfo" then
            return Config.SQL.Columns.vehicleinfo
        elseif data == "garage" then
            return Config.SQL.Columns.garage
        elseif data == "plate" then
            return Config.SQL.Columns.plate
        end
    elseif typ == "Tables" then
        if data == "character" then
            return Config.SQL.Tables.character
        elseif data == "vehicles" then
            return Config.SQL.Tables.vehicles
        end
    end
end

function Fetch()
    return Funcs
end

exports("Fetch", Fetch)