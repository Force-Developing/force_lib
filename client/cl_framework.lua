-- The framework file NEEDS to be loaded last so every module exists before lib:Init runs.
if ForceLibBridge.CheckResourceName() then
    ForceLibBridge.Detect(function(framework, frameworkName, frameworkVariant)
        ForceLibBridge.ResolveTarget()
        lib:Init(framework, frameworkName, frameworkVariant)
    end)
end
