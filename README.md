# IA Auto-Scanner

**English** | [Español](#ia-auto-scanner-español)

---

## What is this?

**IA Auto-Scanner** is a small local web panel that makes it easy to run [llamafile](https://github.com/mozilla-ai/llamafile) models on Windows.

Instead of manually editing a `.bat` file every time you want to switch models, this tool:

- Automatically detects all `.gguf` models in a `Models` folder
- Shows a clean dark web interface to select and launch them
- Lets you start / stop the model server with one click
- Opens the official llamafile chat UI
- Supports **English** and **Spanish**

Perfect if you keep multiple local AI models and want a simple way to switch between them.

---

## Features

- Auto-scan of `.gguf` files (including subfolders)
- One-click start / stop of the llamafile server
- Direct link to the llamafile web chat (`http://127.0.0.1:8080`)
- Language switcher (ES / EN)
- Built-in instructions with links to download llamafile and models
- No installation required — just run the `.bat`

---

## Project structure

```
Your folder/
├── Iniciar IA.bat          # Double-click to start
├── Iniciar_IA.ps1          # Main script
├── llamafile.exe           # You must download & rename this
└── Models/
    ├── model-a.gguf
    ├── model-b.gguf
    └── ...
```

---

## How to use

### 1. Get llamafile
1. Go to [mozilla-ai/llamafile releases](https://github.com/mozilla-ai/llamafile/releases)
2. Download the Windows build (`llamafile-x.xx.x`)
3. Rename it to `llamafile.exe` and place it next to the scripts

### 2. Get models
1. Go to [Hugging Face Models](https://huggingface.co/models)
2. Search for models in **`.gguf`** format
3. Download them and put the `.gguf` files inside the `Models` folder  
   (extract first if they come compressed)

### 3. Run
1. Double-click `Iniciar IA.bat`
2. A browser tab will open with the panel
3. Select a model → click **START SERVER**
4. Click **OPEN LLAMA INTERFACE** to chat

---

## Buttons

| Button | Action |
|--------|--------|
| **START SERVER** | Launches the selected model with llamafile |
| **OPEN LLAMA INTERFACE** | Opens `http://127.0.0.1:8080` |
| **STOP MODEL** | Kills the running llamafile process |

---

## Requirements

- Windows
- PowerShell (comes with Windows)
- A modern browser (Chrome, Edge, Firefox…)

---

## Notes

- The control panel runs on `http://localhost:8765`
- The llamafile chat UI runs on `http://127.0.0.1:8080`
- Switching models automatically stops the previous one
- The `Models` folder is created automatically if it doesn't exist

---

<br>

# IA Auto-Scanner (Español)

**Español** | [English](#ia-auto-scanner)

---

## ¿Qué es esto?

**IA Auto-Scanner** es un pequeño panel web local que facilita el uso de modelos [llamafile](https://github.com/mozilla-ai/llamafile) en Windows.

En lugar de editar un archivo `.bat` cada vez que quieres cambiar de modelo, esta herramienta:

- Detecta automáticamente todos los modelos `.gguf` de la carpeta `Models`
- Muestra una interfaz web oscura y limpia para seleccionarlos y lanzarlos
- Permite iniciar y apagar el servidor del modelo con un solo clic
- Abre la interfaz de chat oficial de llamafile
- Soporta **Español** e **Inglés**

Ideal si tienes varios modelos de IA locales y quieres cambiar entre ellos de forma sencilla.

---

## Características

- Escaneo automático de archivos `.gguf` (incluye subcarpetas)
- Inicio / apagado del servidor llamafile con un clic
- Enlace directo a la interfaz de chat de llamafile (`http://127.0.0.1:8080`)
- Selector de idioma (ES / EN)
- Instrucciones integradas con enlaces para descargar llamafile y modelos
- No requiere instalación — solo ejecuta el `.bat`

---

## Estructura del proyecto

```
Tu carpeta/
├── Iniciar IA.bat          # Doble clic para arrancar
├── Iniciar_IA.ps1          # Script principal
├── llamafile.exe           # Debes descargarlo y renombrarlo
└── Models/
    ├── modelo-a.gguf
    ├── modelo-b.gguf
    └── ...
```

---

## Cómo usarlo

### 1. Obtener llamafile
1. Entra en [mozilla-ai/llamafile releases](https://github.com/mozilla-ai/llamafile/releases)
2. Descarga la versión para Windows (`llamafile-x.xx.x`)
3. Renómbralo a `llamafile.exe` y colócalo junto a los scripts

### 2. Obtener modelos
1. Entra en [Hugging Face Models](https://huggingface.co/models)
2. Busca modelos en formato **`.gguf`**
3. Descárgalos y guarda los archivos `.gguf` dentro de la carpeta `Models`  
   (descomprime antes si vienen comprimidos)

### 3. Ejecutar
1. Haz doble clic en `Iniciar IA.bat`
2. Se abrirá una pestaña del navegador con el panel
3. Selecciona un modelo → pulsa **INICIAR SERVIDOR**
4. Pulsa **ABRIR INTERFAZ LLAMA** para chatear

---

## Botones

| Botón | Acción |
|-------|--------|
| **INICIAR SERVIDOR** | Lanza el modelo seleccionado con llamafile |
| **ABRIR INTERFAZ LLAMA** | Abre `http://127.0.0.1:8080` |
| **APAGAR MODELO** | Cierra el proceso de llamafile en ejecución |

---

## Requisitos

- Windows
- PowerShell (incluido en Windows)
- Un navegador moderno (Chrome, Edge, Firefox…)

---

## Notas

- El panel de control corre en `http://localhost:8765`
- La interfaz de chat de llamafile corre en `http://127.0.0.1:8080`
- Al cambiar de modelo se cierra automáticamente el anterior
- La carpeta `Models` se crea sola si no existe
