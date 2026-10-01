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

function lib:Init(framework, frameworkName, frameworkVariant)
    self.Framework = framework;
    self.FrameworkName = frameworkName; -- 'ESX', 'QBCore' (also on QBX) or 'Custom'
    self.FrameworkVariant = frameworkVariant; -- e.g. 'QBX' when running qbx_core through its qb-core bridge

    self.Funcs:Init();
    self.FrameworkBased:Init();
    self.Ready = true;

    local label = self.FrameworkVariant and (self.FrameworkName .. " / " .. self.FrameworkVariant) or self.FrameworkName
    print("^4"..GetCurrentResourceName().."^0 Just loaded ^2["..label.."]!^0");
end

exports('Fetch', function()
    -- while not lib.Funcs or not lib.Funcs.GetFramework or not lib.FrameworkBased do -- Saftey feature
    --     Wait(0);
    -- end
    return lib.Funcs, lib.FrameworkBased;
end)