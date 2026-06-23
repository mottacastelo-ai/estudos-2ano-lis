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

## Checklist anti-bug para `gerador-atividades`

Antes de finalizar qualquer HTML de atividade, verificar:

- [ ] Cada item de classificação/pareamento tem correspondência literal na HQ ou em `termos_tecnicos`? (ERR-001)
- [ ] Para atividades "Complete a Palavra": índice `fixed[i]` conferido caractere a caractere para toda palavra? (ERR-002)
- [ ] Nenhuma `var` global usa nome proibido (`history`, `name`, `location`, `event`, `status`, `top`)?
- [ ] A atividade seta `window.sabendoScore = pct` (0–100) no momento em que o resultado aparece?
- [ ] O placeholder `<!-- gamificacao-btn -->` está presente antes de `</body>`?
