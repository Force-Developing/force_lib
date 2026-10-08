-- [[ Framework + target system detection, shared by server and client. ]]
-- The server decides: it sees every installed resource, while a client only knows the resources it has mounted
-- so far (a framework ensured after force_lib reads "missing" there). The decision is replicated through
-- GlobalState and the client waits for it, then for that resource to start on the client. Neither side gives up:
-- a framework ensured later (or restarted) is picked up when it starts, and its core object is fetched again.
ForceLibBridge = {}

local IS_SERVER = IsDuplicityVersion()
local STATE_KEY = 'force_lib:framework'
local POLL_MS = 250
local WARN_EVERY_MS = 15000
local READY_POLL_MS = 100

local function printError(message)
    print(('^1[force_lib] ERROR: %s^0'):format(message))
end
ForceLibBridge.PrintError = printError

local function printWarning(message)
    print(('^3[force_lib] WARNING: %s^0'):format(message))
end
ForceLibBridge.PrintWarning = printWarning

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

-- Fetches an export through its export event instead of `exports[resource]`. The exports proxy caches functions per
-- resource name and only clears that cache when a resource of the SAME name stops, so `exports['qb-core']` served
-- by qbx_core would keep returning a dead function after qbx_core restarts.
local function freshExport(resource, name)
    local fn
    TriggerEvent(('__cfx_export_%s_%s'):format(resource, name), function(exported) fn = exported end)
    if not fn then error(('No such export %s in resource %s'):format(name, resource), 0) end
    return fn
end

-- Order matters: qbx_core is checked before qb-core, because qbx_core `provide`s qb-core and GetResourceState('qb-core')
-- reports qbx_core's state. QBX is exposed as 'QBCore' through its qb-core bridge, so GetFramework() keeps returning 'QBCore'.
local CANDIDATES = {
    {
        resource = 'es_extended', name = 'ESX',
        get = function() return freshExport('es_extended', 'getSharedObject')() end,
    },
    {
        resource = 'qbx_core', name = 'QBCore', variant = 'QBX',
        get = function() return freshExport('qb-core', 'GetCoreObject')() end,
        hint = "qbx_core is running but its qb-core bridge is unavailable. force_lib needs the bridge - make sure the convar qbx:enablebridge is not set to false.",
    },
    {
        resource = 'qb-core', name = 'QBCore',
        get = function() return freshExport('qb-core', 'GetCoreObject')() end,
    },
}

local function customCandidate()
    local resource = Config.Framework.Resource
    return {
        resource = resource, name = 'Custom',
        get = function()
            local framework
            if Config.Framework.Export then
                framework = freshExport(resource, Config.Framework.Export)()
            elseif Config.Framework.Event then
                TriggerEvent(Config.Framework.Event, function(obj) framework = obj end)
            end
            return framework
        end,
        hint = ("'%s' is started but returned no core object - check Config.Framework.Export / Config.Framework.Event."):format(tostring(resource)),
    }
end

local function candidatesFor(resource)
    if not Config.Framework.AutoDetect then return { customCandidate() } end
    if not resource then return CANDIDATES end
    for _, candidate in ipairs(CANDIDATES) do
        if candidate.resource == resource then return { candidate } end
    end
    return {}
end

-- Returns { framework, candidate } for the first started candidate whose core object can be fetched.
local function detectOnce(resource)
    local firstError
    for _, candidate in ipairs(candidatesFor(resource)) do
        if isStarted(candidate.resource) then
            local ok, obj = pcall(candidate.get)
            if ok and obj then return { framework = obj, candidate = candidate } end
            firstError = firstError or candidate.hint or ("'%s' is started but its core object could not be fetched: %s"):format(candidate.resource, tostring(obj))
        end
    end
    return nil, firstError
end

-- [[ Target system: 'auto' picks the first running one; an explicit choice wins when that resource is running. ]]
local AUTO_TARGET_ORDER = { 'ox_target', 'qb-target', 'contextmenu' }
local LEGACY_TARGET_ORDER = { 'qb-target', 'ox_target', 'contextmenu' }
local configuredTarget = Config.TargetSystem

