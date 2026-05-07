---
name: portal-educacional-2ano
description: "Skill para o Portal Educacional do 2º Ano (github.com/mottacastelo-ai/estudos-2ano). Acione quando Léo fornecer fotos de conteúdo escolar ou mencionar novo tema, nova disciplina, fotos da escola, atividades para o portal da Lis ou atualizar o site. SEMPRE executa Fase 0 de análise de escopo e aguarda aprovação antes de gerar HQs, atividades ou HTML. Modo padrão via Cowork: edita index.html diretamente na pasta local e salva arquivos na raiz do projeto sem subpastas nem ZIPs. Fallback Claude.ai: ZIP com index.html completo já atualizado."
---

# Skill: Portal Educacional — 2º Ano (Lis)

## Visão geral do processo

Dado um conjunto de fotos de conteúdo escolar, esta skill executa o seguinte pipeline:

```
FOTOS → [FASE 0] Análise de escopo → Proposta estrutural → ⏸ AGUARDAR APROVAÇÃO DE LÉO
         ↓ (após aprovação)
         Separação por tema → Para cada tema:
           1. Prompt HQ (.md)
           2. Atividades HTML (Quiz + variáveis + Mapa Mental)
           3. Atualização do index.html
           4. Entrega em ZIP (arquivos novos/alterados apenas)
```

> **Regra absoluta:** Nenhum arquivo é gerado antes da aprovação explícita de Léo na Fase 0.

---

## Contexto do projeto

| Item | Detalhe |
|---|---|
| Série | 2º ano do Ensino Fundamental |
| Faixa etária | 7–8 anos |
| Aluna | Lis (personagem principal do portal) |
| Repositório | `github.com/mottacastelo-ai/estudos-2ano` |
| Pasta local | `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano` |
| Hospedagem | GitHub Pages |
| Ferramenta de imagem para HQs | DALL·E 3 via ChatGPT |
| Projeto irmão (referência) | `github.com/mottacastelo-ai/estudos` (5º ano — André) |

---

## FASE 0 — Análise de escopo e proposta estrutural ⚠️ OBRIGATÓRIA

**Esta fase ocorre antes de qualquer geração de conteúdo e exige confirmação explícita de Léo.**

### 0.1 Leitura do conteúdo

Examine todas as imagens fornecidas e extraia:
- Disciplina(s) identificada(s)
- Capítulos ou unidades visíveis
- Todos os subtemas e conceitos-chave presentes (listar exaustivamente)
- Habilidades específicas trabalhadas pelo livro

### 0.2 Critérios de divisão em temas

Aplique os seguintes critérios para decidir se o conteúdo deve ser dividido em um ou mais temas:

| Critério | Um único tema | Dois ou mais temas |
|---|---|---|
| Foco conceitual | Subtemas se subordinam a um conceito central | Subtemas têm autonomia conceitual própria |
| Volume de conteúdo | Até ~8 páginas do livro com densidade similar | Capítulos distintos ou mais de ~8 páginas densas |
| Coerência narrativa | Uma HQ consegue cobrir o arco com foco | Uma HQ por tema seria necessária para narrativa coesa |
| Habilidades distintas | Mesmas habilidades ao longo do material | Habilidades diferentes por bloco |

**Sinal de alerta obrigatório:** se o conteúdo cobrir dois ou mais capítulos do livro com subtemas autônomos, a skill deve propor divisão em temas separados e justificar.

### 0.3 Formato da proposta estrutural

Apresente a Léo um relatório no seguinte formato **antes de gerar qualquer arquivo**:

---

**📚 Conteúdo identificado**
[Disciplina] — [Capítulo(s)/Unidade(s)]

**🗂️ Subtemas mapeados**
- [Subtema 1]: [conceitos-chave em bullets]
- [Subtema 2]: [conceitos-chave em bullets]
- ...

**🎯 Proposta de estrutura**

> Opção A — [N] tema(s): [Nome do Tema 1] + [Nome do Tema 2]
> Justificativa: [por que essa divisão serve melhor pedagogicamente]

> Opção B — Tema único: [Nome]
> Justificativa: [por que agrupar pode funcionar, com ressalvas de cobertura]

**⚠️ Alertas de cobertura**
[Listar conceitos ou habilidades que poderiam ficar de fora se o conteúdo for comprimido em menos temas do que o ideal]

**✅ Aguardando sua decisão para prosseguir.**

---

### 0.4 Regra de bloqueio

A skill **não avança para a Fase 1** até receber de Léo:
- Qual opção de estrutura foi aprovada (ou uma estrutura alternativa)
- Confirmação explícita para começar a geração

---

## FASE 1 — Identificação e separação de temas (após aprovação da Fase 0)

