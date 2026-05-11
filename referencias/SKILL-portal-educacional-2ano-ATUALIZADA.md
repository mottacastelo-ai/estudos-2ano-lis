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
           1. Prompt HQ (.md)                   ← entregue para uso externo por Léo
           2. Atividades HTML (Quiz + variáveis + Mapa Mental)
           3. Atualização do index.html
           4. Entrega via Cowork
```

> **Nota:** A geração das imagens de HQ (ChatGPT) é uma etapa externa à skill, executada por Léo com a skill dedicada de HQ. A skill do portal entrega o prompt `.md` e segue direto para as atividades — os 4 arquivos `hq-[slug]-pg1.png` … `pg4.png` devem ser copiados manualmente por Léo para a raiz do projeto antes do deploy.

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
| Ferramenta de imagem para HQs | GPT Quadrinhos Sabendo (https://chatgpt.com/g/g-69ff2b40169881918c5f75a8d9767f30-gpt-quadrinhos-sabendo) |
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

**🎯 Proposta de estrutura**

> Opção A — [N] tema(s): [Nome do Tema 1] + [Nome do Tema 2]
> Justificativa: [por que essa divisão serve melhor pedagogicamente]

> Opção B — Tema único: [Nome]
> Justificativa: [por que agrupar pode funcionar, com ressalvas de cobertura]

**⚠️ Alertas de cobertura**
[Listar conceitos ou habilidades que poderiam ficar de fora]

**✅ Aguardando sua decisão para prosseguir.**

---

### 0.4 Regra de bloqueio

A skill **não avança para a Fase 1** até receber de Léo:
- Qual opção de estrutura foi aprovada
- Confirmação explícita para começar a geração

---

## FASE 1 — Identificação e separação de temas (após aprovação da Fase 0)

### 1.1 Separação por tema

Com base na estrutura aprovada na Fase 0, delimite com precisão quais imagens/páginas pertencem a cada tema.

### 1.2 Verificação de conflito com temas existentes

Consulte `references/temas-existentes.md`. Se o tema já existir, pergunte antes de sobrescrever.

### 1.3 Mapeamento de disciplina → código

| Disciplina  | Código HTML | Cor primária | Cor clara   | Bg          | Gradiente hero                                    |
|-------------|-------------|--------------|-------------|-------------|---------------------------------------------------|
| Português   | `port`      | `#E8430A`    | `#FB8C5A`   | `#FFF4EF`   | `135deg, #7A1F04, #E8430A 60%, #FB8C5A`          |
| Matemática  | `mat`       | `#0AACE8`    | `#5AC8FB`   | `#EFF9FF`   | `135deg, #044A7A, #0AACE8 60%, #5AC8FB`          |
| Ciências    | `cien`      | `#22C55E`    | `#6EE7A0`   | `#F0FDF4`   | `135deg, #14532D, #22C55E 60%, #6EE7A0`          |
| História    | `hist`      | `#A855F7`    | `#D08EF8`   | `#FAF5FF`   | `135deg, #4A1272, #A855F7 60%, #D08EF8`          |
| Geografia   | `geo`       | `#F59E0B`    | `#FCD34D`   | `#FFFBEB`   | `135deg, #78350F, #F59E0B 60%, #FCD34D`          |

**Lógica da paleta:** cores vibrantes e saturadas, adequadas ao público infantil de 7–8 anos. Deliberadamente distintas das cores do projeto do 5º ano.

Para novas disciplinas não listadas, proponha uma paleta ao usuário antes de continuar.

---

## FASE 2 — Criação de personagem narrativo

### Personagem principal (sempre presente)

- **Lis** — menina de 7 anos, cabelos castanhos longos e ondulados, sorriso expressivo e aberto, estilo despojado. Protagonista de todas as HQs. Curiosa, animada, levemente atrevida.

### Personagens de suporte já criados

*(atualizar progressivamente à medida que novos personagens forem criados)*

| Personagem | Tema | Descrição visual |
|---|---|---|
| *(a preencher)* | *(a preencher)* | *(a preencher)* |

### Diretrizes para novos personagens

- Deve ser metáfora visual do conteúdo
- Tom: lúdico, acolhedor, levemente engraçado — adequado a 7 anos
- Mistura de animais falantes e objetos animados conforme o contexto
- Cor e estilo devem dialogar com a paleta da disciplina
- Sempre interage com a Lis na HQ
- Expressões faciais exageradas para facilitar leitura emocional pela criança

