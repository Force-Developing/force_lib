Config = {}
Config.Debug = true

Config.UnkownData = 'Unkown'
Config.UnkownImg = 'https://img.freepik.com/premium-vector/male-avatar-icon-unknown-anonymous-person-default-avatar-profile-icon-social-media-user-business-man-man-profile-silhouette-isolated-white-background-vector-illustration_735449-122.jpg'

Config.TargetSystem = 'qb-target' -- Currently supports "ox_target", "qb-target", "contextmenu" or leave it blank for no target system or custom function
Config.DefaultLocale = "en" -- [[ Sets default locale for all resources set to nil or false to use resources locale ]]

Config.Framework = {
    AutoDetect = true, -- As of now auto detect supports ESX & QBCore, feel free to send suggestions on what other frameworks you would like to se support for!

    -- [[ When using anything other then QBCore or ESX you should put AutoDetect to false and change these values so it adapts to your framework ]]
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

-- [[ This will auto detect the framework if AutoDetect is set to true so only change when AutoDetect is set to false or needed ]]
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