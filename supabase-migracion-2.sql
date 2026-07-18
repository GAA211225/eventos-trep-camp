-- ============================================================
-- TREP CAMP — Migración 2: admin, colaboración entre Hubs y observaciones
-- Ejecutar UNA VEZ en: Supabase → SQL Editor → New query → pegar → Run
-- (Solo si ya corriste supabase-setup.sql antes. Añade lo nuevo, no borra nada.)
-- ============================================================

-- ---------- Rol de administrador ----------

alter table public.profiles drop constraint if exists profiles_rol_check;
alter table public.profiles add constraint profiles_rol_check
  check (rol in ('pendiente', 'ambassador', 'asesor', 'admin'));

create or replace function public.es_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from profiles p where p.id = auth.uid() and p.rol = 'admin');
$$;

-- Los administradores también cuentan como miembros aprobados
create or replace function public.es_miembro() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from profiles p
    where p.id = auth.uid() and p.rol in ('ambassador', 'asesor', 'admin')
  );
$$;

-- Un admin puede ver y modificar los perfiles (asignar rol y hub)
drop policy if exists "admin edita perfiles" on public.profiles;
create policy "admin edita perfiles" on public.profiles
  for update to authenticated using (public.es_admin()) with check (public.es_admin());

-- ---------- Colaboración entre Hubs ----------

alter table public.eventos add column if not exists es_colaboracion boolean default false;

create table if not exists public.evento_colaboradores (
  evento_id uuid not null references public.eventos(id) on delete cascade,
  hub_id uuid not null references public.hubs(id),
  primary key (evento_id, hub_id)
);
alter table public.evento_colaboradores enable row level security;

-- ¿El usuario es ambassador de algún hub colaborador de este evento?
create or replace function public.es_ambassador_colaborador(p_evento uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(
    select 1 from profiles p
    join evento_colaboradores c on c.hub_id = p.hub_id
    where p.id = auth.uid() and p.rol = 'ambassador' and c.evento_id = p_evento
  );
$$;

-- ¿El usuario puede editar este evento? (ambassador organizador O ambassador colaborador)
create or replace function public.puede_editar_evento(p_evento uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from eventos e where e.id = p_evento and public.es_ambassador_de(e.hub_id))
      or public.es_ambassador_colaborador(p_evento);
$$;

-- Eventos visibles en un Hub: los que organiza + los que colabora
create or replace function public.eventos_de_hub(p_hub uuid)
returns setof public.eventos
language sql stable security definer set search_path = public as $$
  select e.* from public.eventos e
  where public.es_miembro()
    and (e.hub_id = p_hub
         or exists (select 1 from evento_colaboradores c where c.evento_id = e.id and c.hub_id = p_hub))
  order by e.fecha desc nulls last;
$$;

-- Políticas de la tabla de colaboradores
drop policy if exists "ver colaboradores" on public.evento_colaboradores;
create policy "ver colaboradores" on public.evento_colaboradores
  for select to authenticated using (public.es_miembro());
drop policy if exists "crear colaboradores" on public.evento_colaboradores;
create policy "crear colaboradores" on public.evento_colaboradores
  for insert to authenticated
  with check (public.es_ambassador_de((select hub_id from eventos where id = evento_id)));
drop policy if exists "borrar colaboradores" on public.evento_colaboradores;
create policy "borrar colaboradores" on public.evento_colaboradores
  for delete to authenticated
  using (public.es_ambassador_de((select hub_id from eventos where id = evento_id)));

-- Editar eventos: ahora también los colaboradores
drop policy if exists "editar eventos" on public.eventos;
create policy "editar eventos" on public.eventos
  for update to authenticated using (public.puede_editar_evento(id));

-- ---------- Archivos: permiso por evento (permite a colaboradores subir) ----------

drop policy if exists "crear archivos" on public.archivos;
create policy "crear archivos" on public.archivos
  for insert to authenticated with check (public.puede_editar_evento(evento_id));
drop policy if exists "borrar archivos" on public.archivos;
create policy "borrar archivos" on public.archivos
  for delete to authenticated using (public.puede_editar_evento(evento_id));

-- Almacenamiento: la ruta ahora empieza con el id del evento
drop policy if exists "subir archivos storage" on storage.objects;
create policy "subir archivos storage" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'archivos' and public.puede_editar_evento(((storage.foldername(name))[1])::uuid));
drop policy if exists "borrar archivos storage" on storage.objects;
create policy "borrar archivos storage" on storage.objects
  for delete to authenticated
  using (bucket_id = 'archivos' and public.puede_editar_evento(((storage.foldername(name))[1])::uuid));

-- ---------- Observaciones (retroalimentación del asesor) ----------

create table if not exists public.observaciones (
  id uuid primary key default gen_random_uuid(),
  evento_id uuid not null references public.eventos(id) on delete cascade,
  autor_id uuid references public.profiles(id),
  autor_nombre text default '',
  autor_rol text default '',
  texto text not null,
  creado_en timestamptz default now()
);
alter table public.observaciones enable row level security;

drop policy if exists "ver observaciones" on public.observaciones;
create policy "ver observaciones" on public.observaciones
  for select to authenticated using (public.es_miembro());
drop policy if exists "crear observaciones" on public.observaciones;
create policy "crear observaciones" on public.observaciones
  for insert to authenticated with check (public.es_miembro() and autor_id = auth.uid());
drop policy if exists "borrar observaciones" on public.observaciones;
create policy "borrar observaciones" on public.observaciones
  for delete to authenticated using (autor_id = auth.uid() or public.es_admin());

-- ============================================================
-- IMPORTANTE: conviértete en administrador (cambia el correo por el tuyo)
-- Descomenta la línea siguiente, pon tu correo y ejecútala:
-- update public.profiles set rol = 'admin' where correo = 'TU_CORREO@ejemplo.com';
-- ============================================================