local function resolveTarget()
    local configured = configuredTarget
    if type(configured) ~= 'string' or configured == '' then return configured end

    if configured == 'auto' then
        for _, resource in ipairs(AUTO_TARGET_ORDER) do
            if isStarted(resource) then return resource end
        end
        return ''
    end

    if isStarted(configured) then return configured end

    -- Legacy behaviour: fall back to whichever supported target system is running.
    for _, resource in ipairs(LEGACY_TARGET_ORDER) do
        if isStarted(resource) then return resource end
    end
    return configured
end

-- Kept for compatibility. The server resolves the target system and the client takes the server's choice.
function ForceLibBridge.ResolveTarget()
    Config.TargetSystem = resolveTarget()
end

local function isTargetResource(resource)
    if resource == configuredTarget then return true end
    for _, name in ipairs(AUTO_TARGET_ORDER) do
        if name == resource then return true end
    end
    return false
end

--- Waits (inside a thread) until force_lib is initialised, at most timeoutMs. Returns whether it is ready.
function ForceLibBridge.AwaitReady(timeoutMs)
    if lib.Ready then return true end
    local deadline = GetGameTimer() + (tonumber(timeoutMs) or 0)
    while not lib.Ready and GetGameTimer() < deadline do Wait(READY_POLL_MS) end
    return lib.Ready == true
end

local warnedNotReady = {}

--- Wraps every function of a module so that a call made while force_lib is not ready (framework not started yet,
--- or restarting) returns nil with a one-time warning instead of indexing a missing or dead core object.
--- Functions listed in `waitFor` yield anyway, so they first wait up to waitMs for force_lib. Functions listed in
--- `passThrough` handle the not-ready case themselves.
function ForceLibBridge.GuardModule(module, moduleName, waitFor, waitMs, passThrough)
    for key, fn in pairs(module) do
        if type(fn) == 'function' and key ~= 'Init' and not (passThrough and passThrough[key]) then
            module[key] = function(...)
                if not lib.Ready and not (waitFor and waitFor[key] and ForceLibBridge.AwaitReady(waitMs)) then
                    local name = moduleName .. ':' .. key
                    if not warnedNotReady[name] then
                        warnedNotReady[name] = true
                        printWarning(("%s() was called by %s before force_lib had loaded the framework and returned nil. Ensure your framework before force_lib in server.cfg."):format(name, tostring(GetInvokingResource() or GetCurrentResourceName())))
                    end
                    return nil
                end
                return fn(...)
            end
        end
    end
end

-- [[ Server: decide, publish, keep watching ]]
local function detectServer(onFound)
    local current -- the candidate in use
    local waiting = false

    local function publish()
        GlobalState[STATE_KEY] = current and {
            resource = current.resource, name = current.name, variant = current.variant, target = Config.TargetSystem,
        } or nil
    end

    local function found(result)
        current = result.candidate
        if SQL_PRESETS[current.name] then mergeSQL(SQL_PRESETS[current.name]) end
        Config.TargetSystem = resolveTarget()
        publish()
        onFound(result.framework, current.name, current.variant)
    end

    local function waitForFramework()
        if waiting then return end
        waiting = true
        CreateThread(function()
            local nextWarning = GetGameTimer() + WARN_EVERY_MS
            local announced = false
            while not lib.Ready do
                Wait(POLL_MS)
                if lib.Ready then break end
                local result, lastError = detectOnce(current and current.resource)
                if result then found(result) break end
                if GetGameTimer() >= nextWarning then
                    if lastError then
                        printError(lastError)
                    elseif current then
                        printError(("%s is not started. Waiting for it to start again."):format(current.resource))
                    elseif Config.Framework.AutoDetect then
                        printError("No supported framework is started yet. force_lib supports ESX (es_extended), QBCore (qb-core) and QBX (qbx_core). Ensure your framework BEFORE force_lib in server.cfg. For a custom framework set Config.Framework.AutoDetect = false and fill in Config.Framework.")
                    else
                        printError(("Config.Framework.Resource '%s' is not started yet. Ensure it BEFORE force_lib in server.cfg."):format(tostring(Config.Framework.Resource)))
                    end
                    if not announced then
                        printError("force_lib is NOT initialised yet - resources that depend on it will not work until the framework starts. Still waiting.")
                        announced = true
                    end
                    nextWarning = GetGameTimer() + WARN_EVERY_MS
                end
            end
            waiting = false
        end)
    end

    -- Also replaces whatever a previous run of force_lib left in GlobalState.
    local result = detectOnce()
    if result then found(result) else publish() waitForFramework() end

    -- A framework ensured later initialises force_lib inside its own start event, i.e. before any resource ensured
    -- after it loads. A restarted framework gets its core object fetched again (the old one is dead).
    AddEventHandler('onServerResourceStart', function(resource)
        if not lib.Ready and (not current or resource == current.resource) then
            local fresh = detectOnce(current and current.resource)
            if fresh then found(fresh) end
        elseif lib.Ready and isTargetResource(resource) then
            Config.TargetSystem = resolveTarget()
            publish()
        end
    end)

    AddEventHandler('onServerResourceStop', function(resource)
        if current and resource == current.resource then
            lib.Ready = false
            printWarning(("%s stopped - force_lib waits for it to start again."):format(resource))
            waitForFramework()
        elseif lib.Ready and isTargetResource(resource) then
            -- the stopping resource still reports itself as started inside its own stop event
            SetTimeout(0, function()
                Config.TargetSystem = resolveTarget()
                publish()
            end)
        end
    end)
