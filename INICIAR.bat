@echo off
title TREP CAMP - Organizador de Eventos
cd /d "%~dp0"
start "" http://localhost:8123
node servidor.js
pause
