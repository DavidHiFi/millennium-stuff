# Millennium Stuff

My [Millennium](https://steambrew.app) setup for the Steam client: the theme I actually
run, the acrylic plugin it needs, and the config that ties them together.

## What's in here

| Path | What it is |
| --- | --- |
| `themes/enhanced-space-theme/` | [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) with my changes (label removed, Catppuccin Mocha + blue palette, extra font option, clean chrome) |
| `plugins/dwmx/` | [DWMX (Window Styler)](https://github.com/ejalxndr/dwmx) built and patched so the acrylic backdrop actually works on current Windows 11 |
| `plugins/dwmx-src/` | The patched DWMX source files (`backend/main.lua`, `frontend/index.tsx`) plus the theme CSS that goes with it |
| `configs/millennium-config.example.json` | Millennium config showing the theme options and enabled plugins I use |
| `docs/` | What changed and why, per project |
| `install.ps1` | Audit/apply installer (`-Audit` by default, `-Apply` to install) |

## Quick start

```powershell
# look first, changes nothing
pwsh -File .\install.ps1

# install theme + plugin (backs up the existing theme folder)
pwsh -File .\install.ps1 -Apply

# also set the theme options in Millennium's config (Steam must be closed)
pwsh -File .\install.ps1 -Apply -Configure
```

Then in Millennium: **Themes → SpaceTheme → General** and pick
`Font: FiraCode Nerd Font`, `Mica & Acrylic plugin support: yes`.

`install.ps1` copies the theme into `millennium\themes\Steam` (same folder name the
SpaceTheme install uses, so the config keeps working) and the plugin into
`millennium\plugins\dwmx`. Restart Steam after installing.

## Enhanced Space Theme

Fork of SpaceTheme. Changes, all in `themes/enhanced-space-theme`:

- The "Space"/"Theme" text next to the Steam logo is gone from the theme itself.
- `FiraCode Nerd Font` added to the font dropdown.
- Catppuccin Mocha palette with Blue/Lavender accents (`src/css/plugins/dwmx.css`).
- Chrome (bottom bar, titlebar controls) is solid Mocha instead of washed-out grey;
  "Add shelf" gets one soft hairline.
- Inner containers no longer stack alpha layers over the window tint, which is what
  made the library darker than the sidebar (a hard edge) and killed the blur.

Full detail: `docs/enhanced-space-theme.md`.

## DWMX acrylic plugin

Upstream DWMX sets a window blur that no longer renders on Windows 11 25H2, and its
Lua backend never found Steam's windows at all (32-bit `ULONG_PTR` against Millennium's
64-bit Lua VM). `plugins/dwmx` is the fixed build; `plugins/dwmx-src` is the source of
those fixes.

Full detail: `docs/dwmx-acrylic-plugin.md`.

## Credits and licenses

- Theme: [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy, MIT.
- Plugin: [DWMX](https://github.com/ejalxndr/dwmx) by ejalxndr, Apache-2.0.
- Palette: [Catppuccin](https://github.com/catppuccin/catppuccin), MIT.
- My changes: MIT, see `LICENSE` and `NOTICE.md`.
