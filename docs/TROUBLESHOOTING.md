# Diagnóstico e resolução

Voltar ao [manual principal](../README.md). Instalação: [INSTALLATION.md](INSTALLATION.md). MCP: [ATLASSIAN-MCP.md](ATLASSIAN-MCP.md).

## O Cursor não lista o subagente

<a id="o-cursor-nao-lista-o-subagente"></a>

1. Confirme o caminho.
   - Global: `~/.cursor/agents/jira-card-creator.md`
   - Projeto: `<raiz>/.cursor/agents/jira-card-creator.md`
2. O nome no frontmatter é `jira-card-creator`. A invocação documentada é `/jira-card-creator`.
3. Abra a raiz certa. Um arquivo instalado só no projeto A não aparece quando o workspace é o projeto B.
4. Se existir cópia no projeto e outra no usuário, a do projeto prevalece ([documentação](https://cursor.com/docs/subagents)).
5. Feche e abra o chat de Agent. Se ainda não aparecer, recarregue a janela da Cursor.
6. Confira se o arquivo não foi salvo como UTF-8 por engano. Compare o SHA-256 com o da [versão 1.0.0](../CHANGELOG.md).

## Arquivo instalado e o Jira não responde

<a id="arquivo-instalado-e-o-jira-nao-responde"></a>

Separe as camadas. Uma não corrige a outra.

1. **Arquivo.** O caminho existe e o SHA-256 é o de [CHANGELOG.md](../CHANGELOG.md). Se o hash divergir, a Cursor pode estar lendo outra cópia, ou o arquivo foi regravado noutro encoding. Veja [ENCODING.md](ENCODING.md).
2. **Seleção.** No chat de Agent, `/jira-card-creator` precisa resolver esse subagente. Se o comando não aparece, volte à seção [O Cursor não lista o subagente](#o-cursor-nao-lista-o-subagente). Ter o arquivo no disco não força a delegação.
3. **MCP.** Customize mostra o plugin Atlassian autenticado, no namespace `plugin-atlassian-atlassian`. Sem isso, CARD_REVIEW de arquivo local ainda pode rodar; CREATE e leitura de chave Jira não.
4. **Permissão no site.** `getAccessibleAtlassianResources` devolve o site, e a conta enxerga o projeto. Ferramenta ausente no catálogo primário não é o mesmo que permissão negada. Compare com [ATLASSIAN-MCP.md](ATLASSIAN-MCP.md).
5. **Operação.** Criar issue é outro passo, só depois do rascunho e da confirmação. Falha de `createJiraIssue` não se resolve transicionando status.

Não cole token no chat para "destravar" uma dessas camadas.

## A instalação recusou a cópia

Esse é o comportamento pedido. O comando para quando o destino já existe, para não apagar outro agente nem uma customização local.

Leia o caminho impresso no erro. Se for o arquivo certo e você quiser atualizar, use o procedimento de [atualização](../README.md#atualizar-o-subagente), que faz backup antes. Não apague o destino no escuro.

## O hash da cópia não confere

1. Copie de novo com `Copy-Item` ou `cp`, a partir de `.cursor/agents/jira-card-creator.md` deste clone.
2. Não use `Set-Content`, `Out-File` nem "Salvar como" de editor.
3. Confira se o `git pull` trouxe o arquivo sem conversão de fim de linha. Neste repositório, `.gitattributes` marca o subagente como `-text`.
4. Se o clone estiver corrompido, clone outra pasta e compare de novo com:

```text
1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF
```

Esse valor é a versão 1.0.0. Versões futuras publicam outro hash no [CHANGELOG.md](../CHANGELOG.md).

## O MCP Atlassian não aparece

1. Veja Customize e confirme o plugin [Atlassian](https://cursor.com/marketplace/atlassian) no escopo em que você está trabalhando.
2. O subagente procura o namespace `plugin-atlassian-atlassian`. Um `mcp.json` com outro nome de servidor pode estar conectado e ainda assim não atender o texto do subagente. Detalhe em [ATLASSIAN-MCP.md](ATLASSIAN-MCP.md#por-que-o-nome-plugin-atlassian-atlassian-importa).
3. Subagente de nuvem não herda o MCP da sua sessão local. A documentação de subagentes diz que Cloud Subagents usam os servidores de `cursor.com/agents`.
4. Não cole token no chat para contornar a ausência do servidor.

## A autenticação expira ou fica pendente

1. Abra Customize, no servidor Atlassian, e refaça o OAuth no navegador.
2. Use a conta que enxerga o site Jira do time.
3. Se o admin desativou API token, OAuth é o caminho suportado pela Atlassian. Não invente um header de token neste repositório.
4. Uma checagem segura, sem criar card: pedir `getAccessibleAtlassianResources`. Falha dessa chamada não foi reproduzida nesta publicação; o passo é seu, na sua conta.

## Ferramenta citada pelo subagente não aparece

<a id="ferramenta-citada-pelo-subagente-nao-aparece"></a>

No catálogo primário observado na origem, estas ferramentas do texto **não** estavam na lista direta:

- `getVisibleJiraProjects`
- `getJiraProjectIssueTypesMetadata`
- `getJiraIssueTypeMetaWithFields`
- `getConfluencePage`

Também houve diferença de nome no schema local de `createJiraIssue`: o texto do subagente fala em `issueTypeName` e `assignee_account_id`; o schema lido nesta sessão usa `issueType` e `assignee`. Isso não foi exercitado com uma criação real.

O que fazer:

1. Peça `GetDynamicTools` no namespace `plugin-atlassian-atlassian` e leia o schema atual.
2. Não trate ferramenta ausente como sucesso.
3. Não contorne a ausência editando o subagente só na sua máquina se a equipe precisa do mesmo comportamento. Abra uma issue ou um Pull Request descrevendo o nome que o servidor passou a expor, sem colar resposta de API com dados de issue.
4. O servidor oferece `discover` para operações fora da lista primária. Esta publicação não chamou `discover` e não garante que os nomes antigos ainda existem.

## A busca de duplicidade falha

O próprio subagente deve parar, informar a falha e perguntar se pode criar sem a varredura completa. Ele não deve dizer que pesquisou se a JQL falhou.

Confira permissão de busca (`search_jira` na documentação Atlassian) e se a chave do projeto está correta. Não há, neste repositório, uma JQL de produção para copiar além dos exemplos genéricos que já estão no subagente (`project = KEY AND text ~ "..."`).

## O card foi criado sem o template

Isso foge do comportamento publicado. O rascunho e a descrição precisam das sete seções, nessa ordem, com esses títulos. Se uma execução divergir:

1. Não peça transição de status para "consertar".
2. Não peça edição silenciosa. Edição só com pedido explícito de ajuste pontual, e a descrição resultante ainda deve ser o template oficial.
3. Rode um CARD_REVIEW na chave criada e guarde o parecer.
4. Se o texto do subagente no seu disco for diferente do SHA-256 da versão que a equipe adotou, restaure a cópia do repositório. Customização local explica divergência de comportamento.

## Permissão negada ao criar ou ler

A conta autenticada no MCP usa as permissões que ela já tem no Jira. Este repositório não eleva permissão.

- Leitura negada em `getJiraIssue`: a conta não vê aquela issue ou o site.
- Criação negada: falta permissão de criar aquele tipo no projeto, ou um campo obrigatório do Jira não foi informado. O subagente deve ler o metadata, pedir só o valor que falta e tentar uma vez. Na segunda falha, ele para e relata o erro.
- Campos obrigatórios do Jira vão no campo da issue, não como seção nova da descrição.

## Quero desfazer uma atualização do arquivo

1. Se a atualização usou `scripts/install.ps1 -Replace`, ou o backup descrito no [README](../README.md#atualizar-o-subagente), copie o `.bak` mais recente de volta para `jira-card-creator.md` com `Copy-Item` ou `cp`.
2. Ou reinstale um commit conhecido:

```bash
git checkout <commit-ou-tag> -- .cursor/agents/jira-card-creator.md
```

Execute isso na pasta do clone e depois copie o arquivo restaurado para o destino da Cursor, de novo sem sobrescrever às cegas: faça backup do que está instalado hoje.

Não use `git push --force` nem `git reset --hard` para voltar versão publicada no remoto, a menos que o mantenedor peça explicitamente essa operação.

## O repositório público e dados sensíveis

O GitHub `JCarvalhoQA/cursor-jira-card-agent` é público. Não abra Pull Request com `.env`, token, senha, CPF, cartão, cookie, connection string ou URL interna de cliente. O subagente já manda mascarar esses dados quando for escrever no Jira; o mesmo vale para issue e diff deste repositório.
