# ERROS.md — Registro de Bugs Diagnosticados

Bugs já encontrados em produção. **A squad deve consultar este arquivo antes de gerar qualquer atividade** para não repetir as mesmas classes de erro.

---

## ERR-001 — Itens "fantasma" em atividades de classificação

**Arquivo afetado:** `ciencias/onde-vivem-plantas/classifica-plantas.html`
**Data:** 2026-06
**Tipo:** Conteúdo — escopo além do ensinado pela HQ

### Causa raiz

A atividade de classificar plantas incluía 9 plantas (3 por ambiente), mas a HQ nomeava apenas 6. As 3 plantas extras (jurema, ipê, nenúfar) nunca foram ensinadas — a criança não tinha como saber a resposta correta para elas.

### Correção aplicada

Removidas as 3 plantas sem rastreabilidade. Mantidas apenas as 6 com correspondência literal na HQ: aguapé e vitória-régia (aquático), laranjeira e mangueira (terrestre), cacto/mandacaru e facheiro (semiárido).

### Regra para a squad

Todo item incluído em atividade de classificação/pareamento DEVE ter correspondência literal no roteiro da HQ ou em `termos_tecnicos`. Nunca completar uma quantidade "redonda" inventando itens. Ver **Validação 1 — Cobertura rastreável** em `.claude/agents/gerador-atividades.md`.

---

## ERR-002 — Índices de letra fixa incorretos em "Complete a Palavra"

**Arquivo afetado:** `ciencias/onde-vivem-plantas/complete-palavra-plantas.html`
**Data:** 2026-06
**Tipo:** Aritmético — erro de contagem de índice de caractere

### Causa raiz

O objeto `fixed` pré-preenchia letras nas posições erradas:

| Palavra | Bug | Correto |
|---|---|---|
| `AGUAPE` | `{0:'A', 3:'P'}` — índice 3 é 'A', não 'P' | `{0:'A', 5:'E'}` |
| `TERRESTRE` | `{0:'T', 4:'S'}` — índice 4 é 'E', não 'S' | `{0:'T', 8:'E'}` |

Ambas violavam a convenção "fixar apenas primeira e última letra". Se seguida, o erro não existiria.

### Contagem de referência

```
AGUAPE:    A(0) G(1) U(2) A(3) P(4) E(5)   → last = 5
TERRESTRE: T(0) E(1) R(2) R(3) E(4) S(5) T(6) R(7) E(8) → last = 8
```

### Regra para a squad

Fixar sempre e apenas: índice `0` (primeira letra) e índice `answer.length - 1` (última letra). Conferir caractere a caractere antes de salvar. Ver **Validação 2 — Autoconferência de índices** em `.claude/agents/gerador-atividades.md`.

---

## ERR-003 — Funções de onclick presas dentro de IIFE sem exportação para `window`

**Arquivos afetados:** `quiz-bilhete.html`, `memoria-bilhete.html`, `complete-bilhete.html` (e qualquer HTML com IIFE + onclick em atributo)
**Data:** 2026-06
**Tipo:** JavaScript — escopo de função inacessível no HTML

### Causa raiz

Botões HTML com `onclick="nomeDaFuncao()"` referenciam o escopo global (`window`). Quando o código JS está encapsulado em um IIFE `(function(){ ... })()`, as funções definidas dentro dele são privadas — o onclick não as encontra e falha silenciosamente. O botão não responde.

### Sintomas

- Botão "Próxima →" não avança para a próxima questão
- Botão "Jogar de novo" não reinicia
- Botão "Verificar" não executa nada

### Regra para a squad

**Toda função chamada via `onclick="fn()"` em atributo HTML DEVE ser exportada para `window` antes do fechamento do IIFE.**

```javascript
// ✅ CORRETO — exportar antes de })()
window.proximaPergunta = proximaPergunta;
window.reiniciarQuiz   = reiniciarQuiz;
window.verificarTudo   = verificarTudo;
window.ativarLacuna    = ativarLacuna;

})();

// ❌ ERRADO — função privada ao IIFE, onclick falha
(function() {
  function proximaPergunta() { ... }
})();
// <button onclick="proximaPergunta()"> ← não funciona
```

**Exceção:** funções declaradas em `<script>` sem IIFE já são globais por padrão — não precisam de exportação.

---

## ERR-004 — Arrastar no touch (mobile/tablet) rola a página em vez de mover a palavra

