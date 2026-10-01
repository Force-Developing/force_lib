lib = {
    Funcs = {},
    Streaming = {},
    FrameworkBased = {},
    Math = {}
};

function lib:Init(framework, frameworkName, frameworkVariant)
    self.Framework = framework;
    self.FrameworkName = frameworkName; -- 'ESX', 'QBCore' (also on QBX) or 'Custom'
    self.FrameworkVariant = frameworkVariant; -- e.g. 'QBX' when running qbx_core through its qb-core bridge

    self.Funcs:Init();
    self.Streaming:Init();
    self.FrameworkBased:Init();
    self.Math:Init();
    self.Ready = true;

    local label = self.FrameworkVariant and (self.FrameworkName .. " / " .. self.FrameworkVariant) or self.FrameworkName
    print("^4"..GetCurrentResourceName().."^0 Just loaded ^2["..label.."]!^0");
end

exports('Fetch', function()
    -- while not lib.Funcs or not lib.Funcs.GetFramework or not lib.FrameworkBased do -- Saftey feature
    --     Wait(0);
    -- end
    return lib.Funcs, lib.Streaming, lib.FrameworkBased, lib.Math, lib.Admin, Config.DefaultLocale;
end)