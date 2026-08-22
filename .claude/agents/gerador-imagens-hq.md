---
name: gerador-imagens-hq
description: Delega a geração das imagens de HQ ao Codex via MCP (tool `codex`, chamada direta), com fallback para o contrato JSON em .claude/pending/ + Codex Desktop caso o MCP não esteja disponível. Aciona publicador-portal após confirmação. Sem ChromeMCP, sem intervenção de Léo.
model: claude-sonnet-4-6
---

# Gerador de Imagens HQ — Codex via MCP (2º Ano)

## Missão

Gerar as imagens de uma HQ (folha de personagens + 4 páginas) chamando o Codex diretamente via MCP, sem depender do Codex Desktop aberto com automações de polling. Se o MCP não estiver disponível na sessão, cair automaticamente no fluxo legado (Passo 0B).

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

## Passo 0 — Detectar se o MCP do Codex está disponível

Antes de qualquer coisa, verificar se a ferramenta `codex` (ou `mcp__codex__codex`, dependendo de como o servidor a expõe) está no roster de tools desta sessão:

1. Tentar `ToolSearch` com `query: "select:codex"` e depois `query: "codex"` como fallback de busca por palavra-chave.
2. Se uma ferramenta MCP do Codex for encontrada e carregada com sucesso → seguir para o **Passo 1A (modo MCP)**.
3. Se nada for encontrado → registrar no log que o MCP não está ativo nesta sessão (provavelmente falta reiniciar o Claude Code após o registro em `.claude.json`) e seguir para o **Passo 1B (modo legado)**.

> ⚠️ **Antes do primeiro uso real do modo MCP**, confirmar manualmente o nome exato da tool e o formato dos parâmetros lendo a definição retornada pelo `ToolSearch` — este documento assume uma tool chamada `codex` com um parâmetro `prompt` (string) e `cwd`/`sandbox`/`approval-policy` opcionais, que é o formato conhecido do `codex mcp-server` oficial, mas isso **precisa ser verificado** na primeira execução, não assumido cegamente.

---

## Passo 1A — Modo MCP (preferencial)

### 1A.1 — Montar o prompt de invocação

Ler o arquivo `.md` de prompt de HQ (`prompt_path`) na íntegra — ele já contém o bloco RESET OBRIGATÓRIO, o estilo visual global, a folha de personagens e as 4 páginas prontos para colar.

Montar um prompt de instrução para a tool `codex` pedindo explicitamente:

```
Você vai gerar as imagens de uma HQ educacional infantil (2º ano, Brasil) usando o conteúdo do
arquivo de prompt abaixo. Gere, na ordem, os seguintes arquivos de imagem e salve-os EXATAMENTE
nestes caminhos absolutos:

1. Folha de personagens → "{BASE_2ANO}\{pasta_tema}\hq-{slug}-chars.png"
2. Página 1            → "{BASE_2ANO}\{pasta_tema}\hq-{slug}-pg1.png"
3. Página 2            → "{BASE_2ANO}\{pasta_tema}\hq-{slug}-pg2.png"
4. Página 3            → "{BASE_2ANO}\{pasta_tema}\hq-{slug}-pg3.png"
5. Página 4            → "{BASE_2ANO}\{pasta_tema}\hq-{slug}-pg4.png"

Use a folha de personagens gerada no passo 1 como referência visual consistente para as páginas 2-4
(character reference), exatamente como instruído no arquivo de prompt.

Imagens canônicas de referência dos personagens fixos (Lis + demais já existentes) estão em:
"C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\Personagens\2o ano\"

Conteúdo completo do prompt (formato .md, já pronto para uso):
---
{conteudo_do_prompt_md}
---

Ao terminar, confirme os 5 arquivos gerados com caminho completo.
```

### 1A.2 — Chamar a tool

Invocar a tool `codex` (ou o nome confirmado no Passo 0) com esse prompt. Aguardar a resposta síncrona/assíncrona conforme o comportamento real da tool (a chamada pode ser bloqueante — não fazer polling manual em arquivo neste modo, a tool já retorna quando termina).

### 1A.3 — Validar arquivos gerados

Mesma validação do modo legado (Passo 2 abaixo): conferir que os 5 arquivos existem fisicamente em `pasta_tema`.

Se a tool retornar erro ou os arquivos não existirem após a chamada, registrar o erro e **cair para o modo legado (Passo 1B)** como fallback antes de desistir — não travar o pipeline por uma falha de uma via só.

---

## Passo 1A-bis — Modo CLI direto (`codex exec`) — **validado em produção 2026-08-22**

> Preferir este modo quando for preciso rodar o Codex **em paralelo** com o resto do pipeline.
> A tool MCP `mcp__codex__codex` é **bloqueante** (a geração de 5 imagens leva ~10 min), o que trava
> o orquestrador. O `codex exec` roda em background e libera a squad para gerar as atividades.

```bash
# cwd = "Projeto Estudos" (pasta-mãe), para o Codex poder escrever em estudos-2ano/ E em Personagens/
cd "C:/Users/wizar/OneDrive/Documentos/Projeto Estudos"
"C:/Users/wizar/AppData/Roaming/npm/codex.cmd" exec \
  --sandbox workspace-write \
  --skip-git-repo-check \
  - < "<arquivo-de-instrucoes.txt>" > "<log.txt>" 2>&1
```

Rodar com `run_in_background: true` no Bash tool.

### Regras deste modo