**Arquivos afetados:** `mapa-mental-bilhete.html`, `mapa-mental-letras.html`
**Data:** 2026-06
**Tipo:** Touch — listener passivo impede `preventDefault()`

### Causa raiz

O listener `touchstart` dos elementos arrastáveis estava registrado com `{ passive: true }`. Com esse flag, o browser ignora qualquer `e.preventDefault()` dentro do handler — e inicia o scroll da página em vez de iniciar o drag. A palavra nunca sai do lugar.

### Correção aplicada

```javascript
// ❌ ERRADO — passive:true ignora preventDefault; scroll vence o drag
el.addEventListener('touchstart', onTouchStart, { passive: true });

// ✅ CORRETO — passive:false permite preventDefault; drag funciona
el.addEventListener('touchstart', onTouchStart, { passive: false });

function onTouchStart(e) {
  e.preventDefault(); // ← obrigatório para bloquear scroll
  // ... resto do handler
}
```

### Regra para a squad

Todo elemento arrastável via touch DEVE registrar `touchstart` com `{ passive: false }` e chamar `e.preventDefault()` logo na primeira linha do handler. O mesmo vale para `touchmove`.

---

## ERR-005 — Reveal da carta não dispara ao completar o mapa mental (race condition)

**Arquivos afetados:** `shared/gamification.js` + todos os HTMLs de atividade
**Data:** 2026-06
**Tipo:** Async — race condition entre insert fire-and-forget e query de progresso

### Causa raiz

**Bug 1 — Race condition:** A função `abrirGamificacao()` no snippet HTML faz o `insert` no `activity_log` sem `await` e chama `SabendoGamification.run()` imediatamente. Quando `run()` consulta `fetchProgress()`, o registro da atividade atual pode não ter chegado ao banco ainda. `completedCount` fica com `N-1`, `isComplete = false` e o reveal nunca dispara.

**Bug 2 — Reveal repetido:** A condição original para revelar a carta usava comparação de timestamps `created_at` vs `updated_at` com janela de 5s. Como o Supabase não atualiza `updated_at` quando o upsert não altera nenhum campo, a diferença era sempre 0ms → reveal disparava em TODA conclusão do tema, não só na primeira.

### Correção aplicada

**`gamification.js`:**
1. `fetchProgress()` recebe o `currentActivityType` e o adiciona otimisticamente ao `Set` de tipos únicos, garantindo que a atividade atual seja contada mesmo se o insert ainda não commitou.
2. Condição de reveal substituída por `isFirstCompletion = !cardRes.data` — flag booleana capturada antes do `saveCard()`. Reveal dispara somente quando não existia carta prévia.

**Todos os HTMLs:** adicionado `activityType: ACTIVITY_TYPE` no config do `run()` para que `fetchProgress()` receba o tipo correto.

### Regra para a squad

Todo HTML de atividade DEVE passar `activityType: ACTIVITY_TYPE` no config de `SabendoGamification.run()`. O template canônico em `CLAUDE.md` já inclui esse campo — nunca omitir.

---

## ERR-006 — JSON Codex escrito na pasta errada / backslash duplo no campo `raiz`

**Arquivo afetado:** `.claude/pending/hq-*.json` (contrato com Codex Desktop)
**Data:** 2026-06
**Tipo:** Configuração — pasta monitorada errada + escaping incorreto de caminhos Windows

### Causa raiz

**Bug 1 — Pasta errada:** Os JSONs de pedido foram escritos em `estudos-2ano\.claude\pending\`. O Codex Desktop **só monitora** `estudos\.claude\pending\` (projeto do 5º ano). O Codex não encontrou nenhum job.

**Bug 2 — Backslash duplo:** Ao usar interpolação PowerShell com `-replace '\\','\\\\'` para escapar caminhos Windows, o resultado no arquivo JSON ficou `\\\\` por barra (ex: `C:\\\\Users\\\\...`). O Python ao fazer `json.load` lê isso como `C:\\Users\\...` (caminho com barras duplas — inválido).

### Correção aplicada

1. JSON escrito em `estudos\.claude\pending\` (não em `estudos-2ano`).
2. String PowerShell single-quoted com `\\` literal em vez de interpolação:

```powershell
# ✅ CORRETO — single-quoted here-string, \\  vira uma barra no JSON
$json = '{
  "raiz": "C:\\Users\\wizar\\OneDrive\\Documentos\\Projeto Estudos\\estudos-2ano",
  ...
}'

