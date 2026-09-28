# Enhanced Space Theme

A fork of [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam), running on
Millennium. Everything below is in `themes/enhanced-space-theme/`.

## Changes

### 1. The "SpaceTheme" label is gone

`src/css/steam/titlebar.css` used to inject `content: "Space"` / `content: "Theme"`
pseudo-elements next to the Steam logo. That block is replaced with rules that hide
both pseudo-elements and keep the logo icon at 23px.

The same snippets were previously kept in Millennium's Quick CSS; they live in the
theme now, so Quick CSS can stay empty.

### 2. FiraCode Nerd Font

`options/fonts/firaCodeNerdFont.css` plus a `"FiraCode Nerd Font"` entry in the
`Font` option in `skin.json`. It expects the font to be installed on the system
(`FiraCodeNerdFont-*.ttf`), it is not bundled.

### 3. Catppuccin Mocha with blue accents

`src/css/plugins/dwmx.css` (applied by the "Mica & Acrylic plugin support" option)
sets the palette from [catppuccin/catppuccin](https://github.com/catppuccin/catppuccin):

- base `#1e1e2e`, mantle `#181825`, crust `#11111b`, surface0 `#313244`
- accents: Blue `#89b4fa`, Lavender `#b4befe`

### 4. Chrome contrast, without boxes

- Sidebar bottom bar and titlebar controls are solid mantle (92% opacity) instead of
  a washed-out grey, with `subtext1` labels instead of Steam's `rgb(139-169)` grey.
- "Add shelf" keeps a single soft hairline (surface1 at 0.25 alpha) and a brighter
  fill on hover; Add a Game / download status share the hover fill.
- An earlier attempt put inset rings on every panel. Avoid that: `.Queue` (the
  downloads row) sits inside `.BottomBar`, so the rings doubled up and drew hard
  edges. Solid fills, no outlines.

### 5. One backdrop layer, not three (the blur fix)

Steam stacks backgrounds inside the library: window wrapper + content `Container` +
each `ShowcaseOuter` shelf. With the theme's translucent colours that is three 75%
layers (~98% opaque) against the sidebar's two (~94%), so the library painted darker
than the sidebar and its edge showed as a hard vertical line - and nothing looked
see-through.

`dwmx.css` now makes those inner containers transparent so only the window wrapper
carries the tint:

```css
[class~="ShowcaseOuter"],
._3VQUewWB8g6Z5qB4C7dGFr,
._1ijTaXJJA5YWl_fW2IxcaT { background-color: transparent !important; }
```

Then `Mica Transparency` can do its job. 55% is what I run; higher values look more
solid, lower values more glassy.

## Install

Copy the folder to `C:\Program Files (x86)\Steam\millennium\themes\Steam` (same folder
name as the normal SpaceTheme install, so the theme options in the config keep
matching), or run `install.ps1 -Apply -Configure` from the repo root. Then in
Millennium: General → Font → `FiraCode Nerd Font`, and Other →
`Mica & Acrylic plugin support` → yes.

`metadata.json` is not included on purpose: without it Millennium does not offer to
update the fork back to the upstream store build and overwrite the changes.

## Undo

Restore the upstream theme from the store (install it again over the folder), or
delete `themes/Steam` and install from
[the theme page](https://steambrew.app/theme?id=zQndv1rI0FXLh3QTRgOL).
