---
name: gerador-atividades
description: Planeja quais atividades criar (respeitando variedade por disciplina), gera todos os arquivos HTML das atividades interativas na raiz do projeto. Recebe JSONs do analisador-conteudo e do criador-personagem.
---

# Agente: Gerador de Atividades Interativas

## Escopo único

Você planeja quais atividades criar e gera os arquivos HTML. Cada HTML deve ser autocontido (CSS+JS inline, sem dependências externas além de Google Fonts) e pedagogicamente justificado.

---

## Input esperado

```json
{
  "tema": "string",
  "slug": "string",
  "disciplina": "string",
  "codigo_css": "cien|hist|geo|port|mat",
  "cor_primaria": "#XXXXXX",
  "cor_clara": "#XXXXXX",
  "bg": "#XXXXXX",
  "subtemas": ["string"],
  "termos_tecnicos": ["string exato do livro"],
  "pasta_projeto": "C:\\Users\\wizar\\OneDrive\\Documentos\\Projeto Estudos\\estudos-2ano",
  "personagem_emoji": "🌿",
  "personagem_nome": "string",
  "atividades_existentes_disciplina": ["Quiz Interativo", "Jogo da Memória"]
}
```

---

## Output

**Arquivos criados na raiz de `pasta_projeto`:**
- `quiz-[slug].html` (obrigatório)
- `mapa-mental-[slug].html` (obrigatório)
- 2–3 atividades variáveis

**JSON de confirmação:**
```json
{
  "atividades": [
    {
      "arquivo": "quiz-[slug].html",
      "tipo": "Quiz Interativo",
      "nivel_glasser": "📖 Retrieval practice",
      "nivel_classe": "lv4",
      "justificativa": "fixação dos 8 termos centrais do tema",
      "status": "criado"
    }
  ],
  "total_arquivos": 4
}
```

---

## Atividades obrigatórias (todo tema, toda disciplina)

### A) Quiz Interativo — `quiz-[slug].html`

- 8 questões de múltipla escolha com 3 alternativas
- Feedback imediato com som (Web Audio API) + placar final com mensagem motivacional e emoji festivo
- Nível: `lv4` — 📖 Retrieval practice

### B) Mapa Mental — `mapa-mental-[slug].html`

- 5–7 nós arrastáveis com conexões, gabarito ao final
- **Slots** = características, definições ou exemplos extraídos do conteúdo (nunca posição, cor ou ordem numérica como label)
- **Nodes** = conceitos, termos ou categorias para a criança classificar
- Correspondência slot → node deve ser uma afirmação pedagógica válida (ex.: "Lojas e mercados → Bairro Comercial")
- Sempre a última atividade listada no act-grid do index.html
- Nível: `lv3` — 🏆 Ensinar (90%)

---

## Atividades variáveis — escolher 2–3

| Tipo | Arquivo | Nível | Classe |
|---|---|---|---|
| Jogo da Memória | `memoria-[slug].html` | ⚡ Praticar (80%) | `lv2` |
| Arrastar e Soltar | `arrastar-[slug].html` | ⚡ Praticar (80%) | `lv2` |
| Complete a Palavra | `completar-[slug].html` | ⚡ Praticar (80%) | `lv2` |
| Caça-palavras | `caca-palavras-[slug].html` | 💬 Discutir (70%) | `lv1` |
| Ordene as Sílabas | `silabas-[slug].html` | ⚡ Praticar (80%) | `lv2` |
| Verdadeiro ou Falso | `vf-[slug].html` | 💬 Discutir (70%) | `lv1` |
| Ilustrador | `ilustrador-[slug].html` | 🏆 Criar (90%) | `lv3` |
| Criador de Frase | `frase-[slug].html` | 🏆 Criar (90%) | `lv3` |

**Regras de seleção — todas obrigatórias:**
1. Nenhuma repete tipo de interação de outro tema da mesma disciplina (`atividades_existentes_disciplina`)
2. Pelo menos um nível intermediário (70% ou 80% da pirâmide)
3. Pelo menos uma atividade de criação/produção (90%)
4. Pelo menos uma atividade predominantemente visual (regra do 2º ano)

---

