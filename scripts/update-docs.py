#!/usr/bin/env python3
"""
update-docs.py — Portal da Lis (2º Ano)
Lê index.html como fonte primária, extrai todos os temas e atividades,
valida arquivos no filesystem e gera CONTEUDO.md na raiz do projeto.
"""

import re
import os
import sys
from datetime import date
from pathlib import Path

# ── Configuração ────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent.parent
INDEX_HTML = BASE_DIR / "index.html"
CONTEUDO_MD = BASE_DIR / "CONTEUDO.md"
PERSONAGENS_DIR = BASE_DIR / "Personagens" / "2o ano"

DISC_ORDER = ["port", "mat", "cien", "geo", "hist"]
DISC_META = {
    "port": {"emoji": "📝", "nome": "Português"},
    "mat":  {"emoji": "🔢", "nome": "Matemática"},
    "cien": {"emoji": "🔬", "nome": "Ciências"},
    "geo":  {"emoji": "🌍", "nome": "Geografia"},
    "hist": {"emoji": "📜", "nome": "História"},
}


def read_index():
    with open(INDEX_HTML, encoding="utf-8") as f:
        return f.read()


def extract_themes(html):
    """
    Extrai todos os blocos <div class="theme-content[...]" id="theme-DISC-SLUG">.
    Retorna lista de dicts: {disc, slug, block_html}
    """
    # Encontra todos os divs de tema
    pattern = re.compile(
        r'<div\s+class="theme-content[^"]*"\s+id="theme-([a-z]+)-([^"]+)"',
        re.IGNORECASE
    )
    matches = list(pattern.finditer(html))

    themes = []
    for i, m in enumerate(matches):
        disc = m.group(1)
        slug = m.group(2)
        start = m.start()
        # O bloco vai até o próximo tema ou fim do HTML
        end = matches[i + 1].start() if i + 1 < len(matches) else len(html)
        block = html[start:end]
        themes.append({"disc": disc, "slug": slug, "block": block})

    return themes


def detect_hq(theme):
    """
    Busca qualquer <img com src contendo -p1.png ou -pg1.png no bloco do tema.
    Verifica p1–p4 (e pg1–pg4) no filesystem.
    Retorna dict com info da HQ.
    """
    disc = theme["disc"]
    slug = theme["slug"]
    block = theme["block"]

    # Busca o src da página 1
    img_match = re.search(r'<img[^>]+src="([^"]*(?:-p1|-pg1)\.png)[^"]*"', block, re.IGNORECASE)
    if not img_match:
        return {"found": False}

    src_p1 = img_match.group(1)
    # Normaliza barras para Windows
    p1_path = BASE_DIR / src_p1.replace("/", os.sep)
    hq_filename = Path(src_p1).name

    # Detecta se usa sufixo -p ou -pg
    if "-pg1.png" in src_p1.lower():
        suffix_pattern = src_p1.replace("-pg1.png", "-pg{n}.png").replace("-Pg1.png", "-pg{n}.png")
    else:
        suffix_pattern = src_p1.replace("-p1.png", "-p{n}.png").replace("-P1.png", "-p{n}.png")

    pages_status = {}
    for n in range(1, 5):
        page_src = suffix_pattern.replace("{n}", str(n))
        page_path = BASE_DIR / page_src.replace("/", os.sep)
        pages_status[f"p{n}"] = page_path.exists()

    all_pages = all(pages_status.values())

    # Verifica prompt.md
    # Tenta achar hq-[slug]-prompt.md na pasta do tema
    folder = BASE_DIR / disc if disc in ["ciencias", "geografia", "historia"] else BASE_DIR
    # Determina pasta real a partir do src
    folder_from_src = BASE_DIR / "/".join(src_p1.split("/")[:-1])
    prompt_candidates = [
        folder_from_src / f"hq-{slug}-prompt.md",
        BASE_DIR / f"hq-{slug}-prompt.md",
    ]
    prompt_exists = any(p.exists() for p in prompt_candidates)

    return {
        "found": True,
        "filename": hq_filename,
        "src_p1": src_p1,
        "pages": pages_status,
        "all_pages": all_pages,
        "prompt_exists": prompt_exists,
    }


