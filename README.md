# Millennium Stuff

My [Millennium](https://steambrew.app) setup for the Steam client: the theme I actually
run, the acrylic plugin it needs, and the config that ties them together.

## Download

- Packaged zip of everything (theme, plugin, installer, docs):
  [latest release](https://github.com/DavidHiFi/millennium-stuff/releases/latest)
- Or just the theme folder:
  [themes/mocha-steam](https://github.com/DavidHiFi/millennium-stuff/tree/main/themes/mocha-steam)
- Or clone it: `git clone https://github.com/DavidHiFi/millennium-stuff`

## What's in here

| Path | What it is |
| --- | --- |
| `themes/mocha-steam/` | **Mocha Steam** - my own Catppuccin Mocha theme for Millennium, built as a fork of [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) |
| `plugins/dwmx/` | [DWMX (Window Styler)](https://github.com/ejalxndr/dwmx) built and patched so the acrylic backdrop actually works on current Windows 11 |
| `plugins/dwmx-src/` | The patched DWMX source files (`backend/main.lua`, `frontend/index.tsx`) plus the theme CSS that goes with it |
| `configs/millennium-config.example.json` | Millennium config showing the theme options and enabled plugins I use |
| `docs/` | What changed and why, per project |
| `install.ps1` | Audit/apply installer (`-Audit` by default, `-Apply` to install) |

## Quick start

```powershell
# look first, changes nothing
pwsh -File .\install.ps1

# install theme + plugin (backs up anything it replaces)
pwsh -File .\install.ps1 -Apply

# also point Millennium at Mocha Steam and set its options (Steam must be closed)
pwsh -File .\install.ps1 -Apply -Configure
```

Then in Millennium, **Themes**: enable **Mocha Steam**. Its options live under
General / Other: `Font` and `Mica & Acrylic plugin support`.

`install.ps1` installs the theme to `millennium\themes\MochaSteam` and the plugin to
`millennium\plugins\dwmx`. It never touches a SpaceTheme install - that stays a
separate, stock theme.

## Mocha Steam

My theme, author DavidHiFi, forked from SpaceTheme by SpaceEnergy (MIT, credited in
`NOTICE.md`). Changes, all in `themes/mocha-steam`:

- The "Space"/"Theme" text next to the Steam logo is gone from the theme itself.
- `FiraCode Nerd Font` added to the font dropdown.
- Catppuccin Mocha palette with Blue/Lavender accents.
- Chrome (bottom bar, titlebar controls, modal dialogs) is one solid Mocha surface
  instead of stacked translucent sub-panels.
- Inner containers no longer stack alpha layers over the window tint, which is what
  made the library darker than the sidebar (a hard edge) and killed the blur.
- The sidebar is one continuous panel at the width you set on every page (console,
  store, community included), with the downloads chip aligned to the account chip,
  and the console page is themed to match.
- Menus, dropdowns and notifications are frosted glass (`backdrop-filter`), and the
  overlay's experimental-warning box is gone.

Full detail: `docs/mocha-steam.md`.

## DWMX acrylic plugin

Upstream DWMX sets a window blur that no longer renders on Windows 11 25H2, and its
Lua backend never found Steam's windows at all (32-bit `ULONG_PTR` against Millennium's
64-bit Lua VM). `plugins/dwmx` is the fixed build; `plugins/dwmx-src` is the source of
those fixes.

Full detail: `docs/dwmx-acrylic-plugin.md`.

## Credits and licenses

- Theme base: [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy, MIT.
- Plugin: [DWMX](https://github.com/ejalxndr/dwmx) by ejalxndr, Apache-2.0.
- Palette: [Catppuccin](https://github.com/catppuccin/catppuccin), MIT.
- My changes: MIT, see `LICENSE` and `NOTICE.md`.