### 1.1 Separação por tema

Com base na estrutura aprovada na Fase 0, delimite com precisão quais imagens/páginas pertencem a cada tema. Se um tema foi aprovado com dois capítulos separados, trate-os como projetos independentes e execute as fases seguintes para cada um.

### 1.2 Verificação de conflito com temas existentes

Consulte `references/temas-existentes.md` para verificar se o tema já foi implementado. Se já existir, pergunte antes de sobrescrever.

### 1.3 Mapeamento de disciplina → código

| Disciplina  | Código HTML | Cor primária | Cor clara   | Bg          | Gradiente hero                                    |
|-------------|-------------|--------------|-------------|-------------|---------------------------------------------------|
| Português   | `port`      | `#E8430A`    | `#FB8C5A`   | `#FFF4EF`   | `135deg, #7A1F04, #E8430A 60%, #FB8C5A`          |
| Matemática  | `mat`       | `#0AACE8`    | `#5AC8FB`   | `#EFF9FF`   | `135deg, #044A7A, #0AACE8 60%, #5AC8FB`          |
| Ciências    | `cien`      | `#22C55E`    | `#6EE7A0`   | `#F0FDF4`   | `135deg, #14532D, #22C55E 60%, #6EE7A0`          |
| História    | `hist`      | `#A855F7`    | `#D08EF8`   | `#FAF5FF`   | `135deg, #4A1272, #A855F7 60%, #D08EF8`          |
| Geografia   | `geo`       | `#F59E0B`    | `#FCD34D`   | `#FFFBEB`   | `135deg, #78350F, #F59E0B 60%, #FCD34D`          |

**Lógica da paleta:** cores vibrantes e saturadas, adequadas ao público infantil de 7–8 anos. Deliberadamente distintas das cores do projeto do 5º ano para garantir identidade visual própria.

Para novas disciplinas não listadas, proponha uma paleta ao usuário antes de continuar.

---

## FASE 2 — Criação de personagem narrativo

Cada novo tema deve ter um personagem ou elemento narrativo novo (ou reutilizar existentes quando fizer sentido).

### Personagem principal (sempre presente)

- **Lis** — menina de 7 anos, cabelos castanhos longos e ondulados, sorriso expressivo e aberto, estilo despojado. Protagonista de todas as HQs. Curiosa, animada, levemente atrevida. Representa a própria aluna que usa o portal.

### Personagens de suporte já criados

*(atualizar progressivamente à medida que novos personagens forem criados)*

| Personagem | Tema | Descrição visual |
|---|---|---|
| *(a preencher)* | *(a preencher)* | *(a preencher)* |

### Diretrizes para novos personagens

- Deve ser metáfora visual do conteúdo (ex.: para Separação de Sílabas → uma borboleta que divide as asas em partes; para Ortografia F e V → dois personagens gêmeos que parecem iguais mas têm diferenças)
- Tom: lúdico, acolhedor, levemente engraçado — adequado a 7 anos
- Mistura de animais falantes e objetos animados conforme o contexto e o conteúdo
- Cor e estilo devem dialogar com a paleta da disciplina
- Sempre interage com a Lis na HQ
- Expressões faciais exageradas para facilitar leitura emocional pela criança

---

## FASE 3 — Geração do prompt de HQ

> **⚠️ Padrão de qualidade obrigatório:** O arquivo `.md` gerado deve seguir o mesmo nível de detalhamento dos prompts do projeto do André (5º ano). Prompts superficiais ou genéricos **não são aceitos**. Cada painel deve ser descrito com precisão cirúrgica: posição na grade, cenário completo, posição corporal dos personagens, expressão facial, ação em curso, objetos em cena, falas nos balões e elementos visuais de apoio. Um prompt bem escrito para este projeto tem **no mínimo 300 linhas**.

O arquivo `.md` gerado deve ser um **documento de produção completo** — Léo deve conseguir colá-lo diretamente no DALL·E 3 via ChatGPT sem nenhuma edição adicional.

### Critérios obrigatórios

- **Mínimo de 300 linhas** — prompts abaixo disso são automaticamente considerados incompletos
- Prompts das páginas em **inglês** (DALL·E responde melhor em inglês)
- Cada página tem seu próprio bloco de prompt **pronto para colar**, entre três backticks
- **Bloco de estilo visual global** separado e reutilizável, referenciado em todas as páginas
- **Folha de personagens** dedicada gerada **primeiro**, com múltiplas variações emocionais
- Instruções de uso no topo (qual ferramenta, qual ordem de geração)
- Dicas práticas no final (painéis mais difíceis, consistência entre páginas, correção de balões)
- Falas dos personagens em **português** dentro dos prompts em inglês, entre aspas
- **Adaptação ao 2º ano:** balões com no máximo 8 palavras por fala, cenas visualmente ricas