---

## FASE 3 — Geração do prompt de HQ

> **⚠️ Padrão de qualidade obrigatório:** Mínimo de 300 linhas. Cada painel descrito com precisão cirúrgica: posição na grade, cenário completo, posição corporal dos personagens, expressão facial, ação em curso, objetos em cena, falas nos balões.

O arquivo `.md` gerado deve poder ser usado por Léo diretamente na ferramenta de geração, sem edição adicional.

### Critérios obrigatórios

- **Mínimo de 300 linhas**
- Prompts das páginas em **inglês**
- Cada página com seu próprio bloco de prompt pronto para colar, entre três backticks
- **Bloco de estilo visual global** separado e reutilizável
- **Folha de personagens** gerada primeiro para estabelecer referência visual do novo personagem
- Falas dos personagens em **português** dentro dos prompts em inglês, entre aspas
- **Adaptação ao 2º ano:** balões com no máximo 8 palavras por fala

### Estrutura obrigatória de cada painel

```
Panel N (posição na grade):
- Cenário completo com elementos de fundo, iluminação e atmosfera
- Personagem A: posição corporal, expressão facial, gesto específico, roupa/adereços visíveis
- Personagem B: posição corporal, expressão facial, gesto específico
- Objetos e elementos visuais pedagógicos em cena
- Speech bubble PERSONAGEM A: "Fala em português — máx. 8 palavras"
- Speech bubble PERSONAGEM B: "Fala em português — máx. 8 palavras"
- Caption box ou legenda, se houver
- Detalhes atmosféricos (luz, partículas, sombras)
```

### Estrutura obrigatória da folha de personagens

**Para a Lis (4 variações emocionais):** Curiosa, Animada/Celebrando, Surpresa, Pensativa — cada uma full-body em quadro arredondado com label em português + emoji.

**Para o personagem de suporte (3 variações):** Ensinando/Calmo, Animado/Surpreso, Emotivo/Divertido — mesmo padrão.

**Comparação de escala obrigatória:** Lis e personagem de suporte lado a lado, corpo inteiro.

### Template completo de prompt de HQ

```markdown
# PROMPT PARA HISTÓRIA EM QUADRINHOS
## Tema: [Nome do Tema]
## [Disciplina] — 2º ano

---

## INSTRUÇÕES DE USO

Cole o bloco de cada página diretamente no ChatGPT (Images 2.0) ou outra ferramenta de geração.
Gere uma página por vez, na ordem definida abaixo.

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
Character design must remain consistent across all pages.
4 panels per page in a 2x2 grid layout.
\`\`\`

---

## PERSONAGENS FIXOS

| Personagem | Descrição visual completa |
|---|---|
| **Lis** | 7-year-old Brazilian girl, warm light skin tone, long wavy chestnut-brown hair reaching her shoulders, large expressive brown eyes, wide open smile sometimes showing teeth, small stature. Outfit: [roupa específica do tema]. |
| **[Personagem de suporte]** | [Descrição visual detalhada — tamanho relativo à Lis, cores, traços distintivos, acessórios] |

---

## ROTEIRO — 4 PÁGINAS

### PÁGINA 1 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
Brazilian children's educational comic book page, 4 panels in 2x2 grid,
colorful flat illustration, bold black outlines, [paleta], Portuguese speech bubbles.

Panel 1 (top left): [descrição completa]
Panel 2 (top right): [descrição completa]
Panel 3 (bottom left): [descrição completa]
Panel 4 (bottom right): [descrição completa]

Style: [resumo], bold outlines, Portuguese speech bubbles, 2x2 grid.
\`\`\`

### PÁGINA 2 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
Character reference: same characters as previous page —
Lis: [resumo visual compacto]. [Personagem]: [resumo visual compacto].

[4 painéis descritos individualmente]
\`\`\`

### PÁGINA 3 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
[Idem — com "Character reference" no topo]
\`\`\`

### PÁGINA 4 — "[Título]"
**Objetivo pedagógico:** [...]

**PROMPT:**
\`\`\`
[Idem — painel 4 com fourth wall break convidando o leitor para o portal]
\`\`\`

---

## FOLHA DE PERSONAGENS (gere primeiro)

\`\`\`
[Prompt completo da folha conforme estrutura obrigatória da Fase 3]
\`\`\`

---

## ORDEM DE GERAÇÃO

1. Folha de personagens
2. Página 1 — [título]
3. Página 2 — [título]
4. Página 3 — [título]
5. Página 4 — [título]

---

*Conteúdo baseado em: [livro didático, páginas referenciadas]*
*Tema: [descrição resumida do conteúdo pedagógico]*
```

