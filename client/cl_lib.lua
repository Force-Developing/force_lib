lib = {
    Funcs = {},
    Streaming = {},
    FrameworkBased = {},
    Math = {}
};

-- Runs fn every time force_lib becomes ready: on the first load and again after every framework restart (the
-- framework's callback table and core object are new then).
lib.ReadyHandlers = {}
function lib:OnReady(fn)
    self.ReadyHandlers[#self.ReadyHandlers + 1] = fn
    if self.Ready then fn() end
end

-- Defines every module function once. Runs at load (before the framework is known), so the tables Fetch()
-- hands out always contain the functions, even when a dependent resource fetches before lib:Init ran.
function lib:DefineModules()
    if self.ModulesDefined then return end
    self.ModulesDefined = true;
    self.Funcs:Init();
    self.Streaming:Init();
    self.FrameworkBased:Init();
    self.Math:Init();
end

function lib:Init(framework, frameworkName, frameworkVariant)
    self.Framework = framework;
    self.FrameworkName = frameworkName; -- 'ESX', 'QBCore' (also on QBX) or 'Custom'
    self.FrameworkVariant = frameworkVariant; -- e.g. 'QBX' when running qbx_core through its qb-core bridge

    self:DefineModules();
    self.Ready = true;
    for _, handler in ipairs(self.ReadyHandlers) do
        local ok, err = pcall(handler)
        if not ok then ForceLibBridge.PrintError(tostring(err)) end
    end

    local label = self.FrameworkVariant and (self.FrameworkName .. " / " .. self.FrameworkVariant) or self.FrameworkName
    print("^4"..GetCurrentResourceName().."^0 Just loaded ^2["..label.."]!^0");
end

exports('Fetch', function()
    -- while not lib.Funcs or not lib.Funcs.GetFramework or not lib.FrameworkBased do -- Saftey feature
    --     Wait(0);
    -- end
    return lib.Funcs, lib.Streaming, lib.FrameworkBased, lib.Math, lib.Admin, Config.DefaultLocale;
end)