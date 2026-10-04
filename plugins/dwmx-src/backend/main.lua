local logger = require("logger")
local millennium = require("millennium")

local ffi = require("ffi")

ffi.cdef[[
typedef int BOOL;
typedef unsigned long DWORD;
typedef long LONG;
typedef unsigned long ULONG;
typedef void* HANDLE;
typedef void* HWND;
typedef const wchar_t* LPCWSTR;
typedef wchar_t WCHAR;
typedef unsigned __int64 ULONG_PTR;
typedef __int64 LONG_PTR;
typedef LONG_PTR LPARAM;
typedef unsigned int UINT;
typedef long HRESULT;
typedef int INT;
typedef unsigned __int64 SIZE_T;
typedef char CHAR;
typedef CHAR *LPSTR;

HANDLE CreateToolhelp32Snapshot(DWORD dwFlags, DWORD th32ProcessID);
BOOL Process32FirstW(HANDLE hSnapshot, void* lppe);
BOOL Process32NextW(HANDLE hSnapshot, void* lppe);
BOOL CloseHandle(HANDLE hObject);

typedef struct {
    DWORD dwSize;
    DWORD cntUsage;
    DWORD th32ProcessID;
    ULONG_PTR th32DefaultHeapID;
    DWORD th32ModuleID;
    DWORD cntThreads;
    DWORD th32ParentProcessID;
    LONG pcPriClassBase;
    DWORD dwFlags;
    WCHAR szExeFile[260];
} PROCESSENTRY32W;

static const int TH32CS_SNAPPROCESS = 0x00000002;

typedef int (__stdcall *WNDENUMPROC)(HWND, LPARAM);
BOOL EnumWindows(WNDENUMPROC lpEnumFunc, LPARAM lParam);
BOOL IsZoomed(HWND hWnd);
BOOL IsWindow(HWND hWnd);
BOOL IsWindowVisible(HWND hWnd);
LONG_PTR GetWindowLongPtrW(HWND hWnd, int nIndex);
LONG_PTR SetWindowLongPtrW(HWND hWnd, int nIndex, LONG_PTR dwNewLong);
int GetClassNameW(HWND hWnd, WCHAR* lpClassName, int nMaxCount);
DWORD GetWindowThreadProcessId(HWND hWnd, DWORD* lpdwProcessId);
int WideCharToMultiByte(UINT CodePage, DWORD dwFlags, const WCHAR *lpWideCharStr, int cchWideChar, char *lpMultiByteStr, int cbMultiByte, const char *lpDefaultChar, int *lpUsedDefaultChar);
HRESULT DwmSetWindowAttribute(HWND hwnd, DWORD dwAttribute, void* pvAttribute, DWORD cbAttribute);

typedef enum _WINDOWCOMPOSITIONATTRIB {
    WCA_ACCENT_POLICY = 19
} WINDOWCOMPOSITIONATTRIB;

typedef struct _ACCENTPOLICY {
    INT nAccentState;
    INT nFlags;
    DWORD nColor;
    INT nAnimationId;
} ACCENTPOLICY;

typedef struct _WINDOWCOMPOSITIONATTRIBDATA {
    WINDOWCOMPOSITIONATTRIB nAttribute;
    void* pData;
    SIZE_T ulDataSize;
} WINDOWCOMPOSITIONATTRIBDATA;

BOOL SetWindowCompositionAttribute(HWND hWnd, WINDOWCOMPOSITIONATTRIBDATA* data);
BOOL SetWindowPos(HWND hWnd, HWND hWndInsertAfter, int X, int Y, int cx, int cy, UINT uFlags);
]]

local C = ffi.C
local user32 = ffi.load("user32")
local dwmapi = ffi.load("dwmapi")

