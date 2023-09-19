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

Funcs.GetMoney = function(id, accountType)
    local player = Funcs.GetPlayer(id)

    if Config.ESX then
        if accountType == "cash" then
            return player.getMoney()
        elseif accountType == "bank" then
            return player.getAccount('bank').money
        end
    elseif Config.QBCORE then
        if accountType == "cash" then
            return player.Functions.GetMoney["cash"]
        elseif accountType == "bank" then
            return player.Functions.GetMoney["bank"]
        end
    end
end

Funcs.ShowNotification = function(id, text)
    if Config.ESX then
        TriggerClientEvent("esx:showNotification", id, text)
    elseif Config.QBCORE then
        TriggerClientEvent('QBCore:Notify', id, text)
    end
end

Funcs.GiveMoney = function(id, amount)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.addMoney(amount)
    elseif Config.QBCORE then
        player.Functions.AddMoney("cash", amount)
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

Funcs.RemoveAccountMoney = function(id, amount)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.removeAccountMoney('bank', amount)
    elseif Config.QBCORE then
        player.Functions.RemoveMoney(amount)
    end
end

Funcs.GiveBlackmoney = function(id, amount)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.addAccountMoney('black_money', amount)
    elseif Config.QBCORE then
        player.Functions.AddMoney("black_money", amount)
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

Funcs.GetPlayerName = function(id)
    local player = Funcs.GetPlayer(id)

    if Config.ESX then
        return player.character.firstname .. " " .. player.character.lastname
    elseif Config.QBCORE then
        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
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
        elseif data == "licensesOwner" then
            return Config.SQL.Columns.licensesOwner
        elseif data == "jobName" then
            return Config.SQL.Columns.jobName
        elseif data == "jobGradesName" then
            return Config.SQL.Columns.jobGradesName
        elseif data == "jobGradesGrade" then
            return Config.SQL.Columns.jobGradesGrade
        end
    elseif typ == "Tables" then
        if data == "character" then
            return Config.SQL.Tables.character
        elseif data == "vehicles" then
            return Config.SQL.Tables.vehicles
        elseif data == "licenses" then
            return Config.SQL.Tables.licenses
        elseif data == "jobs" then
            return Config.SQL.Tables.jobs
        elseif data == "jobGrades" then
            return Config.SQL.Tables.jobGrades
        end
    end
end

Funcs.GetPlayers = function()
    if Config.ESX then
        return ESX.GetPlayers()
    elseif Config.QBCORE then
        return QBCore.Functions.GetPlayers()
    end
end

Funcs.GetPlayerJobName = function(id, job)
    local player = Funcs.GetPlayer(id)
    local isJob = false

    if Config.ESX then
        if player.job.name == job then
            isJob = true
        end
    elseif Config.QBCORE then
        if player.PlayerData.job.name == job then
            isJob = true
        end
    end

    return isJob
end

Funcs.GetPlayerJob = function(id)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        return player.job
    elseif Config.QBCORE then
        return player.PlayerData.job
    end
end

Funcs.SetJob = function(id, job, grade)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        return player.setJob(job, grade)
    elseif Config.QBCORE then
        return player.Functions.SetJob(job, grade)
    end
end

function Fetch()
    return Funcs
end

exports("Fetch", Fetch)