end

-- [[ Client: follow the server's decision ]]
local function detectClient(onFound)
    local decision
    local loading = false

    local function init(result)
        if SQL_PRESETS[decision.name] then mergeSQL(SQL_PRESETS[decision.name]) end
        if decision.target ~= nil then Config.TargetSystem = decision.target end
        onFound(result.framework, result.candidate.name, result.candidate.variant)
    end

    -- Waits for the decided framework to be started on this client, then initialises.
    local function load()
        if loading or not decision or lib.Ready then return end
        loading = true
        CreateThread(function()
            local nextWarning = GetGameTimer() + WARN_EVERY_MS
            while decision and not lib.Ready do
                local result, err
                if isStarted(decision.resource) then
                    result, err = detectOnce(decision.resource)
                    if result then init(result) break end
                end
                if GetGameTimer() >= nextWarning then
                    printWarning(("Still waiting for %s on this client%s"):format(decision.resource, err and (': ' .. err) or '.'))
                    nextWarning = GetGameTimer() + WARN_EVERY_MS
                end
                Wait(POLL_MS)
            end
            loading = false
        end)
    end

    local function apply(value)
        if type(value) ~= 'table' or type(value.resource) ~= 'string' then return end
        local changed = not decision or decision.resource ~= value.resource
        decision = value
        if value.target ~= nil then Config.TargetSystem = value.target end
        if changed then
            local result = isStarted(value.resource) and detectOnce(value.resource)
            if result then init(result) else load() end
        end
    end

    AddStateBagChangeHandler(STATE_KEY, 'global', function(_, _, value) apply(value) end)

    -- Usually the server decided long ago and the framework already runs here: this initialises synchronously, so
    -- resources that start after force_lib find it ready at their load.
    apply(GlobalState[STATE_KEY])

    if not decision then
        CreateThread(function()
            local nextWarning = GetGameTimer() + WARN_EVERY_MS
            while not decision do
                Wait(500)
                apply(GlobalState[STATE_KEY])
                if not decision and GetGameTimer() >= nextWarning then
                    printWarning("Still waiting for the server to detect the framework (see the server console).")
                    nextWarning = GetGameTimer() + WARN_EVERY_MS
                end
            end
        end)
    end

    -- Initialises inside the framework's own start event (resources after it see force_lib ready), and fetches a
    -- fresh core object when the framework restarts.
    AddEventHandler('onClientResourceStart', function(resource)
        if decision and resource == decision.resource and not lib.Ready then
            local result = detectOnce(resource)
            if result then init(result) else load() end
        end
    end)

    AddEventHandler('onClientResourceStop', function(resource)
        if decision and resource == decision.resource then
            lib.Ready = false
            load()
        end
    end)
end

-- Calls onFound(framework, name, variant) whenever the framework (re)becomes available: synchronously when it is
-- already started, otherwise as soon as it starts. Never gives up.
function ForceLibBridge.Detect(onFound)
    if IS_SERVER then return detectServer(onFound) end
    return detectClient(onFound)
end