def extract_activities(theme):
    r"""
    Extrai todos os act-card do bloco do tema.
    Usa \s+ para separar atributos (evita o bug do \b com aspas).
    Retorna lista de dicts: {href, title, file_exists}
    """
    block = theme["block"]

    # Encontra todos os act-card com href
    card_pattern = re.compile(
        r'<a\s+class="act-card\s+[^"]*"\s+href="([^"]+)"',
        re.IGNORECASE
    )
    title_pattern = re.compile(
        r'<div\s+class="act-title"[^>]*>(.*?)</div>',
        re.IGNORECASE | re.DOTALL
    )

    cards = list(card_pattern.finditer(block))
    titles = [m.group(1).strip() for m in title_pattern.finditer(block)]

    activities = []
    for i, card in enumerate(cards):
        href = card.group(1)
        title = titles[i] if i < len(titles) else "(sem título)"
        # Remove tags HTML do título
        title = re.sub(r"<[^>]+>", "", title).strip()
        file_path = BASE_DIR / href.replace("/", os.sep)
        activities.append({
            "href": href,
            "title": title,
            "exists": file_path.exists(),
        })

    return activities


def get_personagens():
    """Lista imagens de personagens em Personagens/2o ano/"""
    if not PERSONAGENS_DIR.exists():
        return []
    imgs = [f.name for f in PERSONAGENS_DIR.iterdir()
            if f.suffix.lower() in (".png", ".jpg", ".jpeg", ".webp")]
    return sorted(imgs)


def build_conteudo(themes_by_disc):
    today = date.today().strftime("%Y-%m-%d")
    lines = []

    lines.append(f"# Inventário do Portal — Lis (2º Ano)")
    lines.append(f"")
    lines.append(f"> Gerado automaticamente por `scripts/update-docs.py` em {today}.")
    lines.append(f"> Fonte primária: `index.html`. Existência de arquivos validada no filesystem.")
    lines.append(f"")
    lines.append(f"---")
    lines.append(f"")

    # ── Tabela resumo ────────────────────────────────────────────────────────
    lines.append(f"## Resumo por Disciplina")
    lines.append(f"")
    lines.append(f"| Disciplina | Temas | Atividades | HQs completas |")
    lines.append(f"|---|---|---|---|")

    total_themes = 0
    total_acts = 0
    total_hqs = 0

    summary_rows = []
    for disc in DISC_ORDER:
        if disc not in themes_by_disc:
            continue
        meta = DISC_META[disc]
        t_list = themes_by_disc[disc]
        n_themes = len(t_list)
        n_acts = sum(len(t["activities"]) for t in t_list)
        n_hqs = sum(1 for t in t_list if t["hq"].get("all_pages"))
        total_themes += n_themes
        total_acts += n_acts
        total_hqs += n_hqs
        summary_rows.append((meta["emoji"], meta["nome"], n_themes, n_acts, n_hqs))

    for emoji, nome, nt, na, nh in summary_rows:
        lines.append(f"| {emoji} {nome} | {nt} | {na} | {nh}/{nt} |")

    lines.append(f"| **Total** | **{total_themes}** | **{total_acts}** | **{total_hqs}/{total_themes}** |")
    lines.append(f"")
    lines.append(f"---")
    lines.append(f"")

    # ── Seções por disciplina ────────────────────────────────────────────────
    for disc in DISC_ORDER:
        if disc not in themes_by_disc:
            continue
        meta = DISC_META[disc]
        t_list = themes_by_disc[disc]
        lines.append(f"## {meta['emoji']} {meta['nome']} (`{disc}`)")
        lines.append(f"")

        for theme_data in t_list:
            slug = theme_data["slug"]
            hq = theme_data["hq"]
            acts = theme_data["activities"]

            lines.append(f"### {slug}")
            lines.append(f"")

            # HQ
            if hq.get("found"):
                pages = hq["pages"]
                p_check = " · ".join(
                    f"{'✅' if pages.get(f'p{n}') else '❌'} p{n}" for n in range(1, 5)
                )
                prompt_status = "✅ prompt.md" if hq.get("prompt_exists") else "❌ prompt.md ausente"
                lines.append(f"**HQ:** `{hq['filename']}` — {p_check} | {prompt_status}")
            else:
                lines.append(f"**HQ:** ❌ não detectada (sem `<img` com `-p1.png`/`-pg1.png` no bloco)")
            lines.append(f"")

            # Atividades
            if acts:
                lines.append(f"**Atividades ({len(acts)}):**")
                lines.append(f"")
                for act in acts:
                    status = "✅" if act["exists"] else "❌"
                    lines.append(f"- {status} [{act['title']}]({act['href']})")
                lines.append(f"")
            else:
                lines.append(f"**Atividades:** ❌ nenhuma encontrada no bloco do tema")
                lines.append(f"")

        lines.append(f"---")
        lines.append(f"")

    # ── Personagens ──────────────────────────────────────────────────────────
    lines.append(f"## Personagens (`Personagens/2o ano/`)")
    lines.append(f"")
    imgs = get_personagens()
    if imgs:
        for img in imgs:
            lines.append(f"- {img}")
    else:
        lines.append(f"- *(pasta não encontrada ou vazia)*")
    lines.append(f"")
    lines.append(f"---")
    lines.append(f"")

    # ── Legenda ──────────────────────────────────────────────────────────────
    lines.append(f"## Legenda")
    lines.append(f"")
    lines.append(f"| Símbolo | Significado |")
    lines.append(f"|---|---|")
    lines.append(f"| ✅ | Arquivo existe no filesystem |")
    lines.append(f"| ❌ | Arquivo ausente ou não detectado |")
    lines.append(f"| p1–p4 | Páginas da HQ (PNG gerados pelo GPT Quadrinhos Sabendo) |")
    lines.append(f"| prompt.md | Arquivo de prompts da HQ na pasta do tema |")
    lines.append(f"")

    return "\n".join(lines)


