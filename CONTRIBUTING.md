# Contributing

Thanks for helping millennium-stuff. It ships a Steam theme, a styler and a set of plugins, so there are several places things can break.

## Ways to help

- Report Steam client updates that break the theme or the plugins
- Send fixes for the setup script and the plugin manifest
- Test on a fresh Steam install when you can

## Getting set up

Set up a test environment with the install script from the README:

```
irm https://raw.githubusercontent.com/DavidHiFi/millennium-stuff/main/setup/Install-MochaSetup.ps1 | iex
```

It closes Steam, then installs the theme, the DWMX styler and the plugins listed in setup/manifest.json.

## Checks before a pull request

- Re-run the setup script against a clean Steam install
- Confirm the manifest entries you changed point at files that exist

## Where to submit

Open issues and pull requests in this repository.