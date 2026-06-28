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
