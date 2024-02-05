lib.Funcs = {}

function lib.Funcs:Init()
    function lib.Funcs:DrawMissionText(text, length, height, scale, spriteWidth, spriteHeight)
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(true)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextEntry("STRING")
        SetTextCentre(true)
        SetTextOutline()
        AddTextComponentString(text)
        DrawText(height, length)
    end

    function lib.Funcs:GetClosestVehicle(coords)
        local vehicles        = self.Funcs:GetVehicles()
        local closestDistance = -1
        local closestVehicle  = -1
        local coords          = coords

        if coords == nil then
            local playerPed = PlayerPedId()
            coords          = GetEntityCoords(playerPed)
        end

        for i=1, #vehicles, 1 do
            local vehicleCoords = GetEntityCoords(vehicles[i])
            local distance      = #(vec3(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z) - vec3(coords.x, coords.y, coords.z))

            if closestDistance == -1 or closestDistance > distance then
                closestVehicle  = vehicles[i]
                closestDistance = distance
            end
        end

        return closestVehicle, closestDistance
    end

    function lib.Funcs:BlipDetails(blipName, blipText, color, route)
        BeginTextCommandSetBlipName("STRING")
        SetBlipColour(blipName, color)
        AddTextComponentString(blipText)
        SetBlipRoute(blipName, route)
        EndTextCommandSetBlipName(blipName)
    end

    function lib.Funcs:Draw3DText(coords, text)
        local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)

        if onScreen then
            SetTextScale(0.38, 0.38)
            SetTextFont(4)
            SetTextProportional(true)
            SetTextColour(255, 255, 255, 200)
            SetTextEntry("STRING")
            SetTextCentre(true)

            AddTextComponentString(text)
            DrawText(_x, _y)
        end
    end

    ---@param text string
    function lib.Funcs:DebugPrint(text)
        if Config.Debug then
            print("^4" .. GetCurrentResourceName() .. "," .. " ^2Debug: ^3" .. text)
        end
    end

    ---@param text string
    function lib.Funcs:ShowNotification(text)
        if lib.FrameworkName == 'ESX' then
            -- local status, error = pcall(function() lib.Framework.ShowNotification(text) end)
            -- if not status then
                lib.Framework.ShowNotification(text)
            -- end
        elseif lib.FrameworkName == 'QBCore' then
            lib.Framework.Functions.Notify(text)
        else
            -- Custom ShowNotification function
        end
    end

    -- This function is declared just because sometimes when you have a hardcoded index on a table you can't get the length of the table
    ---@param table table
    function lib.Funcs:GetTableLength(table)
        local count = 0

        if table then
            for _,_ in pairs(table) do
                count = count + 1
            end
        end

        return count
    end


    function lib.Funcs:EntityPlayAnim(entity, dict, anim, flag, options, cb, cancelFunc)
        if not options then options = {} end

        local Anim = {
            Complete = false,
    
            Player = entity or PlayerPedId(),
            Counter = options.Duration or false,
            Infinite = options.Infinite or false,
            Dictionary = dict or "anim@heists@prison_heiststation@cop_reactions",
            Animation = anim or "cop_a_idle",
            Flag = flag or 0,
    
            Position = options.Coords or GetEntityCoords(entity or PlayerPedId()),
            Heading = options.Heading or GetEntityHeading(entity or PlayerPedId()),
    
            Speed = options.Speed or 1.0,
            AnimTime = options.AnimTime or -1,
    
            Freeze = options.Freeze or false,
            Cancable = options.Cancable or false,
            CancelOnFinish = options.CancelOnFinish or false,
    
            Prop = options.Prop or false,
        }
    
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end

        if Anim.Counter then
            CreateThread(function()
                while Anim.Counter > 0 do
                    Wait(1000)
                    Anim.Counter = Anim.Counter - 1
    
                    if Anim.Counter <= 0 then
                        Anim.Complete = true
                        break
                    end
                end
            end)
        end

        if not Anim.Counter then
            Anim.Counter = 0
        end

        CreateThread(function()
            while Anim.Counter > 0 or Anim.Infinite or Anim.AnimTime == -1 or Anim.AnimTime > 0 do
                Wait(4)
    
                if not IsEntityPlayingAnim(Anim.Player, Anim.Dictionary, Anim.Animation, Anim.Flag) then
                    if not IsEntityPositionFrozen(Anim.Player) then
                        FreezeEntityPosition(Anim.Player, Anim.Freeze)
                    end
                    TaskPlayAnimAdvanced(Anim.Player, Anim.Dictionary, Anim.Animation, Anim.Position.x, Anim.Position.y, Anim.Position.z, 0.0, 0.0, Anim.Heading, Anim.Speed, 0.5, -1, Anim.Flag, Anim.AnimTime, 1, 1)
                end
    
                if Anim.Prop then
                    if not DoesEntityExist(Anim.Prop.Object) then
                        local propModel = GetHashKey(Anim.Prop.Model)
                        RequestModel(propModel) while not HasModelLoaded(propModel) do Wait(0) end
                        Anim.Prop.Object = CreateObject(propModel, Anim.Position.x, Anim.Position.y, Anim.Position.z, true, true, false)
                        AttachEntityToEntity(Anim.Prop.Object, Anim.Player, GetPedBoneIndex(Anim.Player, Anim.Prop.BoneIndex), Anim.Prop.Pos.x or 0, Anim.Prop.Pos.y or 0, Anim.Prop.Pos.z or 0, Anim.Prop.Rot.x or 0, Anim.Prop.Rot.y or 0, Anim.Prop.Rot.z or 0, false, false, true, false, 0, true)
                    end
                end

                if Anim.CancelOnFinish then
                    if GetEntityAnimCurrentTime(Anim.Player, Anim.Dictionary, Anim.Animation) >= 0.99 then
                        CompleteAnimation(true)
                        break
                    end
                end
    
                if Anim.Cancable then
                    if IsControlJustPressed(0, 73) then
                        CompleteAnimation(false)
                        break
                    end
                end
    
                if Anim.Complete then
                    CompleteAnimation(true)
                    break
                end
            end
        end)

        CreateThread(function()
            if cancelFunc then
                print(cancelFunc())
                if cancelFunc() then
                    CompleteAnimation(true)
                end
            end
        end)

        function CompleteAnimation(completed)
            StopAnimTask(Anim.Player, Anim.Dictionary, Anim.Animation, Anim.Speed)
            if Anim.Freeze or IsEntityPositionFrozen(Anim.Player) then
                FreezeEntityPosition(Anim.Player, false)
            end
            if cb then
                cb(completed)
            end
        end
    end

    function lib.Funcs:PlayBasicAnim(entity, dict, anim, blendIn, blendOut, duration, flag, playbackRate, lockX, lockY, lockZ)
        lib.Streaming:LoadAnimDict(dict)
        TaskPlayAnim(entity, dict, anim, blendIn, blendOut, duration or -1, flag, playbackRate, lockX, lockY, lockZ)
    end

    function lib.Funcs:SpawnVehicle(modelName, coords, heading, cb)
        local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))

        Citizen.CreateThread(function()
            RequestModel(model)

            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
            local id      = NetworkGetNetworkIdFromEntity(vehicle)

            SetNetworkIdCanMigrate(id, true)
            SetEntityAsMissionEntity(vehicle, true, false)
            SetVehicleHasBeenOwnedByPlayer(vehicle, true)
            SetVehicleNeedsToBeHotwired(vehicle, false)
            SetModelAsNoLongerNeeded(model)

            RequestCollisionAtCoord(coords.x, coords.y, coords.z)

            while not HasCollisionLoadedAroundEntity(vehicle) do
                RequestCollisionAtCoord(coords.x, coords.y, coords.z)
                Citizen.Wait(0)
            end

            SetVehRadioStation(vehicle, 'OFF')

            if cb ~= nil then
                cb(vehicle)
            end
        end)
    end

    function lib.Funcs:TeleportEntity(entity, coords)
        DoScreenFadeOut(100)
    
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        while not HasCollisionLoadedAroundEntity(entity) do
        RequestCollisionAtCoord(coords.x, coords.x, coords.x)
            Citizen.Wait(0)
        end
        Citizen.Wait(1000)
    
        SetEntityCoords(entity,  coords.x,  coords.y,  coords.z, true, false, false, true)
        if coords.w then
            SetEntityHeading(entity, coords.w)
        end

        DoScreenFadeIn(100)
    end

    function lib.Funcs:GetVehicles()
        local vehicles = {}

        for vehicle in lib.entitier:EnumerateVehicles() do
            table.insert(vehicles, vehicle)
        end

        return vehicles
    end

    function lib.Funcs:GetVehiclesInArea(coords, area)
        local vehicles       = self.Funcs:GetVehicles()
        local vehiclesInArea = {}
    
        for i=1, #vehicles, 1 do
            local vehicleCoords = GetEntityCoords(vehicles[i])
            local distance      = #(vehicleCoords - vec3(coords.x, coords.y, coords.z))
    
            if distance <= area then
                table.insert(vehiclesInArea, vehicles[i])
            end
        end
    
        return vehiclesInArea
    end

    function lib.Funcs:IsSpawnPointClear(coords, radius)
        local vehicles = self.Funcs:GetVehiclesInArea(coords, radius)
    
        return #vehicles == 0
    end

    function lib.Funcs:SetVehicleMods(vehicle, props)
        if not DoesEntityExist(vehicle) then
            return
        end
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        SetVehicleModKit(vehicle, 0)
    
        if props.tyresCanBurst ~= nil then
            SetVehicleTyresCanBurst(vehicle, props.tyresCanBurst)
        end
    
        if props.plate ~= nil then
            SetVehicleNumberPlateText(vehicle, props.plate)
        end
        if props.plateIndex ~= nil then
            SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
        end
        if props.bodyHealth ~= nil then
            SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
        end
        if props.engineHealth ~= nil then
            SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
        end
        if props.tankHealth ~= nil then
            SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
        end
        if props.fuelLevel ~= nil then
            SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
        end
        if props.dirtLevel ~= nil then
            SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
        end
        if props.customPrimaryColor ~= nil then
            SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2],
                props.customPrimaryColor[3])
        end
        if props.customSecondaryColor ~= nil then
            SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2],
                props.customSecondaryColor[3])
        end
        if props.color1 ~= nil then
            SetVehicleColours(vehicle, props.color1, colorSecondary)
        end
        if props.color2 ~= nil then
            SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2)
        end
        if props.pearlescentColor ~= nil then
            SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor)
        end
    
        if props.interiorColor ~= nil then
            SetVehicleInteriorColor(vehicle, props.interiorColor)
        end
    
        if props.dashboardColor ~= nil then
            SetVehicleDashboardColor(vehicle, props.dashboardColor)
        end
    
        if props.wheelColor ~= nil then
            SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor)
        end
        if props.wheels ~= nil then
            SetVehicleWheelType(vehicle, props.wheels)
        end
        if props.windowTint ~= nil then
            SetVehicleWindowTint(vehicle, props.windowTint)
        end
    
        if props.neonEnabled ~= nil then
            SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
            SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
            SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
            SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
        end
    
        if props.extras ~= nil then
            for extraId, enabled in pairs(props.extras) do
                SetVehicleExtra(vehicle, tonumber(extraId), enabled and 0 or 1)
            end
        end
    
        if props.neonColor ~= nil then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
        if props.xenonColor ~= nil then
            SetVehicleXenonLightsColor(vehicle, props.xenonColor)
        end
        if props.customXenonColor ~= nil then
            SetVehicleXenonLightsCustomColor(vehicle, props.customXenonColor[1], props.customXenonColor[2],
                props.customXenonColor[3])
        end
        if props.modSmokeEnabled ~= nil then
            ToggleVehicleMod(vehicle, 20, true)
        end
        if props.tyreSmokeColor ~= nil then
            SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
        end
        if props.modSpoilers ~= nil then
            SetVehicleMod(vehicle, 0, props.modSpoilers, false)
        end
        if props.modFrontBumper ~= nil then
            SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
        end
        if props.modRearBumper ~= nil then
            SetVehicleMod(vehicle, 2, props.modRearBumper, false)
        end
        if props.modSideSkirt ~= nil then
            SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
        end
        if props.modExhaust ~= nil then
            SetVehicleMod(vehicle, 4, props.modExhaust, false)
        end
        if props.modFrame ~= nil then
            SetVehicleMod(vehicle, 5, props.modFrame, false)
        end
        if props.modGrille ~= nil then
            SetVehicleMod(vehicle, 6, props.modGrille, false)
        end
        if props.modHood ~= nil then
            SetVehicleMod(vehicle, 7, props.modHood, false)
        end
        if props.modFender ~= nil then
            SetVehicleMod(vehicle, 8, props.modFender, false)
        end
        if props.modRightFender ~= nil then
            SetVehicleMod(vehicle, 9, props.modRightFender, false)
        end
        if props.modRoof ~= nil then
            SetVehicleMod(vehicle, 10, props.modRoof, false)
        end
    
        if props.modRoofLivery ~= nil then
            SetVehicleRoofLivery(vehicle, props.modRoofLivery)
        end
    
        if props.modEngine ~= nil then
            SetVehicleMod(vehicle, 11, props.modEngine, false)
        end
        if props.modBrakes ~= nil then
            SetVehicleMod(vehicle, 12, props.modBrakes, false)
        end
        if props.modTransmission ~= nil then
            SetVehicleMod(vehicle, 13, props.modTransmission, false)
        end
        if props.modHorns ~= nil then
            SetVehicleMod(vehicle, 14, props.modHorns, false)
        end
        if props.modSuspension ~= nil then
            SetVehicleMod(vehicle, 15, props.modSuspension, false)
        end
        if props.modArmor ~= nil then
            SetVehicleMod(vehicle, 16, props.modArmor, false)
        end
        if props.modTurbo ~= nil then
            ToggleVehicleMod(vehicle, 18, props.modTurbo)
        end
        if props.modXenon ~= nil then
            ToggleVehicleMod(vehicle, 22, props.modXenon)
        end
        if props.modFrontWheels ~= nil then
            SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomFrontWheels)
        end
        if props.modBackWheels ~= nil then
            SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomBackWheels)
        end
        if props.modPlateHolder ~= nil then
            SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
        end
        if props.modVanityPlate ~= nil then
            SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
        end
        if props.modTrimA ~= nil then
            SetVehicleMod(vehicle, 27, props.modTrimA, false)
        end
        if props.modOrnaments ~= nil then
            SetVehicleMod(vehicle, 28, props.modOrnaments, false)
        end
        if props.modDashboard ~= nil then
            SetVehicleMod(vehicle, 29, props.modDashboard, false)
        end
        if props.modDial ~= nil then
            SetVehicleMod(vehicle, 30, props.modDial, false)
        end
        if props.modDoorSpeaker ~= nil then
            SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
        end
        if props.modSeats ~= nil then
            SetVehicleMod(vehicle, 32, props.modSeats, false)
        end
        if props.modSteeringWheel ~= nil then
            SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
        end
        if props.modShifterLeavers ~= nil then
            SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
        end
        if props.modAPlate ~= nil then
            SetVehicleMod(vehicle, 35, props.modAPlate, false)
        end
        if props.modSpeakers ~= nil then
            SetVehicleMod(vehicle, 36, props.modSpeakers, false)
        end
        if props.modTrunk ~= nil then
            SetVehicleMod(vehicle, 37, props.modTrunk, false)
        end
        if props.modHydrolic ~= nil then
            SetVehicleMod(vehicle, 38, props.modHydrolic, false)
        end
        if props.modEngineBlock ~= nil then
            SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
        end
        if props.modAirFilter ~= nil then
            SetVehicleMod(vehicle, 40, props.modAirFilter, false)
        end
        if props.modStruts ~= nil then
            SetVehicleMod(vehicle, 41, props.modStruts, false)
        end
        if props.modArchCover ~= nil then
            SetVehicleMod(vehicle, 42, props.modArchCover, false)
        end
        if props.modAerials ~= nil then
            SetVehicleMod(vehicle, 43, props.modAerials, false)
        end
        if props.modTrimB ~= nil then
            SetVehicleMod(vehicle, 44, props.modTrimB, false)
        end
        if props.modTank ~= nil then
            SetVehicleMod(vehicle, 45, props.modTank, false)
        end
        if props.modWindows ~= nil then
            SetVehicleMod(vehicle, 46, props.modWindows, false)
        end
    
        if props.modLivery ~= nil then
            SetVehicleMod(vehicle, 48, props.modLivery, false)
            SetVehicleLivery(vehicle, props.modLivery)
        end
    
        if props.windowsBroken ~= nil then
            for k, v in pairs(props.windowsBroken) do
                if v then
                    RemoveVehicleWindow(vehicle, tonumber(k))
                end
            end
        end
    
        if props.doorsBroken ~= nil then
            for k, v in pairs(props.doorsBroken) do
                if v then
                    SetVehicleDoorBroken(vehicle, tonumber(k), true)
                end
            end
        end
    
        if props.tyreBurst ~= nil then
            for k, v in pairs(props.tyreBurst) do
                if v then
                    SetVehicleTyreBurst(vehicle, tonumber(k), true, 1000.0)
                end
            end
        end
    end

    function lib.Funcs:GetVehicleProperties(vehicle)
        if not DoesEntityExist(vehicle) then
            return
        end
    
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
        local dashboardColor = GetVehicleDashboardColor(vehicle)
        local interiorColor = GetVehicleInteriorColour(vehicle)
        local customPrimaryColor = nil
        if hasCustomPrimaryColor then
            customPrimaryColor = { GetVehicleCustomPrimaryColour(vehicle) }
        end
    
        local hasCustomXenonColor, customXenonColorR, customXenonColorG, customXenonColorB = GetVehicleXenonLightsCustomColor(vehicle)
        local customXenonColor = nil
        if hasCustomXenonColor then
            customXenonColor = { customXenonColorR, customXenonColorG, customXenonColorB }
        end
    
        local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
        local customSecondaryColor = nil
        if hasCustomSecondaryColor then
            customSecondaryColor = { GetVehicleCustomSecondaryColour(vehicle) }
        end
    
        local extras = {}
        for extraId = 0, 20 do
            if DoesExtraExist(vehicle, extraId) then
                extras[tostring(extraId)] = IsVehicleExtraTurnedOn(vehicle, extraId)
            end
        end
    
        local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
        local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))
    
        local TyresIndex = {             -- Wheel index list according to the number of vehicle wheels.
            ['2'] = { 0, 4 },            -- Bike and cycle.
            ['3'] = { 0, 1, 4, 5 },      -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
            ['4'] = { 0, 1, 4, 5 },      -- Vehicle with 4 wheels.
            ['6'] = { 0, 1, 2, 3, 4, 5 } -- Vehicle with 6 wheels.
        }
    
        if TyresIndex[numWheels] then
            for _, idx in pairs(TyresIndex[numWheels]) do
                tyreBurst[tostring(idx)] = IsVehicleTyreBurst(vehicle, idx, false)
            end
        end
    
        for windowId = 0, 7 do              -- 13
            RollUpWindow(vehicle, windowId) --fix when you put the car away with the window down
            windowsBroken[tostring(windowId)] = not IsVehicleWindowIntact(vehicle, windowId)
        end
    
        local numDoors = GetNumberOfVehicleDoors(vehicle)
        if numDoors and numDoors > 0 then
            for doorsId = 0, numDoors do
                doorsBroken[tostring(doorsId)] = IsVehicleDoorDamaged(vehicle, doorsId)
            end
        end
    
        return {
            model = GetEntityModel(vehicle),
            doorsBroken = doorsBroken,
            windowsBroken = windowsBroken,
            tyreBurst = tyreBurst,
            tyresCanBurst = GetVehicleTyresCanBurst(vehicle),
            plate = lib.Math:Trim(GetVehicleNumberPlateText(vehicle)),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
    
            bodyHealth = lib.Math:Round(GetVehicleBodyHealth(vehicle), 1),
            engineHealth = lib.Math:Round(GetVehicleEngineHealth(vehicle), 1),
            tankHealth = lib.Math:Round(GetVehiclePetrolTankHealth(vehicle), 1),
    
            fuelLevel = lib.Math:Round(GetVehicleFuelLevel(vehicle), 1),
            dirtLevel = lib.Math:Round(GetVehicleDirtLevel(vehicle), 1),
            color1 = colorPrimary,
            color2 = colorSecondary,
            customPrimaryColor = customPrimaryColor,
            customSecondaryColor = customSecondaryColor,
    
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
    
            dashboardColor = dashboardColor,
            interiorColor = interiorColor,
    
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            xenonColor = GetVehicleXenonLightsColor(vehicle),
            customXenonColor = customXenonColor,
    
            neonEnabled = { IsVehicleNeonLightEnabled(vehicle, 0), IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2), IsVehicleNeonLightEnabled(vehicle, 3) },
    
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
    
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modRoofLivery = GetVehicleRoofLivery(vehicle),
    
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
    
            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
    
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modCustomFrontWheels = GetVehicleModVariation(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modCustomBackWheels = GetVehicleModVariation(vehicle, 24),
    
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleMod(vehicle, 48) == -1 and GetVehicleLivery(vehicle) or GetVehicleMod(vehicle, 48),
            modLightbar = GetVehicleMod(vehicle, 49)
        }
    end

    function lib.Funcs:MakeEntityFaceEntity(entity01, entity02)
        local p1 = GetEntityCoords(entity01, true)
        local p2 = GetEntityCoords(entity02, true)
    
        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
    
        local heading = GetHeadingFromVector_2d(dx, dy)
        SetEntityHeading(entity01, heading)
    end

    function lib.Funcs:SetEntityCoordsInfrontOfEntity(entity01, entity02)
        local pedCoords = GetEntityCoords(entity02)
        local front = GetEntityForwardVector(entity02)
        SetEntityCoords(entity01, pedCoords.x + front.x, pedCoords.y + front.y, pedCoords.z - 0.985, false, false, false, true)
    end

    function lib.Funcs:SendDiscordLog(webHook, header, message)
        TriggerServerEvent("force_lib:eventHandler", "SendDiscordLog", {webHook = webHook, header = header, message = message})
    end

    function lib.Funcs:KeyCodes(key)
        if not lib.KeyCodes[key] then lib.Funcs:DebugPrint("Could not find key: "..(key or tostring(key))) return end
        return lib.KeyCodes[key]
    end

    function lib.Funcs:GetSQLInfo()
        return Config.SQL
    end

    function lib.Funcs:GetFramework()
        return lib.FrameworkName
    end

    function lib.Funcs:CreateTarget(target, elements, data)
        if not data then data = {} end
        local Target = {
            isEntity = type(target) ~= ('vector3' or 'vec3'),
            size = data.size or vec3(3.0, 3.0, 3.0),
            distance = data.distance or 3.0,
            rotation = data.rotation or 45,
            heading = data.heading or 0.0
        }

        if Config.TargetSystem == 'ox_target' then
            if Target.isEntity then
                exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(target), elements)
            else
                exports.ox_target:addBoxZone({
                    coords = target,
                    size = Target.size,
                    rotation = Target.rotation,
                    distance = Target.distance,
                    options = {elements}
                })
            end
        elseif Config.TargetSystem == 'qb-target' then
            if Target.isEntity then
                exports['qb-target']:AddTargetEntity(target, {
                    options = {elements},
                    distance = Target.distance
                })
            else
                exports['qb-target']:AddBoxZone(tostring(target), target, Target.size.x, Target.size.y, {
                    name = tostring(target),
                    debugPoly = false,
                    heading = Target.heading,
                    minZ = target.z - 2,
                    maxZ = target.z + 2,
                }, {
                    options = {elements},
                    distance = Target.distance
                })
            end
        elseif Config.TargetSystem == 'contextmenu' then
            exports.contextmenu:Add(tostring(target), elements.name, {elements}, {onSelect = function() elements.onSelect(target) end}, nil, target)
        else
            -- Custom target function
        end
    end

    function lib.Funcs:StartProgressbar(text, time)
        if lib.FrameworkName == 'ESX' then
            local status, error = pcall(function() exports['esx_progressbar']:startUI(time, text) end)
            if not status then
                exports['progressbar']:StartProgress(text, time, nil, '#00b350')
            end
        elseif lib.FrameworkName == 'QBCore' then
            exports['qb-core']:Progressbar(time, text)
        else
            -- Custom progressbar function
            local player = PlayerPedId()
            CreateThread(function()
                while time > 0 do
                    Wait(0)

                    time = time - 1
                    lib.Funcs:Draw3DText(GetEntityCoords(player), text)
                end
            end)
        end
    end

    function lib.Funcs:TableContains(table, value)
        for _,v in pairs(table) do
            if v == value then
                return true
            end
        end
        return false
    end
end