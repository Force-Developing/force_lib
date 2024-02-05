fx_version 'cerulean'
lua54 'yes'
game 'gta5'

author 'Force3883'
description 'Library for ^2Force^1 FiveM resources'

github 'https://github.com/Force-Developing/force_lib'
versioncheck 'https://raw.githubusercontent.com/Force-Developing/force_lib/main/version.txt'
name '^2force_lib'
version '2.0'

dependencys {
    'oxmysql' -- This can be oxmysql or mysql-async, i recommend oxmysql for better performance!
}

client_scripts {
    -- [[ STARTER FILES ]]
    'client/cl_lib.lua',

    -- [[ FUNCS ]]
    'client/funcs/cl_funcs.lua',
    'client/funcs/cl_frameworkbased.lua',
    'client/funcs/cl_streaming.lua',

    -- [[ MODULES ]]
    'client/modules/cl_math.lua',
    'client/modules/cl_entitier.lua',
    'client/modules/cl_keys.lua',

    -- [[ ADMIN MANAGER ]]
    'client/admin/cl_adminmanager.lua',

    -- The framework file NEEDS to be loaded last to initialize the lib properly
    'client/cl_framework.lua'
}

server_scripts {
    -- [[ DEPENDENCIES (For some functions) ]]
    '@oxmysql/lib/MySQL.lua', -- Can me mysql-async aswell but i really recommend switching to oxmysql if you haven't already

    -- [[ STARTER FILES ]]
    'server/sv_versionChecker.lua',
    'server/sv_lib.lua',

    -- [[ FUNCS ]]
    'server/funcs/sv_funcs.lua',
    'server/funcs/sv_frameworkbased.lua',

    -- [[ ADMIN MANAGER ]]
    'server/admin/sv_adminmanager.lua',

    -- The framework file NEEDS to be loaded last to initialize the lib properly
    'server/sv_framework.lua'
}

shared_scripts {
    'config.lua'
}

files {
    'imports.lua' -- This is for resources who decide to import the lib via the fxmanifest.lua rather then using the export
}