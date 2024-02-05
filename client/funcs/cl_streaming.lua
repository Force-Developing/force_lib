lib.Streaming = {
    CachedObjects = {},
    CachedEntities = {}
};

function lib.Streaming:Init()
    function lib.Streaming:RequestModel(model)
        local model = (type(model) == 'number' and model or GetHashKey(model))
        if HasModelLoaded(model) then return true end
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        if HasCollisionForModelLoaded(model) then return true end
        RequestCollisionForModel(model)
        while not HasCollisionForModelLoaded(model) do Wait(0) end
    end

    function lib.Streaming:LoadAnimDict(dict)
        if HasAnimDictLoaded(dict) then return true end
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do Wait(0) end
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