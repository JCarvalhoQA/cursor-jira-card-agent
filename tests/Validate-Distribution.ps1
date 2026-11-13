#Requires -Version 5.1
<#
.SYNOPSIS
  Confere o pacote jira-card-creator sem chamar o Jira e sem gravar no agente.
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
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

$agentPath = Join-Path $repoRoot '.cursor\agents\jira-card-creator.md'
$agentsDir = Join-Path $repoRoot '.cursor\agents'
if (-not (Test-Path -LiteralPath $agentPath -PathType Leaf)) {
    Add-Failure "Subagente ausente: $agentPath"
    Write-Host "RESULTADO: $($failures.Count) falha(s)"
    exit 1
}
Add-Pass "Arquivo do subagente existe."

$agentFiles = @(Get-ChildItem -LiteralPath $agentsDir -File -Force)
if ($agentFiles.Count -ne 1 -or $agentFiles[0].Name -ne 'jira-card-creator.md') {
    Add-Failure "A pasta .cursor/agents deve conter somente jira-card-creator.md."
} else {
    Add-Pass "Somente um subagente esta versionado."
}

$bytes = [System.IO.File]::ReadAllBytes($agentPath)
$utf16 = $false
if ($bytes.Length -ge 4 -and $bytes[1] -eq 0 -and $bytes[3] -eq 0 -and $bytes[0] -ne 0) {
    $utf16 = $true
}
if (-not $utf16) {
    Add-Failure "A codificacao do agente distribuido nao e UTF-16 LE sem BOM."
} else {
    Add-Pass "Codificacao distribuida: UTF-16 LE sem BOM."
}

$text = [System.Text.Encoding]::Unicode.GetString($bytes)
$utf8 = New-Object System.Text.UTF8Encoding $false
$tempUtf8 = Join-Path ([System.IO.Path]::GetTempPath()) ("jcc-utf8-{0}.md" -f [guid]::NewGuid().ToString('N'))
try {
    [System.IO.File]::WriteAllText($tempUtf8, $text, $utf8)
    $roundTrip = [System.IO.File]::ReadAllText($tempUtf8, $utf8)
    $tempBytes = [System.IO.File]::ReadAllBytes($tempUtf8)
    $tempNul = @($tempBytes | Where-Object { $_ -eq 0 }).Count
    if ($roundTrip -ne $text -or $tempNul -ne 0) {
        Add-Failure "A transcodificacao temporaria para UTF-8 nao preservou o texto."
    } else {
        Add-Pass "Copia temporaria UTF-8 preserva o texto e nao contem NUL."
    }
} finally {
    if (Test-Path -LiteralPath $tempUtf8) {
        Remove-Item -LiteralPath $tempUtf8 -Force
    }
}

if (-not $text.StartsWith("---$([char]10)")) {
    Add-Failure "Frontmatter nao abre com ---."
} else {
    $closeAt = $text.IndexOf("$([char]10)---$([char]10)", 4)
    if ($closeAt -lt 0) {
        Add-Failure "Frontmatter nao fecha."
    } else {
        $frontmatter = $text.Substring(4, $closeAt - 4)
        $lines = @($frontmatter -split "`n" | Where-Object { $_ -ne '' })
        $nameLine = $lines | Where-Object { $_ -like 'name:*' } | Select-Object -First 1
        $descriptionLine = $lines | Where-Object { $_ -like 'description:*' } | Select-Object -First 1
        if (-not $nameLine -or -not $descriptionLine) {
            Add-Failure "Frontmatter sem name ou description."
        } elseif ($nameLine.Trim() -ne 'name: jira-card-creator') {
            Add-Failure "Nome do frontmatter diferente de jira-card-creator."
        } elseif ($descriptionLine.Trim().Length -lt 20) {
            Add-Failure "description do frontmatter esta vazia."
        } else {
            Add-Pass "Frontmatter YAML simples valido, nome jira-card-creator."
        }
    }
}

