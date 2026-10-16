-- [[ SERVER-ONLY CONFIG ]]
-- This file is listed only in server_scripts, so it is never sent to clients.
-- Convars take priority over the values below. Recommended (server.cfg, use `set` - NOT `setr`/`sets`):
--   set force_lib:discordToken "your-bot-token"
--   set force_lib:discordWebhook "https://discord.com/api/webhooks/..."
--   set force_lib:webhookAllowlist "https://discord.com/api/webhooks/...,..."  (optional: webhooks client logs may use)
--
-- Other convars (not secrets):
--   set  force_lib:clientCallbackTimeout 120000  -- read by the server (Funcs:TriggerClientCallback)
--   setr force_lib:callbackTimeout 120000        -- read by clients (FrameworkBased:TriggerCallback). Clients only
--                                                -- see replicated convars, so this one needs setr.

ServerConfig = {
    Discord = {
        ServerToken = '', -- Discord bot token, required for "role:" admin checks (https://discord.com/developers/applications)
        DefaultWebhook = '', -- Used when a log is sent without a webhook, or by client-side SendDiscordLog calls
    }
}