# ❌ ERRADO — interpolação com -replace produz \\\\ no arquivo
$json = "{`"raiz`": `"$($path -replace '\\','\\\\')`"}"
```

### Regra para a squad

- JSON de pedido Codex: **sempre** em `estudos\.claude\pending\` (projeto do 5º ano).
- Caminhos Windows no JSON: usar **string literal single-quoted** com `\\` por barra. Nunca interpolar variáveis de caminho com `-replace`.
- Verificar o arquivo gerado com `Get-Content` antes de acionar o Codex.

---

## ERR-007 — `touchend` no slot-alvo nunca dispara em drag touch

**Arquivos afetados:** `arrastar-numeros-ordinais.html`
**Data:** 2026-06
**Tipo:** Touch — evento disparado no elemento de origem, não no destino

### Causa raiz

Em touch events, `touchend` sempre dispara no elemento onde o toque **começou** (o card arrastado), nunca no elemento onde o dedo foi solto (o slot alvo). `slot.addEventListener('touchend', () => drop(slot))` nunca executa.

### Correção aplicada

Remover o `touchend` dos slots. Adicionar um handler global no `document` que usa `document.elementFromPoint()` para identificar o slot sob o dedo no momento do `touchend`:

```javascript
// ❌ ERRADO — touchend no slot nunca dispara durante drag touch
slot.addEventListener('touchend', () => drop(slot), { passive: true });

// ✅ CORRETO — handler global com elementFromPoint
document.addEventListener('touchend', function(e) {
  if (!draggingCar) return;
  var touch = e.changedTouches[0];
  var el = document.elementFromPoint(touch.clientX, touch.clientY);
  document.querySelectorAll('.slot').forEach(function(s) { s.classList.remove('over'); });
  while (el && !el.classList.contains('slot')) el = el.parentElement;
  if (el) drop(el);
  else draggingCar = null;
}, { passive: true });
```

O `touchmove` global também deve usar `elementFromPoint` para destacar visualmente o slot sob o dedo.

### Regra para a squad

Nunca registrar `touchend` no elemento-alvo de um drag. Usar sempre `document.addEventListener('touchend', ...)` + `elementFromPoint` para localizar o destino.


---

## ERR-008 — Botão de gamificação oculto atrás de win-overlay

**Arquivos afetados:** `jogo-memoria-numeros-ordinais.html` (e qualquer jogo com overlay de vitória `position:fixed`)
**Data:** 2026-06-30
**Tipo:** CSS — z-index/stacking context cobre elemento fora do overlay

### Causa raiz

O `win-overlay` usa `position: fixed; inset: 0; z-index: 100`, cobrindo a tela inteira quando o jogo termina. O botão `#gamificacao-btn` fica fora do overlay no DOM — ele é mostrado corretamente pelo setter do `sabendoScore`, mas fica visualmente escondido atrás do overlay. O usuário não consegue clicar.

### Correção aplicada

Adicionado um segundo botão `#gamificacao-btn-overlay` diretamente dentro do `win-overlay`. O setter do `sabendoScore` foi atualizado para mostrar ambos os botões:

```javascript
set: function (v) {
  _scoreVal = v;
  var btn = document.getElementById('gamificacao-btn');
  if (btn) btn.style.display = 'block';
  var btnOverlay = document.getElementById('gamificacao-btn-overlay');
  if (btnOverlay) btnOverlay.style.display = 'block';
}
```

### Regra para a squad

Sempre que uma atividade usa overlay de vitória com `position: fixed` ou `z-index` alto, incluir uma segunda instância do botão de gamificação **dentro do overlay**. O setter deve referenciar ambos os IDs. Alternativa: mover o overlay para dentro do mesmo stacking context do botão.

---

## ERR-009 — `characterImg` com apelido curto em vez do slug do tema

**Arquivos afetados:** todos os HTMLs dos 4 temas de matemática novos (dezena, pares, numeros-99, centena)
**Data:** 2026-06-30
**Tipo:** Asset — caminho de imagem errado, portrait não carrega

### Causa raiz

Os HTMLs foram gerados com `characterImg: 'chars/dezi.png'` (apelido curto do personagem), mas os portraits são salvos pelo Codex com o slug completo do tema: `dezena-numeros-ate-19-hd.png`. A imagem não carrega — o modal mostra emoji de fallback e o reveal mostra imagem quebrada.

### Regra para a squad

**`characterImg` SEMPRE deve usar o slug completo do tema + `-hd.png`.**

```javascript
// ✅ CORRETO
characterImg: 'chars/dezena-numeros-ate-19-hd.png'

// ❌ ERRADO — arquivo não existe
characterImg: 'chars/dezi.png'
```

