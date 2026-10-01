lib.Streaming = {
    CachedObjects = {},
    CachedEntities = {}
};

function lib.Streaming:Init()
    local DEFAULT_STREAMING_TIMEOUT_MS = 10000

    -- Returns true when the model is loaded, false if it doesn't exist or timed out (instead of hanging forever).
    function lib.Streaming:RequestModel(model, timeout)
        local modelHash = (type(model) == 'number' and model or GetHashKey(model))
        if HasModelLoaded(modelHash) and HasCollisionForModelLoaded(modelHash) then return true end

        if not IsModelInCdimage(modelHash) then
            lib.Funcs:DebugPrint(("RequestModel: model '%s' does not exist"):format(tostring(model)))
            return false
        end

        local deadline = GetGameTimer() + (timeout or DEFAULT_STREAMING_TIMEOUT_MS)

        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            if GetGameTimer() > deadline then
                lib.Funcs:DebugPrint(("RequestModel: timed out loading '%s'"):format(tostring(model)))
                return false
            end
            Wait(0)
        end

        RequestCollisionForModel(modelHash)
        while not HasCollisionForModelLoaded(modelHash) and GetGameTimer() <= deadline do Wait(0) end

        return true
    end

    -- Returns true when the dictionary is loaded, false if it doesn't exist or timed out.
    function lib.Streaming:LoadAnimDict(dict, timeout)
        if HasAnimDictLoaded(dict) then return true end

        if not DoesAnimDictExist(dict) then
            lib.Funcs:DebugPrint(("LoadAnimDict: anim dict '%s' does not exist"):format(tostring(dict)))
            return false
        end

        local deadline = GetGameTimer() + (timeout or DEFAULT_STREAMING_TIMEOUT_MS)
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() > deadline then
                lib.Funcs:DebugPrint(("LoadAnimDict: timed out loading '%s'"):format(tostring(dict)))
                return false
            end
            Wait(0)
        end
        return true
    end

    function lib.Streaming:CreateObject(model, coords, isNetwork, options, cb)
        if not options then options = {} end
        local Object = {
            ground = options.ground or false,
            heading = options.heading or 0.0,
            freeze = options.freeze or false,
            invincible = options.invincible or false,
            missionEntity = options.missionEntity or false,
            rotation = options.rotation or false
        }
        lib.Streaming:RequestModel(model)
        local obj = CreateObject(model, coords.x, coords.y, coords.z, isNetwork or false, false, false)
        SetEntityHeading(obj, Object.heading)
        FreezeEntityPosition(obj, Object.freeze)
        SetEntityInvincible(obj, Object.invincible)
        SetEntityAsMissionEntity(obj, Object.missionEntity, Object.missionEntity)
        if Object.ground then
            PlaceObjectOnGroundProperly(obj)
        end
        if Object.rotation then
            SetEntityRotation(obj, Object.rotation.x, Object.rotation.y, Object.rotation.z, 2, true)
        end
        lib.Streaming.CachedObjects[obj] = true

        if not cb then return obj end
        cb(obj)
    end

    function lib.Streaming:CreateEntity(model, coords, heading, isNetwork, options, cb)
        lib.Streaming:RequestModel(model)
        local entity = CreatePed(4, model, coords.x, coords.y, coords.z, heading or coords.w, isNetwork or false, false)

        if not options then return (cb(entity) or entity) end
        local Entity = {
            freeze = options.freeze or false,
            blockEvents = options.blockEvents or false,
            invicible = options.invicible or false,
            anim = options.anim or false,
            ground = options.ground or false
        }
        FreezeEntityPosition(entity, Entity.freeze)
        SetBlockingOfNonTemporaryEvents(entity, Entity.blockEvents)
        SetEntityInvincible(entity, Entity.invicible)
        if Entity.ground then
            SetEntityCoordsNoOffset(entity, coords.x, coords.y, coords.z, false, false, false)
        end
        if Entity.anim then
            lib.Funcs:PlayBasicAnim(entity, Entity.anim.dict, Entity.anim.animation, Entity.anim.blendIn, Entity.anim.blendOut, Entity.anim.duration, Entity.anim.flag, Entity.anim.playbackRate, Entity.anim.lockX, Entity.anim.lockY, Entity.anim.lockZ)
        end
        lib.Streaming.CachedEntities[entity] = true

        if not cb then return entity end
        cb(entity)
    end

    function lib.Streaming:ClearObjects(radius)
        local notiString = 'Cleared all objects!'
        if radius then
            notiString = 'Cleared all objects within %s units!'
            for k,v in pairs(lib.Streaming.CachedObjects) do
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(k)) <= radius then
                    DeleteObject(k)
                    SetEntityAsNoLongerNeeded(k)
                    lib.Streaming.CachedObjects[k] = nil
                end
            end
        else
            for k,v in pairs(lib.Streaming.CachedObjects) do
                DeleteObject(k)
                SetEntityAsNoLongerNeeded(k)
                lib.Streaming.CachedObjects[k] = nil
            end
        end
        lib.Funcs:ShowNotification((notiString):format(radius or ''))
    end

    function lib.Streaming:ClearEntities(radius)
        local notiString = 'Cleared all entities!'
        if radius then
            notiString = 'Cleared all entities within %s units!'
            for k,v in pairs(lib.Streaming.CachedEntities) do
                if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(k)) <= radius then
                    DeleteEntity(k)
                    SetEntityAsNoLongerNeeded(k)
                    lib.Streaming.CachedEntities[k] = nil
                end
            end
        else
            for k,v in pairs(lib.Streaming.CachedEntities) do
                DeleteEntity(k)
                SetEntityAsNoLongerNeeded(k)
                lib.Streaming.CachedEntities[k] = nil
            end
        end
        lib.Funcs:ShowNotification((notiString):format(radius or ''))
    end
end