Funcs = {}

Funcs.DrawMissionText = function(text, height, length)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(length, height)
end

Funcs.BlipDetails = function(blipName, blipText, color, route)
    BeginTextCommandSetBlipName("STRING")
    SetBlipColour(blipName, color)
    AddTextComponentString(blipText)
    SetBlipRoute(blipName, route)
    EndTextCommandSetBlipName(blipName)
end

Funcs.Draw3DText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    
    SetTextScale(0.38, 0.38)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 200)
    SetTextEntry("STRING")
    SetTextCentre(1)

    AddTextComponentString(text)
    DrawText(_x, _y)

    local factor = string.len(text) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

Funcs.DebugPrint = function(text)
    if Config.Debug then
        print("^4" .. GetCurrentResourceName() .. "," .. " ^2Debug: ^3" .. text)
    end
end

exports("Draw3DText", Funcs.Draw3DText)
exports("BlipDetails", Funcs.BlipDetails)
exports("DrawMissionText", Funcs.DrawMissionText)