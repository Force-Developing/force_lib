Funcs = {}

Funcs.GetPlayer = function(id)
    if Config.ESX then
        return ESX.GetPlayerFromId(id)
    elseif Config.QBCORE then
        return QBCore.Functions.GetPlayer(id)
    end
end

Funcs.AddInventoryItem = function(id, item, count, data)
    if data == nil then
        data = {}
    end
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        player.addInventoryItem({
            item = item,
            count = count,
            data = data
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
            return player.Functions.GetMoney('cash')
        elseif accountType == "bank" then
            return player.Functions.GetMoney('bank')
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
        player.removeMoney(tonumber(amount))
    elseif Config.QBCORE then
        player.Functions.RemoveMoney("cash", amount, "Cash withdrawl")
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
        return player.socialnumber
    elseif Config.QBCORE then
        return player.PlayerData.citizenid
    end
end

Funcs.GetInventoryItem = function(id, item)
    local player = Funcs.GetPlayer(id)
    if Config.ESX then
        return player.getInventoryItem(item).count
    elseif Config.QBCORE then
        if player.Functions.GetItemByName(item) ~= nil then
            return player.Functions.GetItemByName(item).amount
        else
            return 0
        end
    end
end

-- Funcs.GetPlayerInventory = function(id)
--     local player = Funcs.GetPlayer(id)
--     if Config.ESX then
--         return player.inventory
--     elseif Config.QBCORE then
--         return QBCore.Player.LoadInventory()
--     end
-- end

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

Funcs.GetPlayerJobInfo = function(id)
    local player = Funcs.GetPlayer(id)

    if Config.ESX then
        local job = {
            job = player.job.name,
            grade = player.job.grade,
            label = player.job.label
        }
        return job
    elseif Config.QBCORE then
        local job = {
            job = player.PlayerData.job.name,
            grade = player.PlayerData.job.grade,
            label = player.PlayerData.job.label
        }
        return job
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

Funcs.SendDiscordLog = function(webHook, header, message, target)
    local embeds = {
        {
            type = "rich",
			color = Config.Logs.LogsColor,
			title = header,
			author = {
				["name"] = 'Force Developments - ' .. GetInvokingResource(),
				['icon_url'] = 'https://cdn.discordapp.com/attachments/1083112303236485120/1176799520525385778/New_Project.png?ex=65702ef5&is=655db9f5&hm=2597de5b58d90a9851a115e90a598041028133fe32addbaa5405fac11d5b2206&'
			},
			description = message .. "\n " .. Funcs.GetPlayerDetails(target or source),
			footer = {
				icon_url = 'https://cdn.discordapp.com/attachments/1083112303236485120/1176799776965152831/Force_dev_logotyp.png?ex=65702f32&is=655dba32&hm=1286c75fe4cb7d38d409c42d79cdca030e41f202e0291fc9a728fecb7228c800&',
				text = os.date("%d") .. "/" .. os.date("%m") .. "/" .. os.date("%Y") .. " - " .. os.date("%H") .. ":" .. os.date("%M")
			}
        }
	}

	PerformHttpRequest(webHook, function(err, text, headers) end, "POST", json.encode({username = "force_report", embeds = embeds}), { ["Content-Type"] = "application/json" })
end

Funcs.GetPlayerDetails = function(src)
	local player_id = src
	local ids = Funcs.ExtractIdentifiers(player_id)
	if Config.Logs.discordID then if ids.discord ~= "" then _discordID ="\n**Discord ID:** <@" ..ids.discord:gsub("discord:", "")..">" else _discordID = "\n**Discord ID:** N/A" end else _discordID = "" end
	if Config.Logs.steamID then if ids.steam ~= "" then _steamID ="\n**Steam ID:** " ..ids.steam.."" else _steamID = "\n**Steam ID:** N/A" end else _steamID = "" end
	if Config.Logs.steamURL then  if ids.steam ~= "" then _steamURL ="\nhttps://steamcommunity.com/profiles/" ..tonumber(ids.steam:gsub("steam:", ""),16).."" else _steamURL = "\n**Steam URL:** N/A" end else _steamURL = "" end
	if Config.Logs.IP then if ids.ip ~= "" then _ip ="\n**IP:** " ..ids.ip else _ip = "\n**IP :** N/A" end else _ip = "" end
	return _discordID..''.._steamID..''.._steamURL..''.._ip
end

Funcs.ExtractIdentifiers = function(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end

Funcs.GetFramework = function()
	if Config.QBCORE then
		return "QBCORE"
	elseif Config.ESX then
		return "ESX"
	end
end

function Fetch()
    return Funcs
end

exports("Fetch", Fetch)