lib = {
    Funcs = {},
    Streaming = {},
    FrameworkBased = {},
    Math = {}
};

function lib:Init(framework, frameworkName)
    self.Framework = framework;
    self.FrameworkName = frameworkName;

    self.Funcs:Init();
    self.Streaming:Init();
    self.FrameworkBased:Init();
    self.Math:Init();

    print("^4"..GetCurrentResourceName().."^0 Just loaded ^2["..self.FrameworkName.."]!^0");
end

exports('Fetch', function()
    -- while not lib.Funcs or not lib.Funcs.GetFramework or not lib.FrameworkBased do -- Saftey feature
    --     Wait(0);
    -- end
    return lib.Funcs, lib.Streaming, lib.FrameworkBased, lib.Math, lib.Admin, Config.DefaultLocale;
end)