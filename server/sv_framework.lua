local framework = nil
local frameworkName = nil

-- CreateThread(function()
    if GetCurrentResourceName() ~= 'force_lib' then
        print("Please rename the resource to 'force_lib'!")
        return
    end

    -- while framework == nil do
    --     Wait(0)

        if not Config.Framework.AutoDetect then
            if GetResourceState(Config.Framework.Resource) == 'started' then
                if Config.Framework.Export then
                    framework = exports[Config.Framework.Resource][Config.Framework.Export]()
                else
                    TriggerEvent(Config.Framework.Event, function(obj) framework = obj  
                    end)
                end
                if not frameworkName then frameworkName = "Custom" end
            end
        else
            if GetResourceState('es_extended') == 'started' then
                framework = exports['es_extended']:getSharedObject()
                if not frameworkName then frameworkName = "ESX" end

                Config.SQL = {
                    Tables = {
                        character = "users",
                        vehicles = "owned_vehicles",
                    },

                    Columns = {
                        identifier = "identifier",
                        owner = "owner",
                        garage = "garage",
                        plate = "plate", 
                        vehicleinfo = "vehicle",
                    }
                }

            elseif GetResourceState('qb-core') == 'started' then
                framework = exports['qb-core']:GetCoreObject()
                if not frameworkName then frameworkName = "QBCore" end

                Config.SQL = {
                    Tables = {
                        character = "players",
                        vehicles = "player_vehicles",
                    },

                    Columns = {
                        identifier = "citizenid",
                        owner = "citizenid",
                        garage = "garage",
                        plate = "plate", 
                        vehicleinfo = "mods",
                    }
                }
            end
        end

        if string.len(Config.TargetSystem) > 0 then
            if GetResourceState('qb-target') == 'started' then
                Config.TargetSystem = 'qb-target'
            elseif GetResourceState('ox_target') == 'started' then
                Config.TargetSystem = 'ox_target'
            elseif GetResourceState('contextmenu') == 'started' then
                Config.TargetSystem = 'contextmenu'
            end
        end

        if framework then
            lib:Init(framework, frameworkName)
        end
    -- end
-- end)