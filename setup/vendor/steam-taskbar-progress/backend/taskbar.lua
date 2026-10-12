local logger            = require("logger")
local ffi               = require("ffi")
local libs              = require("ffi_defs")

local user32            = libs.user32
local ole32             = libs.ole32

local CLSID_TaskbarList = ffi.new("CLSID",
    { 0x56FDF344, 0xFD6D, 0x11D0, { 0x95, 0x8A, 0x00, 0x60, 0x97, 0xC9, 0xA0, 0x90 } })
local IID_ITaskbarList  = ffi.new("IID",
    { 0x56FDF342, 0xFD6D, 0x11D0, { 0x95, 0x8A, 0x00, 0x60, 0x97, 0xC9, 0xA0, 0x90 } })
local IID_ITaskbarList3 = ffi.new("IID",
    { 0xEA1AFB91, 0x9E28, 0x4B86, { 0x90, 0xE9, 0x9E, 0x9F, 0x8A, 0x5E, 0xEF, 0xAF } })

logger:info("[taskbar] CoInitializeEx (COINIT_APARTMENTTHREADED)")
local hr = ole32.CoInitializeEx(nil, 2)
logger:info(string.format("[taskbar] CoInitializeEx hr=0x%08X%s",
    hr,
    hr == 0 and " (S_OK)" or hr == 1 and " (S_FALSE: already initialized on this thread)" or ""))
if hr < 0 then
    error(string.format("CoInitializeEx failed: 0x%08X", hr))
end

local ppv = ffi.new("void*[1]")

logger:info("[taskbar] CoCreateInstance(CLSID_TaskbarList)")
hr = ole32.CoCreateInstance(CLSID_TaskbarList, nil, 1, IID_ITaskbarList, ppv)
logger:info(string.format("[taskbar] CoCreateInstance hr=0x%08X  ptr=%s", hr, tostring(ppv[0])))
if hr ~= 0 then
    error(string.format("CoCreateInstance failed: 0x%08X", hr))
end

local tb = ffi.cast("ITaskbarList3*", ppv[0])
logger:info(string.format("[taskbar] QueryInterface(IID_ITaskbarList3) on %s", tostring(tb)))
hr = tb.lpVtbl.QueryInterface(tb, IID_ITaskbarList3, ppv)
logger:info(string.format("[taskbar] QueryInterface hr=0x%08X  ptr=%s", hr, tostring(ppv[0])))
logger:info("[taskbar] Releasing ITaskbarList ref")
tb.lpVtbl.Release(tb)
if hr ~= 0 then
    error(string.format("QueryInterface(ITaskbarList3) failed: 0x%08X", hr))
end

tb = ffi.cast("ITaskbarList3*", ppv[0])
logger:info(string.format("[taskbar] HrInit on %s", tostring(tb)))
hr = tb.lpVtbl.HrInit(tb)
logger:info(string.format("[taskbar] HrInit hr=0x%08X", hr))
if hr ~= 0 then
    tb.lpVtbl.Release(tb)
    error(string.format("HrInit failed: 0x%08X", hr))
end

logger:info("[taskbar] Caching vtable function pointers")
local tb_SetProgressValue = tb.lpVtbl.SetProgressValue
local tb_SetProgressState = tb.lpVtbl.SetProgressState
local tb_Release          = tb.lpVtbl.Release
logger:info(string.format("[taskbar] SetProgressValue=%s  SetProgressState=%s  Release=%s",
    tostring(tb_SetProgressValue), tostring(tb_SetProgressState), tostring(tb_Release)))

local steam_hwnd = nil
local deferred_percent = nil
local waiting_for_window = false
local kernel32 = libs.kernel32

local function is_steam_window(hwnd)
    if hwnd == nil or user32.IsWindow(hwnd) == 0 then return false end
    local pid = ffi.new("DWORD[1]")
    user32.GetWindowThreadProcessId(hwnd, pid)
    local process = kernel32.OpenProcess(0x1000, 0, pid[0])
    if process == nil then return false end
    local path = ffi.new("char[32768]")
    local size = ffi.new("DWORD[1]", 32768)
    local ok = kernel32.QueryFullProcessImageNameA(process, 0, path, size)
    kernel32.CloseHandle(process)
    if ok == 0 then return false end
    return ffi.string(path):lower():match("[^/\\]+$") == "steamwebhelper.exe"
end

local function find_steam()
    if is_steam_window(steam_hwnd) then
        waiting_for_window = false
        return true
    end
    local hwnd = user32.FindWindowA("SDL_app", "Steam")
    if not is_steam_window(hwnd) then
        -- Themes can rename the main window. Choose the largest visible Steam
        -- CEF window rather than depending on its title.
        local candidate = nil
        local largest_area = 0
        local cursor = nil
        repeat
            cursor = user32.FindWindowExA(nil, cursor, "SDL_app", nil)
            if cursor ~= nil and user32.IsWindowVisible(cursor) ~= 0 and is_steam_window(cursor) then
                local rect = ffi.new("TASKBAR_RECT[1]")
                if user32.GetWindowRect(cursor, rect) ~= 0 then
                    local area = (rect[0].right - rect[0].left) * (rect[0].bottom - rect[0].top)
                    if area > largest_area then
                        candidate, largest_area = cursor, area
                    end
                end
            end
        until cursor == nil
        hwnd = candidate
    end
    if hwnd ~= nil then
        steam_hwnd = hwnd
        waiting_for_window = false
        logger:info("[taskbar] Main Steam window resolved")
        return true
    end
    steam_hwnd = nil
    if not waiting_for_window then
        logger:info("[taskbar] Waiting for Steam's main window; progress will resume when it is available")
    end
    waiting_for_window = true
    return false
end

local function set_progress_percent(percent)
    logger:info("[taskbar] set_progress_percent(" .. percent .. ")")
    if type(percent) ~= "number" or percent ~= percent or (percent ~= -1 and percent ~= -2 and (percent < 0 or percent > 100)) then
        logger:error("[taskbar] Invalid download percentage")
        return false
    end
    deferred_percent = percent
    if not find_steam() then return false end
    deferred_percent = nil
    local hr_s
    if percent == -1 then
        logger:info("[taskbar] SetProgressState -> NOPROGRESS")
        hr_s = tb_SetProgressState(tb, steam_hwnd, 0)
    elseif percent == -2 then
        logger:info("[taskbar] SetProgressState -> PAUSED")
        hr_s = tb_SetProgressState(tb, steam_hwnd, 8)
    elseif percent == 100 then
        logger:info("[taskbar] SetProgressState -> NOPROGRESS + FlashWindow")
        hr_s = tb_SetProgressState(tb, steam_hwnd, 0)
        user32.FlashWindow(steam_hwnd, 1)
    else
        logger:info(string.format("[taskbar] SetProgressState -> NORMAL, SetProgressValue(%d/100)", percent))
        tb_SetProgressState(tb, steam_hwnd, 2)
        hr_s = tb_SetProgressValue(tb, steam_hwnd, percent, 100)
    end
    if hr_s ~= nil and hr_s ~= 0 then
        logger:error(string.format("[taskbar] COM call returned 0x%08X", hr_s))
    end
    return true
end

local function cleanup()
    logger:info("[taskbar] Releasing ITaskbarList3")
    tb_Release(tb)
end

return {
    set_progress_percent = set_progress_percent,
    resume_pending = function()
        if deferred_percent ~= nil then return set_progress_percent(deferred_percent) end
        return true
    end,
    get_status = function()
        return waiting_for_window and "Waiting for Steam window" or "Ready"
    end,
    cleanup              = cleanup,
}