### Estrutura obrigatória de cada página (4 painéis descritos individualmente)

Cada página deve descrever **todos os 4 painéis** com o seguinte nível de detalhe:

```
Panel N (posição na grade):
- Cenário completo com elementos de fundo, iluminação e atmosfera
- Personagem A: posição corporal, expressão facial, gesto específico, roupa/adereços visíveis
- Personagem B: posição corporal, expressão facial, gesto específico
- Objetos, diagramas, cartazes ou elementos visuais pedagógicos em cena (descritos visualmente)
- Speech bubble PERSONAGEM A (contexto do gesto): "Fala curta em português"
- Speech bubble PERSONAGEM B: "Fala curta em português"
- Caption box ou elemento de legenda, se houver
- Detalhes atmosféricos (luz, partículas, sombras, efeitos visuais de apoio)
```

Nunca use descrições genéricas como "Lis e o personagem conversam". Descreva exatamente o que cada personagem faz, onde está, o que olha e como se sente.

### Estrutura obrigatória da folha de personagens

A folha deve incluir obrigatoriamente:

**Para a Lis (4 variações emocionais mínimas):**
- Variação 1 — Curiosa: corpo inclinado para frente, objeto de exploração na mão, sobrancelha levantada
- Variação 2 — Animada/Celebrando: braços erguidos, sorriso mostrando dentes, na ponta dos pés
- Variação 3 — Surpresa: olhos arregalados e redondos, boca em "O", mãos nas bochechas
- Variação 4 — Pensativa: mão no queixo, olhar para cima, bolha de pensamento com "?"
- Cada variação: full-body, em quadro arredondado, com label abaixo em português + emoji

**Para o personagem de suporte (3 variações emocionais mínimas):**
- Variação 1 — Ensinando/Calmo: postura confiante, gesto didático, expressão serena
- Variação 2 — Animado/Surpreso: postura com movimento implícito, expressão vibrante
- Variação 3 — Emotivo/Nostálgico ou Divertido: expressão terna ou cômica conforme o personagem
- Cada variação: full-body, em quadro arredondado, com label abaixo em português + emoji

**Comparação de escala obrigatória:**
- Lis e o personagem de suporte lado a lado, corpo inteiro, mostrando proporção real de tamanho
- Label: "Escala de tamanho"

### Template completo de prompt de HQ