---

## FASE 4 — Design das atividades

### Princípios de design para o 2º ano

1. **Fonte grande** — `font-size` mínimo de `1.2rem` para conteúdo; `1.5rem` para enunciados
2. **Sessão curta** — máximo de 8–10 questões ou interações por atividade
3. **Feedback imediato e visual** — sons via Web Audio API; animações simples
4. **Linguagem simplificada** — frases curtas, sem vocabulário técnico desnecessário
5. **Apelo visual alto** — emojis, cores vibrantes, ícones grandes
6. **Interações intuitivas** — clicar, arrastar, selecionar — nunca digitar texto livre

### 4.0 Regra global — Cobertura obrigatória dos termos técnicos centrais

**Fontes válidas de termos técnicos:**
- ✅ Texto do livro didático (páginas fotografadas)
- ✅ Títulos, legendas e glossários do livro
- ✅ Exercícios e enunciados do livro
- ❌ Roteiro ou falas da HQ gerada pela skill
- ❌ Conhecimento geral da skill sobre o tema
- ❌ Materiais externos não fornecidos por Léo

**Checklist global antes de concluir qualquer tema:**
- [ ] Termos técnicos extraídos exclusivamente do material didático fotografado?
- [ ] Nenhum termo incluído por ter aparecido apenas na HQ?
- [ ] Cada atividade cobre pelo menos um termo técnico confirmado explicitamente?
- [ ] Nenhuma atividade usa apenas paráfrases quando o objetivo é fixar o termo?
- [ ] O conjunto cobre definição, identificação e aplicação dos termos do livro?

### 4.1 Atividades obrigatórias (todo tema, toda disciplina)

#### A) Quiz Interativo
- **Arquivo:** `quiz-[slug].html`
- **Estrutura:** 8 questões de múltipla escolha com 3 alternativas
- **Feedback:** imediato com som + placar final com mensagem motivacional e emoji festivo
- **Nível Glasser:** 📖 Retrieval practice

#### B) Mapa Mental
- **Arquivo:** `mapa-mental-[slug].html`
- **Estrutura:** Nós arrastáveis com conexões, gabarito ao final
- **Conteúdo:** 5–7 nós
- **Nível Glasser:** 🏆 Ensinar (90%)
- **Sempre é a última atividade listada no act-grid**
- **Regra de conteúdo obrigatória — slots e nodes:**
  - **Slots** (receptáculos fixos no mapa) = características, definições ou exemplos extraídos do conteúdo
  - **Nodes** (cards arrastáveis) = conceitos, termos ou categorias que a criança precisa classificar
  - Jamais usar posição geográfica, ordem numérica, cor ou qualquer atributo de layout como label de slot
  - Teste de validade: a correspondência slot → node deve fazer sentido como afirmação pedagógica ("Lojas e mercados → Bairro Comercial"), nunca como posição ("Norte → Bairro Residencial")

### 4.2 Atividades variáveis

Selecione **2–3 atividades** respeitando:
1. Nenhuma deve repetir o tipo de interação de outro tema da mesma disciplina
2. Deve cobrir pelo menos um nível intermediário (70% ou 80% da pirâmide)
3. Deve haver pelo menos uma atividade de criação/produção (90%)
4. **Regra adicional do 2º ano:** pelo menos uma atividade deve ser predominantemente visual

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
2. **Usar as fontes do projeto:** `Nunito` (principal) + `Baloo 2` (títulos e destaques)
3. **Aplicar a paleta da disciplina** conforme tabela da Fase 1
4. **Ter feedback imediato** — visual e sonoro (Web Audio API)
5. **Ter botão "Voltar ao Portal"** que fecha a aba (`window.close()`) ou vai para `index.html`
6. **Ser responsivo** (funcionar em mobile e tablet)
7. **Ter cabeçalho** com nome do tema e emoji do personagem
8. **Font-size mínimo:** `1.2rem` para conteúdo; `1.5rem` para enunciados
9. **Botões grandes** — `padding` mínimo de `14px 24px`, `border-radius` de 12px+

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

### 6.1 Sequência de edições no index.html

