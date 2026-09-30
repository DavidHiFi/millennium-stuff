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

### 6. Sidebar: one panel, the width you set, on every page

Three sidebar artifacts, fixed in `src/css/steam/sidebar.css` and
`options/general/fixedSidebar.css`:

- **The line where the tint cut off.** Only the top block (Home / Games and
  Software / search) and the bottom chrome were tinted, so the tint stopped dead
  above the game list and read as a hard edge. The whole column is one panel now
  (`._3x1HklzyDs4TEjACrRO2tB`), inner surfaces are transparent so nothing stacks
  a second alpha layer, and the divider under the search block is gone.
- **The downloads chip wider than the sidebar off the library page.** The
  "Always show sidebar" option pins `width: unset !important` on the sidebar
  column whenever the library content is hidden (console, store, community),
  which cancelled `Sidebar width: 400` - the sidebar fell back to Steam's 256px
  default while the chip and the user panel stayed sized for 400.
  `fixedSidebar.css` re-asserts the width with enough specificity to win in
  every page state, and the chip is now sized like the account chip below it
  (same inset, same 6px gap, stacked).
- **Panel see-through.** The panel fill is 0.8, not 0.55 (`--st-sidebar-bg` in
  `src/css/regular.css`): at 0.55 the wallpaper behind the window bled through as
  a tone edge where its sky/ground line crossed the list. 0.8 keeps the glass
  look with that edge below visibility.

### 7. Themed console page

`src/css/steam/consolePage.css` (new, imported from
`src/css/libraryroot.custom.css`): Steam paints the console with its own teal
panel and square corners, so it never matched Mocha. It is one rounded surface
like the rest now, console input included.

### 8. Overlay notice removed

`src/css/overlay.custom.css`: SpaceTheme drew an "overlay is experimental,
please do not make bug reports" box in the bottom-right of the in-game overlay.
The rule is deleted; the overlay's dim background is unchanged.

### 9. Millennium's own dialogs

- Settings pages are divided into bordered sections ("On Startup", "Updates",
  ...) with the per-row fills flattened, so each block reads as its own panel
  against the dialog surface (`src/css/steam/modalDialogPopup/millenniumSettings.css`).
- The Library Settings panel (`MillenniumDesktopSidebar`) is frosted now
  (`--st-glass` + `--st-glass-blur`) instead of a plain 55% fill that the library
  art showed through sharp.
- The shelf "move panel" grip (the hamburger next to the shelf title) is centered
  on the header row instead of hanging over its top edge (`src/icons/fluent/fluent.css`).
- Plugin and theme rows are individual rounded cards now (`--st-surface-0` fill,
  `--st-edge` ring, 8px gap) instead of a continuous list of text.
- Every settings tab carries its own edge; the active tab lifts to surface0 with
  a blue rim, so the open tab is obvious against the dialog surface.

### 10. Top strip (menu bar / super nav)

The strip above the content (`._3Z7VQ1IMk4E3HsHvrkLNgo`) was `background: none`,
so it was fully translucent: a bright app behind the window (Discord) showed
straight through it as a lighter block with a hard edge above the sidebar - the
"line where it cuts off". It now carries the same solid chrome surface as the
rest of the title bar (`rgba(mantle, 0.92)`, `src/css/steam/titlebar.css`), so
the strip stays one tone whatever is behind the window.

### 11. Backdrop blocks ("blocky" patches)

Two more places where the raw blurred backdrop read through as blocks: a bright
patch over the sidebar pills and a tone step in the library content. Root cause:
the acrylic accent had no tint (see `docs/dwmx-acrylic-plugin.md`), so the
backdrop kept the brightness of whatever window was behind Steam. Fixed on three
levels:

- DWMX accent tint: mantle at ~0.88 alpha (`0xE0251818`), flattens the backdrop.
- Sidebar panel: 0.8 -> 0.9 (`--st-sidebar-bg` in `src/css/regular.css`).
- Page surfaces: `Mica Transparency` option 55 -> 75 (config), so the window
  base and the pills are more opaque.

