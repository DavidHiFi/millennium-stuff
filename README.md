# Mocha Steam for Millennium

Catppuccin Mocha for Steam, with rounded controls, frosted menus and native Windows acrylic. By DavidHiFi, forked from [SpaceTheme for Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy.

![Mocha Steam library](themes/mocha-steam/.github/assets/preview.png)

## Set up Millennium, the theme and the plugins

Run this in Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/DavidHiFi/millennium-stuff/main/setup/Install-MochaSetup.ps1 | iex
```

The script:

1. Runs the official Millennium installer if Millennium is missing. You click through it.
2. Closes Steam if it is running.
3. Installs the Mocha Steam theme and the DWMX window styler.
4. Installs 23 plugins at the versions in `setup/manifest.json`.
5. Writes the Millennium config and the plugin settings from the author's setup.

Your existing config is backed up and merged. Plugin data, such as the Gratitude friend list, is kept. Start Steam when the script finishes.

To read the plan before anything changes, download the script and run the audit mode:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/DavidHiFi/millennium-stuff/main/setup/Install-MochaSetup.ps1 -OutFile Install-MochaSetup.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\Install-MochaSetup.ps1 -Audit
```

If Steam is installed somewhere else, add `-SteamPath 'D:\Steam'`. To stop the script from starting the Millennium installer, add `-SkipMillenniumInstall`.

## Install four plugins by hand

These four plugins publish no license, so this repository does not include their code. Install each one from Millennium's plugin store, or from its repository at the commit below. Millennium enables them once they are in place, because the config already lists them.

- `adamraichu.auto-accept-custom-launch-args`: [AdamRaichu/auto-accept-custom-launch-args](https://github.com/AdamRaichu/auto-accept-custom-launch-args) at commit `084d32b`. Its README warns that it changes a Steam safety feature for launch arguments. Read that first.
- `browser_history`: [ricewind012/steam-browser-history](https://github.com/ricewind012/steam-browser-history) at commit `8214f36`. It shows your browsing history in the URL bar.
- `easy-restart-reload-for-steam`: [SaiyajinK/Easy-Restart-Reload-for-Steam](https://github.com/SaiyajinK/Easy-Restart-Reload-for-Steam) at commit `dc79ae2`.
- `steam-change-window-params`: [ricewind012/steam-change-window-params](https://github.com/ricewind012/steam-change-window-params) at commit `ee57e92`.

## What is not copied

- **Lua Tools Collection** (`luatools-collection`) is not included. It adds a collection for SteamTools Lua scripts.
- **Personal data** stays on the author's machine: Steam friend lists, Gratitude data, non-Steam playtime sessions, the list of installed Windows apps, and proxy settings.
- **Steam's own state**, such as your account, library, and window positions, is not part of any package.

The full list of plugins with sources and versions is in [NOTICE.md](NOTICE.md) and [setup/manifest.json](setup/manifest.json).

## Theme only

The theme and DWMX can also be installed without the plugins. From the repository root, `install.ps1` audits by default. Add `-Apply` to install the theme and DWMX, and add `-Configure` to select Mocha Steam and enable DWMX. Steam must be closed.

The [MochaSteam repository](https://github.com/DavidHiFi/MochaSteam) has `skin.json` at its root for Millennium's theme installer. It contains the same theme files.

## Requirements

- Windows 11 for native acrylic. The theme still works as a dark theme without it.
- Enable **Mica & Acrylic plugin support** in the theme options when you use acrylic.
- Install the fonts separately. The default font is Be Vietnam Pro.

## Included changes

- Catppuccin Mocha palette, Blue and Lavender accents, and rounded controls.
- Frosted menus, tooltips, dropdowns and dialogs, with transparent popup shells that keep their rounded corners.
- Native acrylic applied when Steam shows its pre-created popups, without polling or refreshing the main window.
- Aligned library icons and ProtonDB indicators.
- A library bottom edge that keeps the sidebar, the Downloads bar and the user panel inside one frame, and a top edge that stays below the Steam top bar.
- SpaceTheme updates through `ce67165`, including hover-sidebar retention, dropdown rounding, gift-card visibility and favorite-friend status options.

The native menu blur was checked with paired high-contrast captures. Steam updates can change selectors or popup behavior, and those tests do not cover every future client state.

## Contributing

Bug reports, feature ideas and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for setup, checks and what to include.

## Star history

⭐ Thanks for the stars, Steam client reports and plugin fixes.

<a href="https://www.star-history.com/?repos=DavidHiFi%2Fmillennium-stuff&amp;type=date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=DavidHiFi/millennium-stuff&amp;type=date&amp;theme=dark&amp;legend=top-left" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=DavidHiFi/millennium-stuff&amp;type=date" />
    <img alt="DavidHiFi/millennium-stuff GitHub star history" src="https://api.star-history.com/chart?repos=DavidHiFi/millennium-stuff&amp;type=date" />
  </picture>
</a>

## Credits and licenses

SpaceTheme by SpaceEnergy is MIT licensed. DWMX by ejalxndr is Apache-2.0 licensed. Catppuccin is MIT licensed. Third-party plugins keep their own licenses. DavidHiFi's changes are MIT licensed. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
