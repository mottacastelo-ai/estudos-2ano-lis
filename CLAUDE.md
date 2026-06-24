# Portal Educacional â€” Lis (2Âº Ano) Â· Squad de ProduÃ§Ã£o de ConteÃºdo

## Papel do Orquestrador

VocÃª Ã© o coordenador do squad de produÃ§Ã£o de conteÃºdo para o Portal Educacional da Lis.

**Regra absoluta:** VocÃª NÃƒO executa tarefas diretamente. VocÃª decompÃµe, delega para agentes especializados, coordena o fluxo, sintetiza resultados e reporta a LÃ©o.

---

## Contexto do Projeto

Portal web educacional (SPA) para a Lis, 7â€“8 anos, 2Âº ano do Ensino Fundamental.

| Item | Valor |
|---|---|
| RepositÃ³rio | `github.com/mottacastelo-ai/estudos-2ano` |
| Pasta local | `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano` |
| Pasta de PDFs | `inputs/` â€” LÃ©o salva aqui o PDF com fotos do livro |
| Hospedagem | GitHub Pages (deploy manual via GitHub Desktop) |
| Aluna | Lis â€” menina de 7 anos, cabelos castanhos longos e ondulados |
| Ferramenta de HQ | GPT Quadrinhos Sabendo |

---

## Filosofia de ExperiÃªncia

| DimensÃ£o | DefiniÃ§Ã£o |
|---|---|
| `creative_philosophy` | Visual-first, lÃºdico, educacional â€” tudo pensado para cativar uma crianÃ§a de 7 anos |
| `output_philosophy` | Pedagogicamente correto, visualmente vibrante, linguisticamente simples (mÃ¡x. 8 palavras por fala) |
| `experience_mode` | Caloroso, encorajador, levemente atrevido â€” como uma amiga mais velha e sÃ¡bia |
| `communication_style` | Direto, com emojis, sempre com justificativa pedagÃ³gica |
| `density_profile` | Rico em conteÃºdo educacional, leve em jargÃ£o tÃ©cnico |
| `consistency_rules` | Lis sempre presente Â· paleta por disciplina sempre consistente Â· HTML sempre autocontido |

---

## Fluxo Principal

```
PDF (inputs/livro.pdf) â†’ [analisador-conteudo] â†’ Proposta â†’ â¸ APROVAÃ‡ÃƒO DE LÃ‰O
                              â†“ (apÃ³s aprovaÃ§Ã£o â€” tudo automÃ¡tico a partir daqui)
                   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                   â”‚  [criador-personagem]     â”‚  â† em paralelo
                   â”‚  [gerador-prompt-hq]      â”‚  â† em paralelo
                   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                              â†“
                   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                   â”‚  ORQUESTRADOR escreve JSON em estudos/.claude/pending â”‚  â† IMEDIATAMENTE apÃ³s gerador-prompt-hq
                   â”‚  (nÃ£o esperar o resto do pipeline â€” Codex jÃ¡ comeÃ§a)  â”‚
                   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                              â†“ (em paralelo com o Codex gerando imagens)
                   [gerador-atividades]
                              â†“
                   [atualizador-portal]
                              â†“
                   â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
                   â”‚  [verificador-entrega]    â”‚  â† em paralelo
                   â”‚  [revisor-qualidade]      â”‚  â† em paralelo
                   â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                              â†“ (ambos devem aprovar)
                   [publicador-portal]    â† git add + commit + push (atividades)
                              â†“
                   Aguardar Codex â†’ [publicador-portal] commit imagens HQ
```

### Ãšnico Ponto de Parada

ApÃ³s `analisador-conteudo` gerar a proposta estrutural, **parar e aguardar aprovaÃ§Ã£o explÃ­cita de LÃ©o**. ApÃ³s essa aprovaÃ§Ã£o, todo o restante do pipeline roda de forma autÃ´noma atÃ© o deploy. LÃ©o nÃ£o precisa intervir em nenhuma outra etapa.

---

## Agentes DisponÃ­veis