$rules = @(
    @{ Name = 'modo CREATE'; Pattern = '(?m)^- \*\*CREATE\*\*' },
    @{ Name = 'modo CARD_REVIEW'; Pattern = '(?m)^- \*\*CARD_REVIEW\*\*' },
    @{ Name = 'confirmacao antes de criar'; Pattern = 'Crie só após o usuário confirmar \(sim, pode criar, ok, cria\)' },
    @{ Name = 'proibicao de status'; Pattern = 'transitionJiraIssue` é proibido' },
    @{ Name = 'proibicao de exclusao'; Pattern = 'Nunca excluir cards\.' },
    @{ Name = 'busca de duplicidade'; Pattern = 'searchJiraIssuesUsingJql' },
    @{ Name = 'duplicata silenciosa proibida'; Pattern = 'Não crie duplicata silenciosa\.' },
    @{ Name = 'integracao MCP citada'; Pattern = 'plugin-atlassian-atlassian' },
    @{ Name = 'BDD Dado que'; Pattern = '\*\*Dado que\*\*' },
    @{ Name = 'BDD Quando'; Pattern = '\*\*Quando\*\*' },
    @{ Name = 'BDD Entao'; Pattern = '\*\*Então\*\*' },
    @{ Name = 'READY_FOR_DEV'; Pattern = 'READY_FOR_DEV' },
    @{ Name = 'READY_WITH_OBSERVATIONS'; Pattern = 'READY_WITH_OBSERVATIONS' },
    @{ Name = 'NOT_READY_FOR_DEV'; Pattern = 'NOT_READY_FOR_DEV' }
)
foreach ($rule in $rules) {
    if ($text -notmatch $rule.Pattern) {
        Add-Failure "Regra ausente: $($rule.Name)"
    } else {
        Add-Pass $rule.Name
    }
}

$sections = @(
    '## Resumo/Descrição',
    '## Passo a Passo para Reprodução',
    '## Resultado esperado',
    '## Resultado atual',
    '## Dispositivo/Browser',
    '## Ambiente',
    '## Evidências/anexos'
)
$cursor = -1
$orderOk = $true
foreach ($section in $sections) {
    $index = $text.IndexOf($section)
    if ($index -lt 0 -or $index -le $cursor) {
        $orderOk = $false
        Add-Failure "Secao fora de ordem ou ausente: $section"
    }
    $cursor = $index
}
if ($orderOk) {
    Add-Pass "Sete secoes obrigatorias presentes e na ordem do template."
}

$mcpDoc = Join-Path $repoRoot 'docs\ATLASSIAN-MCP.md'
if (-not (Test-Path -LiteralPath $mcpDoc -PathType Leaf)) {
    Add-Failure "docs/ATLASSIAN-MCP.md ausente."
} else {
    $mcpText = [System.IO.File]::ReadAllText($mcpDoc)
    if ($mcpText -notmatch 'plugin-atlassian-atlassian') {
        Add-Failure "A documentacao MCP nao cita plugin-atlassian-atlassian."
    } else {
        Add-Pass "Integracao MCP documentada."
    }
}

$checksumFile = Join-Path $repoRoot 'checksums.sha256'
$hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $agentPath).Hash.ToUpperInvariant()
$expected = ((Get-Content -LiteralPath $checksumFile -TotalCount 1) -split '\s+')[0].ToUpperInvariant()
if ($hash -ne $expected) {
    Add-Failure "SHA-256 do agente difere de checksums.sha256."
} elseif ($hash -ne '1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF') {
    Add-Failure "O hash publicado da versao 1.0.0 mudou sem uma decisao de conversao."
} else {
    Add-Pass "SHA-256 confere com a versao 1.0.0 do agente."
}

$secretPatterns = @(
    'ghp_[A-Za-z0-9]{20,}',
    'gho_[A-Za-z0-9]{20,}',
    'github_pat_[A-Za-z0-9_]{20,}',
    'AKIA[0-9A-Z]{16}',
    '-----BEGIN [A-Z ]+PRIVATE KEY-----',
    '(?i)(api[_-]?key|password|secret)\s*[:=]\s*[^\s''"]{8,}'
)
$files = Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Force |
    Where-Object { $_.FullName -notmatch '\\.git\\' }
foreach ($file in $files) {
    $fileBytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $content = $null
    if ($fileBytes.Length -ge 4 -and $fileBytes[1] -eq 0 -and $fileBytes[0] -ne 0) {
        $content = [System.Text.Encoding]::Unicode.GetString($fileBytes)
    } else {
        $content = [System.Text.Encoding]::UTF8.GetString($fileBytes)
    }
    foreach ($pattern in $secretPatterns) {
        if ($content -match $pattern) {
            Add-Failure "Possivel segredo em $($file.FullName): $pattern"
        }
    }
}
if (-not ($failures | Where-Object { $_ -like 'Possivel segredo*' })) {
    Add-Pass "Nenhuma credencial encontrada nos arquivos versionados."
}

if ($failures.Count -gt 0) {
    Write-Host "RESULTADO: $($failures.Count) falha(s)"
    exit 1
}

Write-Host "RESULTADO: aprovado"
exit 0