Measured after: the sidebar is flat within 1-2 levels over its whole height and
the library content within ~6 (blur gradient), against 20-30 before.

### 12. Glass and readable artwork overlays

The top strip uses the content pane's mantle tint at 0.75. Its `::before`
layer carries the frost filter so the bar does not become the positioning
anchor for the bottom-left account and options controls. The sidebar keeps
its 0.9 fill. The content pane and sidebar declare the same 20px frost filter.

Header chips and HowLongToBeat pills now have a mantle fill at 0.72 and a 6px
filter. Their previous color declarations became invalid when DWMX added an
alpha component to the palette variables. The theme now uses RGB-only
variables when a declaration supplies its own alpha, which also restores the
missing shadows across the library and store.

The visible wallpaper blur comes from DWMX's Windows acrylic backdrop.
Increasing CSS `backdrop-filter` on a surface whose backdrop is a flat page
fill does not increase that wallpaper blur. The existing acrylic tint and
sidebar opacity remain in place to prevent bright patches.

Notification cards and the notification menu use a 0.9 mantle fill with no
local backdrop filter. The menu also removes the outer shadow to avoid a
blurred patch at the popup window's clipped edge.

### 13. Popup window conflict and continuous glass

Windhawk's "Titlebar for Everyone" mod can force every Steam popup to use
`browserType=3`. Steam then adds a frame area beneath a notification card,
which exposes a second blurred strip. This also changes native overlay windows.

If you use that Windhawk mod, add `steamwebhelper.exe` to its custom process
exclusions. Keep existing exclusions. The registry setting is
`HKLM\SOFTWARE\Windhawk\Engine\Mods\titlebar-for-everyone\ExcludeCustom`.
Back up the setting first. This leaves the mod enabled for other applications
and lets Steam use its native window controls and popup types. The theme
installer does not edit Windhawk settings. Already running Steam windows may
retain the injected popup wrapper until Steam next starts.

A native in-game toast now measures 283 by 70 pixels, with its 283 by 66
card and the normal 4px bottom margin, instead of the enlarged 299 by 109
window. Cards use a 0.84 mantle fill and
6px local blur with an inset edge. The notification menu keeps its 0.9 fill.
Store search results and options dropdowns use a 0.78 mantle fill, 16px blur,
and a 1px edge.

DWMX's acrylic tint is now mantle at 50 percent. The main Steam window has
one 0.55 mantle fill; its title bar and content pane are transparent, without
separate regional filters. The sidebar keeps its 0.9 fill. These rules replace
the earlier title-strip tint in section 12 and remove the colour seams between
page regions.

The native toast type and dimensions, saved-file parity, and store dropdown
computed styles were verified. A fresh game launch and the full store dropdown
appearance were not retested. No game files changed.

### 14. Store dropdown backdrop root

The actual store search dropdown could declare 16px blur and still show the
banner sharply. Steam's navbar ancestor had its own 10px backdrop filter,
which created a backdrop root. The dropdown's filter could only sample pixels
inside that root rather than the page behind it.

The DWMX stylesheet now removes backdrop filters from the current and legacy
store navbar containers, scoped to `MillenniumWindow_SteamBrowser`. The search
dropdown keeps its 16px filter. On the real store page, the dropdown's computed
filter is 16px and every ancestor's filter is none. Installed-file hashes match.
A fresh screenshot was unavailable while the owner's game was foreground,
so this verification covers the actual DOM and styles, not a new visual capture.

## Install

Copy the folder to `C:\Program Files (x86)\Steam\millennium\themes\MochaSteam`, or run
`install.ps1 -Apply -Configure` from the repo root. Then in Millennium: Themes →
enable **Mocha Steam**, and set General → Font → `FiraCode Nerd Font` and
Other → `Mica & Acrylic plugin support` → yes.

## Undo

Delete `millennium\themes\MochaSteam` and select another theme in Millennium.
