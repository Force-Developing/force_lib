lib = {
    Funcs = {},
    FrameworkBased = {}
};

-- [[ Resolve server-only secrets: convar > config.server.lua. Never read from the shared config.lua. ]]
do
    local secrets = (ServerConfig and ServerConfig.Discord) or {}

    local function resolve(convar, fallback)
        local value = GetConvar(convar, '')
        if value ~= '' then return value end
        return fallback or ''
    end

    Config.Discord = Config.Discord or {}
    Config.Discord.Logs = Config.Discord.Logs or {}

    -- Older config.lua files kept the secrets in the shared config, which every client downloads.
    if (Config.Discord.ServerToken or '') ~= '' or (Config.Discord.Logs.DefaultWebhook or '') ~= '' then
        print("^1[force_lib] WARNING: Discord token/webhook found in config.lua. That file is downloaded by every client - move them to config.server.lua or the force_lib:discordToken / force_lib:discordWebhook convars and rotate the token.^0")
    end

    Config.Discord.ServerToken = resolve('force_lib:discordToken', secrets.ServerToken ~= '' and secrets.ServerToken or Config.Discord.ServerToken)
    Config.Discord.Logs.DefaultWebhook = resolve('force_lib:discordWebhook', secrets.DefaultWebhook ~= '' and secrets.DefaultWebhook or Config.Discord.Logs.DefaultWebhook)
end

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
    self.FrameworkBased:Init();
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
    -- Resolve the framework now if it already runs but force_lib hasn't noticed yet (see ForceLibBridge.TryInit).
    local ok, err = pcall(ForceLibBridge.TryInit)
    if not ok then ForceLibBridge.PrintError(tostring(err)) end
    -- while not lib.Funcs or not lib.Funcs.GetFramework or not lib.FrameworkBased do -- Saftey feature
    --     Wait(0);
    -- end
    return lib.Funcs, lib.FrameworkBased;
end)