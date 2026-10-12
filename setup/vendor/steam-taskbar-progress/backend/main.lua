---@diagnostic disable-next-line: undefined-global
jit.off()

local logger     = require("logger")
local millennium = require("millennium")

local taskbar

local function on_frontend_loaded()
    logger:info("[main] Frontend loaded")
    if taskbar then taskbar.resume_pending() end
end

local function on_load()
    logger:info("[main] Backend loaded")
    millennium.ready()
end

local on_unload = function() end

logger:info("[main] Loading taskbar module")
local ok
ok, taskbar = pcall(require, "taskbar")

if not ok then
    local load_error = taskbar
    taskbar = nil
    logger:error("[main] Taskbar module failed to load: " .. tostring(load_error))
    function set_progress_percent(_) return false end
    function get_plugin_status() return "Not ready: " .. tostring(load_error) end
else
    function set_progress_percent(percent) return taskbar.set_progress_percent(percent) end
    function get_plugin_status() return taskbar.get_status() end
    on_unload = function()
        logger:info("[main] Unloading")
        taskbar.cleanup()
    end
    logger:info("[main] Plugin ready")
end

return { on_frontend_loaded = on_frontend_loaded, on_load = on_load, on_unload = on_unload }