**Se nova disciplina:**
1. Variáveis CSS dentro do bloco `:root`
2. Classes CSS da disciplina no bloco de estilos
3. Sidebar — substituir botão `soon` pelo botão ativo com sub-menu
4. Card na home — substituir `div.disc-home-card.soon` pelo card ativo
5. Contadores da home — atualizar os três `hstat`
6. JavaScript `firstTheme` — adicionar a disciplina no objeto
7. Screen da disciplina — inserir antes de `</main>`

**Se disciplina já existe (apenas novo tema):**
1. Adicionar `<button class="theme-link">` dentro do `div#sub-[disc]` na sidebar
2. Adicionar `<button class="theme-tab-btn [disc]-tab">` dentro do `.theme-tabs`
3. Inserir novo `<div class="theme-content" id="theme-[disc]-[slug]">` dentro do `screen-[disc]`
4. Atualizar contador `d-count` da disciplina na sidebar
5. Atualizar chips e contadores da home

### 6.2 Estrutura do theme-content

```html
<div class="theme-content" id="theme-[disc]-[slug]">
  <div class="hq-card">
    <div class="hq-nav">
      <button class="hq-nav-btn" onclick="hqPrev('[slug]')">◀</button>
      <img class="hq-img" id="hq-img-[slug]" src="hq-[slug]-pg1.png" alt="HQ [Nome do Tema]">
      <button class="hq-nav-btn" onclick="hqNext('[slug]')">▶</button>
    </div>
    <div class="hq-page-indicator" id="hq-page-[slug]">Página 1 de 4</div>
    <div class="hq-caption"><span>📖</span><span>[Título HQ] — 4 páginas · Personagens: Lis e [personagem de suporte] · Tema: [tema]</span></div>
  </div>
  <hr class="sdiv">
  <div class="act-grid">
    <!-- act-cards -->
  </div>
  <hr class="sdiv">
  <div class="sched-title">📅 Sugestão de uso</div>
  <div class="sched">
    <!-- sched-rows — máximo 3 dias, sessões curtas (1–2 atividades por dia) -->
  </div>
</div>
```

> Os 4 arquivos referenciados pelo componente de navegação são: `hq-[slug]-pg1.png`, `hq-[slug]-pg2.png`, `hq-[slug]-pg3.png`, `hq-[slug]-pg4.png`. Verificar que todos os 4 nomes estão corretos no código gerado.

> **⚠️ Regra de estilo obrigatória — imagem da HQ:** O elemento `img` dentro do viewer deve sempre usar `object-fit: contain` — nunca `object-fit: cover`. O valor `cover` recorta as bordas da imagem para preencher o container, cortando texto e painéis das HQs. O valor `contain` preserva a imagem inteira.

> **⚠️ Regra de estilo obrigatória — touch-action:** Elementos de exibição de imagem (`.hq-page-base`, `.hq-page-base img` e equivalentes) devem sempre usar `touch-action: auto`. Nunca usar `touch-action: pan-y pinch-zoom` nesses elementos — esse valor captura eventos de toque e impede o scroll normal da página no celular quando o dedo começa o gesto sobre o quadrinho. Botões de navegação podem usar `touch-action: manipulation`.

> **⚠️ Regra de estilo obrigatória — lombada decorativa:** Nunca adicionar pseudo-elemento `::before` com gradiente lateral simulando lombada de livro no container do viewer de HQ. Esse efeito sobrepõe a borda esquerda da imagem e corta o conteúdo do quadrinho.

### 6.3 Checklist de estilo ao editar o index.html

- [ ] Imagem da HQ usa `object-fit: contain` no viewer (nunca `cover`)
- [ ] Container e imagem do viewer usam `touch-action: auto` (nunca `pan-y pinch-zoom`)
- [ ] Nenhum `::before` com gradiente lateral no container do viewer

---

## FASE 7 — Entrega via Cowork

### 7.1 O que o Cowork escreve na pasta local

```
C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano\
├── index.html                         ← editado diretamente (Fase 6)
├── hq-[slug]-prompt.md                ← criado (Fase 3)
├── quiz-[slug].html                   ← criado (Fase 5)
├── mapa-mental-[slug].html            ← criado (Fase 5)
├── [atividade-variavel-1]-[slug].html ← criado (Fase 5)
└── [atividade-variavel-2]-[slug].html ← criado (Fase 5)
```