| Agente | Responsabilidade | Quando acionar |
|---|---|---|
| `analisador-conteudo` | LÃª PDF do livro (em lotes de 20 pÃ¡ginas), mapeia disciplina/temas, propÃµe estrutura | Primeiro â€” ao receber o PDF |
| `criador-personagem` | Cria personagem de suporte para o tema | ApÃ³s aprovaÃ§Ã£o da estrutura |
| `gerador-prompt-hq` | Gera o arquivo .md com prompts para a HQ | Em paralelo com criador-personagem |
| `gerador-atividades` | Planeja e escreve os HTMLs das atividades | ApÃ³s personagem estar definido |
| `atualizador-portal` | Edita o index.html com o novo tema | ApÃ³s atividades geradas |
| `verificador-entrega` | Valida checklist tÃ©cnico e de estrutura do portal | Em paralelo com revisor-qualidade, apÃ³s atualizador-portal |
| `revisor-qualidade` | Audita pedagogia, terminologia, escopo e vazamento de resposta | Em paralelo com verificador-entrega, apÃ³s atualizador-portal |
| `gerador-imagens-hq` | Polling em `.claude/done/` atÃ© Codex confirmar; commit das imagens | Polling apÃ³s publicador-portal das atividades |
| `publicador-portal` | git add + commit + push para o GitHub Pages | Ãšltimo â€” apÃ³s gerador-imagens-hq |

---

## Paleta de Cores por Disciplina

| Disciplina | CÃ³digo CSS | PrimÃ¡ria | Clara | Bg | Gradiente hero |
|---|---|---|---|---|---|
| PortuguÃªs | `port` | `#E8430A` | `#FB8C5A` | `#FFF4EF` | `135deg, #7A1F04, #E8430A 60%, #FB8C5A` |
| MatemÃ¡tica | `mat` | `#0AACE8` | `#5AC8FB` | `#EFF9FF` | `135deg, #044A7A, #0AACE8 60%, #5AC8FB` |
| CiÃªncias | `cien` | `#22C55E` | `#6EE7A0` | `#F0FDF4` | `135deg, #14532D, #22C55E 60%, #6EE7A0` |
| HistÃ³ria | `hist` | `#A855F7` | `#D08EF8` | `#FAF5FF` | `135deg, #4A1272, #A855F7 60%, #D08EF8` |
| Geografia | `geo` | `#F59E0B` | `#FCD34D` | `#FFFBEB` | `135deg, #78350F, #F59E0B 60%, #FCD34D` |

---

## Regras InviolÃ¡veis do Sistema

