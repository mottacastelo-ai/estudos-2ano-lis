# Gamificação — Schema Supabase (2º Ano)

## Projeto Supabase

- **URL:** `https://mmtrzxmitklpibfilbio.supabase.co`
- **Chave pública:** `sb_publishable_ZgA70ikD1XRgEhxzz7aKzQ_TNSAsxQ_`
- **Auth:** email/password via `supa.auth.getSession()` — uid = `session.user.id`

---

## Tabelas

### `activity_log` e `streaks` — já existem no projeto

Gerenciadas pelo `index.html` via `logActivity()`. A gamificação lê `activity_log` para contar quantas `activity_type` distintas foram concluídas por tema (usada para o progresso do pixel reveal do personagem).

### `cards` — criar via SQL Editor ⬅ único passo pendente

Uma carta por usuário por tema. A carta temática é sorteada aleatoriamente na primeira conclusão total do módulo.

```sql
create table cards (
  user_id     text not null,
  theme_slug  text not null,
  discipline  text not null,
  card_slug   text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  primary key (user_id, theme_slug)
);

create index on cards (user_id);

alter table cards enable row level security;
create policy "allow all" on cards for all using (true) with check (true);
```

**Cartas disponíveis (`card_slug`):** `abacaxi` · `banana` · `coracao` · `estrela` · `kiwi` · `maca` · `melancia` · `morango` · `pessego` · `uva`

**Assets:** `_landing/cartas/carta-fundo-[card_slug].png`

---

## Diferenças em relação ao 5º ano

| Item | 5º Ano | 2º Ano |
|---|---|---|
| Carta | Baseada em raridade (score/performance) | Temática aleatória (frutas, coração, estrela) |
| Campo de carta | `rarity` (comum/rara/epica/lendaria) | `card_slug` (nome temático) |
| Tiers de reveal | Efeito varia por raridade | Confete colorido igual para todas |
| `reinforcement_queue` | Existe | **Não existe** |
| Auth | Email/password via Supabase | Email/password via Supabase (mesmo projeto `mmtrzxmitklpibfilbio`) |
