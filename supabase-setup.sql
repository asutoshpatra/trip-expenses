-- Trip expenses: run this once in Supabase → SQL Editor → New query → Run.
-- It creates the tables, opens them to anyone with the page link,
-- turns on live updates, and creates a public "bills" storage bucket.

-- Tables ---------------------------------------------------------------
create table if not exists public.trips (
  id         text primary key,
  name       text not null,
  currency   text not null default 'USD',
  created_at timestamptz not null default now()
);

create table if not exists public.members (
  id         uuid primary key default gen_random_uuid(),
  trip_id    text not null references public.trips(id) on delete cascade,
  name       text not null check (char_length(name) between 1 and 40),
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id           uuid primary key default gen_random_uuid(),
  trip_id      text not null references public.trips(id) on delete cascade,
  description  text not null check (char_length(description) between 1 and 120),
  amount_cents integer not null check (amount_cents > 0),
  spent_on     date not null default current_date,
  paid_by      uuid not null references public.members(id),   -- blocks deleting a member who paid
  split        text not null check (split in ('equal', 'custom')),
  shares       jsonb not null,                                 -- { "<member id>": cents, ... }
  bill_path    text,
  bill_name    text,
  bill_type    text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

create index if not exists members_trip_idx  on public.members(trip_id);
create index if not exists expenses_trip_idx on public.expenses(trip_id);

-- Access: anyone with the link (the anon / publishable key) -------------
alter table public.trips    enable row level security;
alter table public.members  enable row level security;
alter table public.expenses enable row level security;

drop policy if exists "link access" on public.trips;
drop policy if exists "link access" on public.members;
drop policy if exists "link access" on public.expenses;

create policy "link access" on public.trips    for all to anon, authenticated using (true) with check (true);
create policy "link access" on public.members  for all to anon, authenticated using (true) with check (true);
create policy "link access" on public.expenses for all to anon, authenticated using (true) with check (true);

-- Live updates so everyone sees new expenses without reloading ---------
do $$
begin
  begin alter publication supabase_realtime add table public.trips;    exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.members;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.expenses; exception when duplicate_object then null; end;
end $$;

-- Bill photos and PDFs --------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('bills', 'bills', true, 10485760, array['image/jpeg', 'application/pdf'])
on conflict (id) do nothing;

drop policy if exists "bills read"   on storage.objects;
drop policy if exists "bills upload" on storage.objects;
drop policy if exists "bills delete" on storage.objects;

create policy "bills read"   on storage.objects for select to anon, authenticated using (bucket_id = 'bills');
create policy "bills upload" on storage.objects for insert to anon, authenticated with check (bucket_id = 'bills');
create policy "bills delete" on storage.objects for delete to anon, authenticated using (bucket_id = 'bills');

-- The Vermont trip -------------------------------------------------------
insert into public.trips (id, name, currency)
values ('vermont', 'Vermont trip', 'USD')
on conflict (id) do nothing;
