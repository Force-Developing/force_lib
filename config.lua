Config = {
    --Debugs
    Debug = true,

    --Framework to use
    ESX = true,
    QBCORE = false,

       -- [**ESX**]
    SQL = {
        Tables = {
            character = "users",
            vehicles = "garages",
            licenses = "user_licenses",
            jobs = "jobs",
            jobGrades = "job_grades",
        },

        Columns = {
            identifier = "identifier",
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

    -- [**QBCORE**]
    -- SQL = {
    --     Tables = {
    --         character = "players",
    --         vehicles = "garages",
    --         licenses = "user_licenses",
    --         jobs = "jobs",
    --         jobGrades = "job_grades",
    --     },

    --     Columns = {
    --         identifier = "citizenid",
    --         owner = "owner", -- This is for example owned_vehicles identifier
    --         garage = "garage", -- This is for example owned_vehicles in what garage it is
    --         plate = "plate", -- This is for example owned_vehicles that the plate is stored
    --         vehicleinfo = "vehicleinfo", -- This is for example owned_vehicles vehicleInfo
    --         licensesOwner = "owner", -- This is for example user_licenses owner where the identifier for the characters license is
    --         jobName = "name",
    --         jobGradesName = "job_name",
    --         jobGradesGrade= "grade",
    --     }
    -- }
}