```markdown
# PROMPT PARA HISTÓRIA EM QUADRINHOS
## Tema: [Nome do Tema]
## [Disciplina] — 2º ano

---

## INSTRUÇÕES DE USO

Cole o bloco de cada página diretamente em:
- **DALL·E 3** (via ChatGPT) — ferramenta principal deste projeto
- **Ideogram** — alternativa para painéis com mais texto nos balões
- **Adobe Firefly** — alternativa para manter consistência dos personagens entre páginas

Gere **uma página por vez**. Comece pela folha de personagens e valide o visual
do personagem de suporte antes de gerar as páginas.

---

## ESTILO VISUAL (aplique em todas as páginas)

\`\`\`
Visual style: colorful Brazilian children's educational comic book,
flat illustration, bold black outlines, vibrant saturated colors,
friendly cartoon characters, ages 7-8 audience,
expressive faces and exaggerated body language,
speech bubbles with clear rounded borders and black outline,
panels with thick black borders, white gutters between panels.

Color palette: [descrever paleta dominante conforme disciplina e tema].
Thematic visual elements: [elementos visuais específicos do tema].
Color mood progression: [descrever a progressão emocional das 4 páginas].
Character design must remain consistent across all pages.
4 panels per page in a 2x2 grid layout.
\`\`\`

---

## PERSONAGENS FIXOS

| Personagem | Descrição visual completa |
|---|---|
| **Lis** | 7-year-old Brazilian girl, warm light skin tone, long wavy chestnut-brown hair reaching her shoulders, large expressive brown eyes, wide open smile sometimes showing teeth, small stature (short for her age). Outfit: [roupa específica do tema]. Energetic and expressive body language. |
| **[Personagem de suporte]** | [Descrição visual detalhada e consistente — incluir tamanho relativo à Lis, cores, traços distintivos, acessórios] |

---

## ROTEIRO — 4 PÁGINAS

---

### PÁGINA 1 — "[Título da página]"
**Objetivo pedagógico:** [o que a criança deve aprender nesta página]

**PROMPT:**
\`\`\`
Brazilian children's educational comic book page, 4 panels in 2x2 grid,
colorful flat illustration, bold black outlines, [paleta de cores],
Portuguese speech bubbles, thick panel borders, white gutters.
[Atmosfera/mood específico desta página].

Panel 1 (top left):
[Cenário detalhado com elementos de fundo, iluminação e atmosfera].
[PERSONAGEM A] ([descrição resumida de referência]): [posição corporal precisa],
[expressão facial detalhada], [gesto específico com qual membro].
[PERSONAGEM B] ([descrição resumida]): [posição, expressão, gesto].
[Objetos em cena descritos visualmente, incluindo qualquer elemento pedagógico].
[Efeitos visuais atmosféricos: luz, sombras, partículas, etc.].
Speech bubble [PERSONAGEM A] ([contexto do gesto]): "[Fala em português — máx. 8 palavras]"
Speech bubble [PERSONAGEM B]: "[Fala em português — máx. 8 palavras]"
[Caption box se houver: cor, posição, texto em português]

Panel 2 (top right):
[Idem — descrito com o mesmo nível de detalhe]

Panel 3 (bottom left):
[Idem]

Panel 4 (bottom right):
[Idem]

Style: [resumo de estilo + elementos temáticos desta página específica],
bold outlines, Portuguese speech bubbles, 2x2 grid, thick borders, white gutters.
\`\`\`

---

### PÁGINA 2 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
Brazilian children's educational comic book page, 4 panels in 2x2 grid,
[paleta + mood desta página].

Character reference: same characters as previous page —
[PERSONAGEM A]: [resumo visual compacto: cabelo, roupa, traços-chave].
[PERSONAGEM B]: [resumo visual compacto: traços-chave, proporção de tamanho].

Panel 1 (top left):
[...]

Panel 2 (top right):
[...]

Panel 3 (bottom left):
[...]

Panel 4 (bottom right):
[...]

Style: [...]
\`\`\`

---

### PÁGINA 3 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
[Idem — com "Character reference" no topo]
[4 painéis descritos individualmente]
\`\`\`

---

### PÁGINA 4 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
[Idem — com "Character reference" no topo]

[Painéis 1-3 descritos normalmente]

Panel 4 (bottom right — CLOSING PANEL, fourth wall break):
Full panel. [PERSONAGEM A] e [PERSONAGEM B] facing DIRECTLY TOWARD THE READER.
[PERSONAGEM B]: [expressão mais vibrante da HQ toda — descrever em detalhe].
[PERSONAGEM A]: [maior sorriso da HQ, postura convidativa para o leitor].
[Elementos visuais celebratórios flutuando: estrelas, confetes, ícones do tema].
[Badge ou caixa de conclusão no canto: texto motivacional].
Speech bubble [PERSONAGEM A] (bold, direct to reader): "Agora é sua vez! Teste no portal!"
Speech bubble [PERSONAGEM B]: "[Fala de fechamento relacionada ao tema]"
Small italic caption at bottom: "Continue explorando nas atividades interativas! 🔬"

Style: [...]
\`\`\`

---

## FOLHA DE PERSONAGENS (gere primeiro)

\`\`\`
Character reference sheet, Brazilian children's educational comic book style,
flat illustration, bold black outlines, white background.
Two character groups with name labels below each. Same vibrant cartoon style as HQ pages.
[Paleta de cores do tema].

1. LIS — FOUR EMOTIONAL VARIATIONS:
7-year-old Brazilian girl. Warm light skin tone. Long wavy chestnut-brown hair reaching her shoulders.
Large expressive brown eyes. Wide smile sometimes showing teeth. Small stature.
[Roupa específica do tema].
Show four full-body poses side by side, each in a soft rounded frame:

VARIATION 1 — CURIOUS: body leaning forward, [objeto do tema] in one hand,
free hand pointing outward, one eyebrow raised high, mouth in a small excited "ooh".
Label below frame: "Lis — curiosa 🔍"

VARIATION 2 — EXCITED/CELEBRATING: both arms thrown fully above her head,
biggest possible open smile showing teeth, eyes wide and sparkling, standing on tiptoe,
small [elemento temático] sparkles radiating outward.
Label below frame: "Lis — animada 🎉"

VARIATION 3 — SURPRISED: eyes opened extremely wide and round, mouth in a giant O shape,
both hands pressed flat against cheeks, hair flying slightly outward.
Label below frame: "Lis — surpresa 😮"

VARIATION 4 — THOUGHTFUL: one hand on chin with elbow resting on other arm,
eyes slightly narrowed directed upward-left,
small thought bubble above containing a simple question mark.
Label below frame: "Lis — pensando 🤔"

2. [PERSONAGEM DE SUPORTE] — THREE EMOTIONAL VERSIONS + SIZE COMPARISON:
[Descrição visual completa e detalhada do personagem].
[Incluir: tamanho relativo à Lis, cores, texturas, traços distinctivos, acessórios].

VERSION 1 — CALM/TEACHING: [postura, expressão, gesto didático].
Label below: "[Nome] — ensinando 📚"

VERSION 2 — EXCITED/DELIGHTED: [postura com movimento, expressão vibrante].
Label below: "[Nome] — animado/a ✨"

VERSION 3 — [EMOTIVO/DIVERTIDO — escolher conforme personalidade do personagem]:
[postura, expressão terna ou cômica].
Label below: "[Nome] — [estado emocional] [emoji]"

SIZE COMPARISON:
Full-body LIS standing next to full-body [PERSONAGEM] side by side.
[Personagem] reaches approximately [parte do corpo da Lis]. Both smiling warmly at each other.
Label below: "Escala de tamanho"

White background throughout. Flat illustration consistent with HQ pages.
\`\`\`

---

## DICAS PARA MELHORES RESULTADOS

- **[Personagem de suporte]** é o elemento mais difícil de manter consistente — [traços-chave que
  devem aparecer em todo prompt de referência, ex.: óculos, padrão do casco, proporção de tamanho].
  Regenere a folha de personagens até ter uma versão sólida antes de gerar as páginas.
- **Página [N], Painel [N]** ([nome do painel mais complexo]) é o painel mais difícil deste tema —
  [explicar por quê e como lidar se falhar, ex.: gerar separadamente com prompt focado].
- Para consistência entre páginas: adicione ao início de cada novo prompt o bloco
  "Character reference: same characters as previous page — [descrição compacta de cada personagem]".
- Se o texto dos balões sair em inglês, corrija no **Canva** adicionando caixas de texto sobre
  as imagens geradas.
- **DALL·E 3** funciona melhor para cenas de personagens e natureza.
  **Ideogram** funciona melhor para painéis com diagramas, tabelas ou muito texto visual.
- [Dica específica adicional relevante para o tema ou personagem deste HQ]

---

## ORDEM DE GERAÇÃO

1. Folha de personagens ([Personagem] nas 3 versões + Lis nas 4 variações + escala)
2. Página 1 — [título]
3. Página 2 — [título]
4. Página 3 — [título]
5. Página 4 — [título]

---

*Conteúdo baseado em: [livro didático, páginas referenciadas]*
*Tema: [descrição resumida do conteúdo pedagógico coberto pelas 4 páginas]*
```

