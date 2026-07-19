-- ============================================================
-- TREP CAMP — Migración 3: admin puede editar todo + Hub elegido al registrarse
-- Ejecutar UNA VEZ en: Supabase → SQL Editor → New query → pegar → Run
-- ============================================================

-- 1) El registro guarda el Hub elegido por la persona
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, nombre, correo, hub_id)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nombre', ''),
    new.email,
    nullif(new.raw_user_meta_data->>'hub_id', '')::uuid
  );
  return new;
end;
$$;

-- 2) La lista de Hubs es visible sin iniciar sesión (para el formulario de registro).
--    Solo son los nombres de los 32 estados, nada sensible.
drop policy if exists "ver hubs" on public.hubs;
create policy "ver hubs" on public.hubs
  for select to anon, authenticated using (true);

-- 3) El admin puede editar eventos y archivos de cualquier Hub
create or replace function public.puede_editar_evento(p_evento uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select public.es_admin()
      or exists(select 1 from eventos e where e.id = p_evento and public.es_ambassador_de(e.hub_id))
      or public.es_ambassador_colaborador(p_evento);
$$;

drop policy if exists "crear eventos" on public.eventos;
create policy "crear eventos" on public.eventos
  for insert to authenticated with check (public.es_ambassador_de(hub_id) or public.es_admin());
drop policy if exists "borrar eventos" on public.eventos;
create policy "borrar eventos" on public.eventos
  for delete to authenticated using (public.es_ambassador_de(hub_id) or public.es_admin());

drop policy if exists "crear colaboradores" on public.evento_colaboradores;
create policy "crear colaboradores" on public.evento_colaboradores
  for insert to authenticated
  with check (public.es_admin() or public.es_ambassador_de((select hub_id from eventos where id = evento_id)));
drop policy if exists "borrar colaboradores" on public.evento_colaboradores;
create policy "borrar colaboradores" on public.evento_colaboradores
  for delete to authenticated
  using (public.es_admin() or public.es_ambassador_de((select hub_id from eventos where id = evento_id)));
