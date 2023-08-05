Citizen.CreateThread(function()
    if GetCurrentResourceName() ~= "force_lib" then
        Funcs.DebugPrint("^1The resourcs need to be namned 'force_lib' otherwise the exports in my scripts won't work :(")
        StopResource(GetCurrentResourceName())
    end
end)