---

## FASE 4 — Design das atividades

### Princípios de design para o 2º ano

Toda atividade deve respeitar obrigatoriamente:

1. **Fonte grande** — `font-size` mínimo de `1.2rem` para textos de conteúdo; `1.5rem` ou maior para enunciados
2. **Sessão curta** — máximo de 8–10 questões ou interações por atividade (não 10 por padrão como no 5º ano)
3. **Feedback imediato e visual** — sons de acerto/erro via Web Audio API quando possível; animações simples (shake no erro, bounce no acerto)
4. **Linguagem simplificada** — enunciados com frases curtas, sem vocabulário técnico desnecessário
5. **Apelo visual alto** — emojis como apoio visual, cores vibrantes, ícones grandes
6. **Interações intuitivas** — clicar, arrastar, selecionar — nunca digitar texto livre como atividade principal

### 4.0 Regra global — Cobertura obrigatória dos termos técnicos centrais

> **⚠️ Esta regra se aplica a TODAS as atividades do tema — quiz, mapa mental e variáveis.**

Antes de gerar qualquer atividade, a skill deve executar o seguinte passo obrigatório:

**Identificar e registrar os termos técnicos primários do tema.**

Estes são os conceitos que o currículo pretende instalar como vocabulário permanente — ignorá-los em qualquer atividade invalida o objetivo pedagógico, independentemente de quão correto seja o restante do conteúdo gerado.

**Exemplos:**
- Ciclo da Vida → _vivíparo_, _ovíparo_
- Separação de Sílabas → _sílaba_, _monossílabo_, _dissílabo_, _polissílabo_
- Adição → _parcela_, _soma_, _total_
- Formas Geométricas → _vértice_, _lado_, _face_

**Regras de cobertura por atividade:**

| Atividade | Obrigação |
|---|---|
| Quiz | Mínimo de 2 questões que usam o termo técnico diretamente (definição, identificação ou aplicação) |
| Mapa Mental | Os termos técnicos centrais devem ser nós do mapa, não podem estar ausentes da estrutura |
| Arrastar e Soltar / Classificador | Os rótulos das categorias devem usar os termos técnicos (não paráfrases) |
| Jogo da Memória | Pelo menos um par deve parear o termo técnico com sua definição ou imagem representativa |
| Verdadeiro ou Falso | Pelo menos 2 afirmações devem usar os termos técnicos diretamente |
| Complete a Palavra / Ordene as Sílabas | Incluir os próprios termos técnicos como palavras a completar/montar, quando aplicável ao nível da palavra |
| Criador de Frase | O banco de palavras deve incluir os termos técnicos para que a criança os use na frase |
| Caça-palavras | Os termos técnicos devem estar obrigatoriamente entre as palavras a encontrar |