> **Nota:** os 4 arquivos `hq-[slug]-pg1.png` … `pg4.png` **não são gerados por esta skill** — Léo os gera externamente (skill de HQ) e os copia manualmente para a raiz do projeto antes do deploy.

Todos os arquivos vão direto para a raiz do projeto — nunca em subpastas.

### 7.2 Checklist antes de concluir

- [ ] `index.html` salvo com todas as alterações da Fase 6
- [ ] Todos os arquivos HTML das atividades na raiz da pasta
- [ ] Todos os `href` dos `act-card` batem com os nomes dos arquivos criados
- [ ] O `id` do `theme-content` bate com o `onclick` do tab e do sidebar
- [ ] Contadores da home atualizados
- [ ] `firstTheme` atualizado no JavaScript (se nova disciplina)
- [ ] Nenhum arquivo criado em subpasta
- [ ] Font-size mínimo respeitado em todas as atividades
- [ ] Função `playSound` presente em todas as atividades interativas
- [ ] Os 4 `src` do componente de navegação usam o padrão `hq-[slug]-pg1.png` … `pg4.png`
- [ ] Imagem da HQ usa `object-fit: contain` no viewer
- [ ] Container e imagem do viewer usam `touch-action: auto`
- [ ] Nenhum `::before` com gradiente lateral no container do viewer
- [ ] Léo foi informado de que precisa copiar manualmente os 4 arquivos `hq-[slug]-pgN.png` para a pasta antes do deploy

### 7.3 Mensagem de conclusão

Ao finalizar, informar Léo:
1. Quais temas foram gerados e em qual disciplina
2. Quais atividades variáveis foram escolhidas e **por que** (justificativa pedagógica)
3. O personagem de suporte criado com breve descrição visual
4. Se algum conceito da Fase 0 ficou sem cobertura nas atividades geradas
5. Próximo passo após a geração das HQs: commit + push no GitHub Desktop → GitHub Pages publica automaticamente

### 7.4 Acionamento automático da skill hq-generator

Após salvar todos os arquivos na pasta local, acionar automaticamente a skill **hq-generator** para cada tema gerado, na sequência.

**Parâmetros passados pela skill do portal:**

| Parâmetro | Valor |
|---|---|
| `PASTA_PROJETO` | `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano` |
| `SLUG` | slug do tema recém-gerado |
| `PROMPT_MD` | `[PASTA_PROJETO]\hq-[slug]-prompt.md` |
| `MONTAR` | `False` — páginas individuais são mantidas separadas |

**Parâmetros detectados automaticamente pela hq-generator:**

- `TAB_ID` — obtido via `list_connected_browsers` ou `tabs_context_mcp`; usar a aba ativa do Chrome
- `CONVERSA_URL` — navegar para `https://chatgpt.com/g/g-69ff2b40169881918c5f75a8d9767f30-gpt-quadrinhos-sabendo` (sem `/c/...`) para iniciar nova conversa; a URL resultante após o redirecionamento é a `CONVERSA_URL`

Se houver mais de um tema no lote, executar a hq-generator para cada um em sequência — aguardar a conclusão completa (Fase 2 da hq-generator) antes de iniciar o próximo tema.

**Esta etapa substitui o lembrete manual de geração de HQ.** Os 4 arquivos `hq-[slug]-pg1.png` … `pg4.png` já estarão na raiz do projeto ao final.

### 7.5 Fallback — quando executado fora do Cowork

Se a skill for executada no Claude.ai (sem acesso ao sistema de arquivos local), entregar um **único ZIP** contendo:
- Todos os arquivos HTML das atividades
- O `hq-[slug]-prompt.md`
- O `index.html` **completo e já atualizado** — nunca um arquivo de instruções separado

O `index.html` completo exige que Léo forneça o arquivo atual no início da conversa. Se não for fornecido, solicitar antes de prosseguir para a Fase 5.

Neste modo, a hq-generator **não é acionada automaticamente** — informar Léo que deverá executá-la manualmente após extrair o ZIP.

---

## Referências

- `references/temas-existentes.md` — lista de todos os temas já implementados
- `references/atividades-por-disciplina.md` — catálogo de tipos de atividade com critérios de escolha
- `references/index-template-snippets.md` — snippets HTML prontos para copiar ao atualizar o index
- Projeto irmão (referência de arquitetura): `github.com/mottacastelo-ai/estudos`
