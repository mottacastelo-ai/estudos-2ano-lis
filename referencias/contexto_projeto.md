# Contexto do Projeto Educacional — Portal Interativo de Aprendizagem (Lis, 2º Ano)

**Última atualização:** 2026-06-23

> **Projeto irmão:** [Portal do André — 5º Ano](../../estudos/referencias/contexto_projeto.md) — mesma metodologia, stack técnico e workflow, mas personagens, cores e conteúdos distintos. **SEMPRE consultar o 5º ano antes de implementar qualquer padrão novo.**

---

## Visão Geral

Portal web educacional construído como SPA para o aprendizado da Lis (2º ano, 7–8 anos). Usa a mesma metodologia do portal do André: aprendizagem ativa, Pirâmide de Glasser, gamificação com cartas. Atividades adaptadas à faixa etária — linguagem simples, balões com máx. 8 palavras, cores vibrantes.

- **Repositório:** [github.com/mottacastelo-ai/estudos-2ano-lis](https://github.com/mottacastelo-ai/estudos-2ano-lis)
- **URL pública:** https://lis.sabendo.app
- **Pasta local:** `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano`

---

## Ecossistema sabendo.app

| Portal | URL | Pasta local |
|---|---|---|
| Landing page | https://sabendo.app | `estudos\_landing\` |
| Portal André (5º ano) | https://andre.sabendo.app | `estudos\` |
| Portal Lis (2º ano) | https://lis.sabendo.app | `estudos-2ano\` |

---

## Infraestrutura Técnica

### Hospedagem & Deploy
- **Hospedagem:** GitHub Pages
- **Deploy:** manual — commit + push (`git add → commit → push origin main`)
- **`.nojekyll`** na raiz do repo — obrigatório para que GitHub Pages sirva a pasta `_landing/` (Jekyll ignora pastas com `_` por padrão)

### Supabase
- **Projeto:** `mmtrzxmitklpibfilbio.supabase.co`
- **Chave anon pública:** `sb_publishable_ZgA70ikD1XRgEhxzz7aKzQ_TNSAsxQ_`
- **Usuária:** `lis@sabendo.app` (portal: estudos-2ano, year: 2)

**Tabelas ativas:**
| Tabela | Uso |
|---|---|
| `profiles` | user_id, portal, year |
| `activity_log` | user_id, discipline, theme_slug, activity_type, score, created_at |
| `streaks` | current_streak, longest_streak, last_activity_date, total_activities |
| `cards` | user_id, theme_slug, discipline, rarity, avg_score |

### Autenticação
Login na landing (sabendo.app) → detecta portal via `profiles.portal` → redireciona com tokens no hash → portal processa via `detectSessionInUrl: true` → limpa hash. Se sem sessão → redirect para `https://sabendo.app`.

---

## Estrutura de Arquivos

```
estudos-2ano/
├── index.html                          ← SPA principal — fonte primária de verdade
├── .nojekyll                           ← obrigatório para GitHub Pages servir _landing/
├── ERROS.md                            ← consultar SEMPRE antes de gerar atividades
├── shared/
│   ├── gamification.js                 ← engine de gamificação (cartas, reveal, Supabase)
│   └── portal-back.js                  ← voltarAoPortal() — padrão obrigatório de retorno
├── _landing/
│   ├── cartas/
│   │   └── carta-fundo-[slug].png      ← backgrounds das cartas (abacaxi, banana, etc.)
│   └── chars/
│       ├── [slug]-hd.png               ← portraits HD gerados pelo Codex
│       └── [slug]-portrait-prompt.md   ← prompts para geração dos portraits
├── ciencias/[slug]/
├── geografia/[slug]/
├── historia/[slug]/
├── matematica/[slug]/
├── portugues/[slug]/
│   └── cada pasta contém:
│       ├── hq-[slug]-pg1.png … pg4.png ← páginas da HQ (4 arquivos separados)
│       ├── [tipo-atividade].html
│       └── hq-[slug]-prompt.md
└── referencias/
    ├── contexto_projeto.md             ← este arquivo
    ├── temas-existentes.md             ← temas implementados + personagens
    ├── SKILL-portal-educacional-2ano-ATUALIZADA.md
    ├── hq-gerador-SKILL.md
    └── gamificacao-schema.md
```

> **Diferença do André:** HQs do 2º ano são 4 arquivos separados (`pg1.png … pg4.png`), não coladas em um único arquivo.

---

## Estado Atual — 5 Disciplinas · 13 Temas

Ver `temas-existentes.md` para lista completa com personagens e atividades por tema.

| Disciplina | Temas |
|---|---|
| Ciências | 4 (animais-ciclo-vida, orgaos-sentidos, preservando-meio-ambiente, onde-vivem-plantas) |
| Geografia | 2 (representar-lugares, paisagem-bairros) |
| História | 5 (memorias-lugares, meu-lugar-viver, convivencia-pessoas, regras-convivencia, mudancas-convivencia) |
| Matemática | 1 (numeros-ordinais) |
| Português | 2 (bilhete-cartao-pessoal, letras-silabas-pontuacao) |

---

## Funcionalidades Implementadas no Portal (index.html)

### Gamificação (mesmo padrão do 5º ano)
- **Sistema de cartas temáticas** — ao concluir todas as atividades de um tema, a Lis coleta uma carta aleatória
- `shared/gamification.js` — engine completa (Supabase + localStorage fallback)
- Confete arco-íris + reveal cinematográfico com glow da disciplina
- **Cartas disponíveis:** abacaxi, banana, coração, estrela, kiwi, maçã, melancia, morango, pêssego, uva
- `_landing/cartas/carta-fundo-[slug].png` — backgrounds das cartas

### Badges de atividade completada
- `.act-badge` / `.act-badge-done` — ícone "✓ Feito" nos cards de atividade
- `.act-score-line` — melhor pontuação exibida abaixo do badge
- `HREF_MAP` no index.html — mapa `url → theme_slug|activity_type` para 58 atividades
- `loadActivityStatus()` — lê `activity_log` do Supabase, aplica badges em todos os cards

### Pontos de progresso nos temas (sidebar)
- `.theme-progress-dot` — ponto ao lado de cada tema na sidebar
  - Verde (`--done`) = todas as atividades concluídas
  - Âmbar (`--partial`) = ao menos uma concluída
- Calculado em `loadActivityStatus()` com base no `HREF_MAP`

### Galeria de Cartas ("Minhas Cartas")
- Botão `🎴 Minhas Cartas` na sidebar com contador de cartas coletadas
- `#screen-cartas` — tela dedicada com grid de cartas
- `loadCartas()` — busca tabela `cards` do Supabase, renderiza cada carta com background temático
- `themeToCardSlug()` — hash determinístico que mapeia theme_slug → card background slug

### Streak e progresso geral
- `loadStreak()` — exibe dias seguidos e total de atividades no hero do portal
- `loadActivityStatus()` + `loadCartasCount()` chamados em `initAuth()` após login

### Portraits dos Personagens
- `THEME_CATALOG` no index.html — array com metadados de todos os 13 temas incluindo `charImg: 'chars/[slug]-hd.png'`
- Portraits gerados pelo Codex Desktop via JSON de contrato em `estudos\.claude\pending\portraits-2ano.json`
- Automação Codex: **"Gerar Portraits pendentes"** (distinta de "Gerar HQs pendentes")
- Fundo chroma-key `#00ff00`, canvas 1024×1024
- Arquivo de saída: `_landing/chars/[slug]-hd.png`

---

## Padrões Obrigatórios nos HTMLs de Atividade

### window.sabendoScore
```javascript
// CORRETO — setar junto com o resultado
function mostrarResultado() {
  window.sabendoScore = Math.round((acertos / total) * 100);
  painelResultado.style.display = 'block';
}
// ERRADO — nunca incremental nem em funções intermediárias
```
Para atividades sem score numérico (mapa mental, etc.): `window.sabendoScore = 100` na conclusão.

### Botão de retorno
**Nunca `onclick="window.close()"`** — browsers modernos bloqueiam. Usar sempre `onclick="voltarAoPortal()"` + `<script src="../../shared/portal-back.js"></script>` antes do `</body>`.

### Variáveis JS globais proibidas
Nunca em escopo global: `var history`, `var name`, `var location`, `var event`, `var status`, `var top`. Usar nomes descritivos: `quizHistory`, `pageName`, etc.

### Snippet de gamificação
Ver CLAUDE.md para o snippet completo obrigatório (`<!-- GAMIFICAÇÃO -->`). Campos a preencher: `THEME_SLUG`, `DISCIPLINE`, `ACTIVITY_TYPE`, `TOTAL_ATIV`, `characterName`, `characterImg`, `themeLabel`, cores da disciplina.

---

## Personagens de Suporte (13 temas)

Ver `temas-existentes.md` para lista completa. Cada personagem tem:
- Folha de personagens (`[disciplina]/[slug]/folha-personagens-[nome].png`) — Bilheto e Pontinho (português)
- Página 1 da HQ (`[disciplina]/[slug]/hq-[slug]-pg1.png`) — referência visual para os demais 11
- Portrait HD (`_landing/chars/[slug]-hd.png`) — gerado pelo Codex, usado no reveal de cartas

**Protagonista:** Lis — menina de 7 anos, cabelos castanhos longos e ondulados, sorriso expressivo.

---

## Paleta de Cores por Disciplina

| Disciplina | Primária | Clara | Bg | glowRgb |
|---|---|---|---|---|
| Português (`port`) | `#E8430A` | `#FB8C5A` | `#FFF4EF` | `232,67,10` |
| Matemática (`mat`) | `#0AACE8` | `#5AC8FB` | `#EFF9FF` | `10,172,232` |
| Ciências (`cien`) | `#22C55E` | `#6EE7A0` | `#F0FDF4` | `34,197,94` |
| História (`hist`) | `#A855F7` | `#D08EF8` | `#FAF5FF` | `168,85,247` |
| Geografia (`geo`) | `#F59E0B` | `#FCD34D` | `#FFFBEB` | `245,158,11` |

Gradiente hero: `135deg, [escuro], [primária] 60%, [clara]`

---

## Workflow de Entrega

1. Analisador lê PDF → propõe estrutura → **pausa para aprovação de Léo**
2. Após aprovação → pipeline automático:
   - Criador de personagem + gerador de prompt HQ (paralelo)
   - JSON Codex escrito em `estudos\.claude\pending\` IMEDIATAMENTE após prompt HQ
   - Gerador de atividades → atualizador do portal
   - Verificador + revisor (paralelo) → publicador (commit + push atividades)
   - Polling em `estudos\.claude\done\` → commit das imagens HQ

### Codex Desktop — pré-requisitos
Antes de iniciar o pipeline, o Codex Desktop deve estar aberto com **duas automações ativas**:
- **"Gerar HQs pendentes"** — processa JSONs de HQ (`hq-[slug].json`)
- **"Gerar Portraits pendentes"** — processa `portraits-2ano.json`

### JSON de contrato Codex
Escrito em **`estudos\.claude\pending\`** (pasta do projeto do 5º ano — é isso que o Codex monitora, NÃO `estudos-2ano\.claude\pending\`).
- Encoding: UTF-8 sem BOM via `[System.IO.File]::WriteAllText` com `[System.Text.UTF8Encoding]::new($false)`
- Backslashes: usar string literal PowerShell single-quoted com `\\` — NUNCA interpolar com `-replace` (gera `\\\\`)

---

## Referências Críticas

| Arquivo | Quando consultar |
|---|---|
| `ERROS.md` | **SEMPRE antes de gerar atividades** |
| `referencias/temas-existentes.md` | Verificar conflito de tema ou atividade |
| `referencias/SKILL-portal-educacional-2ano-ATUALIZADA.md` | Templates HTML e padrões de atividade |
| `referencias/hq-gerador-SKILL.md` | Workflow de geração de HQ |
| `../../estudos/referencias/contexto_projeto.md` | **Portal irmão — consultar ANTES de qualquer padrão novo** |
| `shared/gamification.js` | Engine de gamificação |
| `shared/portal-back.js` | Função voltarAoPortal() |

---

## Contato & Manutenção

- **Responsável:** Léo Motta (`wizardcastelo@gmail.com`)
- **Repositório:** github.com/mottacastelo-ai/estudos-2ano-lis