# SQUAD.md — Portal Educacional da Lis (2º Ano)

> Mapa organizacional do squad de produção de conteúdo.
> Última atualização: 2026-06-02

---

## Visão Geral

| Item | Valor |
|---|---|
| Projeto | Portal web educacional (SPA) da Lis, 7–8 anos, 2º ano do Ensino Fundamental |
| Repositório | `github.com/mottacastelo-ai/estudos-2ano` |
| Pasta local | `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano` |
| Hospedagem | GitHub Pages — deploy via `publicador-portal` (automático) |
| Aluna | Lis — menina de 7 anos, cabelos castanhos longos e ondulados |
| Responsável | Léo Motta |
| Ferramenta de HQ | Codex Desktop (contrato pending/done/error) |

---

## Arquitetura de Arquivos

```
estudos-2ano/
├── CLAUDE.md                        ← orquestrador e regras do projeto
├── SQUAD.md                         ← este arquivo
├── CONTEUDO.md                      ← inventário gerado por update-docs.py
├── index.html                       ← SPA do portal (fonte primária)
├── ref-viewer.html                  ← viewer auxiliar
├── ciencias/
│   ├── animais-ciclo-vida/          ← HQ p1–p4 + atividades HTML
│   ├── orgaos-sentidos/
│   ├── preservando-meio-ambiente/
│   └── onde-vivem-plantas/
│
├── geografia/
│   ├── representar-lugares/
│   └── paisagem-bairros/
│
├── historia/
│   ├── memorias-lugares/
│   ├── meu-lugar-viver/
│   ├── convivencia-pessoas/
│   ├── regras-convivencia/
│   └── mudancas-convivencia/
│
├── inputs/                          ← PDFs do livro (Léo salva aqui)
│
├── scripts/
│   └── update-docs.py               ← gera CONTEUDO.md automaticamente
│
├── referencias/
│   ├── temas-existentes.md
│   ├── contexto_projeto.md
│   ├── SKILL-portal-educacional-2ano-ATUALIZADA.md
│   └── hq-gerador-SKILL.md
│
└── .claude/
    ├── settings.json                ← Stop hook: executa update-docs.py
    ├── settings.local.json          ← permissões (não editar)
    ├── pending/                     ← JSON de pedido HQ (monitorado pelo Codex)
    ├── done/                        ← JSON movido pelo Codex após sucesso
    ├── error/                       ← JSON movido pelo Codex com error_message
    └── agents/
        ├── analisador-conteudo.md
        ├── criador-personagem.md
        ├── gerador-prompt-hq.md
        ├── gerador-atividades.md
        ├── atualizador-portal.md
        ├── verificador-entrega.md
        ├── gerador-imagens-hq.md
        ├── publicador-portal.md
        └── atualizador-docs.md      ← novo
```

---

## Agentes do Squad

| Agente | Modelo | Responsabilidade |
|---|---|---|
| `analisador-conteudo` | — | Lê PDF do livro didático, mapeia disciplinas e temas, propõe estrutura para aprovação de Léo |
| `criador-personagem` | — | Cria o personagem de suporte narrativo (metáfora visual do conteúdo) para o tema |
| `gerador-prompt-hq` | — | Gera `hq-[slug]-prompt.md` com prompts para geração de imagens via Codex Desktop (mín. 300 linhas) |
| `gerador-atividades` | — | Planeja e gera os arquivos HTML das atividades interativas (autocontidos, CSS+JS inline) |
| `atualizador-portal` | — | Edita `index.html` para integrar o novo tema (sidebar, tabs, theme-content, contadores) |
| `verificador-entrega` | — | Valida checklist completo e gera mensagem de conclusão — não cria nem edita arquivos |
| `gerador-imagens-hq` | claude-sonnet-4-6 | Escreve JSON de pedido em `.claude/pending/`; polling até Codex confirmar em `.claude/done/` |
| `publicador-portal` | — | Executa `git add + commit + push` para deploy no GitHub Pages |
| `atualizador-docs` | Haiku 4.5 | Regenera `CONTEUDO.md` lendo `index.html` como fonte primária; roda ao final do pipeline |

---

## Fluxo Principal

