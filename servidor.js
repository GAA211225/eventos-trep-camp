// Servidor local de TREP CAMP — sin dependencias, solo Node.js
// Inicia con doble clic en INICIAR.bat (o: node servidor.js)
const http = require('http');
const fs = require('fs');
const path = require('path');
const os = require('os');

const PUERTO = 8123;
const CARPETA = __dirname;

const TIPOS = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
  '.md': 'text/plain; charset=utf-8',
};

const servidor = http.createServer((req, res) => {
  let ruta = decodeURIComponent(req.url.split('?')[0]);
  if (ruta === '/') ruta = '/index.html';

  const archivo = path.join(CARPETA, path.normalize(ruta));
  // Seguridad: no servir nada fuera de esta carpeta
  if (!archivo.startsWith(CARPETA)) {
    res.writeHead(403); res.end('Prohibido'); return;
  }

  fs.readFile(archivo, (err, datos) => {
    if (err) { res.writeHead(404); res.end('No encontrado'); return; }
    res.writeHead(200, {
      'Content-Type': TIPOS[path.extname(archivo).toLowerCase()] || 'application/octet-stream',
      'Cache-Control': 'no-cache',
    });
    res.end(datos);
  });
});

servidor.listen(PUERTO, '0.0.0.0', () => {
  console.log('==============================================');
  console.log('  TREP CAMP - Organizador de Eventos');
  console.log('==============================================');
  console.log('');
  console.log('  En esta computadora:');
  console.log(`    http://localhost:${PUERTO}`);
  console.log('');
  console.log('  Desde otros dispositivos en tu misma red Wi-Fi:');
  const redes = os.networkInterfaces();
  for (const nombre of Object.keys(redes)) {
    for (const red of redes[nombre]) {
      if (red.family === 'IPv4' && !red.internal) {
        console.log(`    http://${red.address}:${PUERTO}`);
      }
    }
  }
  console.log('');
  console.log('  La app NO es publica: solo se ve en tu red local.');
  console.log('  Deja esta ventana abierta mientras uses la app.');
  console.log('  Para detenerla, cierra esta ventana.');
  console.log('==============================================');
});