def main():
    print(f"[update-docs] Lendo {INDEX_HTML} ...")
    html = read_index()

    print(f"[update-docs] Extraindo temas ...")
    raw_themes = extract_themes(html)

    themes_by_disc = {}
    for t in raw_themes:
        disc = t["disc"]
        if disc not in themes_by_disc:
            themes_by_disc[disc] = []
        hq = detect_hq(t)
        acts = extract_activities(t)
        themes_by_disc[disc].append({
            "slug": t["slug"],
            "hq": hq,
            "activities": acts,
        })

    # Estatísticas
    total_themes = sum(len(v) for v in themes_by_disc.values())
    total_acts = sum(len(t["activities"]) for v in themes_by_disc.values() for t in v)
    total_hqs = sum(1 for v in themes_by_disc.values() for t in v if t["hq"].get("all_pages"))

    print(f"[update-docs] Encontrados: {total_themes} temas, {total_acts} atividades, {total_hqs} HQs completas")
    for disc in DISC_ORDER:
        if disc in themes_by_disc:
            meta = DISC_META[disc]
            slugs = [t["slug"] for t in themes_by_disc[disc]]
            n_acts = sum(len(t["activities"]) for t in themes_by_disc[disc])
            print(f"  [{disc}] {meta['nome']}: {len(slugs)} tema(s), {n_acts} atividade(s) - {', '.join(slugs)}")

    print(f"[update-docs] Gerando {CONTEUDO_MD} ...")
    content = build_conteudo(themes_by_disc)
    with open(CONTEUDO_MD, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"[update-docs] CONTEUDO.md gerado com sucesso.")

    # Output JSON para integração com agentes
    import json
    result = {
        "status": "ok",
        "total_themes": total_themes,
        "total_activities": total_acts,
        "total_hqs_complete": total_hqs,
        "disciplines": {
            disc: {
                "themes": [t["slug"] for t in themes_by_disc[disc]],
                "activity_count": sum(len(t["activities"]) for t in themes_by_disc[disc]),
            }
            for disc in DISC_ORDER if disc in themes_by_disc
        },
    }
    print(f"[update-docs] JSON: {json.dumps(result, ensure_ascii=False)}")


if __name__ == "__main__":
    main()
