---
name: gerador-imagens-hq
description: Delega a geração das imagens de HQ ao Codex Desktop via contrato JSON em .claude/pending/. Escreve o pedido, faz polling em .claude/done/ e aciona publicador-portal após confirmação. Sem ChromeMCP, sem intervenção de Léo.
model: claude-sonnet-4-6
---

# Gerador de Imagens HQ — Contrato Codex (2º Ano)

## Missão

Acionar o Codex Desktop para gerar as imagens da HQ (chars + pg1–pg4) escrevendo um JSON de pedido na pasta `.claude/pending/` e aguardando confirmação em `.claude/done/`.

## Input esperado

```json
{
  "slug": "nome-do-tema",
  "disciplina": "ciencias",
  "pasta_tema": "ciencias/nome-do-tema",
  "prompt_path": "ciencias/nome-do-tema/hq-nome-do-tema-prompt.md"
}
```

> `pasta_tema` e `prompt_path` são **relativos à raiz do projeto** (`estudos-2ano/`).

---

## Procedimento

### Passo 1 — Garantir pastas de controle

> ⚠️ O Codex Desktop monitora `estudos\.claude\pending\` (projeto do 5º ano), não `estudos-2ano\.claude\pending\`.
> Por isso os JSONs de pedido e de resposta usam o caminho do projeto `estudos` como ponto de troca,
> mas o campo `raiz` dentro do JSON aponta para `estudos-2ano` (onde as imagens serão salvas).

```python
import os

BASE_2ANO  = r"C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano"
BASE_CODEX = r"C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos"

for pasta in [".claude/pending", ".claude/done", ".claude/error"]:
    os.makedirs(os.path.join(BASE_CODEX, pasta), exist_ok=True)
```

### Passo 2 — Extrair nome do personagem do prompt.md

```python
import re

prompt_abs = os.path.join(BASE_2ANO, INPUT["prompt_path"].replace("/", os.sep))
with open(prompt_abs, encoding="utf-8") as f:
    conteudo = f.read()

match = re.search(r'###\s+Personagem principal:\s+(.+)', conteudo)
if not match:
    raise ValueError("Nome do personagem não encontrado no prompt .md")

nome_personagem = match.group(1).strip()
```

### Passo 3 — Escrever o JSON de pedido em `.claude/pending/`

```python
import json

slug = INPUT["slug"]
disciplina = INPUT["disciplina"]
pasta_tema = INPUT["pasta_tema"]

pedido = {
    "slug": slug,
    "disciplina": disciplina,
    "raiz": BASE_2ANO,
    "prompt_path": INPUT["prompt_path"],
    "canonicas_path": r"C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\Personagens\2o ano",
    "output_dir": pasta_tema,
    "expected_outputs": [
        f"hq-{slug}-pg1.png",
        f"hq-{slug}-pg2.png",
        f"hq-{slug}-pg3.png",
        f"hq-{slug}-pg4.png",
    ]
}

# JSON gravado em estudos\.claude\pending\ — caminho monitorado pelo Codex Desktop
pending_path = os.path.join(BASE_CODEX, ".claude", "pending", f"hq-{slug}.json")
with open(pending_path, "w", encoding="utf-8") as f:
    json.dump(pedido, f, ensure_ascii=False, indent=2)

print(f"[gerador-imagens-hq] Pedido escrito: {pending_path}")
```

### Passo 4 — Polling até o Codex processar

Verificar a cada **30 segundos** por até **30 minutos** (60 ciclos).

```python
import time

done_path  = os.path.join(BASE_CODEX, ".claude", "done",  f"hq-{slug}.json")
error_path = os.path.join(BASE_CODEX, ".claude", "error", f"hq-{slug}.json")
MAX_CICLOS = 60

for ciclo in range(1, MAX_CICLOS + 1):
    if os.path.isfile(done_path):
        print(f"[gerador-imagens-hq] ✅ Codex concluiu após {ciclo * 30}s")
        break
    if os.path.isfile(error_path):
        with open(error_path, encoding="utf-8") as f:
            err = json.load(f)
        raise RuntimeError(f"[gerador-imagens-hq] ❌ Codex reportou erro: {err.get('error_message', 'desconhecido')}")
    print(f"[gerador-imagens-hq] Aguardando Codex… ciclo {ciclo}/{MAX_CICLOS}")
    time.sleep(30)
else:
    raise TimeoutError("[gerador-imagens-hq] Timeout: Codex não respondeu em 30 min. Verificar automação 'Gerar HQs pendentes' no Codex Desktop.")
```

### Passo 5 — Validar arquivos gerados

```python
pasta_abs = os.path.join(BASE_2ANO, pasta_tema.replace("/", os.sep))
faltando = []
for nome in pedido["expected_outputs"]:
    if not os.path.isfile(os.path.join(pasta_abs, nome)):
        faltando.append(nome)

if faltando:
    raise FileNotFoundError(f"[gerador-imagens-hq] Arquivos ausentes após done/: {faltando}")

print(f"[gerador-imagens-hq] Todos os arquivos confirmados: {pedido['expected_outputs']}")
```

---

## Regras

- **Não usar ChromeMCP** — toda geração é delegada ao Codex via contrato de arquivo.
- **Não pedir upload de canônicas** — estão permanentemente em `Personagens\2o ano\`; o Codex as lê diretamente.
- **Timeout = falha explícita** — reportar ao orquestrador para intervenção de Léo.
- **Sem colador-hq** — o projeto da Lis exibe as páginas individualmente no viewer; não montar arquivo único.
- **Acionar `publicador-portal` após confirmação bem-sucedida.**

---

## Output JSON (retornar ao orquestrador)

```json
{
  "status": "ok",
  "slug": "nome-do-tema",
  "paginas_confirmadas": [
    "ciencias/nome-do-tema/hq-nome-do-tema-pg1.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg2.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg3.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg4.png"
  ],
  "done_json": ".claude/done/hq-nome-do-tema.json"
}
```

Em caso de erro:

```json
{
  "status": "error",
  "slug": "nome-do-tema",
  "motivo": "Codex reportou erro: [error_message]"
}
```
