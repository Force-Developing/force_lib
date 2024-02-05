lib.Admin = {};

function lib.Admin:CheckAdmin(id)
    if not id or not tonumber(id) then id = GetPlayerServerId(PlayerId()) end
    local promise = promise.new()
    lib.FrameworkBased:TriggerCallback('force_lib:admin:CheckAdmin', function(res)
        promise:resolve(res)
    end, id)
    Citizen.Await(promise)
    return promise.value
end

if Config.AdminManager.Enabled then
    CreateThread(function()
        local isAdmin = lib.Admin:CheckAdmin(nil)
        -- The F in the end of the command is for Force, so it doesn't conflict with other resources
        RegisterCommand('clearobjectsF', function(source, args)
            if isAdmin then
                lib.Streaming:ClearObjects(tonumber(args[1]))
            end
        end, false)

        RegisterCommand('clearentitiesF', function(source, args)
            if isAdmin then
                lib.Streaming:ClearEntities(tonumber(args[1]))
            end
        end, false)
    end)
end