local CP_UTF8 = 65001
local TH32CS_SNAPPROCESS = 0x00000002
local WCA_ACCENT_POLICY = 19
local ACCENT_ENABLE_BLURBEHIND = 3
local ACCENT_FLAG_ENABLE_BLURBEHIND = 0x20
local DWMWA_WINDOW_CORNER_PREFERENCE = 33
local DWMWCP_DONOTROUND = 1
local DWMWCP_ROUND = 2
local DWMWA_SYSTEMBACKDROP_TYPE = 38
local DWMSBT_MAINWINDOW = 2      -- Mica
local DWMSBT_TRANSIENTWINDOW = 3 -- Acrylic

local IS_CORNER_PREFERENCE_COMPATIBLE = true
local IS_BLUR_BEHIND_COMPATIBLE = true

-- Global state for window enumeration
local current_target_pids = {}

-- Single reusable callback - created once and reused
local window_enum_callback = nil
local patched_windows = {}
local patch_stats = { applied = 0, unchanged = 0, deferred = 0, failed = 0 }

-- cast wchar to utf8 string. 
-- 260 == MAX_PATH, we assume steam is not running from a path longer than that.
-- that is likely a safe assumption (I hope).
local function wchar_to_utf8(wstr)
    local outbuf = ffi.new("char[260]")
    local res = C.WideCharToMultiByte(CP_UTF8, 0, wstr, -1, outbuf, 260, nil, nil)
    if res == 0 then return nil end
    return ffi.string(outbuf)
end

-- find all process IDs matching the given executable name (case insensitive)
local function find_pids_by_name(exe_name)
    local pids = {}
    local snap = C.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
    if snap == ffi.cast("HANDLE", -1) then
        logger:error("CreateToolhelp32Snapshot failed")
        return pids
    end
    local success, result = pcall(function()
        local entry = ffi.new("PROCESSENTRY32W")
        entry.dwSize = ffi.sizeof(entry)

        local ok = C.Process32FirstW(snap, entry)
        while ok ~= 0 do
            local name = wchar_to_utf8(entry.szExeFile)
            if name then
                if name:lower() == exe_name:lower() then
                    table.insert(pids, tonumber(entry.th32ProcessID))
                end
            end
            ok = C.Process32NextW(snap, entry)
        end
        return pids
    end)
    C.CloseHandle(snap) -- Always cleanup handle
    if not success then
        logger:error("Error during process enumeration: " .. tostring(result))
        return {}
    end
    return result
end

local function EnableBlurBehind(hwnd)
    local policy = ffi.new("ACCENTPOLICY")
    policy.nAccentState = 4
    policy.nFlags = ACCENT_FLAG_ENABLE_BLURBEHIND
    -- Mantle tint at 50%. The previous 88% tint plus page fills hid the
    -- acrylic. The theme now uses one 55% tint for the main background.
    policy.nColor = 0x80251818
    policy.nAnimationId = 0

    local data = ffi.new("WINDOWCOMPOSITIONATTRIBDATA")
    data.nAttribute = WCA_ACCENT_POLICY
    data.pData = ffi.cast("void*", ffi.cast("ACCENTPOLICY*", policy))
    data.ulDataSize = ffi.sizeof(policy)

    local ok
    local s, fn = pcall(function() return user32.SetWindowCompositionAttribute end)
    if s and fn ~= nil then
        ok = fn(hwnd, data)
    else
        ok = C.SetWindowCompositionAttribute(hwnd, data)
    end
    return ok ~= 0
end

local function EnableRoundedCorners(hwnd)
    -- Rounding a maximized window leaves 1px edge lines with the backdrop, so
    -- only round windows that are not maximized.
    local pref = ffi.new("int[1]", C.IsZoomed(hwnd) ~= 0 and DWMWCP_DONOTROUND or DWMWCP_ROUND)
    local hr = dwmapi.DwmSetWindowAttribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, pref, ffi.sizeof(pref))
    return hr == 0
end

