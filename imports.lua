if not IsDuplicityVersion() then
    Funcs, Streaming, FrameworkBased, Math, Admin, DefaultLocale = exports['force_lib']:Fetch()
else
    Funcs, FrameworkBased = exports['force_lib']:Fetch()
end