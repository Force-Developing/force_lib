AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if GetCurrentResourceName() ~= "force_lib" then
        return print("Please rename the resource to force_lib")
    end

    local url = GetResourceMetadata(resourceName, "versioncheck", 0)
    local version = GetResourceMetadata(resourceName, "version", 0)

    local lastestVersionStr = "^0[ ^4"..resourceName.." ^0is running on the latest version ^2(v"..version..")! ^0]"

    local divider = ""

    for i = 1, string.len(lastestVersionStr) do
        divider = divider.."-"
    end
    
    PerformHttpRequest(url, function(err, text, headers)
        --
        print("^0[ ^3Performing Update Check ^0: "..resourceName.." ] ")
        if (text ~= nil) then
            if tonumber(version) >= tonumber(text) then
                print(divider)
                print(lastestVersionStr)
                print(divider)
            else
                print("\n")
                print("New version of "..resourceName.." found, please update as soon as possible! If you're running anything below 2.0 reasources from 2024+ won't work!")
                print("[ Old : v"..version.." ] ")
                print("[ New : v"..text.." ] ")        
                print("\n")
            end
        else
            print("Unable to find version.txt on "..url..", please check if you're internet connection is working properly and stable!")
        end
    end, "GET", "", {})
end)