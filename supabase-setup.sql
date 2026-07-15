-- ============================================================
-- TREP CAMP · Organizador de Eventos — Configuración de Supabase
-- Ejecutar UNA VEZ en: Supabase → SQL Editor → New query → pegar → Run
-- ============================================================

-- ---------- Tablas ----------

create table public.hubs (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text default '',
  correo text default '',
  -- pendiente: recién registrado, sin acceso hasta que el administrador le asigne rol
  rol text not null default 'pendiente' check (rol in ('pendiente', 'ambassador', 'asesor')),
  hub_id uuid references public.hubs(id)
);

create table public.eventos (
  id uuid primary key default gen_random_uuid(),
  hub_id uuid not null references public.hubs(id),
  nombre text default '',
  fecha date,
  hora_inicio text default '',
  hora_fin text default '',
  lugar text default '',
  notas text default '',
  guion text default '',
  creado_por uuid references public.profiles(id),
  actualizado_en timestamptz default now()
);

create table public.archivos (
  id uuid primary key default gen_random_uuid(),
  evento_id uuid not null references public.eventos(id) on delete cascade,
  hub_id uuid not null references public.hubs(id),
  categoria text not null,
  nombre text not null,
  tamano bigint,
  tipo text,
  ruta text not null,
  creado_en timestamptz default now()
);

-- ---------- Funciones de ayuda para permisos ----------

-- ¿El usuario actual ya tiene rol aprobado (ambassador o asesor)?
create function public.es_miembro() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from profiles p
    where p.id = auth.uid() and p.rol in ('ambassador', 'asesor')
  );
$$;

-- ¿El usuario actual es el ambassador de este hub?
create function public.es_ambassador_de(hub uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from profiles p
    where p.id = auth.uid() and p.rol = 'ambassador' and p.hub_id = hub
  );
$$;

-- ---------- Perfil automático al registrarse ----------

create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, nombre, correo)
  values (new.id, coalesce(new.raw_user_meta_data->>'nombre', ''), new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Seguridad por filas (RLS) ----------

alter table public.hubs enable row level security;
alter table public.profiles enable row level security;
alter table public.eventos enable row level security;
alter table public.archivos enable row level security;

-- Hubs: cualquier miembro aprobado puede verlos
create policy "ver hubs" on public.hubs
  for select to authenticated using (public.es_miembro());

-- Perfiles: cada quien ve el suyo; los miembros ven los demás (para mostrar nombres)
create policy "ver perfiles" on public.profiles
  for select to authenticated using (id = auth.uid() or public.es_miembro());

-- Eventos: los miembros ven todo; solo el ambassador del hub modifica
create policy "ver eventos" on public.eventos
  for select to authenticated using (public.es_miembro());
create policy "crear eventos" on public.eventos
  for insert to authenticated with check (public.es_ambassador_de(hub_id));
create policy "editar eventos" on public.eventos
  for update to authenticated using (public.es_ambassador_de(hub_id));
create policy "borrar eventos" on public.eventos
  for delete to authenticated using (public.es_ambassador_de(hub_id));

-- Archivos (metadatos): igual que eventos
create policy "ver archivos" on public.archivos
  for select to authenticated using (public.es_miembro());
create policy "crear archivos" on public.archivos
  for insert to authenticated with check (public.es_ambassador_de(hub_id));
create policy "borrar archivos" on public.archivos
  for delete to authenticated using (public.es_ambassador_de(hub_id));

-- ---------- Almacenamiento de archivos ----------

insert into storage.buckets (id, name, public) values ('archivos', 'archivos', false);

-- Los archivos se guardan como: {hub_id}/{evento_id}/{archivo}
create policy "leer archivos storage" on storage.objects
  for select to authenticated
  using (bucket_id = 'archivos' and public.es_miembro());
create policy "subir archivos storage" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'archivos' and public.es_ambassador_de(((storage.foldername(name))[1])::uuid));
create policy "borrar archivos storage" on storage.objects
  for delete to authenticated
  using (bucket_id = 'archivos' and public.es_ambassador_de(((storage.foldername(name))[1])::uuid));

-- ---------- Los 32 Hubs (estados de México) ----------

insert into public.hubs (nombre) values
  ('Aguascalientes'), ('Baja California'), ('Baja California Sur'), ('Campeche'),
  ('Chiapas'), ('Chihuahua'), ('Ciudad de México'), ('Coahuila'),
  ('Colima'), ('Durango'), ('Estado de México'), ('Guanajuato'),
  ('Guerrero'), ('Hidalgo'), ('Jalisco'), ('Michoacán'),
  ('Morelos'), ('Nayarit'), ('Nuevo León'), ('Oaxaca'),
  ('Puebla'), ('Querétaro'), ('Quintana Roo'), ('San Luis Potosí'),
  ('Sinaloa'), ('Sonora'), ('Tabasco'), ('Tamaulipas'),
  ('Tlaxcala'), ('Veracruz'), ('Yucatán'), ('Zacatecas');