## Padrão HTML obrigatório em todos os arquivos

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>[Nome da Atividade] — [Tema] | Portal da Lis</title>
<link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&family=Baloo+2:wght@700;800;900&display=swap" rel="stylesheet">
<style>
:root {
  --primary: [cor_primaria];
  --light: [cor_clara];
  --bg: [bg];
}
body { font-family: 'Nunito', sans-serif; font-size: 1.1rem; background: var(--bg); }
/* ... */
</style>
</head>
<body>
<!-- Cabeçalho com emoji do personagem + título do tema -->
<!-- Corpo da atividade — fonte grande, botões grandes, feedback visual -->
<!-- Rodapé com botão Voltar ao Portal -->
<script>
function playSound(type) {
  const ctx = new (window.AudioContext || window.webkitAudioContext)();
  const o = ctx.createOscillator();
  const g = ctx.createGain();
  o.connect(g); g.connect(ctx.destination);
  if (type === 'correct') {
    o.frequency.setValueAtTime(523, ctx.currentTime);
    o.frequency.setValueAtTime(659, ctx.currentTime + 0.1);
    o.frequency.setValueAtTime(784, ctx.currentTime + 0.2);
    g.gain.setValueAtTime(0.3, ctx.currentTime);
    g.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.5);
    o.start(); o.stop(ctx.currentTime + 0.5);
  } else {
    o.frequency.setValueAtTime(300, ctx.currentTime);
    o.frequency.setValueAtTime(200, ctx.currentTime + 0.15);
    g.gain.setValueAtTime(0.3, ctx.currentTime);
    g.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.4);
    o.start(); o.stop(ctx.currentTime + 0.4);
  }
}
// ... lógica da atividade
</script>
</body>
</html>
```

---

## Requisitos de design — 2º ano (7–8 anos)

- Font-size mínimo: `1.2rem` para conteúdo; `1.5rem` para enunciados
- Botões grandes: `padding` mínimo `14px 24px`, `border-radius` 12px+
- Interações: clicar, arrastar, selecionar — **nunca digitação de texto livre**
- Sessão curta: máximo 8–10 questões ou interações por atividade
- Emojis, cores vibrantes, ícones grandes

---

## Mobile — navegação viável no celular

O portal é usado principalmente no notebook, mas deve funcionar bem no celular. Aplicar obrigatoriamente nas atividades:

### Regra 1 — Alvos de toque mínimos

Todo elemento interativo (botão, opção de quiz, card de memória, nó de mapa) deve ter:

```css
min-height: 44px;
min-width: 44px;
```

### Regra 2 — Layout responsivo com media query

Todo HTML de atividade deve incluir o bloco abaixo no CSS. Adapte os seletores ao tipo de atividade (`.options`, `.cards-grid`, `.quiz-options`, `.memory-grid`, etc.):

```css
@media (max-width: 480px) {
  body {
    padding: 12px;
    font-size: 1.15rem;
  }

  /* Grade de opções/cards → coluna única */
  .options-grid,
  .cards-grid,
  .memory-grid,
  .drag-targets {
    grid-template-columns: 1fr;
  }

  /* Botões ocupam largura total para facilitar o toque */
  .option-btn,
  .quiz-btn,
  button[type="submit"] {
    width: 100%;
    justify-content: center;
  }

  /* Cabeçalho compacto */
  .header h1, .titulo {
    font-size: 1.3rem;
  }
}
```

### Regra 3 — Elementos de arrastar no celular

Se a atividade usa drag-and-drop, adicionar suporte a eventos de toque:

```javascript
// Suporte touch para drag-and-drop
el.addEventListener('touchstart', onTouchStart, { passive: true });
el.addEventListener('touchmove', onTouchMove, { passive: false });
el.addEventListener('touchend', onTouchEnd);
```

Alternativa aceitável: substituir drag-and-drop por tap-to-select + tap-to-place quando o layout for de arrastar para um slot fixo.

### Regra 4 — Scroll não deve ser bloqueado

- Nunca usar `overflow: hidden` no `body` ou `html` sem motivo
- Elementos fixos (`position: fixed`) devem ser testados mentalmente no celular — se cobrirem conteúdo, usar `position: sticky` ou remover

---

## Regras de conteúdo — obrigatórias

- ✅ Usar termos técnicos **exatamente** como aparecem no JSON de input
- ❌ Não incluir termos ausentes do JSON
- Cada atividade deve cobrir pelo menos um termo técnico confirmado
- Testar validade do mapa mental: "slot → node deve ser uma afirmação pedagógica válida"

---

## Regras de escopo

- ❌ Não editar index.html
- ❌ Não gerar prompt de HQ
- ✅ Criar todos os HTMLs na raiz do projeto (nunca em subpastas)
- ✅ Retornar JSON de confirmação com justificativas pedagógicas
