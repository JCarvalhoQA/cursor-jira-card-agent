# Changelog

O versionamento deste repositório segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e [Versionamento Semântico](https://semver.org/lang/pt-BR/).

A versão identifica o **pacote de distribuição**. O arquivo `.cursor/agents/jira-card-creator.md` não recebe campo de versão nem comentário extra: ele permanece cópia integral do subagente original. A identidade desse arquivo é o SHA-256 publicado em cada versão.

## [1.1.0] - 2026-11-13

### Adicionado

- `scripts/install.ps1`, com escopo global ou de projeto, `-DryRun`, checagem de SHA-256 e `-Replace` com backup.
- `tests/Validate-Distribution.ps1` e `tests/Test-Install.ps1`.
- Fixture sintética `tests/fixtures/spec-incompleta.md`.
- `docs/ENCODING.md` e `docs/SMOKE-TEST.md`.
- `checksums.sha256` com o hash do subagente.

### Mantido

- Bytes de `.cursor/agents/jira-card-creator.md`. O SHA-256 continua `1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF`.
- Regras de CREATE, CARD_REVIEW, template, duplicidade, confirmação, status e exclusão.

### Pendente

- Conversão do subagente para UTF-8. O texto sobrevive à transcodificação, e o GitHub mostra o arquivo como binário, mas esta versão não carregou uma cópia UTF-8 na Cursor. O arquivo distribuído permanece UTF-16 LE sem BOM.

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
