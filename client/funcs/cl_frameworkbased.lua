lib.FrameworkBased = {};

-- QB/ESX server callbacks have no timeout, and a callback that isn't registered (yet, or any more after a framework
-- restart) is never answered. Waiting for it forever would hang the calling thread, so give up after this long.
local CALLBACK_TIMEOUT_MS = math.max(1000, GetConvarInt('force_lib:callbackTimeout', 60000))

-- Triggers a framework server callback and waits for its first value, at most timeoutMs.
-- Returns value, timedOut.
function lib.TriggerCallbackTimeout(name, timeoutMs, ...)
    local p = promise.new()
    local function onResult(res) p:resolve({ res }) end

    if lib.FrameworkName == "QBCore" then
        lib.Framework.Functions.TriggerCallback(name, onResult, ...)
    elseif lib.FrameworkName == "ESX" then
        lib.Framework.TriggerServerCallback(name, onResult, ...)
    else
        -- You're custom callback function here (call onResult(result) with the answer)
        return nil, false
    end

    SetTimeout(timeoutMs, function() p:resolve(false) end) -- resolving a settled promise is a no-op
    local result = Citizen.Await(p)
    if result == false then
        ForceLibBridge.PrintError(("Server callback '%s' did not answer within %d ms (not registered on the server, or it never calls cb)."):format(tostring(name), timeoutMs))
        return nil, true
    end
    return result[1], false
end

function lib.FrameworkBased:Init()
    function lib.FrameworkBased:TriggerCallback(name, cb, ...)
        local res, timedOut = lib.TriggerCallbackTimeout(name, CALLBACK_TIMEOUT_MS, ...)
        if timedOut then return nil end

        if (type(cb) == "table" or type(cb) == "function") then
            cb(res)
        end

        if (cb == false) then
            return res
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

    -- function lib.FrameworkBased:GetClosestPlayer(coords, distance)
        
    -- end
end