# Contexto do Projeto Educacional — Portal Interativo de Aprendizagem (Lis, 2º Ano)

**Última atualização:** 2026-05-22 (baseado no estado atual da pasta local)

> **Projeto irmão:** [Portal do André — 5º Ano](../../estudos/referencias/contexto_projeto.md) — mesma metodologia, stack técnico e workflow, mas personagens, cores e conteúdos distintos.

---

## Visão Geral

Portal web educacional construído como aplicação de página única (SPA) para o aprendizado da Lis (2º ano, 7–8 anos). Usa a mesma metodologia do portal do André: aprendizagem ativa (Roediger & Karpicke, 2006; Mayer, 2009) e Pirâmide de Glasser. As atividades são adaptadas à faixa etária — linguagem mais simples, balões com no máximo 8 palavras, cores mais vibrantes e saturadas.

- **Repositório:** [github.com/mottacastelo-ai/estudos-2ano](https://github.com/mottacastelo-ai/estudos-2ano)
- **Pasta local:** `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano`
- **Ferramenta de HQ:** GPT Quadrinhos Sabendo (`chatgpt.com/g/g-69ff2b40169881918c5f75a8d9767f30-gpt-quadrinhos-sabendo`)

---

## Infraestrutura Técnica

### Hospedagem & Deploy
- **Hospedagem:** GitHub Pages
- **Workflow de deploy:**
  1. Editar arquivos localmente
  2. Commit + push via GitHub Desktop (**manual**, ~30 segundos)
  3. GitHub Pages publica automaticamente após o push

### Estrutura de Arquivos

```
estudos-2ano/
├── index.html                      ← SPA principal
├── ref-viewer.html                 ← visualizador de referências de personagens
├── versao canonica lis.png         ← referência visual canônica da Lis
├── ciencias/
│   ├── orgaos-sentidos/
│   ├── animais-ciclo-vida/
│   ├── onde-vivem-plantas/
│   └── preservando-meio-ambiente/
├── historia/
│   ├── meu-lugar-viver/
│   ├── memorias-lugares/
│   └── convivencia-pessoas/
├── geografia/
│   ├── paisagem-bairros/
│   └── representar-lugares/
└── referencias/
    ├── contexto_projeto.md         ← este arquivo
    ├── temas-existentes.md
    ├── SKILL-portal-educacional-2ano-ATUALIZADA.md
    └── hq-gerador-SKILL.md
```

Cada subdiretório de tema contém: HQ (4 arquivos `.png` separados), atividades (`.html`) e prompt HQ (`.md`).

> **Diferença importante em relação ao portal do André:** as 4 páginas da HQ são mantidas como arquivos separados (`hq-[slug]-pg1.png` … `pg4.png`) — **não são coladas em um único arquivo**. O Cowork salva os arquivos em `[disciplina]/[slug]/` e Léo copia manualmente as imagens geradas para essa pasta antes do deploy.

---

## Estado Atual — Disciplinas e Temas

### 🔬 Ciências — 4 temas

| Tema | Slug |
|---|---|
| Órgãos dos Sentidos | `orgaos-sentidos` |
| Ciclo de Vida dos Animais | `animais-ciclo-vida` |
| Onde Vivem as Plantas | `onde-vivem-plantas` |
| Preservando o Meio Ambiente | `preservando-meio-ambiente` |

### 📜 História — 3 temas

| Tema | Slug |
|---|---|
| Meu Lugar de Viver | `meu-lugar-viver` |
| Memórias dos Lugares | `memorias-lugares` |
| Convivência com as Pessoas | `convivencia-pessoas` |

### 🗺️ Geografia — 2 temas

| Tema | Slug |
|---|---|
| Paisagem dos Bairros | `paisagem-bairros` |
| Representar Lugares | `representar-lugares` |

**Total atual: 3 disciplinas · 9 temas**

> Português e Matemática estão previstos na paleta de cores mas ainda não têm temas implementados.

---

## Personagens

### Protagonista (sempre presente)

**Lis** — menina de 7 anos, cabelos castanhos longos e ondulados, sorriso expressivo e aberto, estilo despojado. Curiosa, animada, levemente atrevida. Protagonista de todas as HQs.

### Personagens de suporte

*(a documentar progressivamente conforme novos temas forem criados)*

### Diretrizes para novos personagens

- Metáfora visual do conteúdo (animais falantes, objetos animados)
- Tom lúdico, acolhedor, levemente engraçado — adequado a 7 anos
- Expressões faciais exageradas para facilitar leitura emocional
- Cor e estilo dialogam com a paleta da disciplina
- Sempre interage com a Lis na HQ

---

## Paleta de Cores por Disciplina

| Disciplina | Código CSS | Cor primária | Cor clara | Bg |
|---|---|---|---|---|
| Português | `port` | `#E8430A` | `#FB8C5A` | `#FFF4EF` |
| Matemática | `mat` | `#0AACE8` | `#5AC8FB` | `#EFF9FF` |
| Ciências | `cien` | `#22C55E` | `#6EE7A0` | `#F0FDF4` |
| História | `hist` | `#A855F7` | `#D08EF8` | `#FAF5FF` |
| Geografia | `geo` | `#F59E0B` | `#FCD34D` | `#FFFBEB` |

> Cores deliberadamente distintas das do portal do André — mais vibrantes e saturadas para o público de 7–8 anos.

---

## Fundamentação Pedagógica

Idêntica ao portal do André: Retrieval practice (Roediger & Karpicke, 2006), Aprendizagem Multimídia (Mayer, 2009), Pirâmide de Glasser e gamificação (Plass, Homer & Kinzer, 2015).

**Adaptações para o 2º ano:**
- Balões com no máximo 8 palavras por fala
- Prompts de HQ com mínimo de 300 linhas (mais detalhados que os do 5º ano)
- Atividades com linguagem e complexidade adequadas a 7–8 anos
- Cada painel descrito com precisão: posição na grade, cenário, expressão facial, gesto, objetos

---

## Princípios Reitores

1. **Termos técnicos do livro são obrigatórios** — usar o nome exato (ex.: "metamorfose completa", não só "transformação").
2. **Proibido introduzir conteúdo fora do escopo das fotos** — nenhum conceito ausente nas fotos enviadas pode aparecer nas atividades.
3. **Variedade de tipos de atividade** — nenhum tipo deve se repetir entre temas da mesma disciplina.
4. **Qualidade sobre quantidade.**
5. **Narrativa contínua** — a Lis aparece em todas as HQs, criando coesão entre os temas.

---

## Workflow de Entrega (Cowork)

- O Cowork edita `index.html` diretamente e salva todos os arquivos em `[disciplina]/[slug]/`
- As imagens das HQs (`hq-[slug]-pg1.png` … `pg4.png`) são geradas por Léo no GPT Quadrinhos Sabendo e copiadas manualmente para a pasta do tema antes do deploy
- Fallback Claude.ai: ZIP com `index.html` completo já atualizado + todos os arquivos de atividade

---

## Contato & Manutenção

- **Responsável:** Léo Motta
- **Repositório:** github.com/mottacastelo-ai/estudos-2ano
- **Pasta local:** `C:\Users\wizar\OneDrive\Documentos\Projeto Estudos\estudos-2ano`
