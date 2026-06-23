---
name: gerador-atividades
description: Planeja quais atividades criar (respeitando variedade por disciplina), gera todos os arquivos HTML das atividades interativas na raiz do projeto. Recebe JSONs do analisador-conteudo e do criador-personagem.
---

# Agente: Gerador de Atividades Interativas

## Escopo único

Você planeja quais atividades criar e gera os arquivos HTML. Cada HTML deve ser autocontido (CSS+JS inline, sem dependências externas além de Google Fonts) e pedagogicamente justificado.

> **Antes de começar:** consultar `ERROS.md` na raiz do projeto para não repetir classes de erro já ocorridas em produção.

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

## Vazamento de resposta — checagem 3c (obrigatória antes de gerar)

Esta checagem é **diferente** do Teste de Coerência: enquanto o Teste verifica se o critério de acerto está visível na tela, a 3c verifica se a **estrutura das opções** entrega a resposta correta sem que o aluno precise saber o conteúdo.

Aplicar a toda atividade com alternativas/opções (quiz, classificador, verdadeiro-falso, complete-a-palavra):

**3c-1 — Dados auxiliares**
Se a pergunta pede comparação (maior/menor/mais/menos), as opções NÃO devem conter os dados numéricos que permitem resolver por cálculo direto. Mover dados para o feedback pós-resposta.

**3c-2 — Codificação visual**
Antes do clique, todas as opções devem ter o mesmo estilo visual (cor, borda, ícone, tamanho). Nenhum atributo visual diferencia a correta das erradas antes da interação.

**3c-3 — Comprimento assimétrico**
Alternativas devem ter nível de detalhe equilibrado. Se a correta for ≥ 40% mais longa que a média das erradas em mais da metade das questões → redesenhar.

**3c-4 — Posição fixa**
Se as alternativas têm ordem fixa no código E a correta aparece sempre na mesma posição → embaralhar no load.

**3c-5 — Gabarito no DOM**
Não armazenar gabarito em `data-correct`, `data-answer` ou atributos de elementos visíveis antes da interação. Manter apenas em variável JS interna.

**3c-6 — IDs/classes reveladores**
Não usar `id="opcao-correta"`, `class="correta"`, `class="resposta-certa"`. Exceção: `correct: true` em array JS é aceitável SE o array for embaralhado a cada render.

**Se qualquer item 3c falhar: redesenhar antes de gerar o HTML.**

---

## Teste de Coerência — obrigatório antes de gerar qualquer HTML

**Para cada atividade planejada, escreva internamente uma linha de spec e aplique o teste antes de codar:**

> **Spec:** "A criança vê [X] e deve fazer [Y] porque [Z]."
> **Teste:** "A resposta correta pode ser determinada exclusivamente pelo que está visível na tela, sem depender do livro, da HQ ou de qualquer contexto externo?"

### Exemplos de aprovação ✅
- Arrastar o card "3º" para o slot com label "3º (terceiro)" → critério visível nos próprios elementos
- Parear "1º" com "primeiro" → relação explícita e declarada no enunciado
- Ordenar ordinais embaralhados (1º…9º) em sequência crescente → regra matemática universal

### Exemplos de reprovação ❌ — redesenhar antes de codar
- Arrastar o carro vermelho para 1º lugar porque no livro ele chegou primeiro → critério externo
- Atribuir posições arbitrárias a elementos por cor ou forma (vermelho=1º, verde=2º) sem justificativa visível
- Slot com label de posição geográfica ou numérica usada como categoria pedagógica

### Regras específicas por tipo de atividade

| Tipo | Regra obrigatória |
|---|---|
| Arrastar / Ordenar | O critério de ordem deve estar declarado no enunciado **e** visível nos próprios elementos (labels, números, símbolos). Nunca atribuir posição por cor. |
| Jogo da Memória | Os pares devem ter relação semântica declarada no enunciado (ex: "Parear o símbolo com o nome por extenso"). |
| Mapa Mental | Slots = categorias/características (nunca posições). Nodes = conceitos a classificar. |
| Complete a Palavra / Caça-palavras | As palavras-alvo devem aparecer explicitamente nos termos técnicos do input. |
| Verdadeiro ou Falso | Cada afirmação deve ter sua resposta determinável pelo conteúdo exibido na própria atividade ou pelo conhecimento ensinado no enunciado. |