local function EnableWindowBackdrop(hwnd)
    -- API success alone does not prove this fallback renders on Steam's CEF.
    local bt = ffi.new("int[1]", DWMSBT_TRANSIENTWINDOW)
    local hr = dwmapi.DwmSetWindowAttribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, bt, ffi.sizeof(bt))
    return hr == 0
end

local function PatchWindowContext(hwnd)
    -- Steam pre-creates its popup and supernav windows while hidden and
    -- reuses them on hover, without ever calling window.open. Those windows
    -- must be patched too, or they render the theme's translucent surfaces
    -- straight onto the sharp desktop. Patch SDL_app windows regardless of
    -- visibility, then promote each one the first time it is seen visible.
    local class_name = ffi.new("WCHAR[260]")
    C.GetClassNameW(hwnd, class_name, 260)
    if wchar_to_utf8(class_name) ~= "SDL_app" then return end
    local was_visible = C.IsWindowVisible(hwnd) ~= 0
    local pid = ffi.new("DWORD[1]")
    C.GetWindowThreadProcessId(hwnd, pid)
    local key = tostring(hwnd)
    local zoomed = C.IsZoomed(hwnd) ~= 0
    local previous = patched_windows[key]
    local exstyle = tonumber(user32.GetWindowLongPtrW(hwnd, -20))
    local bit = require("bit")
    -- Steam's Composited creation flag adds legacy bottom-to-top GDI double
    -- buffering. CEF already uses GPU composition. Keep transparent-parent
    -- support, but remove the second buffering path before applying acrylic.
    local has_composited = bit.band(exstyle, 0x02000000) ~= 0
    if previous and previous.pid == tonumber(pid[0]) and not has_composited then
        if previous.zoomed ~= zoomed then
            EnableRoundedCorners(hwnd)
            previous.zoomed = zoomed
        end
        if was_visible and not previous.seen_visible then
            -- Accents set before DWM ever composited the window can be
            -- dropped. Re-apply once at first show, with the frame refresh,
            -- so a reused popup never appears without its blur.
            previous.promote_attempts = (previous.promote_attempts or 0) + 1
            local ok = EnableBlurBehind(hwnd)
            local SWP_NOSIZE_NOMOVE_NOZORDER_NOACTIVATE_FRAMECHANGED = 0x37
            if user32.SetWindowPos(hwnd, nil, 0, 0, 0, 0, SWP_NOSIZE_NOMOVE_NOZORDER_NOACTIVATE_FRAMECHANGED) == 0 then
                logger:error("SetWindowPos promote refresh failed")
                patch_stats.failed = patch_stats.failed + 1
                return
            end
            if ok then
                previous.seen_visible = true
                patch_stats.applied = patch_stats.applied + 1
                logger:info("Promoted acrylic on first show of " .. key)
            else
                -- Bounded retries: a permanent failure must not turn the
                -- show callbacks into a frame-refresh storm.
                patch_stats.failed = patch_stats.failed + 1
                if previous.promote_attempts >= 5 then
                    previous.seen_visible = true
                    logger:error("Acrylic promote failed five times for " .. key)
                end
            end
            return
        end
        patch_stats.unchanged = patch_stats.unchanged + 1
        return
    end
    if has_composited then
        user32.SetWindowLongPtrW(hwnd, -20, bit.band(exstyle, bit.bnot(0x02000000)))
        if bit.band(tonumber(user32.GetWindowLongPtrW(hwnd, -20)), 0x02000000) ~= 0 then
            patch_stats.failed = patch_stats.failed + 1
            logger:error("Could not remove WS_EX_COMPOSITED")
            return
        end
    end
    if IS_CORNER_PREFERENCE_COMPATIBLE then
        local ok = EnableRoundedCorners(hwnd)
        if not ok then logger:error("EnableRoundedCorners failed") end
    end
    -- Legacy acrylic accent (ACCENT_ENABLE_ACRYLICBLURBEHIND) is the variant
    -- that actually produces frosted blur on current Windows 11 Steam windows;
    -- DWMWA_SYSTEMBACKDROP_TYPE is a no-op on these opaque CEF windows.
    local ok = EnableBlurBehind(hwnd)
    if not ok then
        logger:error("EnableBlurBehind failed, falling back to system backdrop")
        local ok2 = EnableWindowBackdrop(hwnd)
        if not ok2 then logger:error("EnableWindowBackdrop failed") end
    end
    -- The accent only takes effect once DWM recomposites the window. Applied
    -- after the window's composition already exists (plugin load, restarts)
    -- it stays inert until a frame change - the "blur vanished after a
    -- restart" bug. SWP_FRAMECHANGED forces the refresh without moving,
    -- resizing, restacking or focusing the window.
    local SWP_NOSIZE_NOMOVE_NOZORDER_NOACTIVATE_FRAMECHANGED = 0x37
    if user32.SetWindowPos(hwnd, nil, 0, 0, 0, 0, SWP_NOSIZE_NOMOVE_NOZORDER_NOACTIVATE_FRAMECHANGED) == 0 then
        logger:error("SetWindowPos frame refresh failed")
        patch_stats.failed = patch_stats.failed + 1
        return
    end
    if ok then
        patched_windows[key] = { hwnd = hwnd, pid = tonumber(pid[0]), zoomed = zoomed, seen_visible = was_visible }
        patch_stats.applied = patch_stats.applied + 1
        logger:info("Applied acrylic once to " .. key)
    else
        patch_stats.failed = patch_stats.failed + 1
    end