```
PDF (inputs/livro.pdf) → [analisador-conteudo] → Proposta → ⏸ APROVAÇÃO DE LÉO
                              ↓ (após aprovação — tudo automático a partir daqui)
                   ┌──────────────────────────┐
                   │  [criador-personagem]     │  ← em paralelo
                   │  [gerador-prompt-hq]      │  ← em paralelo
                   └──────────────────────────┘
                              ↓
                   [gerador-atividades]
                              ↓
                   [atualizador-portal]
                              ↓
                   [verificador-entrega]
                              ↓
                   [gerador-imagens-hq]   ← automático, sem gate
                              ↓
                   [publicador-portal]    ← git add + commit + push
                              ↓
                   [atualizador-docs]     ← regenera CONTEUDO.md
```

**Único ponto de parada:** após `analisador-conteudo` gerar a proposta estrutural, aguardar aprovação explícita de Léo. Após essa aprovação, todo o restante roda de forma autônoma até o deploy e a atualização do inventário.

---

## Regras Invioláveis do Sistema

1. Nenhum arquivo é gerado antes da aprovação de Léo na análise de escopo
2. Termos técnicos vêm exclusivamente do livro didático fotografado — nunca da HQ ou conhecimento geral
3. Balões da HQ: máximo 8 palavras por fala
4. Prompt de HQ: mínimo 300 linhas
5. HTMLs de atividade: autocontidos (CSS+JS inline), sem dependências externas além de Google Fonts
6. Imagem da HQ no viewer: sempre `object-fit: contain`, nunca `cover`
7. Viewer da HQ: sempre `touch-action: auto`, nunca `pan-y pinch-zoom`
8. Nunca adicionar `::before` com gradiente lateral no container do viewer da HQ
9. **Pré-requisito para HQ:** Codex Desktop aberto com a automação "Gerar HQs pendentes" ativa antes de iniciar o pipeline — canônicas em `Personagens\2o ano\`, sem ação manual de Léo

---

## Paleta de Cores por Disciplina

| Disciplina | Código CSS | Primária | Clara | Bg | Gradiente hero |
|---|---|---|---|---|---|
| Português | `port` | `#E8430A` | `#FB8C5A` | `#FFF4EF` | `135deg, #7A1F04, #E8430A 60%, #FB8C5A` |
| Matemática | `mat` | `#0AACE8` | `#5AC8FB` | `#EFF9FF` | `135deg, #044A7A, #0AACE8 60%, #5AC8FB` |
| Ciências | `cien` | `#22C55E` | `#6EE7A0` | `#F0FDF4` | `135deg, #14532D, #22C55E 60%, #6EE7A0` |
| História | `hist` | `#A855F7` | `#D08EF8` | `#FAF5FF` | `135deg, #4A1272, #A855F7 60%, #D08EF8` |
| Geografia | `geo` | `#F59E0B` | `#FCD34D` | `#FFFBEB` | `135deg, #78350F, #F59E0B 60%, #FCD34D` |

---

## Como Acionar

### Novo tema (fluxo completo)

Salve o PDF em `inputs/livro.pdf` e diga ao Orquestrador:

```
Novo conteúdo em inputs/livro.pdf — inicie o pipeline
```

### Apenas atualizar o inventário

```
Atualize o inventário do portal
```

O `atualizador-docs` será acionado diretamente, sem passar pelo pipeline completo.

### Verificar estado atual

Leia `CONTEUDO.md` na raiz — sempre reflete o último estado validado do portal.

---

## Arquitetura Futura Planejada

### Autenticação + Progresso via Supabase

O portal é atualmente uma SPA estática sem estado persistido. A evolução planejada inclui:

| Componente | Descrição |
|---|---|
| **Autenticação** | Login simplificado (ex: PIN ou magic link) para identificar a Lis no dispositivo |
| **Progresso** | Registro de atividades concluídas e pontuação por tema em tabela Supabase |
| **Dashboard** | Seção "Meu Progresso" na home com % de conclusão por disciplina |
| **Gamificação** | Conquistas desbloqueáveis por tema concluído (ex: emblemas por disciplina) |
| **Backend** | Supabase (PostgreSQL + Auth + Realtime) — sem servidor próprio |

> Nenhuma dessas funcionalidades existe no código atual. Esta seção registra a direção de produto para orientar decisões de design e naming ao criar novos temas.
