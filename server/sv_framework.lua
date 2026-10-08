-- The framework file NEEDS to be loaded last so every module exists before lib:Init runs.
lib:DefineModules()
ForceLibBridge.GuardModule(lib.FrameworkBased, 'FrameworkBased', nil, nil)

if ForceLibBridge.CheckResourceName() then
    ForceLibBridge.Detect(function(framework, frameworkName, frameworkVariant)
        lib:Init(framework, frameworkName, frameworkVariant)
    end)
end
