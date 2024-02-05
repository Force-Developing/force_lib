lib = {
    Funcs = {},
    FrameworkBased = {}
};

function lib:Init(framework, frameworkName)
    self.Framework = framework;
    self.FrameworkName = frameworkName;

    self.Funcs:Init();
    self.FrameworkBased:Init();

    print("^4"..GetCurrentResourceName().."^0 Just loaded ^2["..self.FrameworkName.."]!^0");
end

exports('Fetch', function()
    -- while not lib.Funcs or not lib.Funcs.GetFramework or not lib.FrameworkBased do -- Saftey feature
    --     Wait(0);
    -- end
    return lib.Funcs, lib.FrameworkBased;
end)