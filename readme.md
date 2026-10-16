# Force Library

Force library is a resource where the "framework" and base functions is, i've made this library purley for standalone support and more open customization in my resources and if you like the library it can even be used in you're own resources!

## Documentation

https://force-developing.gitbook.io/docs/force-library

## Download

https://github.com/Force-Developing/force_lib/releases

## Optimization

Sits on 0.0ms on idle
## Upgrading from 2.1

Nothing was removed or renamed. Highlights (full list: https://force-developing.gitbook.io/docs/force-library):

- `Fetch()` / `imports.lua` always return complete function tables, even before the framework is loaded.
- The server decides the framework and target system; a framework that starts late or restarts is picked up. Until then `FrameworkBased` functions return `nil` with a warning. New: `Funcs:IsReady()`, `Funcs:AwaitReady(ms)`.
- Callback waits are bounded: `setr force_lib:callbackTimeout` (client `TriggerCallback`, returns `nil`) and `set force_lib:clientCallbackTimeout` (server `TriggerClientCallback`, request dropped). Both default to 120000 ms; `cb` is only called with an answer.
- `CheckAdmin()` always returns a boolean. `EntityPlayAnim` deletes its prop when it ends.
- Optional `set force_lib:webhookAllowlist "url1,url2"` limits which Discord webhooks client logs may use.
