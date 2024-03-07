lib.FrameworkBased = {};

function lib.FrameworkBased:Init()
    function lib.FrameworkBased:GetPlayer(id)
        if lib.FrameworkName == 'ESX' then
            return lib.Framework.GetPlayerFromId(id)
        elseif lib.FrameworkName == 'QBCore' then
            return lib.Framework.Functions.GetPlayer(id)
        else
            -- Custom GetPlayer function
        end
    end

    function lib.FrameworkBased:GetIdentifier(id)
        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            return player.socialnumber or player.identifier
        elseif lib.FrameworkName == 'QBCore' then
            return player.PlayerData.citizenid
        else
            -- Custom GetIdentifier function
        end
    end

    function lib.FrameworkBased:GetPlayerFromIdentifier(identifier)
        if lib.FrameworkName == 'ESX' then
            return lib.Framework.GetPlayerFromSocialnumber(identifier) or lib.Framework.GetPlayerFromIdentifier(identifier)
        elseif lib.FrameworkName == 'QBCore' then
            return lib.Framework.Functions.GetPlayerByCitizenId(identifier)
        else
            -- Custom GetPlayerFromIdentifier function
        end
    end

    function lib.FrameworkBased:AddInventoryItem(id, item, count, data)
        if not data then data = {} end

        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            local status, error = pcall(function() player.addInventoryItem(item, count, data) end)
            if not status then
                player.addInventoryItem({
                    item = item,
                    count = count,
                    data = data
                })
            end
        elseif lib.FrameworkName == 'QBCore' then
            player.Functions.AddItem(item, count, false, data)
        else
            -- Custom AddInventoryItem function
        end
    end

    function lib.FrameworkBased:RemoveInventoryItem(id, item, count)
        local player = self.FrameworkBased:GetPlayer(id)

        if self.FrameworkName == 'ESX' then
            player.removeInventoryItem(item, count)
        elseif self.FrameworkName == 'QBCore' then
            player.Functions.RemoveItem(item, count)
        else
            -- Custom RemoveInventoryItem function
        end
    end

    function lib.FrameworkBased:GetInventoryItem(id, item)
        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            return player.getInventoryItem(item) or {count = 0}
        elseif lib.FrameworkName == 'QBCore' then
            if not player.Functions.GetItemByName(item) then return {count = 0} end
            local item = player.Functions.GetItemByName(item)
            local formated = {
                count = item.amount
            }
            return formated
        else
            -- Custom GetInventoryItem function
        end
    end

    function lib.FrameworkBased:GetMoney(id, accountType)
        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            if accountType == "cash" then
                return player.getMoney()
            elseif accountType == "bank" then
                local status, error = pcall(function() return player.getAccount('bank').money end)
                if not status then
                    return exports.bank:getMainAccountMoney(player.socialnumber)
                end
            elseif accountType == "black_money" then
                return player.getAccount('black_money').money
            end

            if accountType == 'all' then
                return {
                    {
                        name = "cash",
                        money = player.getMoney()
                    },
                    {
                        name = "bank",
                        money = (player.getAccount('bank')) and player.getAccount('bank').money or exports.bank:getMainAccountMoney(player.socialnumber)
                    },
                }
            end
        elseif lib.FrameworkName == 'QBCore' then
            if accountType == "cash" then
                return player.Functions.GetMoney('cash')
            elseif accountType == "bank" then
                return player.Functions.GetMoney('bank')
            elseif accountType == "black_money" then
                return player.Functions.GetMoney('black_money')
            end

            if accountType == 'all' then
                return {
                    {
                        name = "cash",
                        money = player.Functions.GetMoney('cash')
                    },
                    {
                        name = "bank",
                        money = player.Functions.GetMoney('bank')
                    },
                }
            end
        else
            -- Custom GetMoney function
        end
    end

    function lib.FrameworkBased:GiveMoney(id, accountType, amount, reason)
        if not reason then reason = "No reason provided" end
        amount = tonumber(amount)

        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            if accountType == 'cash' then
                player.addMoney(amount)
            elseif accountType == "bank" then
                player.addAccountMoney('bank', amount)
            elseif accountType == 'black_money' then
                player.addAccountMoney('black_money', amount)
            end
        elseif lib.FrameworkName == 'QBCore' then
            if accountType == 'cash' then
                player.Functions.AddMoney('cash', amount, reason)
            elseif accountType == "bank" then
                player.Functions.AddMoney('bank', amount, reason)
            elseif accountType == 'black_money' then
                player.Functions.AddMoney('black_money', amount, reason)
            end
        else
            -- Custom GiveMoney function
        end
    end

    function lib.FrameworkBased:RemoveMoney(id, accountType, amount, reason)
        if not reason then reason = "No reason provided" end
        if(type(amount) ~= 'number') then amount = tonumber(amount) end

        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            if accountType == 'cash' then
                player.removeMoney(amount)
            elseif accountType == "bank" then
                player.removeAccountMoney('bank', amount)
            elseif accountType == 'black_money' then
                player.removeAccountMoney('black_money', amount)
            end
        elseif lib.FrameworkName == 'QBCore' then
            if accountType == 'cash' then
                player.Functions.RemoveMoney('cash', amount, reason)
            elseif accountType == "bank" then
                player.Functions.RemoveMoney('bank', amount, reason)
            elseif accountType == 'black_money' then
                player.Functions.RemoveMoney('black_money', amount, reason)
            end
        else
            -- Custom RemoveMoney function
        end
    end

    function lib.FrameworkBased:CreateCallback(name, passed)
        if lib.FrameworkName == 'ESX' then
            lib.Framework.RegisterServerCallback(name, passed)
        elseif lib.FrameworkName == 'QBCore' then
            lib.Framework.Functions.CreateCallback(name, passed)
        else
            -- Custom CreateCallback function
        end
    end

    function lib.FrameworkBased:GetPlayers()
        if lib.FrameworkName == 'ESX' then
            return lib.Framework.GetPlayers()
        elseif lib.FrameworkName == 'QBCore' then
            return lib.Framework.Functions.GetPlayers()
        else
            -- Custom GetPlayers function
        end
    end

    function lib.FrameworkBased:ShowNotification(id, text)
        if lib.FrameworkName == 'ESX' then
            -- lib.Framework.ShowNotification(id, text)
            TriggerClientEvent('esx:showNotification', id, text)
        elseif self.FrameworkName == 'QBCore' then
            lib.Framework.Functions.Notify(id, text)
        else
            -- Custom ShowNotification function
        end
    end

    function lib.FrameworkBased:GetPlayerData(id)
        local player = lib.FrameworkBased:GetPlayer(id)
        local info = nil
        local missingData = Config.UnkownData
        local missingImg = Config.UnkownImg
        -- local promise = promise.new()

        if lib.FrameworkName == 'ESX' then
            if player.character == nil then
                info = {
                    identifier = player.socialnumber or player.identifier or missingData,
                    src = missingData,

                    firstname = missingData,
                    lastname = missingData,
                    dob = missingData,
                    phonenumber = missingData,
                    img = missingImg,

                    jobName = missingData,
                    gradeLabel = missingData,
                    grade = missingData,
                    jobLabel = missingData
                }
                return info
            end
            info = {
                identifier = player.socialnumber or player.identifier or missingData,
                src = player.source or missingData,

                firstname = player.character.firstname or missingData,
                lastname = player.character.lastname or missingData,
                dob = player.character.socialnumber or player.character.dob or missingData,
                phonenumber = player.character.phone_number or missingData,
                img = player.character.image or missingImg,

                jobName = player.job.name or missingData,
                gradeLabel = player.job.grade_label or missingData,
                grade = player.job.grade or missingData,
                jobLabel = player.job.label or missingData
            }
            return info
            -- promise:resolve(info)
        elseif lib.FrameworkName == 'QBCore' then
            info = {
                identifier = player.PlayerData.citizenid or player.citizenid or missingData,
                src = player.PlayerData.source or missingData,

                firstname = player.PlayerData.charinfo.firstname or missingData,
                lastname = player.PlayerData.charinfo.lastname or missingData,
                dob = player.PlayerData.citizenid or player.citizenid or missingData,
                phonenumber = player.PlayerData.charinfo.phone or missingData,
                img = player.PlayerData.charinfo.image or missingImg,

                jobName = player.PlayerData.job.name or missingData,
                gradeLabel = player.PlayerData.job.grade.name or missingData,
                grade = player.PlayerData.job.grade.level or missingData,
                jobLabel = player.PlayerData.job.label or missingData
            }
            -- promise:resolve(info)
            return info
        else
            -- Custom GetPlayerData function
        end
        -- Citizen.Await(promise)
        -- return promise.value
    end

    function lib.FrameworkBased:SetJob(id, job, grade)
        local player = lib.FrameworkBased:GetPlayer(id)

        if lib.FrameworkName == 'ESX' then
            player.setJob(job, grade)
        elseif lib.FrameworkName == 'QBCore' then
            player.Functions.SetJob(job, grade)
        else
            -- Custom SetJob function
        end
    end

    function lib.FrameworkBased:FetchBankAccounts(identifier)
        if lib.FrameworkName == 'ESX' then
            return MySQL.query.await('SELECT * FROM `bank_accounts` WHERE `owner` = ?', {
                identifier
            })
        elseif lib.FrameworkName == 'QBCore' then
            local accounts = MySQL.query.await('SELECT * FROM `bank_accounts` WHERE `citizenid` = ?', {
                identifier
            })
            local formatedAccounts = {}
            for _,v in pairs(accounts) do
                table.insert(formatedAccounts, {
                    name = tostring(v.account_type),
                    accountnumber = tostring(v.account_type),
                    balance = tonumber(v.amount),
                    owner = v.citizenid
                })
            end
            return formatedAccounts
        else
            -- Custom FetchBankAccounts function
        end
    end

    function lib.FrameworkBased:FetchInvoices(identifier)
        if lib.FrameworkName == 'ESX' then
            local receivedInvoices = {}
            local invoices = MySQL.query.await('SELECT * FROM `billing`', {})

            if invoices then
                for i = 1, #invoices do
                    local v = invoices[i]
                    v.receiver = json.decode(v.receiver);

                    if v.receiver.socialnumber == identifier then
                        table.insert(receivedInvoices, v)
                    end
                end
            end

            local tableInvoices = {}
            for k,v in pairs(receivedInvoices) do
                table.insert(tableInvoices, {
                    dob = v.receiver.socialnumber,
                    amount = v.price,
                    desc = v.description,
                })
            end
            return tableInvoices
        elseif lib.FrameworkName == 'QBCore' then
            local invoices = MySQL.query.await('SELECT * FROM `phone_invoices` WHERE `citizenid` = ?', {
                identifier
            })

            local tableInvoices = {}
            for k,v in pairs(invoices) do
                table.insert(tableInvoices, {
                    dob = v.citizenid,
                    amount = tonumber(v.amount),
                    desc = v.sender,
                })
            end

            return tableInvoices
        else
            -- Custom FetchInvoices function
        end
    end

    function lib.FrameworkBased:HandleCompanyAccounts(company, func)
        if lib.FrameworkName == 'ESX' then
            local cAccount = {};
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. company, function(account)
                cAccount = account
            end)
            if not cAccount then cAccount = nil end;
            print(cAccount)
                
                if func.name == 'add' then
                    if cAccount then
                        cAccount.addMoney(tonumber(func.amount))
                    end
                elseif func.name == 'remove' then
                    if cAccount then
                        cAccount.removeMoney(tonumber(func.amount))
                    end
                elseif func.name == 'get' then
                    if cAccount then
                        return tonumber(cAccount.money)
                    else
                        return 0 -- or any default value you want to return when cAccount is nil
                    end
                end
                return cAccount
        elseif lib.FrameworkName == 'QBCore' then
            if func.name == 'add' then
                exports['qb-management']:AddMoney(company, tonumber(func.amount))
            elseif func.name == 'remove' then
                exports['qb-management']:RemoveMoney(company, tonumber(func.amount))
            elseif func.name == 'get' then
                return exports['qb-management']:GetAccount(company)
            end
            return true
        else
            -- Custom HandleCompanyAccounts function
        end
    end

    function lib.FrameworkBased:GetClosestPlayer(coords, range)
        local players = lib.FrameworkBased:GetPlayers()
        local closest = nil
        local closestDistance = range

        for k,v in pairs(players) do
            -- local player = lib.FrameworkBased:GetPlayer(v)
            local playerCoords = GetEntityCoords(GetPlayerPed(k))
            local distance = #(coords - playerCoords)

            if distance < closestDistance then
                closest = k
                closestDistance = distance
                break
            end
        end

        return closest, closestDistance
    end
end