end

local function init_window_enum_callback()
    if window_enum_callback then return end

    window_enum_callback = ffi.cast("WNDENUMPROC", function(hwnd, lParam)
        local out = ffi.new("DWORD[1]")
        C.GetWindowThreadProcessId(hwnd, out)
        local window_pid = tonumber(out[0])
        for _, target_pid in ipairs(current_target_pids) do
            if window_pid == target_pid then
                local ok, err = pcall(PatchWindowContext, hwnd)
                if not ok then
                    logger:error(string.format("[PatchAllWindows] Failed to patch hwnd=%s, error: %s", tostring(hwnd), tostring(err)))
                end
                break
            end
        end
        return 1 
    end)
end

function PatchAllWindows()
    for key, state in pairs(patched_windows) do
        local pid = ffi.new("DWORD[1]")
        C.GetWindowThreadProcessId(state.hwnd, pid)
        if C.IsWindow(state.hwnd) == 0 or tonumber(pid[0]) ~= state.pid then
            patched_windows[key] = nil
        end
    end
    init_window_enum_callback() 
    local targets = find_pids_by_name("steamwebhelper.exe")
    if #targets == 0 then
        logger:info("[PatchAllWindows] No steamwebhelper.exe processes found.")
        return false
    end
    current_target_pids = targets
    local ok_enum, err = pcall(function()
        C.EnumWindows(window_enum_callback, 0)
    end)
    if not ok_enum then
        logger:error(string.format("[PatchAllWindows] Failed to enumerate windows, error: %s", tostring(err)))
        return false
    end
    return true
end

function GetPatchStats()
    return string.format('applied=%d unchanged=%d deferred=%d failed=%d',
        patch_stats.applied, patch_stats.unchanged, patch_stats.deferred, patch_stats.failed)
end

local function on_load()
    logger:info("dwmx loaded with Millennium version " .. millennium.version())
    millennium.ready()
    local ok = PatchAllWindows()
    logger:info("[dwmx] initial PatchAllWindows: " .. tostring(ok))
end

local function on_unload()
    logger:info("Plugin unloaded")
    -- Clean up callback if needed (though FFI callbacks are GC'd automatically)
    window_enum_callback = nil
    current_target_pids = {}
    patched_windows = {}
end

local function on_frontend_loaded()
    logger:info("Frontend loaded")
    PatchAllWindows()
end

return {
    on_frontend_loaded = on_frontend_loaded,
    on_load = on_load,
    on_unload = on_unload
}
