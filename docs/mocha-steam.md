# Mocha Steam

My Steam client theme for Millennium: Catppuccin Mocha with a real acrylic backdrop.
A fork of [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy.

Installed folder: `millennium\themes\MochaSteam`. Theme name **Mocha Steam**, author
**DavidHiFi**, credits point at this repo (`github` field in `skin.json`).

## Changes against upstream SpaceTheme

### 1. The "SpaceTheme" label is gone

`src/css/steam/titlebar.css` used to inject `content: "Space"` / `content: "Theme"`
pseudo-elements next to the Steam logo. That block is replaced with rules that hide
both pseudo-elements and keep the logo icon at 23px.

### 2. FiraCode Nerd Font

`options/fonts/firaCodeNerdFont.css` plus a `"FiraCode Nerd Font"` entry in the
`Font` option in `skin.json`. It expects the font to be installed on the system
(`FiraCodeNerdFont-*.ttf`); it is not bundled.

### 3. Catppuccin Mocha with blue accents

`src/css/plugins/dwmx.css` (applied by the "Mica & Acrylic plugin support" option)
sets the palette from [catppuccin/catppuccin](https://github.com/catppuccin/catppuccin):

- base `#1e1e2e`, mantle `#181825`, crust `#11111b`, surface0 `#313244`
- accents: Blue `#89b4fa`, Lavender `#b4befe`

### 4. One surface, no stacked sub-panels

Every extra translucent layer over the window tint showed up as a rectangle. Two
places had the problem, both fixed in `dwmx.css`:

- **Library shelves**: the window wrapper + content `Container` + each
  `ShowcaseOuter` shelf stacked three 75% layers (~98% opaque) against the sidebar's
  two (~94%), so the library painted darker than the sidebar - a hard vertical edge -
  and nothing was see-through. The inner containers are transparent now, so only the
  window wrapper carries the tint and `Mica Transparency` does real work (55% here).
- **Modal dialogs**: Millennium settings and Steam settings painted the tab strip,
  the content and every section row with their own 55% layer. The dialog is now one
  solid surface (`.PagedSettingsDialog` / `.ModalPosition_Content` at 92% mantle) and
  the sub-panels are transparent.

### 5. Chrome contrast, without boxes

- Sidebar bottom bar and titlebar controls are solid mantle (92%) with `subtext1`
  labels instead of Steam's washed-out grey.
- "Add shelf" keeps a single soft hairline (surface1 at 0.25 alpha) and a brighter
  fill on hover. No inset rings on panels - nested panels (the downloads row lives
  inside the bottom bar) doubled them up and drew hard edges.

## Install

Copy the folder to `C:\Program Files (x86)\Steam\millennium\themes\MochaSteam`, or run
`install.ps1 -Apply -Configure` from the repo root. Then in Millennium: Themes →
enable **Mocha Steam**, and set General → Font → `FiraCode Nerd Font` and
Other → `Mica & Acrylic plugin support` → yes.

## Undo

Delete `millennium\themes\MochaSteam` and select another theme in Millennium.
