<#
.SYNOPSIS
    Installs Mocha Steam and the patched DWMX acrylic plugin into a Millennium install.

.DESCRIPTION
    Read-only audit by default: it prints what exists and what it would replace.
    -Apply backs up and installs. -Configure also points Millennium at Mocha Steam
    and writes its options (requires Steam to be closed).

    A SpaceTheme install is never touched - it stays a separate, stock theme.

.EXAMPLE
    pwsh -File .\install.ps1
    pwsh -File .\install.ps1 -Apply
    pwsh -File .\install.ps1 -Apply -Configure
#>
[CmdletBinding()]
param(
    [string]$SteamPath = 'C:\Program Files (x86)\Steam',
    [switch]$Apply,
    [switch]$Configure
)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$themeSrc = Join-Path $root 'themes\mocha-steam'
$pluginSrc = Join-Path $root 'plugins\dwmx'
$themeDst = Join-Path $SteamPath 'millennium\themes\MochaSteam'
$pluginDst = Join-Path $SteamPath 'millennium\plugins\dwmx'
$backupRoot = Join-Path $SteamPath 'millennium\_backups'
$configPath = Join-Path $SteamPath 'millennium\config\config.json'
$themeId = 'MochaSteam'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Step([string]$text) { Write-Host "==> $text" }

foreach ($p in @($SteamPath, $themeSrc, $pluginSrc)) {
    if (-not (Test-Path -LiteralPath $p)) { throw "Missing: $p" }
}

Step "Steam:   $SteamPath"
Step "Theme:   $themeSrc  ->  $themeDst"
Step "Plugin:  $pluginSrc  ->  $pluginDst"
if ($Configure) { Step "Config:  $configPath" }

$steamRunning = [bool](Get-Process steam -ErrorAction SilentlyContinue)
Write-Host ("Steam is {0}" -f $(if ($steamRunning) { 'RUNNING' } else { 'not running' }))

if (-not $Apply) {
    Write-Host ''
    Write-Host 'Audit only. Nothing was changed. Re-run with -Apply to install.'
    if (Test-Path -LiteralPath $themeDst) { Write-Host "  note: $themeDst exists and would be backed up then replaced." }
    if (Test-Path -LiteralPath $pluginDst) { Write-Host "  note: $pluginDst exists and would be backed up then replaced." }
    if ($Configure -and $steamRunning) { Write-Host '  note: -Configure needs Steam closed.' }
    exit 0
}

# --- backups -------------------------------------------------------------
$backup = Join-Path $backupRoot $stamp
New-Item -ItemType Directory -Path $backup -Force | Out-Null
foreach ($pair in @(@{ src = $themeDst; name = 'theme-MochaSteam' }, @{ src = $pluginDst; name = 'plugin-dwmx' })) {
    if (Test-Path -LiteralPath $pair.src) {
        Step "Backup $($pair.src) -> $(Join-Path $backup $pair.name)"
        robocopy $pair.src (Join-Path $backup $pair.name) /E /NFL /NDL /NJH /NJS /NP | Out-Null
    }
}
if ($Configure -and (Test-Path -LiteralPath $configPath)) {
    Copy-Item -LiteralPath $configPath -Destination (Join-Path $backup 'config.json') -Force
    Step "Backup config.json -> $(Join-Path $backup 'config.json')"
}

# --- install -------------------------------------------------------------
foreach ($dst in @($themeDst, $pluginDst)) {
    if (Test-Path -LiteralPath $dst) { Step "Removing old $(Split-Path $dst -Leaf)"; Remove-Item -LiteralPath $dst -Recurse -Force }
}
Step 'Copying theme'
robocopy $themeSrc $themeDst /E /NFL /NDL /NJH /NJS /NP | Out-Null
Step 'Copying plugin'
robocopy $pluginSrc $pluginDst /E /NFL /NDL /NJH /NJS /NP | Out-Null

# --- config --------------------------------------------------------------
if ($Configure) {
    if ($steamRunning) { throw 'Steam must be closed for -Configure (its config would be overwritten on exit).' }
    Step 'Updating Millennium config'
    $cfg = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    if ($cfg.plugins.enabledPlugins -notcontains 'dwmx') {
        $cfg.plugins.enabledPlugins = @($cfg.plugins.enabledPlugins) + 'dwmx'
    }
    $cfg.themes.activeTheme = $themeId
    if (-not $cfg.themes.conditions.$themeId) {
        $source = $cfg.themes.conditions.'Steam'
        if (-not $source) { throw "No themes.conditions.Steam block to copy options from - open the SpaceTheme options once in Millennium, then rerun." }
        $cfg.themes.conditions | Add-Member -NotePropertyName $themeId -NotePropertyValue $source -Force
    }
    if (-not $cfg.themes.themeColors.$themeId -and $cfg.themes.themeColors.'Steam') {
        $cfg.themes.themeColors | Add-Member -NotePropertyName $themeId -NotePropertyValue $cfg.themes.themeColors.'Steam' -Force
    }
    $opts = $cfg.themes.conditions.$themeId
    $opts | Add-Member -NotePropertyName 'Font' -NotePropertyValue 'FiraCode Nerd Font' -Force
    $opts | Add-Member -NotePropertyName 'Mica & Acrylic plugin support' -NotePropertyValue 'yes' -Force
    $opts | Add-Member -NotePropertyName 'Mica Transparency' -NotePropertyValue '55' -Force
    $cfg | ConvertTo-Json -Depth 100 | Set-Content -LiteralPath $configPath -Encoding UTF8
    Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json | Out-Null
    Step "config.json written and re-parsed OK (activeTheme = $themeId)"
}

Write-Host ''
Write-Host 'Done. Restart Steam, then in Millennium check:'
Write-Host '  Themes: Mocha Steam enabled (SpaceTheme left as its own separate theme)'
Write-Host '  Themes > Mocha Steam > General > Font: FiraCode Nerd Font'
Write-Host '  Themes > Mocha Steam > General > Mica & Acrylic plugin support: yes'
Write-Host "Restore from: $backup"