**Checklist global antes de concluir qualquer tema:**
- [ ] Os termos técnicos centrais foram identificados antes de gerar as atividades?
- [ ] Cada atividade cobre pelo menos um dos termos técnicos de forma explícita?
- [ ] Nenhuma atividade usa apenas paráfrases quando o objetivo é fixar o termo em si?
- [ ] O conjunto de atividades do tema cobre definição, identificação e aplicação dos termos?

---

### 4.1 Atividades obrigatórias (todo tema, toda disciplina)

#### A) Quiz Interativo
- **Arquivo:** `quiz-[slug].html`
- **Estrutura:** 8 questões de múltipla escolha com 3 alternativas (não 4 — reduz a carga cognitiva para 7 anos)
- **Feedback:** imediato por questão com som + placar final com mensagem motivacional e emoji festivo
- **Nível Glasser:** 📖 Retrieval practice
- **Termos técnicos:** aplicar obrigatoriamente as regras da seção 4.0 — mínimo de 2 questões com uso direto dos termos centrais do tema
- **Card no index:**
```html
<a class="act-card [disc]" href="quiz-[slug].html" target="_blank">
  <div class="act-icon">❓</div>
  <div class="act-title">Quiz Interativo</div>
  <div class="act-desc">[8 perguntas sobre o tema com feedback imediato]</div>
  <div class="act-tags"><span class="tag tag-[tag-disc]">Digital</span><span class="tag tag-a">Ativo</span></div>
  <div class="level lv4">📖 Retrieval practice</div>
</a>
```

#### B) Mapa Mental
- **Arquivo:** `mapa-mental-[slug].html`
- **Estrutura:** Nós arrastáveis com conexões, gabarito ao final
- **Conteúdo:** 5–7 nós (menos que no 5º ano — foco em conceitos centrais)
- **Nível Glasser:** 🏆 Ensinar (90%)
- **Sempre é a última atividade listada no act-grid**
- **Card no index:**
```html
<a class="act-card [disc]" href="mapa-mental-[slug].html" target="_blank">
  <div class="act-icon">🗺️</div>
  <div class="act-title">Mapa Mental</div>
  <div class="act-desc">Arraste os balões e conecte as ideias do tema.</div>
  <div class="act-tags"><span class="tag tag-[tag-disc]">Digital</span><span class="tag tag-a">Síntese</span></div>
  <div class="level lv3">🏆 Ensinar (90%)</div>
</a>
```

### 4.2 Atividades variáveis

Selecione **2–3 atividades** respeitando:
1. Nenhuma deve repetir o tipo de interação de outro tema da mesma disciplina
2. Deve cobrir pelo menos um nível intermediário (70% ou 80% da pirâmide)
3. Deve haver pelo menos uma atividade de criação/produção (90%)
4. **Regra adicional do 2º ano:** pelo menos uma atividade deve ser predominantemente visual (arrastar, classificar por imagem, parear) — minimizar atividades que dependem apenas de leitura

Tipos de atividade sugeridos para o 2º ano (distintos do projeto do André):

| Tipo | Descrição | Nível |
|---|---|---|
| Jogo da Memória | Parear palavra-imagem ou palavra-conceito | ⚡ Praticar (80%) |
| Arrastar e Soltar | Classificar elementos em categorias visuais | ⚡ Praticar (80%) |
| Complete a Palavra | Preencher letras faltando com banco de letras clicável | ⚡ Praticar (80%) |
| Caça-palavras | Encontrar palavras do tema em grade de letras | 💬 Discutir (70%) |
| Ordene as Sílabas | Arrastar sílabas para montar a palavra | ⚡ Praticar (80%) |
| Verdadeiro ou Falso | Afirmações simples, resposta binária com feedback visual | 💬 Discutir (70%) |
| Ilustrador | A criança escolhe e combina elementos visuais para criar algo | 🏆 Criar (90%) |
| Criador de Frase | Montar frase a partir de banco de palavras clicáveis | 🏆 Criar (90%) |

A escolha deve ser **justificada** com base no conteúdo específico do tema.

### 4.3 Níveis e classes CSS

| Nível Glasser | Label               | Classe CSS |
|---------------|---------------------|------------|
| 50-60%        | 💬 Discutir (70%)   | `lv1`      |
| 70-80%        | ⚡ Praticar (80%)   | `lv2`      |
| 90%           | 🏆 Ensinar (90%)    | `lv3`      |
| Retrieval     | 📖 Retrieval practice | `lv4`    |

