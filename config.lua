Config = {
    --Debugs
    Debug = true,

    --Framework to use
    ESX = false,
    QBCORE = true,

    SQL = {
        Tables = {
            character = "users",
            vehicles = "garages",
        },

        Columns = {
            identifier = "identifier",
            owner = "owner", -- This is for example owned_vehicles identifier
            garage = "garage", -- This is for example owned_vehicles in what garage it is
            plate = "plate", -- This is for example owned_vehicles that the plate is stored
            vehicleinfo = "vehicleinfo", -- This is for example owned_vehicles vehicleInfo
        }
    }
}