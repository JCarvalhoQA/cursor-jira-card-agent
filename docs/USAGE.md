# Utilização

O subagente tem dois modos. Se o pedido misturar os dois, ele revisa primeiro e só cria ou altera depois de confirmação explícita.

Voltar ao [manual principal](../README.md). O template completo está na seção [Template oficial](../README.md#template-oficial-do-card). A instalação está em [INSTALLATION.md](INSTALLATION.md). O que foi executado de fato, e o que ficou só como procedimento, está em [SMOKE-TEST.md](SMOKE-TEST.md).

## Como chamar

No chat de Agent:

```text
/jira-card-creator
```

Ou em linguagem natural, citando o nome `jira-card-creator`. A descrição do arquivo pede uso proativo para ticket, card, issue, Bug, Task, Story, Improvement, chave Jira, URL Jira, arquivo `.md` ou especificação de task.

## Modo CREATE

Use quando quiser abrir um card novo. O subagente prepara o rascunho, pesquisa duplicidades e **não cria** até você confirmar com algo como "sim", "pode criar", "ok" ou "cria".

Ordem interna, que ele não deve pular:

1. Identificar o projeto (`cloudId` e chave).
2. Identificar o tipo real da issue no projeto.
3. Pesquisar duplicidades com JQL.
4. Verificar se há informação suficiente, sem inventar o que falta.
5. Mostrar o rascunho no template oficial e criar só depois da confirmação.

Tipos que ele escolhe pelo conteúdo, se existirem no projeto: **Bug**, **Story**, **Task**, **Improvement** / **Melhoria**. Epic e Sub-task só se você pedir e o tipo existir.

### Informações úteis no CREATE

| Tipo | O que informar | O que pode ficar em placeholder |
| --- | --- | --- |
| Bug | O que aconteceu, ou evidência que mostre isso; o que deveria acontecer, ou um critério já presente na evidência (por exemplo assertion Cypress) | Dispositivo, ambiente e evidências podem ser `A validar.` ou `Não informado.` |
| Story | Objetivo claro da funcionalidade nova | O comportamento atual pode ser "ainda não está disponível" quando for o caso |
| Task | Objetivo claro do trabalho técnico, configuração, documentação ou infra | Fluxo de aplicação descrito em BDD, mesmo sem um erro reproduzível |
| Improvement | Objetivo claro do aprimoramento e, se souber, como funciona hoje | Mesmos placeholders de dispositivo, ambiente e evidência |

Informe a chave do projeto Jira quando souber. Se não informar, o subagente deve listar projetos e perguntar **somente** a chave.

Não peça, no mesmo fio, para ele preencher sozinho responsável, prioridade, labels, sprint ou story points. Ele só envia esses campos se você pedir ou se o Jira marcar o campo como obrigatório na criação. Mesmo nesse caso, a descrição do card continua sendo só o template oficial.

### Exemplo — Bug

```text
Utilize o jira-card-creator para preparar um Bug referente a uma falha funcional. Analise as informações, pesquise duplicidades e apresente o rascunho antes da criação.
```

Junto com esse pedido, envie o relato factual: tela ou fluxo, o que você fez, o que apareceu, o que você esperava, projeto Jira, e qualquer log, print ou resultado de teste que já tenha. Não invente o restante no lugar do subagente: se faltar um dado obrigatório de Bug, ele deve fazer uma pergunta objetiva.

### Exemplo — Task

```text
Utilize o jira-card-creator para preparar uma Task técnica conforme o template oficial.
```

Informe o objetivo técnico, o projeto e o fluxo em que o ajuste deve ser aplicado. Para Task sem erro reproduzível, a seção "Passo a Passo para Reprodução" descreve esse fluxo no formato **Dado que** / **Quando** / **Então**.

## Modo CARD_REVIEW

Use quando enviar uma chave Jira, uma URL Jira, um arquivo `.md`, uma especificação existente, ou pedir para validar um card. Nesse modo ele não cria issue, não edita o card e não corrige em silêncio. A saída é um parecer.

Classificações possíveis:

- `READY_FOR_DEV` — completo, consistente e suficiente para desenvolvimento.
- `READY_WITH_OBSERVATIONS` — dá para iniciar; há pontos não bloqueantes.
- `NOT_READY_FOR_DEV` — ausência, conflito ou indefinição que impede implementação segura.

Seções das quatro primeiras ausentes (Resumo, Passo a Passo, Resultado esperado, Resultado atual) tendem a `NOT_READY_FOR_DEV`. `A validar.` em Dispositivo/Browser ou Ambiente, e `Não informado.` em Evidências, sozinhos não derrubam o card se o restante for implementável.

### Exemplo — revisar um card

```text
Utilize o jira-card-creator em modo CARD_REVIEW para validar o card PROJ-123.
```

Troque `PROJ-123` pela chave real. Você pode enviar a URL do browse no lugar da chave. É preciso ter o MCP autenticado e permissão de leitura nessa issue. Veja [ATLASSIAN-MCP.md](ATLASSIAN-MCP.md).

### Exemplo — validar Markdown

```text
Utilize o jira-card-creator para analisar este arquivo Markdown e verificar se a especificação está pronta para desenvolvimento.
```

O arquivo precisa estar no workspace aberto ou ser colado no chat. O subagente não completa lacuna com suposição. O que não estiver na fonte fica como `NÃO INFORMADO` ou `REQUER DEFINIÇÃO`.

### O que conferir no parecer

O formato obrigatório começa com `CARD REVIEW` e inclui:

- Card e projeto.
- Template: `OK`, `INCOMPLETO` ou `FORA DO PADRÃO`.
- Uma das três classificações de prontidão.
- Status de cada uma das sete seções: `OK`, `INCOMPLETA`, `AUSENTE` ou `INCONSISTENTE`.
- Inconsistências, informações ausentes, pontos bloqueantes, recomendações e parecer.

Cada inconsistência deve vir no bloco `INCONSISTÊNCIA ENCONTRADA`, com Campo, Valor A, Valor B, Origem e Recomendação.

Depois do parecer, reescrita ou atualização no Jira só ocorre se você pedir. Edição de card existente continua restrita: o subagente proíbe `editJiraIssue`, salvo pedido explícito de ajuste pontual depois da criação, sem violar as proibições de status, responsável automático e seções extras.

## O que o subagente não faz

- Não inventa passo, ambiente, dispositivo, resultado, regra de negócio, evidência, log, print, ID, data ou resultado de Cypress.
- Não altera status e não move card para Done.
- Não exclui card.
- Não cria duplicata silenciosa quando a duplicata é forte (mesmo sintoma, mesmo fluxo, issue aberta ou recente).
- Não mascara só "por educação" deixando de registrar o fato: dados sensíveis no texto do Jira (token, senha, CPF, cartão, e-mail pessoal, Authorization, cookie, connection string) devem ser substituídos por `[dado mascarado]`.

## Confirmação antes da criação

Respostas que autorizam a criação, segundo o próprio subagente: "sim", "pode criar", "ok", "cria". Pedido de alteração volta ao rascunho; a criação fica para a confirmação seguinte.

Se a busca JQL falhar, ele deve informar e perguntar se pode criar sem a varredura completa. Ele não deve fingir que pesquisou.