---

## FASE 5 — Geração de HTML das atividades

Cada arquivo HTML de atividade deve:

1. **Ser autocontido** — CSS e JS inline, sem dependências externas além de Google Fonts
2. **Usar as fontes do projeto:** `Nunito` (principal — arredondada e legível para crianças) + `Baloo 2` (títulos e destaques)
3. **Aplicar a paleta da disciplina** conforme tabela da Fase 1
4. **Ter feedback imediato** para cada interação — visual e sonoro (Web Audio API)
5. **Ter botão "Voltar ao Portal"** que fecha a aba (`window.close()`) ou vai para `index.html`
6. **Ser responsivo** (funcionar em mobile e tablet)
7. **Ter cabeçalho** com nome do tema e emoji do personagem em destaque
8. **Font-size mínimo:** `1.2rem` para texto de conteúdo; `1.5rem` para enunciados
9. **Botões grandes** — `padding` mínimo de `14px 24px`, `border-radius` generoso (12px+)
10. **Animações de feedback:** classe `.correct` com `background: #D1FAE5` + bounce; classe `.wrong` com `background: #FEE2E2` + shake

### Sons via Web Audio API (sem arquivos externos)

```javascript
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
```

### Template base de atividade HTML

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
  --primary: [cor primária da disciplina];
  --light: [cor clara da disciplina];
  --bg: [bg da disciplina];
}
body { font-family: 'Nunito', sans-serif; font-size: 1.1rem; background: var(--bg); }
/* ... estilos da atividade ... */
</style>
</head>
<body>
<!-- Cabeçalho com emoji do personagem + título do tema -->
<!-- Corpo da atividade — fonte grande, botões grandes, feedback visual -->
<!-- Rodapé com botão Voltar ao Portal -->
<script>
// Lógica da atividade + função playSound
</script>
</body>
</html>
```

---

## FASE 6 — Atualização do index.html via Cowork

**Modo de operação padrão: Cowork acessa e edita o arquivo diretamente na pasta local.**

O `index.html` vive em:
```
C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\index.html
```

O Cowork deve ler o arquivo, aplicar todas as modificações programaticamente e salvar — sem gerar arquivo de instrução separado, sem etapa manual de substituição.

### 6.1 Sequência de edições no index.html

Para cada novo tema, o Cowork executa as seguintes edições em ordem:

**Se nova disciplina:**

1. **Variáveis CSS** — inserir dentro do bloco `:root`:
```css
--[disc]-color: [cor primária];
--[disc]-light: [cor clara];
--[disc]-bg: [bg];
```

2. **Classes CSS da disciplina** — inserir no bloco de estilos:
```css
.act-card.[disc]:hover { box-shadow: 0 6px 24px rgba([rgb],.15); transform: translateY(-3px); border-color: var(--[disc]-light); }
.act-card.[disc] { border-top: 4px solid var(--[disc]-color); }
.act-card.[disc]::after { color: var(--[disc]-color); }
.disc-hero.[disc] { background: linear-gradient([gradiente da disciplina]); }
.disc-home-card.[disc]:hover { border-color: var(--[disc]-light); box-shadow: 0 8px 28px rgba([rgb],.15); }
.theme-tab-btn.[disc]-tab:hover { border-color: var(--[disc]-color); color: var(--[disc]-color); }
.theme-tab-btn.[disc]-tab.active { background: var(--[disc]-bg); border-color: var(--[disc]-color); color: var(--[disc]-color); }
.tag-[disc] { background: [bg claro]; color: [cor primária]; }
```

3. **Sidebar** — substituir o botão `soon` da disciplina pelo botão ativo com sub-menu:
```html
<button class="disc-nav-btn" id="nav-[disc]" onclick="showDisc('[disc]')">
  <span class="d-icon">[emoji]</span>
  <span class="d-name">[Nome]</span>
  <span class="d-count">[N temas]</span>
</button>
<div class="theme-sub" id="sub-[disc]">
  <button class="theme-link" onclick="showTheme('[disc]','[slug]')">[emoji] [Nome do Tema]</button>
</div>
```

4. **Card na home** — substituir o `div.disc-home-card.soon` da disciplina pelo card ativo:
```html
<button class="disc-home-card [disc]" onclick="showDisc('[disc]')">
  <div class="dhc-icon">[emoji]</div>
  <div class="dhc-name">[Nome]</div>
  <div class="dhc-desc">[descrição]</div>
  <div class="dhc-chips">
    <span class="chip" style="background:[bg];color:[cor]">[N] temas</span>
    <span class="chip" style="background:#ECFDF5;color:#065F46">[N] atividades</span>
  </div>
