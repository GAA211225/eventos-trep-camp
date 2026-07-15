# TREP CAMP · Organizador de Eventos — Instrucciones

## 🌐 La app ya está publicada

- **Dirección de la app:** https://gaa211225.github.io/eventos-trep-camp/
- **Repositorio:** https://github.com/GAA211225/eventos-trep-camp
- Cualquier persona puede abrirla desde esa dirección e instalarla en su teléfono (ver sección 2). Recuerda: cada dispositivo guarda sus propios datos.
- **Para actualizar la app:** haz los cambios en esta carpeta y súbelos con `git add . && git commit -m "cambios" && git push` (GitHub Pages se actualiza solo en 1-2 minutos).

## Qué contiene esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La aplicación completa |
| `manifest.json` | Permite instalarla como app en teléfono/tableta/PC |
| `sw.js` | Hace que funcione sin internet y se actualice sola |
| `icon-192.png`, `icon-512.png` | Íconos de la app |

## ☁️ Cuentas, roles y datos en la nube (Supabase)

La app ahora guarda todo en la nube (Supabase) y tiene inicio de sesión con dos roles:

- **Ambassador**: pertenece a un Hub (estado). Crea y edita los eventos de su Hub, sube materiales, escribe guiones y usa el asistente de IA.
- **Asesor**: entra y ve la lista de los 32 Hubs. Puede abrir cualquiera, revisar sus eventos, leer notas y guiones y descargar materiales — pero no puede modificar ni agregar nada (bloqueado en pantalla y también en el servidor).

### Configuración inicial (una sola vez)

1. Crea una cuenta gratis en **https://supabase.com** → "New project" (elige nombre y contraseña de base de datos; región puede ser la más cercana).
2. En el proyecto: menú **SQL Editor** → "New query" → pega todo el contenido del archivo `supabase-setup.sql` → botón **Run**. Esto crea las tablas, los permisos y los 32 Hubs.
3. Menú **Settings → API**: copia la **Project URL** y la clave **anon public**, y pégalas al inicio del `<script>` de `index.html` (donde dice `PEGAR_AQUI…`). La clave "anon" está diseñada para ser pública, no pasa nada porque esté en el repositorio.
4. (Recomendado) Menú **Authentication → Sign In / Up → Email**: desactiva "Confirm email" para que la gente pueda entrar sin confirmar el correo.

### Administrar quién es quién

Cada persona se registra sola desde la app (nombre, correo y contraseña), pero entra como **pendiente** y no ve nada hasta que tú la actives:

1. En Supabase: menú **Table Editor** → tabla **profiles**.
2. Busca a la persona por su correo y edita su fila:
   - Columna **rol**: escribe `ambassador` o `asesor`.
   - Columna **hub_id**: solo para ambassadors — copia el `id` de su estado desde la tabla **hubs** y pégalo aquí. Los asesores lo dejan vacío.
3. La persona recarga la app y ya tiene acceso.

## 0. Usarla en local, sin publicar nada (recomendado si no quieres que sea pública)

- **Doble clic en `INICIAR.bat`** (necesita Node.js instalado, gratis en https://nodejs.org). Se abre la app en el navegador y en la ventana negra aparece también una dirección `http://192.168.x.x:8123` para abrirla desde otros dispositivos **de tu misma red Wi-Fi**. Nada de esto sale a internet.
- **Compartir con alguien de otra casa:** mándale esta carpeta completa (comprimida en ZIP, por WhatsApp/correo/USB). La otra persona la descomprime y hace doble clic en `index.html` (o en `INICIAR.bat` si tiene Node). Cada quien tiene su propia app con sus propios datos, todo local y privado.
- Ojo: los datos **no se comparten entre personas ni dispositivos** — cada copia guarda lo suyo. Los archivos que quieras pasarle a alguien (cronogramas, presentaciones) se descargan desde la app y se envían por el medio que prefieras.

## 1. Publicarla como página web (solo si algún día la quieres en internet)

Para usarla como página web e instalarla en el teléfono, hay que subir esta carpeta a un servicio gratuito de páginas web. La opción más fácil:

**Netlify (gratis):**
1. Entra a **https://app.netlify.com/drop**
2. Crea una cuenta gratuita (con tu correo de Google es un momento).
3. Arrastra **toda esta carpeta** a la zona de "Drop".
4. Te dará una dirección tipo `https://algo.netlify.app` — esa es tu app. Puedes cambiar el nombre en Site settings.

**Para actualizarla** (si cambias algo en los archivos): entra a tu sitio en Netlify → pestaña "Deploys" → arrastra la carpeta otra vez.

> También puedes usar GitHub Pages, Vercel o cualquier hosting de páginas estáticas.

## 2. Instalarla en el teléfono o tableta

1. Abre la dirección de tu app en el navegador del teléfono (Chrome en Android, Safari en iPhone/iPad).
2. **Android (Chrome):** menú ⋮ → "Agregar a pantalla de inicio" o "Instalar app".
3. **iPhone/iPad (Safari):** botón Compartir □↑ → "Agregar a pantalla de inicio".
4. Listo: aparece con su ícono como cualquier app.

En la computadora (Chrome/Edge) también: aparece un icono de "instalar" en la barra de direcciones.

## 3. Cómo funciona sin internet

- **Con internet:** la app descarga siempre la versión más reciente y puedes usar el asistente de IA.
- **Sin internet:** la app abre con la última versión descargada y puedes seguir creando eventos, escribiendo notas y guiones, subiendo archivos, etc.
- **Importante:** los datos (eventos, archivos, guiones) se guardan **en cada dispositivo**. Lo que agregues en el teléfono no aparece en la computadora y viceversa. El asistente de IA **solo** funciona con internet.

## 4. Activar el asistente de IA para guiones (gratis)

1. Consigue una clave gratuita de Google Gemini: entra a **https://aistudio.google.com** con tu cuenta de Google → botón **"Get API key"** → "Create API key". No pide tarjeta ni pago; el nivel gratuito alcanza de sobra para generar guiones.
2. En la app, pulsa el botón **⚙️** de la barra lateral, pega la clave y guarda.
3. En cualquier evento, botón **✨ Asistente IA** dentro de la sección Guión:
   - Si no hay guión, propone uno completo usando el nombre, fecha, lugar y notas del evento.
   - Si ya hay guión, propone una versión mejorada.
   - Puedes darle indicaciones ("que dure 5 minutos", "presentar al speaker X"...), pedir **otra versión**, y solo se reemplaza tu guión cuando pulsas **✔ Usar esta versión**.

La clave se guarda solo en tu dispositivo. En cada dispositivo donde instales la app tendrás que pegarla una vez.