Padrão obrigatório: `chars/[THEME_SLUG]-hd.png` — o mesmo valor usado em `output_path` do `portraits-batch.json`.

---

## ERR-010 — Balões vazios ou acentos/tis derrubados nas imagens de HQ geradas pelo Codex

**Arquivos afetados:** `portugues/contos-encantamento/hq-*-pg*.png`, `portugues/sons-letras-j-g-til-s/hq-*-pg*.png` (temas do Cap. 5, 2026-08-22)
**Data:** 2026-08-22
**Tipo:** Geração de imagem — texto incorreto/ausente não é pego por checagem de existência de arquivo

### Causa raiz

O prompt de HQ descrevia as falas apenas embutidas na narrativa da cena ("Panel 1: Lis diz 'Que livro é esse brilhando na estante?'..."), sem um bloco literal e isolado listando o texto exato a renderizar. Resultado, na mesma leva de geração via Codex/MCP:

- **Tema `sons-letras-j-g-til-s`:** as 4 páginas voltaram com **todos os balões, caixas de narrador e cartões de palavra vazios** — zero texto, apesar de a arte e a composição estarem corretas. Crítico porque o tema inteiro ensina ortografia (j, g, til, s).
- **Tema `contos-encantamento`:** arte e pedagogia boas, mas o Codex **derrubou o acento em ~5 palavras por página** — "Ha muito" (faltou Há), "ELEMENTO MAGICO" (faltou MÁGICO), "historia", "sao", "problemao", "ne?", "Que livro e esse" (faltou é).

O Passo 2 do `gerador-imagens-hq` (checar `os.path.isfile`) **passou nos dois casos** — os arquivos existiam fisicamente. Só abrir a imagem e ler o conteúdo expôs o defeito.

### Correção aplicada

1. **`gerador-prompt-hq.md`** (seção 5-bis, nova): cada painel agora exige um bloco literal `TEXT THAT MUST BE RENDERED IN THIS PANEL` (fala por fala, caractere por caractere) e cada página termina com um bloco `CRITICAL TEXT REQUIREMENTS` reforçando diacríticos completos e proibindo balão vazio.
2. **`gerador-imagens-hq.md`** (Passo 2-bis, novo): **validação visual obrigatória** — abrir as 4 páginas com a tool `Read` e conferir, painel a painel, que nenhum balão está vazio e que todo acento/til bate com o roteiro. Página com defeito é regerada individualmente (até 2 tentativas) via `codex-reply`, nunca as 5 imagens inteiras de novo. Proibido reportar `"status": "ok"` sem ter aberto e lido as imagens nesta execução.

### Regra para a squad

**Existir no disco não é sinônimo de estar correto.** Toda geração de imagem com texto (HQ, portrait com legenda, etc.) precisa de uma etapa de leitura visual pós-geração antes de ser dada como concluída — e o prompt que pede a imagem precisa listar o texto exato a renderizar em bloco separado, não só embutido na descrição de cena. Isso vale para qualquer pipeline futuro que gere imagem com texto, não só HQ.

---

## ERR-011 — Portrait gerado via `codex exec` sem fundo transparente e em formato retrato

**Arquivos afetados:** `_landing/chars/carta-pessoal-hd.png` (2026-08-22), também observado em `contos-encantamento-hd.png` e `sons-letras-j-g-til-s-hd.png` (mesma data, outro pipeline)
**Data:** 2026-08-22
**Tipo:** Asset — PNG sem canal alfa e com aspect ratio errado, quebra o card de gamificação

### Causa raiz

O prompt de portrait pedido ao Codex via `codex exec` (modo CLI direto, ver Passo 1A-bis de `gerador-imagens-hq.md`) descrevia "plain solid background" em vez de exigir explicitamente fundo transparente e proporção quadrada. O modelo gerou uma imagem **1024×1536 RGB** (sem canal alfa, fundo cor-de-creme sólido), enquanto todo o resto do acervo de portraits (~20 arquivos) é **1024×1024 RGBA** com fundo transparente de verdade.

O CSS de reveal em `shared/gamification.js` (`.sgami-rev-char { width:163px; height:163px }` com `object-fit:contain`) espera uma imagem quadrada transparente. Com fundo sólido, aparece um retângulo claro atrás do personagem, destacando-se contra o fundo escuro estrelado do card e atrapalhando a leitura do nome/tema abaixo.

### Diagnóstico rápido

