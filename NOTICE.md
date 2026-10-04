# Third-party notices

This repo contains work by other people. Their licenses are kept alongside the
code:

| Component | Upstream | License | Upstream license file |
| --- | --- | --- | --- |
| `themes/mocha-steam` | [SpaceTheme/Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy | MIT | `themes/mocha-steam/LICENSE` |
| `themes/mocha-steam/src/icons/fluent` | Microsoft Fluent System Icons, as shipped by SpaceTheme | MIT (see upstream) | `themes/mocha-steam/src/icons/fluent/_font/LICENSE-3rdParty.md` |
| `plugins/dwmx`, `plugins/dwmx-src` | [ejalxndr/dwmx](https://github.com/ejalxndr/dwmx) by ejalxndr | Apache-2.0 | `plugins/dwmx-src/LICENSE` |

Palette values come from [Catppuccin](https://github.com/catppuccin/catppuccin)
(MIT), colour values only, no code.

Provenance of the snapshots these forks are based on:

- SpaceTheme for Steam, commit `ed560f2bd9aae88f1194b9b12e170231cff84640`.
  Mocha Steam has no `metadata.json`, so Millennium treats it as a local theme and
  does not offer to update it back to the upstream store build. A SpaceTheme install
  is untouched by this repo's `install.ps1`.
  Updates through `ce67165b14dc933bc21f84a51d87f9e020a1ba8d` were integrated on
  2026-10-04. This includes SpaceEnergy's Store and friend-status changes,
  ForgottenHero's hover-sidebar fix and EldinBegano's dropdown styling.
  Mocha keeps its own palette, acrylic fills and popup corner corrections.
- DWMX, commit `28c1a17f533d0ae5e98745616e859548912898e0`, built with
  `pnpm install && pnpm build` (`@steambrew/ttc`).

My changes to both are MIT, see `LICENSE`.
