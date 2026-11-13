# Smoke test

Voltar ao [manual principal](../README.md). Instalação: [INSTALLATION.md](INSTALLATION.md). Este documento separa o que foi **executado nesta revisão** do que continua sendo só procedimento.

Nenhum cenário chamou `createJiraIssue`, `editJiraIssue` ou `transitionJiraIssue`.

## Cenário A — Instalação

### Executado

`tests/Test-Install.ps1` exercita `scripts/install.ps1`:

- `-DryRun` global, com o agente já presente em `~/.cursor/agents/`, deve sair com código 2 e não alterar a data do arquivo.
- `-DryRun` num projeto temporário vazio não cria o markdown.
- Instalação de projeto temporário grava o arquivo com o SHA-256 publicado.
- A segunda execução sem `-Replace` sai com código 2.
- `-Replace` cria um único `.bak` e mantém o hash.
- Projeto inexistente sai com código 5.
- A pasta temporária é apagada ao final.

O resultado da última execução local está no relatório da revisão. O script de teste é a evidência repetível: `powershell -NoProfile -File .\tests\Test-Install.ps1`.

### Não executado

Não foi aberta uma segunda janela da Cursor apontando para o projeto temporário para ver se `/jira-card-creator` aparecia só por causa daquela cópia. O reconhecimento observado é o do arquivo global já instalado, descrito no [cenário B](#cenario-b--invocacao).

## Cenário B — Invocação

<a id="cenario-b--invocacao"></a>

### Executado

O subagente `jira-card-creator` foi selecionado e executado nesta sessão com o pedido equivalente a:

```text
/jira-card-creator revise esta especificação Markdown
```

A fonte foi [tests/fixtures/spec-incompleta.md](../tests/fixtures/spec-incompleta.md). A resposta veio no formato `CARD REVIEW`. Isso mostra que esta Cursor resolve o nome do subagente. Não foi um teste de digitar a barra num chat vazio recém-aberto.

### Não executado

Não houve captura da lista de comandos da interface depois de uma instalação limpa.

## Cenário C — CARD_REVIEW

### Executado

A mesma execução do cenário B leu a fixture, que de propósito omite seções, quebra o BDD, inclui `Severidade` e mistura Produção com Homologação.

O parecer retornado:

- Template: `FORA DO PADRÃO`
- Prontidão: `NOT_READY_FOR_DEV`
- Resultado atual: `AUSENTE`
- Ambiente: `AUSENTE`
- Passo a passo: `INCOMPLETA`
- Inconsistência entre Produção e Homologação
- A seção extra Severidade foi citada como fora do template
- A linha final foi `FERRAMENTAS_CHAMADAS: nenhuma`

Não houve alteração de arquivo do repositório por essa execução, nem chamada de escrita no Jira.

### Não executado

Não foi pedido para o subagente corrigir o arquivo nem publicar o parecer no Jira.

## Cenário D — CREATE

### Executado, com restrição

Foi pedido um Bug só com a frase "o botão salvar não funciona", e foi proibido chamar ferramenta. O subagente:

- disse que o card não foi criado;
- pediu chave do projeto, efeito observável, comportamento esperado e fluxo;
- mostrou o template das sete seções;
- usou `A validar.` e `Não informado.` onde não havia fato;
- declarou que a busca de duplicidade não foi feita;
- declarou `FERRAMENTAS_CHAMADAS: nenhuma`.

### Não executado

O fluxo normal de CREATE, que pesquisa duplicidade no Jira antes do rascunho, não rodou. Rodá-lo exigiria leitura real no site. Esta revisão não fez essa leitura.

## Cenário E — MCP Atlassian

### Não executado

Não foram chamados `getAccessibleAtlassianResources`, `discover`, `getJiraIssue`, `searchJiraIssuesUsingJql`, `createJiraIssue`, `editJiraIssue` nem `transitionJiraIssue`.

O que permanece documentado, da leitura de catálogo da publicação 1.0.0, está em [ATLASSIAN-MCP.md](ATLASSIAN-MCP.md). Não trate aquela tabela como uma nova prova desta revisão.

### Procedimento, quando houver autorização explícita para leitura

1. Confirme o namespace `plugin-atlassian-atlassian`.
2. Peça somente `getAccessibleAtlassianResources`.
3. Se precisar localizar ferramenta fora da lista primária, use `discover` com uma frase de consulta, sem executar a operação encontrada.
4. Pare antes de qualquer criação, edição ou transição.

## Como repetir as checagens automáticas

Na raiz do clone:

```powershell
powershell -NoProfile -File .\tests\Validate-Distribution.ps1
powershell -NoProfile -File .\tests\Test-Install.ps1
```

As duas devem terminar com `RESULTADO: aprovado`. Elas não chamam o Jira. `Test-Install.ps1` usa um diretório temporário e recusa alterar o agente global já instalado.