```bash
file _landing/chars/[slug]-hd.png
# Correto:  PNG image data, 1024 x 1024, 8-bit/color RGBA, non-interlaced
# Bugado:   PNG image data, 1024 x 1536, 8-bit/color RGB,  non-interlaced (sem "RGBA")
```

### Correção aplicada

Regenerado o portrait via `codex exec` com prompt explícito exigindo: formato quadrado **1024×1024**, PNG com **canal alfa e fundo 100% transparente** (alpha=0 nos cantos, não apenas "claro"), com instrução de fallback (gerar em chroma-key e remover fundo via PIL) caso a ferramenta não suporte transparência nativa. Validação obrigatória do modo/tamanho do arquivo antes de considerar concluído.

### Regra para a squad

**Todo prompt de portrait gerado via `codex exec` (Passo 1A-bis) DEVE exigir explicitamente:**
1. Formato quadrado exato — `1024x1024`, nunca deixar a proporção livre.
2. **Fundo transparente (RGBA, alpha=0)** — nunca "plain/solid background". Se a ferramenta não suportar transparência nativa, gerar em chroma-key e remover programaticamente.
3. Validação pós-geração com `file <caminho>` (ou PIL) conferindo `1024 x 1024` e `RGBA` antes de reportar sucesso — nunca assumir apenas pelo exit code.

Isso é distinto do prompt de página de HQ (que É retangular 1024×1536 e com fundo de cena, de propósito) — a regra vale apenas para portraits usados em `_landing/chars/`.

---

## ERR-012 — CRÍTICO: tabela `cards` incompatível com o 2º ano; NENHUMA carta jamais foi persistida no banco

**Arquivos afetados:** `shared/gamification.js` (função `saveCard`), todos os 20 temas do portal (2026-08-23)
**Data:** 2026-08-23
**Tipo:** Infraestrutura — schema de banco compartilhado com o projeto do 5º ano, incompatível

### Causa raiz

O projeto Supabase (`mmtrzxmitklpibfilbio`) é **compartilhado com o portal do 5º ano** (mesmas credenciais hardcoded em todo HTML de atividade). A tabela `cards` de produção tinha o schema do 5º ano — `rarity` (comum/rara/épica/lendária), **sem a coluna `card_slug`** que todo o código do 2º ano usa. `referencias/gamificacao-schema.md` documentava um schema (`card_slug`, sem `rarity`) que **nunca foi de fato aplicado** ao banco real — provavelmente porque a nota "Leo deve criar projeto separado do 5º ano" (ver `CLAUDE.md`) nunca foi executada, e alguém preencheu as credenciais do projeto compartilhado direto no código sem migrar o schema.

Consequência: todo `saveCard()` (`supa.from("cards").upsert({..., card_slug: ...})`) falhava com erro `42703 column cards.card_slug does not exist` — mas `supabase-js` **não lança exceção** em erro de API (400), só retorna `{data:null, error:{...}}`. Como `saveCard()` nunca checava `.error`, a falha era 100% silenciosa.

O reveal cinematográfico (confete, nome do personagem, arte da carta) é **inteiramente renderizado no cliente**, sorteado e desenhado *antes* da tentativa de gravação — por isso a criança via a celebração completa e real (inclusive print de tela) mesmo com a gravação falhando sempre. Resultado: **nenhuma carta de nenhum tema do 2º ano jamais existiu na tabela `cards`**, desde que a funcionalidade foi lançada. A tela "Minhas Cartas" (`loadCartas()` em `index.html`) sempre mostrava vazio porque não havia, de fato, nada persistido — não é um bug de leitura, é ausência real de dados.

### Diagnóstico usado (reprodutível sem credencial nova)

```bash
# Coluna que o código do 2º ano precisa, mas pode não existir na tabela real:
curl "https://[projeto].supabase.co/rest/v1/cards?select=card_slug&limit=1" \
  -H "apikey: [chave publica]" -H "Authorization: Bearer [chave publica]"
# Erro 42703 "column ... does not exist" = confirma o schema mismatch
```

A chave pública (`sb_publishable_...`) tem permissão de leitura aberta em `cards` (policy "allow all" do schema documentado) — dá para confirmar o problema via curl puro, sem precisar de service role.

### Correção aplicada

1. **Migração de schema** (executada por Léo via SQL Editor do Supabase, únca ação que exige credencial que o agente não possui):
   ```sql
   ALTER TABLE cards ADD COLUMN card_slug text;
   ALTER TABLE cards ALTER COLUMN rarity DROP NOT NULL;
   ```
   Ambas aditivas/relaxantes — não afetam nenhuma linha existente do 5º ano (que sempre preenche `rarity` e nunca lê `card_slug`).