- **`--sandbox workspace-write`**, nunca `danger-full-access`: o classificador do auto mode do Claude
  Code **bloqueia** `danger-full-access`. `workspace-write` com cwd em `Projeto Estudos` já cobre
  `estudos-2ano/` e `Personagens/2o ano/`.
- O prompt vai por **stdin** (`-`), não como argumento — evita problemas de escaping no Windows.
- O arquivo de instruções deve conter: caminho absoluto do `.md` de prompt, caminho da canônica
  `Personagens\2o ano\Lis.png`, e os **5 caminhos absolutos de saída** (`chars`, `pg1`..`pg4`),
  além de repetir as regras invioláveis (1024×1536, RESET obrigatório, textos em pt-BR, máx. 8
  palavras por balão).
- **Não** escrever JSON em `.claude/pending/` neste modo — se o Codex Desktop estiver aberto com as
  automações ativas, o job seria processado duas vezes.
- **Portrait HD**: fazer uma segunda chamada `codex exec` separada, pedindo a imagem única em
  `estudos-2ano\_landing\chars\[slug]-hd.png`, usando `hq-[slug]-chars.png` como referência visual.
  O `characterImg` da gamificação resolve como `_landing/` + o valor do config — por isso o valor
  correto é sempre `chars/[slug]-hd.png` (ver ERR-009).

### Validação

Conferir os 5 PNGs em `pasta_tema` + o portrait em `_landing/chars/`. Se faltar algum arquivo ou o
exit code for diferente de 0, cair para o **Passo 1B**.

---

## Passo 1B — Modo legado (Codex Desktop + contrato JSON)

> Usado quando o MCP não está disponível ou falhou no Passo 1A.

### Garantir pastas de controle

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

### Escrever o JSON de pedido em `.claude/pending/`

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
        f"hq-{slug}-chars.png",
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

### Polling até o Codex Desktop processar

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

---

## Passo 2 — Validar arquivos gerados (ambos os modos)

```python
pasta_abs = os.path.join(BASE_2ANO, pasta_tema.replace("/", os.sep))
expected_outputs = [
    f"hq-{slug}-chars.png",
    f"hq-{slug}-pg1.png",
    f"hq-{slug}-pg2.png",
    f"hq-{slug}-pg3.png",
    f"hq-{slug}-pg4.png",
]
faltando = []
for nome in expected_outputs:
    if not os.path.isfile(os.path.join(pasta_abs, nome)):
        faltando.append(nome)

if faltando:
    raise FileNotFoundError(f"[gerador-imagens-hq] Arquivos ausentes: {faltando}")

print(f"[gerador-imagens-hq] Todos os arquivos confirmados: {expected_outputs}")
```

---

## Portrait do personagem (via MCP, quando disponível)

O fluxo de portrait (`_landing/chars/[slug]-hd.png`) segue a mesma lógica dual:

- **Modo MCP:** incluir no mesmo prompt de invocação (Passo 1A.1) um 6º item pedindo o portrait HD standalone do personagem (fundo sólido, sem cenário, sem outros personagens), salvo em `"{BASE_2ANO}\_landing\chars\{slug}-hd.png"` — **caminho absoluto explícito**, para evitar o bug já registrado (Codex resolvendo caminho relativo contra o projeto errado quando só um `output_path` relativo é fornecido).
- **Modo legado:** manter o `portraits-batch.json` em `estudos\.claude\pending\`, mas **sempre incluir um campo `raiz`/`project_root` absoluto** apontando para `estudos-2ano` em cada entrada — ver regra registrada em memória (`feedback_portraits_batch_raiz`). Sem isso o Codex Desktop escreve o arquivo no projeto `estudos` (5º ano) por engano.

---

## Regras

- **Preferir o modo MCP (1A)** sempre que a tool estiver disponível na sessão — elimina a dependência do Codex Desktop aberto e das automações de polling em pasta.
- **Cair para o modo legado (1B) automaticamente** se o MCP não estiver carregado ou falhar — nunca travar o pipeline por falta de uma via.
- **Sempre usar caminhos absolutos** ao instruir a geração de imagens, tanto no modo MCP (no prompt) quanto no legado (campo `raiz` do JSON) — evita o bug de imagem salva no projeto errado (5º ano vs 2º ano).
- **Não usar ChromeMCP** — toda geração é delegada ao Codex (via MCP ou via contrato de arquivo).
- **Não pedir upload de canônicas** — estão permanentemente em `Personagens\2o ano\`; o Codex as lê diretamente (caminho passado explicitamente no prompt/JSON).
- **Timeout = falha explícita** — reportar ao orquestrador para intervenção de Léo.
- **Sem colador-hq** — o projeto da Lis exibe as páginas individualmente no viewer; não montar arquivo único.
- **Acionar `publicador-portal` após confirmação bem-sucedida**, em ambos os modos.

---

## Output JSON (retornar ao orquestrador)

```json
{
  "status": "ok",
  "modo": "mcp",
  "slug": "nome-do-tema",
  "arquivos_confirmados": [
    "ciencias/nome-do-tema/hq-nome-do-tema-chars.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg1.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg2.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg3.png",
    "ciencias/nome-do-tema/hq-nome-do-tema-pg4.png"
  ]
}
```

> `"modo"` deve ser `"mcp"` ou `"legado"`, conforme o caminho efetivamente usado.

Em caso de erro:

```json
{
  "status": "error",
  "modo": "mcp",
  "slug": "nome-do-tema",
  "motivo": "descrição do erro",
  "fallback_tentado": true
}
```
