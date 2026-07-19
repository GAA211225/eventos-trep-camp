-- ============================================================
-- TREP CAMP — Migración 4: refuerzo de seguridad
-- 1) Los correos/perfiles solo los ve su dueño y el admin
-- 2) El autor de una observación lo fija el servidor (no se puede suplantar)
-- ============================================================

-- 1) Perfiles: cada quien ve el suyo; solo el admin ve todos
drop policy if exists "ver perfiles" on public.profiles;
create policy "ver perfiles" on public.profiles
  for select to authenticated using (id = auth.uid() or public.es_admin());

-- 2) Observaciones: autor_id, autor_nombre y autor_rol los pone el servidor
create or replace function public.fijar_autor_observacion() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  new.autor_id := auth.uid();
  select coalesce(nullif(p.nombre, ''), p.correo), p.rol
    into new.autor_nombre, new.autor_rol
    from profiles p where p.id = auth.uid();
  return new;
end;
$$;

drop trigger if exists trg_fijar_autor_obs on public.observaciones;
create trigger trg_fijar_autor_obs
  before insert on public.observaciones
  for each row execute function public.fijar_autor_observacion();