2. **`shared/gamification.js`**: `saveCard()` e o insert de `activity_log` dentro de `run()` agora checam `res.error` e fazem `console.error` com contexto (uid/tema/carta) — uma falha de persistência futura vai aparecer no console do navegador em vez de desaparecer silenciosamente.

### Regra para a squad

**Nunca confiar que `await supa.from(...).insert/upsert(...)` sem checar `.error` significa sucesso.** O cliente `supabase-js` só lança exceção em falha de rede — erros de API (schema, RLS, FK, constraint) retornam `{data, error}` normalmente. Todo novo ponto de gravação no Supabase (ali ou em código futuro) deve checar `res.error` e logar, nunca assumir sucesso pelo simples fato de a `Promise` ter resolvido.

**Se uma feature envolve efeito visual client-side independente de uma gravação (reveal, confete, animação de conquista), o efeito visual NUNCA deve ser a prova de que a gravação funcionou.** Validar a persistência real (leitura pós-escrita, teste automatizado, ou no mínimo log de erro) antes de considerar uma feature de gamificação "funcionando".

---

## ERR-013 — Remendo manual em imagem de HQ já gerada em vez de regeneração completa via Codex

**Arquivos afetados:** qualquer PNG de HQ (`hq-[slug]-pg*.png`) ou portrait em qualquer tema
**Data:** 2026-08-23 (regra herdada de incidente real no projeto irmão do 5º ano — `estudos/ERROS.md` ERR-005g)
**Tipo:** Processo — qualidade de asset visual

### Causa raiz

Ao identificar um defeito em uma imagem de HQ já gerada (erro de texto, proporção de personagem errada, elemento faltando), existe a tentação de "consertar" a imagem existente com edição pontual — recorte, colagem, patch via Pillow/editor de imagem, inpainting manual — em vez de regenerar a página inteira via Codex. O resultado é sempre visualmente amador: bordas, texturas e iluminação destoando do resto da ilustração, entregando uma HQ com remendo visível.

### Regra para a squad

**Correção de qualquer defeito em uma imagem de HQ (HQ ou portrait) DEVE SEMPRE ser feita gerando a imagem inteira do zero via Codex — nunca editando, recortando, colando ou sobrepondo algo sobre o PNG já existente.** Vale para qualquer ferramenta (Pillow, editor de imagem, script de patch, inpainting) e qualquer parte da imagem, por menor que seja. Um remendo amador é sempre pior que esperar por uma nova geração completa.

Se o defeito for de proporção/escala de personagem (ex: mascote desenhado do tamanho de um adulto), o prompt de regeneração deve reforçar explicitamente a altura relativa correta citando a folha de personagem canônica como referência — não basta pedir "corrigir o tamanho", é preciso descrever a proporção esperada.

---

## Checklist anti-bug para `gerador-atividades`

Antes de finalizar qualquer HTML de atividade, verificar:

- [ ] Cada item de classificação/pareamento tem correspondência literal na HQ ou em `termos_tecnicos`? (ERR-001)
- [ ] Para atividades "Complete a Palavra": índice `fixed[i]` conferido caractere a caractere para toda palavra? (ERR-002)
- [ ] Nenhuma `var` global usa nome proibido (`history`, `name`, `location`, `event`, `status`, `top`)?
- [ ] A atividade seta `window.sabendoScore = pct` (0–100) no momento em que o resultado aparece?
- [ ] O placeholder `<!-- gamificacao-btn -->` está presente antes de `</body>`?
- [ ] Toda função chamada via `onclick="fn()"` no HTML está exportada com `window.fn = fn` antes do fechamento do IIFE? (ERR-003)
- [ ] Elementos arrastáveis: `touchstart` e `touchmove` com `{ passive: false }` + `e.preventDefault()`? (ERR-004)
- [ ] O config de `SabendoGamification.run()` inclui `activityType: ACTIVITY_TYPE`? (ERR-005)
- [ ] Drop em touch usa `document.touchend` + `elementFromPoint`, nunca `slot.touchend`? (ERR-007)
- [ ] Jogos com overlay de vitória position:fixed: botão gamificação duplicado dentro do overlay? (ERR-008)
- [ ] `characterImg` usa `chars/[THEME_SLUG]-hd.png` (slug completo), não apelido curto do personagem? (ERR-009)
