# Codificação do subagente

Voltar ao [manual principal](../README.md).

## O que o arquivo é

`.cursor/agents/jira-card-creator.md` está em **UTF-16 LE, sem BOM**, com LF. Medição nesta revisão:

| Medida | Valor |
| --- | --- |
| Tamanho | 37556 bytes |
| Primeiros bytes | `2D 00 2D 00` (`-` em UTF-16 LE) |
| BOM | ausente |
| Bytes nulos | 18758, só nas posições ímpares da amostra |
| CRLF | 0 |
| LF | 481 |
| SHA-256 | `1E10F1A17614CDD81F2CAAE4156DAA69A3D26A3FECC89C23A316282065B3DFFF` |

Ler o arquivo como UTF-8 não recupera `name: jira-card-creator`. Ler como UTF-16 LE recupera.

## A Cursor reconhece o original

Nesta sessão, o tipo de subagente `jira-card-creator` está disponível e foi executado no [smoke test](SMOKE-TEST.md). O arquivo global `~/.cursor/agents/jira-card-creator.md` tem o mesmo SHA-256 e a data de gravação `2026-09-03T12:37:49Z`, anterior a esta revisão. A conclusão vale para esse arquivo UTF-16 no caminho global. Não vale, por si só, para uma cópia regravada em UTF-8.

## Cópia temporária UTF-8

Foi gerada fora do repositório, só para comparação, e apagada em seguida.

- O texto decodificado de UTF-16 e o texto relido da cópia UTF-8 foram iguais, caractere a caractere.
- A cópia UTF-8 tinha 19341 bytes e zero bytes nulos.
- O frontmatter `name: jira-card-creator` e `description` continuou legível.
- O arquivo distribuído e o arquivo global não foram substituídos.

## GitHub e `.gitattributes`

O Git trata o arquivo como binário por causa dos bytes nulos. No Pull Request de publicação o diff aparece como `Bin`, não como texto. `.gitattributes` marca o caminho como `-text` para o `core.autocrlf` não inserir CR antes de cada LF e quebrar os pares UTF-16.

Se o arquivo passasse a UTF-8, a regra `-text` deixaria de ser necessária para esse caminho e o diff no GitHub voltaria a ser textual. Essa troca não foi feita.

## Decisão

A transcodificação preserva o texto. Não há prova de que a Cursor carrega essa cópia UTF-8 como subagente: ela não foi instalada no lugar do original. Por isso a versão 1.1.0 **mantém** o UTF-16 LE.

Pendência, para uma versão futura e com teste explícito de reconhecimento:

1. Instalar a cópia UTF-8 num perfil ou projeto de teste, sem apagar o original antes do backup.
2. Abrir um chat novo e confirmar `/jira-card-creator`.
3. Só então trocar o arquivo do repositório, atualizar `checksums.sha256` e o [CHANGELOG.md](../CHANGELOG.md), e retirar a regra `-text` se o arquivo deixar de ser UTF-16.
