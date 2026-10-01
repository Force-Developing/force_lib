-- [[ SERVER-ONLY CONFIG ]]
-- This file is listed only in server_scripts, so it is never sent to clients.
-- Convars take priority over the values below. Recommended (server.cfg, use `set` - NOT `setr`/`sets`):
--   set force_lib:discordToken "your-bot-token"
--   set force_lib:discordWebhook "https://discord.com/api/webhooks/..."

ServerConfig = {
    Discord = {
        ServerToken = '', -- Discord bot token, required for "role:" admin checks (https://discord.com/developers/applications)
        DefaultWebhook = '', -- Used when a log is sent without a webhook, or by client-side SendDiscordLog calls
    }
}
