Config = {
    --Debugs
    Debug = true,

    --Framework to use
    ESX = true,
    QBCORE = false,

    SQL = {
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
    },

    Logs = {
        LogsColor = 16711680,

        playerID = true,
        steamID = true,
        steamURL = true,
        discordID = true,
        IP = false
    }
}