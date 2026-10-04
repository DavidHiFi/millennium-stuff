# Mocha Steam for Millennium

Catppuccin Mocha styling for Steam, with rounded controls, frosted menus and native Windows acrylic. By DavidHiFi, forked from [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy.

## Install the complete Windows setup

1. Install [Millennium](https://docs.steambrew.app/users/getting-started/installation).
2. Download the **millennium-stuff ZIP** from the [latest release](https://github.com/DavidHiFi/millennium-stuff/releases/latest) and extract it.
3. Exit Steam completely. Open PowerShell in the extracted folder and run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 -Apply -Configure
```

4. Start Steam. Mocha Steam and the bundled Window Styler plugin are enabled.

The installer backs up replaced files in `Steam\millennium\_backups`, preserves existing options and other plugins, and supports a clean Millennium setup. Add `-SteamPath 'D:\Steam'` for a custom Steam location.

For a read-only check, run `powershell -File .\install.ps1 -Audit`. To install files without changing the active theme, use `-Apply` without `-Configure`, then select Mocha Steam and enable Window Styler in Millennium.

Native acrylic requires Windows 11 and the bundled DWMX plugin. Enable **Mica & Acrylic plugin support** in the theme options when using it. The theme also works as an ordinary dark theme without native acrylic. Fonts must be installed separately.

## Theme-only installation

The [MochaSteam repository](https://github.com/DavidHiFi/MochaSteam) has `skin.json` at its root for Millennium's theme installer. It contains the same theme files as this bundle and explains manual installation.

## Included changes

- Catppuccin Mocha palette, Blue/Lavender accents and rounded controls.
- Frosted menus, tooltips, dropdowns and dialogs, with transparent popup shells that preserve rounded corners.
- Native acrylic applied when Steam displays pre-created popups, without polling or repeatedly refreshing the main window.
- Aligned library icons and ProtonDB indicators.
- SpaceTheme updates through `ce67165`, including hover-sidebar retention, dropdown rounding, gift-card visibility and favorite-friend status options.

The native menu blur was verified with paired high-contrast captures. Steam updates can change selectors or popup behavior; the tests do not guarantee every future client state.

## Contents and credits

`themes/mocha-steam` contains the theme, `plugins/dwmx` the built plugin, `plugins/dwmx-src` its patched source, `install.ps1` the installer, and `docs` the implementation notes. `configs/mocha-steam-upstream.json` records upstream integration.

SpaceTheme by SpaceEnergy is MIT licensed. DWMX by ejalxndr is Apache-2.0 licensed. Catppuccin is MIT licensed. Original licenses and attribution are preserved. DavidHiFi's theme changes are MIT licensed. See `LICENSE` and `NOTICE.md`.
