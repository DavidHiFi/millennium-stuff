# Third-party notices

This repo contains work by other people. Their licenses are kept alongside the
code:

| Component | Upstream | License | Upstream license file |
| --- | --- | --- | --- |
| `themes/enhanced-space-theme` | [SpaceTheme/Steam](https://github.com/SpaceTheme/Steam) by SpaceEnergy | MIT | `themes/enhanced-space-theme/LICENSE` |
| `themes/enhanced-space-theme/src/icons/fluent` | Microsoft Fluent System Icons, as shipped by SpaceTheme | MIT (see upstream) | `themes/enhanced-space-theme/src/icons/fluent/_font/LICENSE-3rdParty.md` |
| `plugins/dwmx`, `plugins/dwmx-src` | [ejalxndr/dwmx](https://github.com/ejalxndr/dwmx) by ejalxndr | Apache-2.0 | `plugins/dwmx-src/LICENSE` |

Palette values come from [Catppuccin](https://github.com/catppuccin/catppuccin)
(MIT), colour values only, no code.

Provenance of the snapshots these forks are based on:

- SpaceTheme for Steam, commit `ed560f2bd9aae88f1194b9b12e170231cff84640`
  (the `metadata.json` that ties a theme to the upstream store was removed on
  purpose so Millennium does not try to update the fork back to upstream).
- DWMX, commit `28c1a17f533d0ae5e98745616e859548912898e0`, built with
  `pnpm install && pnpm build` (`@steambrew/ttc`).

My changes to both are MIT, see `LICENSE`.