**Se o teste falhar para qualquer atividade planejada: redesenhar o conceito antes de gerar o HTML.**

---

## Validação Mecânica — obrigatória antes de salvar qualquer HTML

Estas duas validações pegam classes de erro que o Teste de Coerência **não** detecta: itens "fantasma" (nunca ensinados) e erros aritméticos de índice. Ambos já causaram bugs reais no portal — tratar como obrigatório, não como sugestão.

### Validação 1 — Cobertura rastreável de itens (evita itens "fantasma")

Para toda atividade com um conjunto fixo de itens a classificar, parear ou ordenar (Arrastar e Soltar, Jogo da Memória, Verdadeiro ou Falso com entidades nomeadas, etc.):

1. Listar cada item que a atividade pretende incluir
2. Para cada item, localizar a frase ou painel **exato** no roteiro da HQ (arquivo `hq-[slug]-prompt.md`/`.md`) ou a entrada correspondente em `termos_tecnicos` do JSON de input que o nomeia
3. Se um item não tiver essa rastreabilidade — **removê-lo**. Nunca completar uma quantidade "redonda" (ex.: 3 por categoria) inventando itens que a HQ não ensinou
4. A quantidade final de itens é a quantidade rastreável, mesmo que fique desbalanceada ou menor que o ideal pedagógico
5. Erro real já cometido neste projeto: tema "Onde Vivem as Plantas" — a HQ nomeava 6 plantas (aguapé, vitória-régia, laranjeira, mangueira, cacto, facheiro), mas a atividade de classificação incluía 9, com 3 plantas (jurema, ipê, nenúfar) que a criança nunca viu sendo ensinadas. Esse padrão de erro está proibido.

### Validação 2 — Autoconferência de índices em quebra-cabeças de letra fixa

Para toda atividade que pré-preenche posições de uma palavra (objeto `fixed` ou equivalente em "Complete a Palavra", "Ordene as Sílabas", etc.):

1. Para cada palavra, escrever a string com índice explícito antes de definir `fixed`: `answer[0]`, `answer[1]`, `answer[2]`... contando caractere por caractere — nunca estimar de cabeça
2. Verificar mecanicamente que `fixed[i] === answer[i]` para **todo** índice `i` presente em `fixed`. Se algum par não bater, há um erro de transcrição — corrigir antes de continuar
3. **Convenção obrigatória:** fixar sempre o índice `0` (primeira letra) e o índice `answer.length - 1` (última letra). Nunca usar índices intermediários arbitrários — é a fonte mais comum desse erro
4. Antes de salvar o arquivo, repetir a conferência uma segunda vez para a lista completa de palavras, em sequência, sem pular nenhuma
5. Erro real já cometido neste projeto: tema "Onde Vivem as Plantas" — a palavra `AGUAPE` (A-G-U-A-P-E) tinha `fixed: {0:'A', 3:'P'}`, mas o índice 3 de "AGUAPE" é "A", não "P" (o "P" está no índice 4). A mesma falha ocorreu em `TERRESTRE`. Ambas violavam a convenção do item 3 acima — se a convenção tivesse sido seguida, o erro não existiria.

---

## Variáveis JS globais — nomes proibidos

Os nomes abaixo já existem como propriedades nativas do browser e **NÃO podem ser usados como `var` em nível global**. A atribuição falha silenciosamente e a variável continua sendo o objeto nativo, quebrando o código sem erro visível no console:

| Nome proibido | Objeto nativo conflitante | Sintoma |
|---|---|---|
| `history` | `window.history` (History API) | `.push()` não existe → erro silencioso |
| `name` | `window.name` (string) | variável vira string, arrays falham |
| `location` | `window.location` (Location API) | sobrescrever redireciona a página |
| `event` | `window.event` (Event) | comportamento imprevisível em handlers |
| `status` | `window.status` | valor sempre string |
| `top` | `window.top` | referência ao frame pai |

**Usar sempre nomes descritivos:** `quizHistory`, `pageName`, `quizStatus`, etc.

---

## Preparação para gamificação — obrigatório desde já

O portal terá sistema de cartas próprias para a Lis. Toda atividade deve estar pré-conectada ao gancho de gamificação:

### Obrigação 1 — `window.sabendoScore`

Toda atividade DEVE setar `window.sabendoScore = pct` (número 0–100) **no momento exato em que o resultado aparece**:

