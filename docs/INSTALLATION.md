# Instalação

Este guia copia o subagente `jira-card-creator` para o Cursor. O arquivo distribuído é binário na prática: UTF-16 LE, sem BOM. Use apenas `Copy-Item` (PowerShell) ou `cp` (Bash). Não abra o arquivo num editor e salve de novo: isso pode converter o texto para UTF-8 e alterar o SHA-256, mesmo que o texto pareça igual.

O procedimento **não substitui** um agente já instalado. Se o destino existir, o comando para e não grava nada.

Voltar ao [manual principal](../README.md). Atualização, preservação de customização e reversão estão na seção [Atualizar o subagente](../README.md#atualizar-o-subagente).

## Antes de copiar

1. Clone o repositório, se ainda não estiver na sua máquina:

```bash
git clone https://github.com/JCarvalhoQA/cursor-jira-card-agent.git
```

2. Entre na pasta do clone. Todos os comandos abaixo assumem esse diretório como pasta atual.
3. Confira o arquivo de origem e o hash esperado da versão [1.0.0](../CHANGELOG.md):

```text
1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF
```

| Escopo | Destino | Efeito |
| --- | --- | --- |
| Global | `~/.cursor/agents/jira-card-creator.md` | Disponível em todos os projetos da sua conta local |
| Projeto | `<raiz-do-projeto>/.cursor/agents/jira-card-creator.md` | Disponível só naquele projeto |

Se o mesmo nome existir nos dois lugares, o Cursor usa o subagente **do projeto**. Fonte: [documentação de subagentes](https://cursor.com/docs/subagents).

## Windows (PowerShell)

### Instalação global

```powershell
$origem = Join-Path (Get-Location) ".cursor\agents\jira-card-creator.md"
if (-not (Test-Path -LiteralPath $origem)) {
  throw "Arquivo de origem não encontrado: $origem. Execute este comando na raiz do clone."
}

$destinoDir = Join-Path $env:USERPROFILE ".cursor\agents"
$destino = Join-Path $destinoDir "jira-card-creator.md"
New-Item -ItemType Directory -Force -Path $destinoDir | Out-Null

if (Test-Path -LiteralPath $destino) {
  throw "Instalação interrompida. O arquivo já existe e não foi sobrescrito: $destino"
}

Copy-Item -LiteralPath $origem -Destination $destino
Get-FileHash -Algorithm SHA256 -LiteralPath $origem, $destino | Format-List Path, Hash
```

O hash dos dois caminhos precisa ser o mesmo.

### Instalação por projeto

Defina a raiz do projeto de aplicação. Não use a pasta deste repositório de distribuição como se ela fosse o produto que você testa.

```powershell
$projeto = "C:\caminho\do\seu\projeto"
$origem = Join-Path (Get-Location) ".cursor\agents\jira-card-creator.md"
if (-not (Test-Path -LiteralPath $origem)) {
  throw "Arquivo de origem não encontrado: $origem. Execute este comando na raiz do clone."
}
if (-not (Test-Path -LiteralPath $projeto)) {
  throw "Pasta do projeto não encontrada: $projeto"
}

$destinoDir = Join-Path $projeto ".cursor\agents"
$destino = Join-Path $destinoDir "jira-card-creator.md"
New-Item -ItemType Directory -Force -Path $destinoDir | Out-Null

if (Test-Path -LiteralPath $destino) {
  throw "Instalação interrompida. O arquivo já existe e não foi sobrescrito: $destino"
}

Copy-Item -LiteralPath $origem -Destination $destino
Get-FileHash -Algorithm SHA256 -LiteralPath $origem, $destino | Format-List Path, Hash
```

## Linux e macOS (Bash)

No Linux, o comando de hash é `sha256sum`. No macOS, é `shasum -a 256`. O bloco abaixo escolhe o que existir.

### Instalação global

```bash
set -euo pipefail

origem="$(pwd)/.cursor/agents/jira-card-creator.md"
destino="${HOME}/.cursor/agents/jira-card-creator.md"

if [ ! -f "$origem" ]; then
  echo "Arquivo de origem não encontrado: $origem" >&2
  echo "Execute este comando na raiz do clone." >&2
  exit 1
fi

mkdir -p "${HOME}/.cursor/agents"

if [ -e "$destino" ]; then
  echo "Instalação interrompida. O arquivo já existe e não foi sobrescrito: $destino" >&2
  exit 1
fi

cp "$origem" "$destino"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$origem" "$destino"
else
  shasum -a 256 "$origem" "$destino"
fi
```

### Instalação por projeto

```bash
set -euo pipefail

projeto="/caminho/do/seu/projeto"
origem="$(pwd)/.cursor/agents/jira-card-creator.md"
destino="${projeto}/.cursor/agents/jira-card-creator.md"

if [ ! -f "$origem" ]; then
  echo "Arquivo de origem não encontrado: $origem" >&2
  exit 1
fi

if [ ! -d "$projeto" ]; then
  echo "Pasta do projeto não encontrada: $projeto" >&2
  exit 1
fi

mkdir -p "${projeto}/.cursor/agents"

if [ -e "$destino" ]; then
  echo "Instalação interrompida. O arquivo já existe e não foi sobrescrito: $destino" >&2
  exit 1
fi

cp "$origem" "$destino"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$origem" "$destino"
else
  shasum -a 256 "$origem" "$destino"
fi
```

## Verificar se o Cursor reconheceu o subagente

1. Confirme que o arquivo está no destino escolhido e que o SHA-256 coincide com o da origem.
2. Abra o Cursor na pasta em que você quer usar o agente. Para instalação global, qualquer projeto serve. Para instalação de projeto, abra a raiz em que o arquivo foi copiado.
3. Abra um chat de Agent.
4. Digite `/jira-card-creator`. A [documentação oficial](https://cursor.com/docs/subagents) descreve a invocação explícita com `/nome`.
5. Você também pode escrever, em português: `Utilize o jira-card-creator para revisar este card.` A descrição do frontmatter pede uso proativo quando o pedido envolve card, issue, Bug, Task, Story, Improvement, chave Jira, URL Jira ou arquivo `.md`.
6. Na página Customize da barra lateral, o subagente pode aparecer entre os subagentes do escopo usuário ou workspace. Referência: [Customize Cursor](https://cursor.com/docs/customize-cursor).

Se `/jira-card-creator` não aparecer, siga [O Cursor não lista o subagente](TROUBLESHOOTING.md#o-cursor-nao-lista-o-subagente).

O reconhecimento do arquivo neste repositório foi conferido pela existência do markdown, pelo frontmatter `name: jira-card-creator` e pela documentação oficial de caminhos. Não há, nesta publicação, uma captura de tela de outra máquina de colaborador.

## Próximo passo

Configure o MCP Atlassian antes de criar ou ler cards. Veja [ATLASSIAN-MCP.md](ATLASSIAN-MCP.md).
