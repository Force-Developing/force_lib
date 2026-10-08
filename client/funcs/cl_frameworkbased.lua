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
            -- `character` only exists on modified ESX builds; stock ESX keeps the names on the player data itself.
            local playerData = lib.Framework.GetPlayerData() or {}
            local character = type(playerData.character) == 'table' and playerData.character or {}
            local job = type(playerData.job) == 'table' and playerData.job or {}
            info = {
                identifier = character.socialnumber or playerData.identifier or missingData,

                firstname = character.firstname or playerData.firstName or missingData,
                lastname = character.lastname or playerData.lastName or missingData,
                dob = character.socialnumber or character.dob or playerData.dateofbirth or missingData,
                phonenumber = character.phone_number or playerData.phone_number or missingData,
                img = character.image or missingImg,

                jobName = job.name or missingData,
                gradeLabel = job.grade_label or missingData,
                grade = job.grade or missingData,
                jobLabel = job.label or missingData
            }
        elseif lib.FrameworkName == 'QBCore' then
            -- Before a character is loaded the player data is empty.
            local playerData = lib.Framework.Functions.GetPlayerData() or {}
            local charinfo = type(playerData.charinfo) == 'table' and playerData.charinfo or {}
            local job = type(playerData.job) == 'table' and playerData.job or {}
            local grade = type(job.grade) == 'table' and job.grade or {}
            info = {
                identifier = playerData.citizenid or missingData,

                firstname = charinfo.firstname or missingData,
                lastname = charinfo.lastname or missingData,
                dob = charinfo.dob or charinfo.birthdate or missingData,
                phonenumber = charinfo.phone_number or charinfo.phone or missingData,
                img = charinfo.image or missingImg,

                jobName = job.name or missingData,
                gradeLabel = grade.label or grade.name or missingData,
                grade = grade.name or missingData,
                jobLabel = job.label or missingData
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
            local playerData = lib.Framework.Functions.GetPlayerData()
            return type(playerData) == 'table' and playerData.charinfo ~= nil
        else
            -- Custom IsPlayerLoaded function
        end
    end

    -- function lib.FrameworkBased:GetClosestPlayer(coords, distance)
        
    -- end
end