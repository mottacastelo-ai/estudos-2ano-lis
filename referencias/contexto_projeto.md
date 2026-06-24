# Contexto do Projeto Educacional â€” Portal Interativo de Aprendizagem (Lis, 2Âº Ano)

**Ãšltima atualizaÃ§Ã£o:** 2026-06-23

> **Projeto irmÃ£o:** [Portal do AndrÃ© â€” 5Âº Ano](../../estudos/referencias/contexto_projeto.md) â€” mesma metodologia, stack tÃ©cnico e workflow, mas personagens, cores e conteÃºdos distintos. **SEMPRE consultar o 5Âº ano antes de implementar qualquer padrÃ£o novo.**

---

## VisÃ£o Geral

Portal web educacional construÃ­do como SPA para o aprendizado da Lis (2Âº ano, 7â€“8 anos). Usa a mesma metodologia do portal do AndrÃ©: aprendizagem ativa, PirÃ¢mide de Glasser, gamificaÃ§Ã£o com cartas. Atividades adaptadas Ã  faixa etÃ¡ria â€” linguagem simples, balÃµes com mÃ¡x. 8 palavras, cores vibrantes.

- **RepositÃ³rio:** [github.com/mottacastelo-ai/estudos-2ano-lis](https://github.com/mottacastelo-ai/estudos-2ano-lis)
- **URL pÃºblica:** https://lis.sabendo.app
- **Pasta local:** `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano`

---

## Ecossistema sabendo.app

| Portal | URL | Pasta local |
|---|---|---|
| Landing page | https://sabendo.app | `estudos\_landing\` |
| Portal AndrÃ© (5Âº ano) | https://andre.sabendo.app | `estudos\` |
| Portal Lis (2Âº ano) | https://lis.sabendo.app | `estudos-2ano\` |

---

## Infraestrutura TÃ©cnica

### Hospedagem & Deploy
- **Hospedagem:** GitHub Pages
- **Deploy:** manual â€” commit + push (`git add â†’ commit â†’ push origin main`)
- **`.nojekyll`** na raiz do repo â€” obrigatÃ³rio para que GitHub Pages sirva a pasta `_landing/` (Jekyll ignora pastas com `_` por padrÃ£o)

### Supabase
- **Projeto:** `mmtrzxmitklpibfilbio.supabase.co`
- **Chave anon pÃºblica:** `sb_publishable_ZgA70ikD1XRgEhxzz7aKzQ_TNSAsxQ_`
- **UsuÃ¡ria:** `lis@sabendo.app` (portal: estudos-2ano, year: 2)

**Tabelas ativas:**
| Tabela | Uso |
|---|---|
| `profiles` | user_id, portal, year |
| `activity_log` | user_id, discipline, theme_slug, activity_type, score, created_at |
| `streaks` | current_streak, longest_streak, last_activity_date, total_activities |
| `cards` | user_id, theme_slug, discipline, rarity, avg_score |

### AutenticaÃ§Ã£o
Login na landing (sabendo.app) â†’ detecta portal via `profiles.portal` â†’ redireciona com tokens no hash â†’ portal processa via `detectSessionInUrl: true` â†’ limpa hash. Se sem sessÃ£o â†’ redirect para `https://sabendo.app`.

---

## Estrutura de Arquivos

```
estudos-2ano/
â”œâ”€â”€ index.html                          â† SPA principal â€” fonte primÃ¡ria de verdade
â”œâ”€â”€ .nojekyll                           â† obrigatÃ³rio para GitHub Pages servir _landing/
â”œâ”€â”€ ERROS.md                            â† consultar SEMPRE antes de gerar atividades
â”œâ”€â”€ shared/
â”‚   â”œâ”€â”€ gamification.js                 â† engine de gamificaÃ§Ã£o (cartas, reveal, Supabase)
â”‚   â””â”€â”€ portal-back.js                  â† voltarAoPortal() â€” padrÃ£o obrigatÃ³rio de retorno
â”œâ”€â”€ _landing/
â”‚   â”œâ”€â”€ cartas/
â”‚   â”‚   â””â”€â”€ carta-fundo-[slug].png      â† backgrounds das cartas (abacaxi, banana, etc.)
â”‚   â””â”€â”€ chars/
â”‚       â”œâ”€â”€ [slug]-hd.png               â† portraits HD gerados pelo Codex
â”‚       â””â”€â”€ [slug]-portrait-prompt.md   â† prompts para geraÃ§Ã£o dos portraits
â”œâ”€â”€ ciencias/[slug]/
â”œâ”€â”€ geografia/[slug]/
â”œâ”€â”€ historia/[slug]/
â”œâ”€â”€ matematica/[slug]/
â”œâ”€â”€ portugues/[slug]/
â”‚   â””â”€â”€ cada pasta contÃ©m:
â”‚       â”œâ”€â”€ hq-[slug]-pg1.png â€¦ pg4.png â† pÃ¡ginas da HQ (4 arquivos separados)
â”‚       â”œâ”€â”€ [tipo-atividade].html
â”‚       â””â”€â”€ hq-[slug]-prompt.md
â””â”€â”€ referencias/
    â”œâ”€â”€ contexto_projeto.md             â† este arquivo
    â”œâ”€â”€ temas-existentes.md             â† temas implementados + personagens
    â”œâ”€â”€ SKILL-portal-educacional-2ano-ATUALIZADA.md
    â”œâ”€â”€ hq-gerador-SKILL.md
    â””â”€â”€ gamificacao-schema.md
```

> **DiferenÃ§a do AndrÃ©:** HQs do 2Âº ano sÃ£o 4 arquivos separados (`pg1.png â€¦ pg4.png`), nÃ£o coladas em um Ãºnico arquivo.

---

## Estado Atual â€” 5 Disciplinas Â· 13 Temas

Ver `temas-existentes.md` para lista completa com personagens e atividades por tema.

| Disciplina | Temas |
|---|---|
| CiÃªncias | 4 (animais-ciclo-vida, orgaos-sentidos, preservando-meio-ambiente, onde-vivem-plantas) |
| Geografia | 2 (representar-lugares, paisagem-bairros) |
| HistÃ³ria | 5 (memorias-lugares, meu-lugar-viver, convivencia-pessoas, regras-convivencia, mudancas-convivencia) |
| MatemÃ¡tica | 1 (numeros-ordinais) |
| PortuguÃªs | 2 (bilhete-cartao-pessoal, letras-silabas-pontuacao) |

---

## Funcionalidades Implementadas no Portal (index.html)

### GamificaÃ§Ã£o (mesmo padrÃ£o do 5Âº ano)
- **Sistema de cartas temÃ¡ticas** â€” ao concluir todas as atividades de um tema, a Lis coleta uma carta aleatÃ³ria
- `shared/gamification.js` â€” engine completa (Supabase + localStorage fallback)
- Confete arco-Ã­ris + reveal cinematogrÃ¡fico com glow da disciplina
- **Cartas disponÃ­veis:** abacaxi, banana, coraÃ§Ã£o, estrela, kiwi, maÃ§Ã£, melancia, morango, pÃªssego, uva
- `_landing/cartas/carta-fundo-[slug].png` â€” backgrounds das cartas

### Badges de atividade completada
- `.act-badge` / `.act-badge-done` â€” Ã­cone "âœ“ Feito" nos cards de atividade
- `.act-score-line` â€” melhor pontuaÃ§Ã£o exibida abaixo do badge
- `HREF_MAP` no index.html â€” mapa `url â†’ theme_slug|activity_type` para 58 atividades
- `loadActivityStatus()` â€” lÃª `activity_log` do Supabase, aplica badges em todos os cards

### Pontos de progresso nos temas (sidebar)
- `.theme-progress-dot` â€” ponto ao lado de cada tema na sidebar
  - Verde (`--done`) = todas as atividades concluÃ­das
  - Ã‚mbar (`--partial`) = ao menos uma concluÃ­da
- Calculado em `loadActivityStatus()` com base no `HREF_MAP`

### Galeria de Cartas ("Minhas Cartas")
- BotÃ£o `ðŸŽ´ Minhas Cartas` na sidebar com contador de cartas coletadas
- `#screen-cartas` â€” tela dedicada com grid de cartas
- `loadCartas()` â€” busca tabela `cards` do Supabase, renderiza cada carta com background temÃ¡tico
- `themeToCardSlug()` â€” hash determinÃ­stico que mapeia theme_slug â†’ card background slug

### Streak e progresso geral
- `loadStreak()` â€” exibe dias seguidos e total de atividades no hero do portal
- `loadActivityStatus()` + `loadCartasCount()` chamados em `initAuth()` apÃ³s login

### Portraits dos Personagens
- `THEME_CATALOG` no index.html â€” array com metadados de todos os 13 temas incluindo `charImg: 'chars/[slug]-hd.png'`
- Portraits gerados pelo Codex Desktop via JSON de contrato em `estudos\.claude\pending\portraits-batch.json`
- AutomaÃ§Ã£o Codex: **"Gerar Portraits pendentes"** (distinta de "Gerar HQs pendentes")
- Fundo chroma-key `#00ff00`, canvas 1024Ã—1024
- Arquivo de saÃ­da: `_landing/chars/[slug]-hd.png`

---

## PadrÃµes ObrigatÃ³rios nos HTMLs de Atividade

### window.sabendoScore
```javascript
// CORRETO â€” setar junto com o resultado
function mostrarResultado() {
  window.sabendoScore = Math.round((acertos / total) * 100);
  painelResultado.style.display = 'block';
}
// ERRADO â€” nunca incremental nem em funÃ§Ãµes intermediÃ¡rias
```
Para atividades sem score numÃ©rico (mapa mental, etc.): `window.sabendoScore = 100` na conclusÃ£o.

### BotÃ£o de retorno
**Nunca `onclick="window.close()"`** â€” browsers modernos bloqueiam. Usar sempre `onclick="voltarAoPortal()"` + `<script src="../../shared/portal-back.js"></script>` antes do `</body>`.

### VariÃ¡veis JS globais proibidas
Nunca em escopo global: `var history`, `var name`, `var location`, `var event`, `var status`, `var top`. Usar nomes descritivos: `quizHistory`, `pageName`, etc.

### Snippet de gamificaÃ§Ã£o
Ver CLAUDE.md para o snippet completo obrigatÃ³rio (`<!-- GAMIFICAÃ‡ÃƒO -->`). Campos a preencher: `THEME_SLUG`, `DISCIPLINE`, `ACTIVITY_TYPE`, `TOTAL_ATIV`, `characterName`, `characterImg`, `themeLabel`, cores da disciplina.

---

## Personagens de Suporte (13 temas)

Ver `temas-existentes.md` para lista completa. Cada personagem tem:
- Folha de personagens (`[disciplina]/[slug]/folha-personagens-[nome].png`) â€” Bilheto e Pontinho (portuguÃªs)
- PÃ¡gina 1 da HQ (`[disciplina]/[slug]/hq-[slug]-pg1.png`) â€” referÃªncia visual para os demais 11
- Portrait HD (`_landing/chars/[slug]-hd.png`) â€” gerado pelo Codex, usado no reveal de cartas

**Protagonista:** Lis â€” menina de 7 anos, cabelos castanhos longos e ondulados, sorriso expressivo.

---

## Paleta de Cores por Disciplina

| Disciplina | PrimÃ¡ria | Clara | Bg | glowRgb |
|---|---|---|---|---|
| PortuguÃªs (`port`) | `#E8430A` | `#FB8C5A` | `#FFF4EF` | `232,67,10` |
| MatemÃ¡tica (`mat`) | `#0AACE8` | `#5AC8FB` | `#EFF9FF` | `10,172,232` |
| CiÃªncias (`cien`) | `#22C55E` | `#6EE7A0` | `#F0FDF4` | `34,197,94` |
| HistÃ³ria (`hist`) | `#A855F7` | `#D08EF8` | `#FAF5FF` | `168,85,247` |
| Geografia (`geo`) | `#F59E0B` | `#FCD34D` | `#FFFBEB` | `245,158,11` |

Gradiente hero: `135deg, [escuro], [primÃ¡ria] 60%, [clara]`

---

## Workflow de Entrega

1. Analisador lÃª PDF â†’ propÃµe estrutura â†’ **pausa para aprovaÃ§Ã£o de LÃ©o**
2. ApÃ³s aprovaÃ§Ã£o â†’ pipeline automÃ¡tico:
   - Criador de personagem + gerador de prompt HQ (paralelo)
   - JSON Codex escrito em `estudos\.claude\pending\` IMEDIATAMENTE apÃ³s prompt HQ
   - Gerador de atividades â†’ atualizador do portal
   - Verificador + revisor (paralelo) â†’ publicador (commit + push atividades)
   - Polling em `estudos\.claude\done\` â†’ commit das imagens HQ

### Codex Desktop â€” prÃ©-requisitos
Antes de iniciar o pipeline, o Codex Desktop deve estar aberto com **duas automaÃ§Ãµes ativas**:
- **"Gerar HQs pendentes"** â€” processa JSONs de HQ (`hq-[slug].json`)
- **"Gerar Portraits pendentes"** â€” processa `portraits-batch.json`

### JSON de contrato Codex
Escrito em **`estudos\.claude\pending\`** (pasta do projeto do 5Âº ano â€” Ã© isso que o Codex monitora, NÃƒO `estudos-2ano\.claude\pending\`).
- Encoding: UTF-8 sem BOM via `[System.IO.File]::WriteAllText` com `[System.Text.UTF8Encoding]::new($false)`
- Backslashes: usar string literal PowerShell single-quoted com `\\` â€” NUNCA interpolar com `-replace` (gera `\\\\`)

---

## ReferÃªncias CrÃ­ticas

| Arquivo | Quando consultar |
|---|---|
| `ERROS.md` | **SEMPRE antes de gerar atividades** |
| `referencias/temas-existentes.md` | Verificar conflito de tema ou atividade |
| `referencias/SKILL-portal-educacional-2ano-ATUALIZADA.md` | Templates HTML e padrÃµes de atividade |
| `referencias/hq-gerador-SKILL.md` | Workflow de geraÃ§Ã£o de HQ |
| `../../estudos/referencias/contexto_projeto.md` | **Portal irmÃ£o â€” consultar ANTES de qualquer padrÃ£o novo** |
| `shared/gamification.js` | Engine de gamificaÃ§Ã£o |
| `shared/portal-back.js` | FunÃ§Ã£o voltarAoPortal() |

---

## Contato & ManutenÃ§Ã£o

- **ResponsÃ¡vel:** LÃ©o Motta (`wizardcastelo@gmail.com`)
- **RepositÃ³rio:** github.com/mottacastelo-ai/estudos-2ano-lis

