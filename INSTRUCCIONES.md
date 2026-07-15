# TREP CAMP · Organizador de Eventos — Instrucciones

## Qué contiene esta carpeta

| Archivo | Para qué sirve |
|---|---|
| `index.html` | La aplicación completa |
| `manifest.json` | Permite instalarla como app en teléfono/tableta/PC |
| `sw.js` | Hace que funcione sin internet y se actualice sola |
| `icon-192.png`, `icon-512.png` | Íconos de la app |

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

## 4. Activar el asistente de IA para guiones

1. Consigue una clave API de Claude: entra a **https://platform.claude.com** → crea una cuenta → sección **API Keys** → "Create key". (Requiere agregar un método de pago; se cobra por uso, cada guión cuesta unos pocos centavos.)
2. En la app, pulsa el botón **⚙️** de la barra lateral, pega la clave y guarda.
3. En cualquier evento, botón **✨ Asistente IA** dentro de la sección Guión:
   - Si no hay guión, propone uno completo usando el nombre, fecha, lugar y notas del evento.
   - Si ya hay guión, propone una versión mejorada.
   - Puedes darle indicaciones ("que dure 5 minutos", "presentar al speaker X"...), pedir **otra versión**, y solo se reemplaza tu guión cuando pulsas **✔ Usar esta versión**.

La clave se guarda solo en tu dispositivo. En cada dispositivo donde instales la app tendrás que pegarla una vez.
