#Requires -Version 5.1
<#
.SYNOPSIS
  Exercita scripts/install.ps1 em pastas temporarias, sem tocar no agente global.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$install = Join-Path $repoRoot 'scripts\install.ps1'
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
    param([string]$Message)
    $script:failures.Add($Message)
    Write-Host "FAIL  $Message"
}

function Add-Pass {
    param([string]$Message)
    Write-Host "PASS  $Message"
}

function Invoke-Install {
    param([string[]]$ArgumentList)
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output = & powershell.exe -NoProfile -File $install @ArgumentList 2>&1
    $code = $LASTEXITCODE
    $ErrorActionPreference = $previous
    return @{
        Code = $code
        Output = ($output | Out-String)
    }
}

if (-not (Test-Path -LiteralPath $install)) {
    Write-Host "FAIL  install.ps1 ausente"
    exit 1
}

$globalAgent = Join-Path $env:USERPROFILE '.cursor\agents\jira-card-creator.md'
$before = $null
if (Test-Path -LiteralPath $globalAgent) {
    $before = (Get-Item -LiteralPath $globalAgent).LastWriteTimeUtc
}
$globalDry = Invoke-Install -ArgumentList @('-Scope', 'Global', '-DryRun')
if ($globalDry.Code -ne 2) {
    Add-Failure "Dry-run global deveria recusar o arquivo ja instalado. Codigo $($globalDry.Code)."
} else {
    Add-Pass "Dry-run global recusou sobrescrever sem -Replace."
}
if ($before) {
    $after = (Get-Item -LiteralPath $globalAgent).LastWriteTimeUtc
    if ($after -ne $before) {
        Add-Failure "O dry-run global alterou a data do agente instalado."
    } else {
        Add-Pass "O agente global existente nao foi modificado."
    }
}

$root = Join-Path ([System.IO.Path]::GetTempPath()) ("jcc-install-{0}" -f [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $root | Out-Null
try {
    $dry = Invoke-Install -ArgumentList @('-Scope', 'Project', '-ProjectPath', $root, '-DryRun')
    $created = Test-Path -LiteralPath (Join-Path $root '.cursor\agents\jira-card-creator.md')
    if ($dry.Code -ne 0 -or $created) {
        Add-Failure "Dry-run de projeto gravou arquivo ou nao retornou 0. Codigo $($dry.Code)."
    } else {
        Add-Pass "Dry-run de projeto nao gravou arquivo."
    }

    $first = Invoke-Install -ArgumentList @('-Scope', 'Project', '-ProjectPath', $root)
    $dest = Join-Path $root '.cursor\agents\jira-card-creator.md'
    $hash = $null
    if (Test-Path -LiteralPath $dest) {
        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $dest).Hash.ToUpperInvariant()
    }
    if ($first.Code -ne 0 -or $hash -ne '1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF') {
        Add-Failure "Instalacao de projeto nao concluiu com o hash esperado."
    } else {
        Add-Pass "Instalacao de projeto conferiu o SHA-256."
    }

    $second = Invoke-Install -ArgumentList @('-Scope', 'Project', '-ProjectPath', $root)
    if ($second.Code -ne 2) {
        Add-Failure "Segunda instalacao deveria recusar. Codigo $($second.Code)."
    } else {
        Add-Pass "Segunda instalacao recusou sem -Replace."
    }

    $replace = Invoke-Install -ArgumentList @('-Scope', 'Project', '-ProjectPath', $root, '-Replace')
    $backups = @(Get-ChildItem -LiteralPath (Join-Path $root '.cursor\agents') -Filter 'jira-card-creator.md.bak-*' -Force)
    $hashAfter = (Get-FileHash -Algorithm SHA256 -LiteralPath $dest).Hash.ToUpperInvariant()
    if ($replace.Code -ne 0 -or $backups.Count -ne 1 -or $hashAfter -ne $hash) {
        Add-Failure "Replace nao criou backup ou alterou o hash."
    } else {
        Add-Pass "Replace criou backup e manteve o hash."
    }

    $missing = Invoke-Install -ArgumentList @('-Scope', 'Project', '-ProjectPath', (Join-Path $root 'nao-existe'))
    if ($missing.Code -ne 5) {
        Add-Failure "Projeto inexistente deveria retornar 5. Codigo $($missing.Code)."
    } else {
        Add-Pass "Projeto inexistente retorna erro claro."
    }
} finally {
    if (Test-Path -LiteralPath $root) {
        Remove-Item -LiteralPath $root -Recurse -Force
    }
}

if ($failures.Count -gt 0) {
    Write-Host "RESULTADO: $($failures.Count) falha(s)"
    exit 1
}

Write-Host "RESULTADO: aprovado"
exit 0
