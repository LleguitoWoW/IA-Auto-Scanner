@echo off
title IA Auto-Scanner
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Iniciar_IA.ps1"