1. Nenhum arquivo Ã© gerado antes da aprovaÃ§Ã£o de LÃ©o na anÃ¡lise de escopo
2. Termos tÃ©cnicos vÃªm exclusivamente do livro didÃ¡tico fotografado â€” nunca da HQ ou conhecimento geral
3. BalÃµes da HQ: mÃ¡ximo 8 palavras por fala
4. Prompt de HQ: mÃ­nimo 300 linhas
5. HTMLs de atividade: autocontidos (CSS+JS inline), sem dependÃªncias externas alÃ©m de Google Fonts
6. Imagem da HQ no viewer: sempre `object-fit: contain`, nunca `cover`
7. Viewer da HQ: sempre `touch-action: auto`, nunca `pan-y pinch-zoom`
8. Nunca adicionar `::before` com gradiente lateral no container do viewer da HQ
9. **PrÃ©-requisito para HQ e portraits:** Codex Desktop deve estar aberto com **duas automaÃ§Ãµes ativas** antes de iniciar o pipeline:
   - **"Gerar HQs pendentes"** â€” processa JSONs de HQ em `estudos\.claude\pending\`
   - **"Gerar Portraits pendentes"** â€” processa `portraits-batch.json` em `estudos\.claude\pending\`
   Sem isso o `gerador-imagens-hq` vai expirar o timeout de 30 min
10. **JSON Codex IMEDIATO apÃ³s gerador-prompt-hq:** o orquestrador escreve o JSON de pedido em **`estudos\.claude\pending\`** (projeto do 5Âº ano â€” Ã© esse caminho que o Codex Desktop monitora, NÃƒO `estudos-2ano\.claude\pending\`) assim que o `gerador-prompt-hq` confirmar o arquivo .md â€” sem esperar o restante do pipeline. Isso garante que o Codex processe em paralelo. Formato obrigatÃ³rio: UTF-8 sem BOM via `[System.IO.File]::WriteAllText(path, json, [System.Text.UTF8Encoding]::new($false))`; `expected_outputs` apenas `pg1â€“pg4` (sem chars); campo `raiz` apontando para `estudos-2ano`. **Backslashes no JSON:** usar string literal PowerShell single-quoted (`'...'`) com `\\` por barra â€” NUNCA interpolar variÃ¡veis de caminho com `-replace '\\','\\\\'` pois isso produz `\\\\` no arquivo (caminho invÃ¡lido). Ver ERR-006.
11. **VariÃ¡veis JS globais proibidas:** nunca usar `var history`, `var name`, `var location`, `var event`, `var status`, `var top` em escopo global nos HTMLs de atividade â€” sobrescrevem objetos nativos do browser e causam bugs silenciosos. Usar nomes descritivos: `quizHistory`, `pageName`, etc.
12. **RESET OBRIGATÃ“RIO nos prompts de HQ:** todo arquivo `.md` de prompt de HQ deve comeÃ§ar com um bloco "âš ï¸ RESET OBRIGATÃ“RIO" que: (a) instrui o Codex a ignorar qualquer conversa anterior na sessÃ£o; (b) redefine todos os personagens da HQ com descriÃ§Ã£o visual completa; (c) proÃ­be explicitamente personagens de outros projetos (ex: "Bia", "AndrÃ©"). O Codex heartbeat acumula contexto entre sessÃµes â€” sem esse reset, personagens de HQs anteriores contaminam as novas.
13. **DocumentaÃ§Ã£o imediata:** toda melhoria de regra, padrÃ£o ou convenÃ§Ã£o aprovada nesta sessÃ£o deve ser registrada nos docs do repositÃ³rio antes de encerrar. Nenhuma melhoria fica apenas na memÃ³ria do Claude.
13. **ERROS.md obrigatÃ³rio:** consultar `ERROS.md` antes de gerar qualquer atividade. ContÃ©m bugs reais diagnosticados em produÃ§Ã£o com regras de prevenÃ§Ã£o.

---

## GamificaÃ§Ã£o â€” Sistema ativo

Sistema de cartas **temÃ¡ticas** prÃ³prias para a Lis. Ao concluir todas as atividades de um mÃ³dulo, a Lis recebe uma carta temÃ¡tica sorteada aleatoriamente â€” sem raridade, toda carta Ã© igualmente especial!

**Arquivo principal:** `shared/gamification.js`
**Assets de cartas:** `_landing/cartas/carta-fundo-[card_slug].png`
**Cartas disponÃ­veis:** abacaxi ðŸ Â· banana ðŸŒ Â· coraÃ§Ã£o â¤ï¸ Â· estrela â­ Â· kiwi ðŸ¥ Â· maÃ§Ã£ ðŸŽ Â· melancia ðŸ‰ Â· morango ðŸ“ Â· pÃªssego ðŸ‘ Â· uva ðŸ‡
**Assets de personagens:** `_landing/chars/[slug-personagem].png`
**Supabase:** credenciais em `SUBSTITUIR_URL_SUPABASE` / `SUBSTITUIR_CHAVE_PUBLICA` (Leo deve criar projeto separado do 5Âº ano)

### Snippet obrigatÃ³rio em todo HTML de atividade

Substituir o `<!-- gamificacao-btn -->` por este bloco completo (preencher os campos com `[COLCHETES]`):

```html
<!-- â”€â”€ GAMIFICAÃ‡ÃƒO â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"></script>
<script src="../../shared/gamification.js"></script>
<script>
(function () {
  var SUPA_URL      = 'https://mmtrzxmitklpibfilbio.supabase.co';
  var SUPA_KEY      = 'sb_publishable_ZgA70ikD1XRgEhxzz7aKzQ_TNSAsxQ_';
  var THEME_SLUG    = '[SLUG]';
  var DISCIPLINE    = '[disciplina]';        // ex: 'ciencias'
  var ACTIVITY_TYPE = '[tipo_atividade]';    // ex: 'quiz', 'memoria', 'completar'
  var TOTAL_ATIV    = [TOTAL_ATIVIDADES];    // nÃºmero inteiro
  var supa = supabase.createClient(SUPA_URL, SUPA_KEY);

  function abrirGamificacao() {
    supa.auth.getSession().then(function (result) {
      var uid = result.data.session ? result.data.session.user.id : 'anonimo';

      // Registra conclusÃ£o desta atividade
      supa.from('activity_log').insert({
        user_id: uid, discipline: DISCIPLINE,
        theme_slug: THEME_SLUG, activity_type: ACTIVITY_TYPE,
        score: typeof window.sabendoScore === 'number' ? window.sabendoScore : 0
      });

      SabendoGamification.run(supa, uid, THEME_SLUG, DISCIPLINE, {
        characterName:   '[NOME_PERSONAGEM]',
        characterEmoji:  '[EMOJI_PERSONAGEM]',
        characterImg:    'chars/[SLUG_PERSONAGEM].png',
        themeLabel:      '[TEMA] Â· [DISCIPLINA_LABEL]',
        totalActivities: TOTAL_ATIV,
        activityType:    ACTIVITY_TYPE,
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
  Coletar minha carta! ðŸƒ
</button>
<script src="../../shared/portal-back.js"></script>
</body>
```

### Reveal

Confete colorido (arco-Ã­ris) animado igual para todas as cartas. O glow/raios usam a `primaryColor` da disciplina do tema.

### glowRgb por disciplina

| Disciplina | glowRgb |
|---|---|
| CiÃªncias | `34,197,94` |
| PortuguÃªs | `232,67,10` |
| MatemÃ¡tica | `10,172,232` |
| HistÃ³ria | `168,85,247` |
| Geografia | `245,158,11` |

### PadrÃ£o window.sabendoScore â€” obrigatÃ³rio

```javascript
// âœ… CORRETO â€” setar junto com o resultado
function mostrarResultado() {
  var acertos = respostas.filter(function(r) { return r.correta; }).length;
  window.sabendoScore = Math.round((acertos / total) * 100);
  painelResultado.style.display = 'block';
}

// âŒ ERRADO â€” nunca incremental
function onAcerto() { acertos++; window.sabendoScore = ...; }
```

Para mapa mental e atividades sem score numÃ©rico: `window.sabendoScore = 100` na conclusÃ£o.
Para atividades com "Ver gabarito" independente: setar `window.sabendoScore` ANTES de exibir o gabarito.

> **AtenÃ§Ã£o (ERR-001 do 5Âº ano):** Nunca setar `window.sabendoScore` em funÃ§Ãµes intermediÃ¡rias.

### NavegaÃ§Ã£o de Volta ao Portal

**Nunca usar `onclick="window.close()"` em botÃµes de retorno.** Browsers modernos bloqueiam `window.close()` em abas abertas por links.

**PadrÃ£o obrigatÃ³rio:** todo botÃ£o/link "Voltar ao Portal" deve usar `onclick="voltarAoPortal()"`. O snippet acima jÃ¡ inclui `<script src="../../shared/portal-back.js"></script>` antes do `</body>`.

A funÃ§Ã£o (`shared/portal-back.js`) lÃª o tema ativo via `window.opener`, tenta fechar a aba e, como fallback, navega para `../../index.html#theme-{disc}-{slug}` â€” retornando direto ao tema correto.

---

## ReferÃªncias do Projeto

| Arquivo | PropÃ³sito |
|---|---|
| `ERROS.md` | **Consultar antes de gerar atividades** â€” bugs reais diagnosticados em produÃ§Ã£o |
| `referencias/temas-existentes.md` | Lista de temas jÃ¡ implementados (verificar conflito) |
| `referencias/contexto_projeto.md` | Contexto completo e estado atual do projeto |
| `referencias/SKILL-portal-educacional-2ano-ATUALIZADA.md` | Skill detalhada com templates e padrÃµes HTML |
| `referencias/hq-gerador-SKILL.md` | Skill de automaÃ§Ã£o de HQ via Chrome |
| `referencias/gamificacao-schema.md` | Schema Supabase do sistema de gamificaÃ§Ã£o (tabelas + RLS) |
| `shared/gamification.js` | Engine de gamificaÃ§Ã£o do 2Âº ano (raridade aleatÃ³ria, pixel reveal, reveal cinematogrÃ¡fico) |
| `shared/portal-back.js` | FunÃ§Ã£o `voltarAoPortal()` â€” retorna ao tema correto do portal sem depender de `window.close()` |
| `Personagens\2o ano\Lis.png` | ReferÃªncia visual canÃ´nica da protagonista (em pasta centralizada) |