</button>
```

5. **Contadores da home** — atualizar os três `hstat` com os totais corretos.

6. **JavaScript `firstTheme`** — adicionar a disciplina no objeto:
```js
var firstTheme = { port: '[primeiro-slug-port]', mat: '[primeiro-slug-mat]', ..., [disc]: '[primeiro-slug]' }[disc];
```

7. **Screen da disciplina** — inserir antes de `</main>`:
```html
<div class="screen" id="screen-[disc]">
  <div class="disc-hero [disc]">...</div>
  <div class="disc-body">
    <div class="theme-tabs">...</div>
    <!-- theme-contents de cada tema -->
  </div>
</div>
```

**Se disciplina já existe (apenas novo tema):**

1. Adicionar `<button class="theme-link">` dentro do `div#sub-[disc]` na sidebar
2. Adicionar `<button class="theme-tab-btn [disc]-tab">` dentro do `.theme-tabs` da disciplina
3. Inserir novo `<div class="theme-content" id="theme-[disc]-[slug]">` dentro do `screen-[disc]`
4. Atualizar contador `d-count` da disciplina na sidebar
5. Atualizar chips e contadores da home

### 6.2 Estrutura do theme-content

```html
<div class="theme-content" id="theme-[disc]-[slug]">
  <div class="hq-card">
    <img class="hq-img" src="hq-[slug].png" alt="HQ [Nome do Tema]">
    <div class="hq-caption"><span>📖</span><span>[Título HQ] — 4 páginas · Personagens: Lis e [personagem de suporte] · Tema: [tema]</span></div>
  </div>
  <hr class="sdiv">
  <div class="act-grid">
    <!-- act-cards -->
  </div>
  <hr class="sdiv">
  <div class="sched-title">📅 Sugestão de uso</div>
  <div class="sched">
    <!-- sched-rows — máximo 3 dias, sessões curtas -->
  </div>
</div>
```

**Nota:** a sugestão de uso semanal do 2º ano usa no máximo 3 dias e sessões menores (1–2 atividades por dia), respeitando a menor capacidade de concentração da faixa etária.

---

## FASE 7 — Entrega via Cowork

**Modo de operação padrão: tudo é escrito diretamente na pasta local do projeto.**

### 7.1 O que o Cowork escreve na pasta local

```
C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\
├── index.html                         ← editado diretamente (Fase 6)
├── hq-[slug]-prompt.md                ← criado
├── quiz-[slug].html                   ← criado
├── mapa-mental-[slug].html            ← criado
├── [atividade-variavel-1]-[slug].html ← criado
└── [atividade-variavel-2]-[slug].html ← criado
```

Todos os arquivos vão direto para a raiz do projeto — nunca em subpastas.

### 7.2 Checklist antes de concluir

- [ ] `index.html` salvo com todas as alterações da Fase 6
- [ ] Todos os arquivos HTML das atividades na raiz da pasta
- [ ] Todos os `href` dos `act-card` no index batem com os nomes dos arquivos criados
- [ ] O `id` do `theme-content` bate com o `onclick` do tab e do sidebar
- [ ] Contadores da home atualizados
- [ ] `firstTheme` atualizado no JavaScript (se nova disciplina)
- [ ] Nenhum arquivo criado em subpasta
- [ ] Font-size mínimo respeitado em todas as atividades
- [ ] Função `playSound` presente em todas as atividades interativas

### 7.3 Mensagem de conclusão

Ao finalizar, informar Léo:
1. Quais temas foram gerados e em qual disciplina
2. Quais atividades variáveis foram escolhidas e **por que** (justificativa pedagógica)
3. O personagem de suporte criado (se houver) com breve descrição visual
4. Se algum conceito da Fase 0 ficou sem cobertura nas atividades geradas
5. Próximo passo: commit + push no GitHub Desktop → GitHub Pages publica automaticamente

### 7.4 Fallback — quando executado fora do Cowork

Se a skill for executada no Claude.ai (sem acesso ao sistema de arquivos local), entregar um **único ZIP** contendo:
- Todos os arquivos HTML das atividades
- O `hq-[slug]-prompt.md`
- O `index.html` **completo e já atualizado** — nunca um arquivo de instruções separado

O `index.html` completo exige que Léo forneça o arquivo atual no início da conversa. Se não for fornecido, solicitar antes de prosseguir para a Fase 5.

---

## Referências

- `references/temas-existentes.md` — lista de todos os temas já implementados
- `references/atividades-por-disciplina.md` — catálogo de tipos de atividade com critérios de escolha
- `references/index-template-snippets.md` — snippets HTML prontos para copiar ao atualizar o index
- Projeto irmão (referência de arquitetura): `github.com/mottacastelo-ai/estudos`
