Config = {}
Config.Debug = true

Config.UnkownData = 'Unkown'
Config.UnkownImg = 'https://img.freepik.com/premium-vector/male-avatar-icon-unknown-anonymous-person-default-avatar-profile-icon-social-media-user-business-man-man-profile-silhouette-isolated-white-background-vector-illustration_735449-122.jpg'

-- "auto" (recommended) picks the first running of ox_target, qb-target, contextmenu.
-- An explicit "ox_target", "qb-target" or "contextmenu" is used when that resource is running, otherwise the first running one is used.
-- Leave it blank ('') for no target system / your own custom function.
Config.TargetSystem = 'auto'
Config.DefaultLocale = "en" -- [[ Sets default locale for all resources set to nil or false to use resources locale ]]

Config.Framework = {
    AutoDetect = true, -- Detects ESX (es_extended), QBCore (qb-core) and QBX (qbx_core, via its qb-core bridge). Waits up to 15s for the framework to start

    -- [[ Only used when AutoDetect = false (custom framework). The framework-specific functions then need to be adapted by you ]]
    Resource = "es_extended",
    Export = "getSharedObject", -- Set this to nil or false to use the event below
    Event = "esx:getSharedObject",
}

-- [[ Non-secret Discord settings. config.lua is a shared_script and is downloaded by EVERY client, ]]
-- [[ so never put the bot token or webhooks here. Secrets live in config.server.lua or in convars.  ]]
Config.Discord = {
    ServerGuild = '', -- Discord server (guild) ID, used for "role:" admin checks

    Logs = {
        LogsColor = 16711680, -- Sets the default color when color is nil

        playerID = true,
        steamID = true,
        steamURL = true,
        discordID = true,
        IP = false,

        AllowClientLogs = true, -- Client-side SendDiscordLog calls (rate limited, tagged [Client]). Set false to ignore them entirely
    }
}

-- [[ Admin Manager just adds commands for handling created object via the library and other usefull stuff ]]
Config.AdminManager = {
    Enabled = true,

    Admins = { -- Check out the documentation for further information on what types you can add (https://docs.forcedevelopments.com/resources/force-library/configuration)
        "steam:123123123", -- Steam HEX ID
        "role:123123123123", -- Discord Role
        "discord:123123123123" -- Discord user ID
    }
}

-- [[ SQL mapping. With AutoDetect, the keys below that differ per framework are overridden:            ]]
-- [[   ESX:        character=users,   vehicles=owned_vehicles,  identifier=identifier, vehicleinfo=vehicle  ]]
-- [[   QBCore/QBX: character=players, vehicles=player_vehicles, identifier/owner=citizenid, vehicleinfo=mods ]]
-- [[ All other keys (licenses, jobs, jobGrades, ...) are kept as written here. The defaults below        ]]
-- [[ (characters / socialnumber / garages) are NOT stock ESX - they match a multi-character ESX setup.   ]]
Config.SQL = {
    Tables = {
        character = "characters",
        vehicles = "garages",
        licenses = "user_licenses",
        jobs = "jobs",
        jobGrades = "job_grades",
    },

    Columns = {
        identifier = "socialnumber",
        owner = "owner", -- This is for example owned_vehicles identifier
        garage = "garage", -- This is for example owned_vehicles in what garage it is
        plate = "plate", -- This is for example owned_vehicles that the plate is stored
        vehicleinfo = "vehicleinfo", -- This is for example owned_vehicles vehicleInfo
        licensesOwner = "owner", -- This is for example user_licenses owner where the identifier for the characters license is
        jobName = "name",
        jobGradesName = "job_name",
        jobGradesGrade= "grade",
    }
}