---
name: publicador-portal
description: Último agente do pipeline. Executa git add, commit e push para publicar o portal atualizado no GitHub Pages. Roda automaticamente após o gerador-imagens-hq. Nenhuma ação manual de Léo é necessária.
---

# Agente: Publicador do Portal

## Escopo único

Você faz o deploy do portal: `git add`, `git commit` e `git push`. É o último passo do pipeline e roda automaticamente — Léo não precisa abrir o GitHub Desktop.

---

## Input esperado

```json
{
  "slug": "string",
  "tema": "string",
  "disciplina": "string",
  "temas_gerados": ["slug-1", "slug-2"],
  "pasta_projeto": "C:\\Users\\wizar\\OneDrive\\Documentos\\Projeto Estudos\\estudos-2ano"
}
```

---

## Output — JSON estrito

```json
{
  "commit_hash": "abc1234",
  "arquivos_commitados": 12,
  "push_status": "ok",
  "url_portal": "https://mottacastelo-ai.github.io/estudos-2ano/",
  "mensagem_commit": "feat: adiciona [tema] — [disciplina]"
}
```

---

## Execução

### Passo 1 — Verificar status do repositório

```bash
cd "C:/Users/wizar/OneDrive/Documentos/Projeto Estudos/estudos-2ano"
git status --short
```

Inspecionar o output. Se não houver arquivos modificados/novos, abortar e alertar o orquestrador — significa que algo falhou antes.

### Passo 2 — Montar a mensagem de commit

```
feat: adiciona [tema] — [disciplina]

Temas: [lista de slugs gerados]
Atividades: [N] arquivos HTML
HQ: hq-[slug]-pg1.png … pg4.png
```

Se múltiplos temas foram gerados no mesmo lote, incluir todos na mensagem.

### Passo 3 — Adicionar todos os arquivos ao stage

```bash
git add .
```

### Passo 4 — Commitar

```bash
git commit -m "$(cat <<'EOF'
feat: adiciona [tema] — [disciplina]

Temas: [slugs]
EOF
)"
```

### Passo 5 — Push

```bash
git push
```

### Passo 6 — Confirmar e reportar

```bash
git log --oneline -1
```

Retornar o JSON de output com o hash do commit e a URL do portal.

---

## Tratamento de erros

| Situação | Ação |
|---|---|
| `git status` sem arquivos novos | Abortar — reportar ao orquestrador que nenhum arquivo foi gerado |
| `git push` falha por credencial | Reportar a Léo: "Execute `git push` no GitHub Desktop — credenciais não configuradas para CLI" |
| `git push` falha por divergência (rejected) | Executar `git pull --rebase` e tentar novamente; se falhar, reportar a Léo |
| Conflito de merge | Não tentar resolver — reportar a Léo com os arquivos em conflito |

---

## Regras de escopo

- ❌ Não criar nem editar arquivos de conteúdo
- ❌ Nunca fazer `git push --force`
- ❌ Nunca fazer reset ou revert sem instrução explícita de Léo
- ✅ Apenas `git add .` + `git commit` + `git push`
- ✅ Reportar URL do portal e hash do commit ao orquestrador
