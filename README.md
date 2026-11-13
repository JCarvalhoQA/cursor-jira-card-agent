# jira-card-creator

Manual de distribuição do subagente Cursor `jira-card-creator`. Este repositório publica **somente** esse subagente, para que outra pessoa instale o mesmo comportamento no Cursor dela.

Repositório: [https://github.com/JCarvalhoQA/cursor-jira-card-agent](https://github.com/JCarvalhoQA/cursor-jira-card-agent)

| Documento | Conteúdo |
| --- | --- |
| [docs/INSTALLATION.md](docs/INSTALLATION.md) | Instalação global e por projeto, com checagem de hash |
| [docs/ATLASSIAN-MCP.md](docs/ATLASSIAN-MCP.md) | Plugin Atlassian, autenticação e ferramentas |
| [docs/USAGE.md](docs/USAGE.md) | Modos CREATE e CARD_REVIEW, com o que informar em cada um |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Falhas de instalação, MCP, hash e permissão |
| [CHANGELOG.md](CHANGELOG.md) | Versões do pacote e o SHA-256 de cada uma |

## O que é

`jira-card-creator` é um subagente de QA para a Cursor. O arquivo versionado é `.cursor/agents/jira-card-creator.md`. Ele analisa o relato, a especificação ou o card que você enviar, monta o texto no template oficial e só cria issue no Jira pelo MCP Atlassian, depois das validações e de uma confirmação explícita.

O arquivo deste repositório é cópia integral do subagente original. As regras de negócio não foram reescritas nem resumidas aqui no arquivo do agente. Este README explica como instalar e usar; o comportamento continua no markdown do subagente.

## Objetivo

Transformar um relato em card claro e testável, sem inventar passo, ambiente, evidência ou regra de negócio. O mesmo subagente também diz se um card ou um `.md` já está no padrão oficial e se está pronto para desenvolvimento.

Ele prepara **Bugs**, **Tasks**, **Stories** e **Improvements** (ou o tipo equivalente que existir no projeto, por exemplo "Melhoria").

## Funcionalidades

- Modo **CREATE** para abrir card novo a partir de relato, bug, evidência, Cypress ou Confluence.
- Modo **CARD_REVIEW** para chave Jira, URL Jira, arquivo `.md` ou especificação existente.
- Template oficial com sete seções, em ordem fixa.
- Passo a passo em formato BDD (**Dado que** / **Quando** / **Então**).
- Busca de duplicidades no projeto antes de criar.
- Cinco validações obrigatórias antes de qualquer criação.
- Rascunho mostrado ao usuário e criação somente depois de confirmação.
- Parecer de prontidão: `READY_FOR_DEV`, `READY_WITH_OBSERVATIONS` ou `NOT_READY_FOR_DEV`.
- Mascaramento de dados sensíveis no texto que for para o Jira.
- Proibição de mudar status, excluir card e editar issue existente, salvo ajuste pontual pedido de forma explícita depois da criação.

## Benefícios para equipes de QA

- O card que o QA abre e o card que outro QA revisa seguem os mesmos títulos e a mesma ordem.
- Desenvolvimento, produto e QA leem resultado esperado antes do resultado atual, com o fluxo em BDD.
- Duplicata forte interrompe a criação até alguém decidir se o card novo ainda faz sentido.
- A descrição não ganha seções extras de severidade, impacto, critério de aceite, prioridade, story points, labels, responsável ou sprint, a menos que alguém peça isso ou o Jira exija o campo na criação. Quando o campo é obrigatório, ele vai na issue, não numa seção nova da descrição.
- O parecer de revisão separa template, consistência e prontidão para implementar.

## Integração com Jira e Atlassian

A criação e a leitura de issues passam pelo MCP Atlassian, identificador `plugin-atlassian-atlassian` no texto do subagente. Esse nome corresponde ao plugin oficial Atlassian da Cursor quando ele está instalado. Detalhes, o que foi de fato observado e o que não foi testado contra um site Jira: [docs/ATLASSIAN-MCP.md](docs/ATLASSIAN-MCP.md).

Ferramentas que o subagente declara usar: `getAccessibleAtlassianResources`, `getVisibleJiraProjects`, `getJiraProjectIssueTypesMetadata`, `getJiraIssueTypeMetaWithFields`, `searchJiraIssuesUsingJql`, `createJiraIssue`, `getJiraIssue` e, só se você enviar URL de Confluence como fonte, `getConfluencePage`. Ele descobre o schema com `GetDynamicTools` antes de cada chamada.

Ele não usa `transitionJiraIssue`. Não usa `editJiraIssue`, exceto no ajuste pontual que você pedir depois da criação, sem violar as outras proibições.

## Diferença entre CREATE e CARD_REVIEW

| | CREATE | CARD_REVIEW |
| --- | --- | --- |
| Quando usar | Você quer abrir um card novo | Você enviou chave, URL, `.md` ou pediu para validar |
| Saída | Rascunho no template e, após confirmação, a issue no Jira | Parecer `CARD REVIEW`, sem gravar no Jira |
| Duplicidade | Pesquisa no projeto e para se a duplicata for forte | Não cria issue |
| Escrita no Jira | `createJiraIssue` só depois das 5 validações e do seu "sim" | Não edita e não corrige em silêncio |
| Se o pedido misturar os dois | Revisar primeiro. Criar ou alterar só com confirmação explícita | O mesmo |

Classificações do parecer:

- **READY_FOR_DEV** — completo, consistente, suficiente para desenvolvimento.
- **READY_WITH_OBSERVATIONS** — dá para iniciar; há pontos não bloqueantes.
- **NOT_READY_FOR_DEV** — falta, conflito ou indefinição que impede implementação segura.

Exemplos de pedido e a lista do que informar estão em [docs/USAGE.md](docs/USAGE.md).

## Instalação

Pré-requisito: [Git](https://git-scm.com/) e a Cursor. O MCP Atlassian é necessário para criar ou ler cards, não para apenas copiar o arquivo. Configuração: [docs/ATLASSIAN-MCP.md](docs/ATLASSIAN-MCP.md).

Clone:

```bash
git clone https://github.com/JCarvalhoQA/cursor-jira-card-agent.git
cd cursor-jira-card-agent
```

Há dois destinos:

| Escopo | Caminho |
| --- | --- |
| Global, todos os projetos do usuário | `~/.cursor/agents/jira-card-creator.md` |
| Só o projeto aberto | `.cursor/agents/jira-card-creator.md` na raiz desse projeto |

Se os dois existirem, o do projeto prevalece. Referência: [Subagents](https://cursor.com/docs/subagents).

Os comandos abaixo **param** se o destino já existe. Eles não substituem outro agente. Copie com `Copy-Item` ou `cp`. Não regrave o arquivo num editor: o original é UTF-16 LE sem BOM, e salvar como UTF-8 muda o hash.

O passo a passo ampliado, incluindo a conferência de hash, está em [docs/INSTALLATION.md](docs/INSTALLATION.md).

### Windows (PowerShell)

Instalação global, executada na raiz do clone:

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

Instalação por projeto: troque a primeira atribuição de destino pela raiz do seu projeto.

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

### Linux e macOS (Bash)

`sha256sum` no Linux, `shasum -a 256` no macOS.

Instalação global:

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

Instalação por projeto:

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

### Ver se a Cursor reconheceu

1. Os dois hashes impressos pelo comando são iguais, e iguais ao da versão em [CHANGELOG.md](CHANGELOG.md).
2. Abra um chat de Agent na pasta certa (qualquer projeto, se a instalação foi global).
3. Digite `/jira-card-creator`.
4. Ou peça em português: `Utilize o jira-card-creator para revisar este card.`

Se o comando não aparecer, use [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#o-cursor-nao-lista-o-subagente).

## Configuração do Atlassian MCP

Resumo. O procedimento completo está em [docs/ATLASSIAN-MCP.md](docs/ATLASSIAN-MCP.md).

1. Abra **Customize** na barra lateral da Cursor. MCP e plugins ficam nessa página ([documentação](https://cursor.com/docs/mcp)).
2. Instale o plugin oficial [Atlassian](https://cursor.com/marketplace/atlassian). É esse plugin que, no ambiente de origem, aparece como namespace `plugin-atlassian-atlassian`.
3. Autentique com OAuth no navegador, na conta que já acessa o Jira do time. Não coloque token neste repositório.
4. Valide o acesso pedindo somente `getAccessibleAtlassianResources`. Não crie issue nessa checagem.
5. Leitura depende de a conta enxergar a issue. Criação depende de permissão de criar o tipo no projeto. Busca de duplicata depende de a JQL ser aceita. Os grupos citados pela Atlassian para Jira são `read_jira`, `search_jira` e `write_jira`. Isso não foi executado contra um site real nesta publicação.
6. Ferramenta indisponível: peça `GetDynamicTools` no namespace `plugin-atlassian-atlassian` e compare os nomes. Se o nome que o subagente cita não estiver no schema, pare e leia [a limitação conhecida](docs/TROUBLESHOOTING.md#ferramenta-citada-pelo-subagente-nao-aparece).

Um `mcp.json` manual com outro nome de servidor pode conectar em `https://mcp.atlassian.com/v2/mcp` e mesmo assim não se chamar `plugin-atlassian-atlassian`. O subagente, do jeito que está escrito, usa esse identificador.

## Guia de utilização

Chame com `/jira-card-creator` ou citando o nome. O guia ampliado está em [docs/USAGE.md](docs/USAGE.md).

### Criação de Bug

```text
Utilize o jira-card-creator para preparar um Bug referente a uma falha funcional. Analise as informações, pesquise duplicidades e apresente o rascunho antes da criação.
```

Envie junto o que for factual: projeto, tela ou fluxo, o que aconteceu, o que deveria acontecer, e evidência se houver (print, log, Cypress). Dispositivo, ambiente e anexo podem ficar como `A validar.` ou `Não informado.` O subagente pergunta só o dado obrigatório que realmente faltar, e não cria antes de você confirmar o rascunho.

### Criação de Task

```text
Utilize o jira-card-creator para preparar uma Task técnica conforme o template oficial.
```

Informe o objetivo técnico, a chave do projeto e o fluxo em que o ajuste entra. Sem erro reproduzível, o passo a passo BDD descreve esse fluxo, não um defeito inventado.

### Revisão de card

```text
Utilize o jira-card-creator em modo CARD_REVIEW para validar o card PROJ-123.
```

Troque `PROJ-123` pela chave real, ou envie a URL. É preciso MCP autenticado e permissão de leitura. A resposta é o parecer, não uma edição do card.

### Validação de Markdown

```text
Utilize o jira-card-creator para analisar este arquivo Markdown e verificar se a especificação está pronta para desenvolvimento.
```

O arquivo precisa estar no workspace ou ser colado no chat. O que não estiver na fonte permanece `NÃO INFORMADO` ou `REQUER DEFINIÇÃO`.

<a id="template-oficial-do-card"></a>

## Template oficial do card

Sete seções, nesta ordem, com estes títulos. O título do Jira (`summary`) fica fora desse markdown: curto, específico, com tela ou fluxo e o sintoma ou o verbo de ação, sem prefixo "Bug:" desnecessário.

1. **Resumo/Descrição** — o que foi pedido, qual é a tarefa, o problema ou a melhoria, por que o ajuste foi solicitado, e o contexto necessário. Sem inventar regra de negócio. Chave de card relacionado (duplicata fraca) entra aqui, não numa seção extra.
2. **Passo a Passo para Reprodução** — BDD. Para Task, Story ou Improvement sem erro reproduzível, esta seção descreve o fluxo em que o ajuste deve ser aplicado, no mesmo formato.
3. **Resultado esperado** — comportamento depois da correção ou implementação: objetivo, verificável e fiel ao que foi pedido. Vem **antes** do resultado atual.
4. **Resultado atual** — o comportamento que motivou o pedido. Bug: o incorreto observado. Improvement: como funciona hoje. Story nova: o comportamento ainda não existe, quando for o caso.
5. **Dispositivo/Browser** — só o que for conhecido. Sem dado: `A validar.`
6. **Ambiente** — preferência por `Homologação` ou `Produção`. Sem dado: `A validar.` Não assumir um quando o relato cita o outro.
7. **Evidências/anexos** — o que foi de fato entregue. Sem evidência: `Não informado.`

Padrão BDD dentro de Passo a Passo:

```markdown
**Dado que** [condição inicial]
**Quando** [ação realizada]
**Então** [resultado/comportamento observado]
```

Várias ações continuam nesse padrão: repetir **Quando** / **Então** ou numerar subpassos dentro do **Quando**. Passo a passo sem **Dado que** / **Quando** / **Então** não fica OK numa revisão; no máximo INCOMPLETA.

Texto do template, na ordem original:

```markdown
## Resumo/Descrição

[Descrição da tarefa, problema ou melhoria, explicando o que foi solicitado e por quê.]

## Passo a Passo para Reprodução

**Dado que** [condição inicial]
**Quando** [ação realizada]
**Então** [resultado/comportamento observado]

## Resultado esperado

[Comportamento esperado após a implementação/correção.]

## Resultado atual

[Comportamento atual que precisa ser corrigido ou alterado.]

## Dispositivo/Browser

[Dispositivo / Browser / Plataforma]

## Ambiente

[Homologação / Produção]

## Evidências/anexos

[Evidências disponíveis ou "Não informado"]
```

Não entram na descrição, salvo pedido explícito seu ou campo obrigatório do Jira (e, nesse caso, no campo da issue, não como seção): Severidade, Impacto, Critérios de aceite, Critérios QA, Prioridade, Story Points, Labels, Assignee, Sprint, e também Contexto, Pré-condições, Escopo ou Notas. Seção extra não substitui as sete obrigatórias.

<a id="atualizar-o-subagente"></a>

## Atualizar o subagente

A versão do pacote está em [CHANGELOG.md](CHANGELOG.md). O arquivo do agente não tem número de versão dentro dele. Compare o SHA-256.

### Consultar atualizações

```bash
git fetch origin
git log HEAD..origin/main -- CHANGELOG.md .cursor/agents/jira-card-creator.md
```

Leia o changelog no GitHub antes de copiar por cima do que está instalado: [CHANGELOG.md](https://github.com/JCarvalhoQA/cursor-jira-card-agent/blob/main/CHANGELOG.md). Enquanto a branch `main` não receber este conteúdo, acompanhe a branch do Pull Request indicada pelo mantenedor.

### Trazer o clone local

Na pasta do clone, com a working tree limpa:

```bash
git pull origin main
```

Se você tiver commit local neste clone, resolva isso antes. `git pull` não é um comando de instalação: ele só atualiza o clone.

### Atualizar o arquivo instalado

Faça backup e só então copie. O bloco abaixo é a atualização **global** no Windows. Ele não roda sozinho no `git pull`.

```powershell
$origem = Join-Path (Get-Location) ".cursor\agents\jira-card-creator.md"
$destino = Join-Path $env:USERPROFILE ".cursor\agents\jira-card-creator.md"
if (-not (Test-Path -LiteralPath $destino)) {
  throw "Nada instalado em $destino. Use a instalação inicial."
}

$backup = "$destino.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item -LiteralPath $destino -Destination $backup
Copy-Item -LiteralPath $origem -Destination $destino -Force
Get-FileHash -Algorithm SHA256 -LiteralPath $origem, $destino, $backup | Format-List Path, Hash
Write-Host "Backup: $backup"
```

No Linux e no macOS, a atualização global equivalente:

```bash
set -euo pipefail

origem="$(pwd)/.cursor/agents/jira-card-creator.md"
destino="${HOME}/.cursor/agents/jira-card-creator.md"

if [ ! -f "$destino" ]; then
  echo "Nada instalado em $destino. Use a instalação inicial." >&2
  exit 1
fi

backup="${destino}.bak-$(date +%Y%m%d-%H%M%S)"
cp "$destino" "$backup"
cp "$origem" "$destino"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$origem" "$destino" "$backup"
else
  shasum -a 256 "$origem" "$destino" "$backup"
fi

echo "Backup: $backup"
```

Para instalação de projeto, troque `$destino` / `destino` pelo caminho `.cursor/agents/jira-card-creator.md` da raiz do projeto.

### Preservar customização

Se você alterou o arquivo instalado, o backup acima guarda essa cópia. Não há merge automático de customização com a versão do GitHub. Para manter as duas:

1. Deixe o backup intacto.
2. Anote o que a sua cópia mudou em relação ao SHA-256 publicado.
3. Reaplique à mão só o que ainda fizer sentido, ou abra um Pull Request se a mudança for da equipe inteira.

Customização local deixa de ser o mesmo subagente publicado. O hash deixa de bater de propósito.

### Reverter uma atualização

Com o backup:

```powershell
Copy-Item -LiteralPath $backup -Destination $destino -Force
```

```bash
cp "$backup" "$destino"
```

Ou, no clone, volte o arquivo do pacote para um commit e copie de novo para o Cursor:

```bash
git checkout <commit-ou-tag> -- .cursor/agents/jira-card-creator.md
```

Não use `git push --force` para reverter histórico já publicado.

### Identificar a versão

1. Abra [CHANGELOG.md](CHANGELOG.md) e veja a versão mais recente.
2. Calcule o SHA-256 do arquivo instalado.
3. Compare com o hash daquela versão. Igual: é aquela distribuição. Diferente: o arquivo foi editado, regravado noutro encoding, ou veio de outro commit.

Versão 1.0.0, em 2026-11-13:

```text
1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF
```

## Colaboração

Melhoria de documentação ou do subagente entra por Pull Request para `main`.

1. Abra uma issue descrevendo o problema observável, sem token, sem dado de cliente e sem URL privada.
2. Crie uma branch a partir de `main` atualizada.
3. Mantenha um único subagente: `.cursor/agents/jira-card-creator.md`. Não adicione outro arquivo em `.cursor/agents/`.
4. Se o PR alterar o markdown do subagente, explique o comportamento que muda. Não reescreva o texto só para encurtar. Preserve, salvo decisão explícita no PR:
   - modos CREATE e CARD_REVIEW;
   - as sete seções, os nomes e a ordem;
   - BDD no passo a passo;
   - as cinco validações e a confirmação antes de criar;
   - a busca de duplicidades;
   - as proibições de status, exclusão e edição;
   - as classificações `READY_FOR_DEV`, `READY_WITH_OBSERVATIONS` e `NOT_READY_FOR_DEV`.
5. Publique no PR o SHA-256 anterior e o novo.
6. Não inclua `.env`, credencial ou evidência real de teste com dado pessoal.

Quem revisar confere o diff do agente linha a linha. Documentação pode ser ajustada sem mexer no comportamento.

## Segurança

- Este repositório é **público**. Não há ambiente corporativo privado por trás desta URL.
- Não versione segredo, token, senha, cookie, connection string, `.env` ou evidência com CPF, cartão ou e-mail pessoal.
- O subagente manda mascarar esse tipo de dado com `[dado mascarado]` quando for escrever no Jira. A mesma regra vale para commit e issue daqui.
- A publicação 1.0.0 não executou criação, edição, comentário nem transição no Jira.
- Instalar o subagente não muda o `mcp.json` da sua Cursor. A configuração do MCP continua sendo sua.

## Integridade

| Item | Valor |
| --- | --- |
| Arquivo | `.cursor/agents/jira-card-creator.md` |
| SHA-256 da versão 1.0.0 | `1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF` |
| Codificação | UTF-16 LE, sem BOM, LF |

Na origem, esse hash foi calculado sobre `~/.cursor/agents/jira-card-creator.md` e sobre a cópia deste repositório. Os dois conferiram. O `.gitattributes` marca esse arquivo como `-text` para o Git não converter fim de linha.

## Estrutura do repositório

```text
cursor-jira-card-agent/
├── .cursor/
│   └── agents/
│       └── jira-card-creator.md
├── docs/
│   ├── INSTALLATION.md
│   ├── ATLASSIAN-MCP.md
│   ├── USAGE.md
│   └── TROUBLESHOOTING.md
├── .gitattributes
├── .gitignore
├── CHANGELOG.md
└── README.md
```

`.gitattributes` e `.gitignore` entram para proteger os bytes do subagente e para não versionar segredo. Não há outro agente.

## Licença de uso interno da equipe

Não há arquivo de licença de software neste repositório. O que está publicado é o subagente e o manual para colaboradores clonarem e instalarem no Cursor. Antes de redistribuir fora do grupo que recebeu este endereço, confirme com o mantenedor do repositório `JCarvalhoQA/cursor-jira-card-agent`.
