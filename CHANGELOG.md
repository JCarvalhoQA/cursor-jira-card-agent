# Changelog

O versionamento deste repositório segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e [Versionamento Semântico](https://semver.org/lang/pt-BR/).

A versão identifica o **pacote de distribuição**. O arquivo `.cursor/agents/jira-card-creator.md` não recebe campo de versão nem comentário extra: ele permanece cópia integral do subagente original. A identidade desse arquivo é o SHA-256 publicado em cada versão.

## [1.0.0] - 2026-11-13

### Adicionado

- Subagente `jira-card-creator` em `.cursor/agents/jira-card-creator.md`.
- SHA-256 do arquivo distribuído: `1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF`.
- Codificação preservada: UTF-16 LE, sem BOM, quebras de linha LF.
- Manual de distribuição em `README.md`.
- Guias em `docs/INSTALLATION.md`, `docs/ATLASSIAN-MCP.md`, `docs/USAGE.md` e `docs/TROUBLESHOOTING.md`.
- `.gitattributes` para impedir que o Git reescreva os bytes do subagente.

### Integridade

- Nenhuma regra funcional do subagente foi reescrita, resumida ou simplificada nesta versão.
- Nenhum outro subagente foi incluído.