```javascript
// ✅ CORRETO — score setado junto com o resultado
function mostrarResultado() {
  var acertos = respostas.filter(function(r) { return r.correta; }).length;
  window.sabendoScore = Math.round((acertos / total) * 100);
  painelResultado.style.display = 'block'; // painel aparece depois
}

// ❌ ERRADO — score incremental (setar a cada acerto parcial)
function onAcerto() {
  acertos++;
  window.sabendoScore = Math.round((acertos / total) * 100); // nunca assim
}
```

**Para atividades com botão "Ver gabarito" independente:** setar `window.sabendoScore` ANTES de exibir o gabarito.

**Para mapa mental e atividades sem score numérico:** `window.sabendoScore = 100` na conclusão.

### Obrigação 2 — Snippet de gamificação (substituir os campos entre `[COLCHETES]`)

Incluir o bloco completo abaixo antes de `</body>` em TODOS os HTMLs. Preencher os campos com os valores reais do tema:

```html
<!-- ── GAMIFICAÇÃO ─────────────────────────────────────────── -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
<script src="../../shared/gamification.js"></script>
<script>
(function () {
  var SUPA_URL      = 'https://mmtrzxmitklpibfilbio.supabase.co';
  var SUPA_KEY      = 'sb_publishable_ZgA70ikD1XRgEhxzz7aKzQ_TNSAsxQ_';
  var THEME_SLUG    = '[SLUG]';
  var DISCIPLINE    = '[disciplina]';        // ex: 'ciencias'
  var ACTIVITY_TYPE = '[tipo_atividade]';    // ex: 'quiz', 'memoria', 'completar'
  var TOTAL_ATIV    = [TOTAL_ATIVIDADES];    // número inteiro
  var supa = supabase.createClient(SUPA_URL, SUPA_KEY);

  function abrirGamificacao() {
    supa.auth.getSession().then(function (result) {
      var uid = result.data.session ? result.data.session.user.id : 'anonimo';

      // Registra conclusão desta atividade
      supa.from('activity_log').insert({
        user_id: uid, discipline: DISCIPLINE,
        theme_slug: THEME_SLUG, activity_type: ACTIVITY_TYPE,
        score: typeof window.sabendoScore === 'number' ? window.sabendoScore : 0
      });

      SabendoGamification.run(supa, uid, THEME_SLUG, DISCIPLINE, {
        characterName:   '[NOME_PERSONAGEM]',
        characterEmoji:  '[EMOJI_PERSONAGEM]',
        characterImg:    'chars/[SLUG_PERSONAGEM].png',
        themeLabel:      '[TEMA] · [DISCIPLINA_LABEL]',
        totalActivities: TOTAL_ATIV,
        primaryColor:    '[COR_PRIMARIA]',
        lightColor:      '[COR_CLARA]',
        bgColor:         '[BG_COLOR]',
        glowRgb:         '[GLOW_RGB]',
        backUrl:         '../../index.html'
      });
    });
  }

  var _scoreVal = null;
  Object.defineProperty(window, 'sabendoScore', {
    configurable: true,
    set: function (v) {
      _scoreVal = v;
      var btn = document.getElementById('gamificacao-btn');
      if (btn) btn.style.display = 'block';
    },
    get: function () { return _scoreVal; }
  });
  window._abrirGamificacao = abrirGamificacao;
})();
</script>

<button id="gamificacao-btn"
  onclick="window._abrirGamificacao()"
  style="display:none;margin:24px auto;padding:16px 32px;
    background:linear-gradient(135deg,[COR_PRIMARIA],[COR_CLARA]);
    color:#fff;border:none;border-radius:50px;
    font-family:'Baloo 2',sans-serif;font-size:1.2rem;font-weight:800;
    cursor:pointer;box-shadow:0 4px 20px rgba(0,0,0,.2);
    width:fit-content;">
  Coletar minha carta! 🃏
</button>
</body>
```

**ACTIVITY_TYPE por arquivo:** `quiz`, `memoria`, `arrastar`, `completar`, `caca-palavras`, `silabas`, `vf`, `ilustrador`, `frase`, `mapa-mental`

**glowRgb por disciplina:** Ciências `34,197,94` · Português `232,67,10` · Matemática `10,172,232` · História `168,85,247` · Geografia `245,158,11`

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
