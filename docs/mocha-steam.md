# Mocha Steam

DavidHiFi's Catppuccin Mocha fork of SpaceTheme by SpaceEnergy. The dedicated [MochaSteam repository](https://github.com/DavidHiFi/MochaSteam) has a root-level `skin.json`. The bundle keeps its mirror in `themes/mocha-steam` alongside the patched acrylic plugin.

## Current behavior

Mocha colors, rounded controls and Blue/Lavender accents extend across Library, Store, Console, settings, friends/chat, menus and notifications. The SpaceTheme titlebar label is removed. Options retain the modular upstream structure with an additional FiraCode Nerd Font choice. Fonts must be installed separately.

Floating cards use a 72% mantle tint and a 20 px CSS backdrop filter. Transparent menu shells avoid square canvas pixels outside rounded cards. Interior dialogs stay transparent to avoid stacked tinted blur layers. Smaller controls and caption strips have lighter filters.

CSS blur samples content in the same page. Native Windows 11 acrylic from DWMX handles separate Steam popup windows. The backend removes WS_EX_COMPOSITED, caches materials and refreshes hidden pre-created popups once on first display. The frontend handles show, focus, visibility and creation events without polling.

The owner's local options currently use 55% main-window tint and 50% sidebar tint with native acrylic. Existing options are preserved by the installer; new installations use `skin.json` defaults. These tint values do not substitute for blur. Without DWMX, the theme remains a dark theme.

Library icons, ProtonDB dots and non-Steam entries use one 6 px indicator slot with a 3 px gap. All 46 measured rendered rows aligned at icon x55 and title x80.

## SpaceTheme integration

Integrated through `ce67165b14dc933bc21f84a51d87f9e020a1ba8d`, with Mocha colors and rounded clipping preserved. This includes hover-sidebar retention over account/download panels, dropdown styling, gift-card visibility, discovery positioning, favorite-friend status backgrounds and hidden-scrollbar hover behavior. `configs/mocha-steam-upstream.json` records the checkpoint.

## Verification limits

In a real Community menu stripe test, interior channel standard deviation fell from 35.47 with native acrylic disabled to 0.49 with it enabled. Red/blue backdrops changed its tint, confirming backdrop sampling. Twelve pre-created menus passed repeated display checks without a second accent application. Idle patch counts remained unchanged.

These tests cover the measured menu and popup lifecycle, not every future Steam version or GPU state. See `dwmx-acrylic-plugin.md` for details.
