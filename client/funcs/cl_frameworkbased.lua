lib.FrameworkBased = {};

function lib.FrameworkBased:Init()
    function lib.FrameworkBased:TriggerCallback(name, cb, ...)
        local promise = promise.new()
        if lib.FrameworkName == "QBCore" then
            lib.Framework.Functions.TriggerCallback(name, function(res)
                if (type(cb) == "table" or type(cb) == "function") then
                    cb(res)
                end
    
                promise:resolve(res)
            end, ...)
        elseif lib.FrameworkName == "ESX" then
            lib.Framework.TriggerServerCallback(name, function(res)
                if (type(cb) == "table" or type(cb) == "function") then
                    cb(res)
                end
    
                promise:resolve(res)
            end, ...)
        else
            -- You're custom callback function here
        end
    
        Citizen.Await(promise)
        if (cb == false) then
            return promise.value
        end
    end

    function lib.FrameworkBased:GetPlayerData()
        local info = {}
        local missingData = Config.UnkownData
        local missingImg = Config.UnkownImg
        if lib.FrameworkName == 'ESX' then
            local playerData = lib.Framework.GetPlayerData()
            info = {
                identifier = playerData.character.socialnumber or playerData.identifier or missingData,

                firstname = playerData.character.firstname or missingData,
                lastname = playerData.character.lastname or missingData,
                dob = playerData.character.socialnumber or playerData.character.dob or missingData,
                phonenumber = playerData.character.phone_number or missingData,
                img = playerData.character.image or missingImg,

                jobName = playerData.job.name or missingData,
                gradeLabel = playerData.job.grade_label or missingData,
                grade = playerData.job.grade or missingData,
                jobLabel = playerData.job.label or missingData
            }
        elseif lib.FrameworkName == 'QBCore' then
            local playerData = lib.Framework.Functions.GetPlayerData()
            info = {
                identifier = playerData.citizenid or missingData,

                firstname = playerData.charinfo.firstname or missingData,
                lastname = playerData.charinfo.lastname or missingData,
                dob = playerData.charinfo.dob or missingData,
                phonenumber = playerData.charinfo.phone_number or missingData,
                img = playerData.charinfo.image or missingImg,

                jobName = playerData.job.name or missingData,
                gradeLabel = playerData.job.grade.label or missingData,
                grade = playerData.job.grade.name or missingData,
                jobLabel = playerData.job.label or missingData
            }
        else
            -- Custom GetPlayerData function
        end
        return info
    end

    function lib.FrameworkBased:IsPlayerLoaded()
        if lib.FrameworkName == 'ESX' then
            return lib.Framework.IsPlayerLoaded()
        elseif lib.FrameworkName == 'QBCore' then
            return lib.Framework.Functions.GetPlayerData().charinfo ~= nil
        else
            -- Custom IsPlayerLoaded function
        end
    end
end