#Requires -Version 5.1
<#
.SYNOPSIS
  Copia jira-card-creator.md para o Cursor.

.DESCRIPTION
  Instala o subagente em escopo global ou de projeto.
  Confere o SHA-256 da origem, recusa destino existente sem -Replace
  e, com -Replace, grava um backup antes de substituir.
  Não altera MCP, git config nem pede privilégio de administrador.

.PARAMETER Scope
  Global usa %USERPROFILE%\.cursor\agents. Project usa -ProjectPath.

.PARAMETER ProjectPath
  Raiz do projeto. Obrigatoria quando Scope e Project.

.PARAMETER Source
  Arquivo de origem. O padrao e o arquivo deste repositorio.

.PARAMETER DryRun
  Mostra a acao e nao grava nada.

.PARAMETER Replace
  Consentimento explicito para substituir um arquivo ja instalado.
#>
[CmdletBinding()]
param(
    [ValidateSet('Global', 'Project')]
    [string]$Scope = 'Global',

    [string]$ProjectPath,

    [string]$Source,

    [switch]$DryRun,

    [switch]$Replace
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-ErrLine {
    param([string]$Message)
    [Console]::Error.WriteLine($Message)
}

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $Source) {
    $Source = Join-Path $repoRoot '.cursor\agents\jira-card-creator.md'
}
$Source = [System.IO.Path]::GetFullPath($Source)

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    Write-ErrLine "Arquivo de origem não encontrado: $Source"
    exit 3
}

$checksumFile = Join-Path $repoRoot 'checksums.sha256'
if (-not (Test-Path -LiteralPath $checksumFile -PathType Leaf)) {
    Write-ErrLine "Arquivo de integridade nao encontrado: $checksumFile"
    exit 4
}

$expectedLine = (Get-Content -LiteralPath $checksumFile -TotalCount 1).Trim()
$expectedHash = (($expectedLine -split '\s+')[0]).ToUpperInvariant()
if ($expectedHash -notmatch '^[0-9A-F]{64}$') {
    Write-ErrLine "checksums.sha256 não contém um SHA-256 válido."
    exit 4
}

$actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash.ToUpperInvariant()
if ($actualHash -ne $expectedHash) {
    Write-ErrLine "Integridade da origem falhou."
    Write-ErrLine "Esperado: $expectedHash"
    Write-ErrLine "Obtido:   $actualHash"
    exit 4
}

if ($Scope -eq 'Project') {
    if (-not $ProjectPath) {
        Write-ErrLine "Informe -ProjectPath para instalação por projeto."
        exit 5
    }
    $ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)
    if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
        Write-ErrLine "Pasta do projeto não encontrada: $ProjectPath"
        exit 5
    }
    $destDir = Join-Path $ProjectPath '.cursor\agents'
} else {
    if (-not $env:USERPROFILE) {
        Write-ErrLine "USERPROFILE não está definido. Não foi possível resolver a pasta do usuário."
        exit 5
    }
    $destDir = Join-Path $env:USERPROFILE '.cursor\agents'
}

$dest = [System.IO.Path]::GetFullPath((Join-Path $destDir 'jira-card-creator.md'))
if ($dest -eq $Source) {
    Write-ErrLine "O destino é o próprio arquivo de origem. Escolha outra pasta de projeto."
    exit 5
}

$destExists = Test-Path -LiteralPath $dest -PathType Leaf
$backup = $null
if ($destExists) {
    $backup = "$dest.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

Write-Host "Origem:  $Source"
Write-Host "Destino: $dest"
Write-Host "SHA-256: $actualHash"
Write-Host "Escopo:  $Scope"

if ($destExists -and -not $Replace) {
    Write-ErrLine "Instalação interrompida. O arquivo já existe e não foi sobrescrito: $dest"
    Write-ErrLine "Para substituir com backup, execute de novo com -Replace."
    if ($DryRun) {
        Write-Host "DRY-RUN: nenhuma cópia seria feita sem -Replace."
    }
    exit 2
}

if ($DryRun) {
    if ($backup) {
        Write-Host "DRY-RUN: seria criado o backup $backup e o destino seria substituído."
    } else {
        Write-Host "DRY-RUN: o arquivo seria copiado para o destino."
    }
    Write-Host "DRY-RUN: nenhum arquivo foi alterado. O MCP não seria modificado."
    exit 0
}

New-Item -ItemType Directory -Force -Path $destDir | Out-Null
if ($destExists) {
    Copy-Item -LiteralPath $dest -Destination $backup
    Write-Host "Backup:  $backup"
}

Copy-Item -LiteralPath $Source -Destination $dest -Force
$destHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $dest).Hash.ToUpperInvariant()
if ($destHash -ne $actualHash) {
    Write-ErrLine "A copia no destino nao confere com a origem."
    exit 4
}

Write-Host "Instalação concluída."
Write-Host "O arquivo foi copiado. O MCP Atlassian não foi alterado e o Jira não foi autenticado."
exit 0
