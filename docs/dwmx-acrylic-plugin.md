# DWMX acrylic plugin, patched

[DWMX (Window Styler)](https://github.com/ejalxndr/dwmx) gives Steam windows a
Windows acrylic backdrop. Themes that support it (SpaceTheme, Fluenty) make their
surfaces translucent so the blur shows through.

Two things were broken on my machine, both fixed here.

## 1. The Lua backend never found Steam's windows

`backend/main.lua` declared Win32 types for a 32-bit target:

```lua
typedef unsigned long ULONG_PTR;
typedef long LONG_PTR;
typedef unsigned long SIZE_T;
```

Millennium's Lua VM is 64-bit (`millennium.luavm64.exe`), so `PROCESSENTRY32W` was
laid out wrong, `szExeFile` was read from the wrong offset,
`find_pids_by_name("steamwebhelper.exe")` returned nothing and `PatchAllWindows`
always returned `false`. They are `unsigned __int64` / `__int64` now.

## 2. The blur API it used no longer renders

On Windows 11 25H2 (build 26200) `DWMWA_SYSTEMBACKDROP_TYPE` is a no-op on Steam's
opaque CEF windows, so the plugin's original method produced nothing. The legacy
accent - `SetWindowCompositionAttribute` with `ACCENT_ENABLE_ACRYLICBLURBEHIND`
(state 4, flag `0x20`) - is what actually renders, so that is the primary call again;
the system backdrop stays as a fallback.

Other fixes in the same file:

- `on_load` calls `PatchAllWindows`, so the main window is patched at startup.
- Rounded corners are skipped for maximized windows (`IsZoomed` →
  `DWMWCP_DONOTROUND`); rounding a maximized window draws 1px lines over the backdrop.

## 3. Popups were patched too early

`frontend/index.tsx` called `PatchAllWindows` *before* opening the new window, so
context menus and popups never got the backdrop. It now patches after
`window.open` as well, retried at 0/100/300/800 ms, and re-patches shortly after
startup (0.5-10 s) because an accent set before a window's composition target exists
is dropped.

`NEW_WINDOW_FLAG` also changed from `274` to `4194576`
(`Resizable | Composited | TransparentParentWindow`) so windows stay
transparency-capable, matching the "Change Window Params" plugin's transparent
window flags.

## 4. The blur vanished after some restarts

The accent is applied when the plugin loads, but DWM only honours it at the next
window recomposite. On a cold start Steam's main window is already composited by
the time the plugin patches, so the accent sat inert: the desktop wallpaper showed
sharp through the theme's translucent surfaces, with visible tone lines where the
surfaces met, until the window was minimized and restored by hand.

`PatchWindowContext` now follows every patch with

```lua
SetWindowPos(hwnd, NULL, 0, 0, 0, 0,
    SWP_NOSIZE | SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED)
```

which forces that recomposite without moving, resizing, restacking or focusing the
window. Verified live in one session on one window: accent off + frame change =
sharp wallpaper, accent on + frame change = frosted blur.

## Dark tint on the accent (2026-09-30)

`policy.nColor` was `0x00000000` - a fully transparent gradient color - so the
backdrop was the raw blurred wallpaper/apps. Behind the theme's translucent
surfaces a bright app (Discord at the top-left of this desktop) showed through
as bright patches with hard edges, which read as "blocky" bugs wherever the
window behind changed. The accent now carries a Catppuccin mantle tint
(`0xE0251818` in ABGR = RGB 24,24,37 at ~0.88 alpha): the blur stays, but the
backdrop is flattened to one dark tone, so those patches disappear.

## Files

- `plugins/dwmx/` - the built plugin, drop into `millennium\plugins\dwmx`.
- `plugins/dwmx-src/` - the changed sources: `backend/main.lua`,
  `frontend/index.tsx`, `plugin.json`, `package.json`, plus
  `theme-dwmx.css` (the copy of the theme side that goes with it).

## Rebuild

```powershell
git clone https://github.com/ejalxndr/dwmx
cd dwmx
git checkout 28c1a17f533d0ae5e98745616e859548912898e0
# apply the two changed files from plugins/dwmx-src
pnpm install
pnpm build          # writes .millennium/Dist/index.js
```

`pnpm` on Windows with the "approve builds" prompt may need
`allowBuilds: { '@parcel/watcher': true }` in `pnpm-workspace.yaml` before the
build's dependency check passes.
