-- [[ Framework + target system detection, shared by server and client. ]]
ForceLibBridge = {}

local DETECT_TIMEOUT_MS = 15000
local DETECT_INTERVAL_MS = 250

local function printError(message)
    print(('^1[force_lib] ERROR: %s^0'):format(message))
end
ForceLibBridge.PrintError = printError

local function isStarted(resource)
    return type(resource) == 'string' and GetResourceState(resource) == 'started'
end

function ForceLibBridge.CheckResourceName()
    local name = GetCurrentResourceName()
    if name == 'force_lib' then return true end

    printError(("This resource is named '%s' but it MUST be named 'force_lib' - every resource that depends on it will fail until it is. Rename the folder to force_lib (GitHub's \"Download ZIP\" creates force_lib-main), or download force_lib.zip from the GitHub Releases page instead."):format(name))
    return false
end

-- [[ Auto-detect only overrides the keys that differ per framework; everything else in Config.SQL is kept. ]]
local SQL_PRESETS = {
    ESX = {
        Tables = { character = "users", vehicles = "owned_vehicles" },
        Columns = { identifier = "identifier", owner = "owner", garage = "garage", plate = "plate", vehicleinfo = "vehicle" },
    },
    QBCore = {
        Tables = { character = "players", vehicles = "player_vehicles" },
        Columns = { identifier = "citizenid", owner = "citizenid", garage = "garage", plate = "plate", vehicleinfo = "mods" },
    },
}

local function mergeSQL(preset)
    Config.SQL = Config.SQL or {}
    for section, values in pairs(preset) do
        Config.SQL[section] = Config.SQL[section] or {}
        for key, value in pairs(values) do
            Config.SQL[section][key] = value
        end
    end
end

-- Order matters: qbx_core is checked before qb-core. QBX is exposed as 'QBCore' through its
-- qb-core bridge (exports['qb-core']:GetCoreObject()), so GetFramework() keeps returning 'QBCore'.
local CANDIDATES = {
    {
        resource = 'es_extended', name = 'ESX',
        get = function() return exports['es_extended']:getSharedObject() end,
    },
    {
        resource = 'qbx_core', name = 'QBCore', variant = 'QBX',
        get = function() return exports['qb-core']:GetCoreObject() end,
        hint = "qbx_core is running but its qb-core bridge is unavailable. force_lib needs the bridge - make sure the convar qbx:enablebridge is not set to false.",
    },
    {
        resource = 'qb-core', name = 'QBCore',
        get = function() return exports['qb-core']:GetCoreObject() end,
    },
}

local function detectCustom()
    local resource = Config.Framework.Resource
    if not isStarted(resource) then return nil end

    local framework
    if Config.Framework.Export then
        local ok, obj = pcall(function() return exports[resource][Config.Framework.Export]() end)
        if ok then framework = obj end
    elseif Config.Framework.Event then
        TriggerEvent(Config.Framework.Event, function(obj) framework = obj end)
    end

    if framework then return { framework = framework, name = 'Custom' } end
    return nil, ("'%s' is started but returned no core object - check Config.Framework.Export / Config.Framework.Event."):format(resource)
end

local function detectOnce()
    if not Config.Framework.AutoDetect then
        return detectCustom()
    end

    local firstError
    for _, candidate in ipairs(CANDIDATES) do
        if isStarted(candidate.resource) then
            local ok, obj = pcall(candidate.get)
            if ok and obj then
                if SQL_PRESETS[candidate.name] then mergeSQL(SQL_PRESETS[candidate.name]) end
                return { framework = obj, name = candidate.name, variant = candidate.variant }
            end
            firstError = firstError or candidate.hint or ("'%s' is started but its core object could not be fetched: %s"):format(candidate.resource, tostring(obj))
        end
    end
    return nil, firstError
end

-- Calls onFound(framework, name, variant) once a framework is available. Initialises synchronously when the
-- framework is already started (the normal, correctly ordered case); otherwise waits up to DETECT_TIMEOUT_MS.
function ForceLibBridge.Detect(onFound)
    local result = detectOnce()
    if result then return onFound(result.framework, result.name, result.variant) end

    CreateThread(function()
        local deadline = GetGameTimer() + DETECT_TIMEOUT_MS
        local lastError

        while GetGameTimer() < deadline do
            Wait(DETECT_INTERVAL_MS)
            result, lastError = detectOnce()
            if result then
                return onFound(result.framework, result.name, result.variant)
            end
        end

        local seconds = math.floor(DETECT_TIMEOUT_MS / 1000)
        if lastError then
            printError(lastError)
        elseif Config.Framework.AutoDetect then
            printError(("No supported framework found after %ds. force_lib supports ESX (es_extended), QBCore (qb-core) and QBX (qbx_core). Ensure your framework BEFORE force_lib in server.cfg. For a custom framework set Config.Framework.AutoDetect = false and fill in Config.Framework."):format(seconds))
        else
            printError(("Config.Framework.Resource '%s' did not start within %ds. Ensure it BEFORE force_lib in server.cfg."):format(tostring(Config.Framework.Resource), seconds))
        end
        printError("force_lib is NOT initialised - resources that depend on it will not work.")
    end)
end

-- [[ Target system: 'auto' picks the first running one; an explicit choice wins when that resource is running. ]]
local AUTO_TARGET_ORDER = { 'ox_target', 'qb-target', 'contextmenu' }
local LEGACY_TARGET_ORDER = { 'qb-target', 'ox_target', 'contextmenu' }

function ForceLibBridge.ResolveTarget()
    local configured = Config.TargetSystem
    if type(configured) ~= 'string' or configured == '' then return end

    if configured == 'auto' then
        for _, resource in ipairs(AUTO_TARGET_ORDER) do
            if isStarted(resource) then
                Config.TargetSystem = resource
                return
            end
        end
        Config.TargetSystem = ''
        return
    end

    if isStarted(configured) then return end

    -- Legacy behaviour: fall back to whichever supported target system is running.
    for _, resource in ipairs(LEGACY_TARGET_ORDER) do
        if isStarted(resource) then
            Config.TargetSystem = resource
            return
        end
    end
end
