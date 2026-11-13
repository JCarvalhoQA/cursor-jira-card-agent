# Atlassian MCP

O `jira-card-creator` cria e lê cards **somente** pelo MCP Atlassian. Ele cita o identificador `plugin-atlassian-atlassian`. Esta página descreve a dependência observada no ambiente de origem e o que um colaborador precisa instalar. Ela não publica credenciais e não altera o MCP de ninguém.

Voltar ao [manual principal](../README.md). Problemas de autenticação e ferramenta ausente estão em [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## O que foi verificado nesta publicação

Verificado no ambiente de origem, sem criar, editar, comentar ou transicionar issues:

- O plugin oficial da Cursor se chama `atlassian`. Manifesto local: servidor MCP `atlassian`, transporte HTTP, URL pública `https://mcp.atlassian.com/v2/mcp`.
- Com esse plugin instalado, a sessão do Cursor expõe o namespace `plugin-atlassian-atlassian` (plugin `atlassian` + servidor `atlassian`). O `serverName` observado foi `atlassian`.
- O catálogo primário dessa sessão listou, entre outras, as ferramentas `getAccessibleAtlassianResources`, `searchJiraIssuesUsingJql`, `createJiraIssue` e `getJiraIssue`.
- A página oficial do plugin no marketplace é [cursor.com/marketplace/atlassian](https://cursor.com/marketplace/atlassian).
- A instalação pela interface segue [Plugins](https://cursor.com/docs/plugins) e [MCP](https://cursor.com/docs/mcp): Customize na barra lateral, ou o fluxo "Add to Cursor" do marketplace.

Não verificado, de propósito:

- Nenhuma chamada real ao Jira ou ao Confluence foi feita durante a publicação.
- Não foi executada a ferramenta `discover` do servidor Atlassian.
- Não foi confirmado, com uma issue de verdade, que leitura, busca ou criação funcionam na conta de um colaborador.
- Não trate este documento como evidência de que a integração está autenticada na sua máquina.

## Por que o nome `plugin-atlassian-atlassian` importa

<a id="por-que-o-nome-plugin-atlassian-atlassian-importa"></a>

O texto do subagente manda usar o MCP `plugin-atlassian-atlassian`. Esse nome foi observado quando o **plugin oficial Atlassian da Cursor** está instalado.

Um servidor adicionado à mão em `mcp.json` com outro nome (por exemplo só `atlassian` ou `Atlassian-Rovo-MCP`) pode conectar no mesmo URL e ainda assim **não** aparecer como `plugin-atlassian-atlassian`. O subagente, como está escrito, procura esse identificador. Prefira o plugin do marketplace para manter o mesmo nome.

Esta publicação não reescreve o subagente para aceitar outros nomes.

## 1. Abrir as configurações MCP

1. Abra a Cursor.
2. Abra **Customize** na barra lateral.
3. Localize MCP servers e plugins. A documentação atual concentra instalação e ativação nessa página: [Customize Cursor](https://cursor.com/docs/customize-cursor) e [Model Context Protocol](https://cursor.com/docs/mcp).
4. Filtre pelo escopo usuário, workspace ou time, conforme onde a integração deve valer.

Não cole tokens, e-mails de serviço nem arquivos `.env` no chat para "ajudar a configurar".

## 2. Instalar a integração compatível

Caminho recomendado, porque produz o namespace que o subagente cita:

1. Abra [Atlassian no marketplace da Cursor](https://cursor.com/marketplace/atlassian).
2. Use **Add to Cursor** / **Install**.
3. Escolha o escopo. Usuário atende todos os seus projetos locais. Workspace limita ao projeto aberto.
4. Confirme que o servidor `atlassian` ficou habilitado em Customize.

O plugin oficial aponta para:

```text
https://mcp.atlassian.com/v2/mcp
```

Esse URL é público, documentado pela Atlassian em [Getting started with the Atlassian Remote MCP Server](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/). Não é uma credencial.

Atalho publicado pela própria Atlassian para a Cursor, no README do servidor:

```text
https://cursor.com/en/install-mcp?name=Atlassian-Rovo-MCP&config=eyJ1cmwiOiJodHRwczovL21jcC5hdGxhc3NpYW4uY29tL3YyL21jcCJ9
```

Se esse atalho criar um servidor com nome diferente de `plugin-atlassian-atlassian`, o subagente pode não reconhecê-lo. Nesse caso, instale o plugin do marketplace e confira o namespace numa sessão de Agent, como na seção 6.

### Configuração manual

Só use `mcp.json` se souber qual namespace a sua Cursor vai exibir. Exemplo **sem segredos**, equivalente ao manifesto do plugin oficial:

```json
{
  "mcpServers": {
    "atlassian": {
      "url": "https://mcp.atlassian.com/v2/mcp"
    }
  }
}
```

Não coloque API token, cookie ou senha nesse arquivo versionado. O fluxo esperado da Cursor para esse servidor remoto é OAuth no navegador.

Há também uma integração de produto "Jira" da Cursor para Cloud Agents, descrita em [cursor.com/docs/integrations/jira](https://cursor.com/docs/integrations/jira). Ela é outra instalação: exige plano Teams ou Enterprise, admin da Cursor e admin do site Jira, e serve a agentes de nuvem. O subagente local usa o MCP da sessão local. [Subagentes na nuvem](https://cursor.com/docs/subagents) usam os MCPs configurados em `cursor.com/agents`, não os servidores da sua sessão local. Esta publicação não testou esse caminho de nuvem.

## 3. Autenticar a conta

1. Com o servidor habilitado, inicie o fluxo de autenticação pedido pela Cursor (OAuth 2.1 no navegador).
2. Entre com a conta Atlassian que já tem acesso ao site Jira do time.
3. Aceite só os produtos e o site que você pretende usar.
4. Volte à Cursor e confira se o servidor deixou o estado de autenticação pendente.

A Atlassian documenta OAuth 2.1 ou API token, e grupos de permissão por produto, no README do servidor e em [Supported tools](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/supported-tools/). Se o admin da organização desativou API token, o caminho é OAuth. Não grave o token neste repositório.

## 4. Validar acesso ao Jira

Faça esta checagem você mesmo, num chat de Agent, depois de autenticar. A publicação deste repositório **não** executou esse passo contra um site real.

Peça somente uma leitura:

```text
Liste os sites Atlassian acessíveis com getAccessibleAtlassianResources. Não crie, edite nem mude status de nenhum card.
```

Resultado esperado: um ou mais `cloudId` (ou hostname do site) aos quais a sua conta tem acesso. Se a ferramenta pedir autenticação de novo, conclua o OAuth antes de usar o subagente.

## 5. Verificar permissão de leitura e de criação

O servidor oficial agrupa Jira em permissões no estilo `read_jira`, `search_jira` e `write_jira`. Isso vem da documentação da Atlassian, não de um teste executado aqui.

| O que você precisa | Ferramenta citada pelo subagente | Sinal de que falta permissão ou a ferramenta não está no catálogo |
| --- | --- | --- |
| Saber o site | `getAccessibleAtlassianResources` | A chamada falha ou pede login |
| Buscar duplicata | `searchJiraIssuesUsingJql` | A busca não existe no catálogo ou o Jira recusa a JQL |
| Criar card | `createJiraIssue` | A ferramenta não aparece, ou a criação retorna erro de permissão |
| Ler o card criado ou revisar | `getJiraIssue` | A chave existe e mesmo assim a leitura é negada |

Para um teste de criação, use um projeto de ensaio e confirme o rascunho antes. O subagente só cria depois das validações e da sua confirmação explícita. Não use esta publicação como esse teste.

## 6. Identificar ferramentas MCP indisponíveis

No chat de Agent, peça a lista do namespace, sem operar o Jira:

```text
Use GetDynamicTools no namespace plugin-atlassian-atlassian e liste só os nomes das ferramentas. Não chame createJiraIssue, editJiraIssue nem transitionJiraIssue.
```

Compare com o que o subagente declara em "Ferramentas permitidas":

| Nome no subagente | No catálogo primário desta sessão de origem |
| --- | --- |
| `getAccessibleAtlassianResources` | Presente |
| `searchJiraIssuesUsingJql` | Presente |
| `createJiraIssue` | Presente |
| `getJiraIssue` | Presente |
| `getVisibleJiraProjects` | Ausente da lista primária |
| `getJiraProjectIssueTypesMetadata` | Ausente da lista primária |
| `getJiraIssueTypeMetaWithFields` | Ausente da lista primária |
| `getConfluencePage` | Ausente da lista primária. Existe a ferramenta primária `getConfluenceContent` |

O README do servidor Atlassian explica que só um conjunto pequeno de ferramentas fica visível de imediato; o restante é descoberto sob demanda. A ferramenta `discover` existe no servidor. **Ela não foi chamada** nesta publicação, então não há confirmação de que os quatro nomes ausentes continuam existindo com exatamente esses identificadores.

Diferença adicional, só de leitura do schema local de `createJiraIssue`, também sem chamada real:

- O subagente menciona `issueTypeName` e, para responsável obrigatório, `assignee_account_id`.
- O schema primário observado nesta sessão exige `issueType` (não `issueTypeName`) junto com `cloudId`, `projectKey` e `summary`, e descreve o responsável no campo `assignee`.
- A descrição desse schema cita `listJiraProjectIssueTypesMetadata`, que também não é o nome escrito no subagente.

O subagente manda descobrir o schema com `GetDynamicTools` antes de cada chamada. O texto interno, porém, não foi alterado para acompanhar esses nomes. Trate isso como risco de compatibilidade, descrito em [TROUBLESHOOTING.md](TROUBLESHOOTING.md#ferramenta-citada-pelo-subagente-nao-aparece).

Ferramentas que o subagente proíbe usar, mesmo que apareçam no servidor: `transitionJiraIssue` e, por padrão, `editJiraIssue`.
