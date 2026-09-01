# IA Auto-Scanner

**English** | [Español](#ia-auto-scanner-español)

---

## What is this?

**IA Auto-Scanner** is a small local web panel that makes it easy to run [llamafile](https://github.com/mozilla-ai/llamafile) models on Windows.

Instead of manually editing a `.bat` file every time you want to switch models, this tool:

- Automatically detects all `.gguf` models in a `Models` folder
- Shows a modern dark web interface to select and launch them
- Lets you start / stop the model server with one click
- Opens the official llamafile chat UI
- Supports **English** and **Spanish**
- Includes an **advanced server configuration panel** (GPU layers, context size, flash attention, speculative decoding, etc.)

Perfect if you keep multiple local AI models and want a simple way to switch between them and tune performance.

---

## Features

- Auto-scan of `.gguf` files (including subfolders)
- One-click start / stop of the llamafile server
- Direct link to the llamafile web chat
- Language switcher (ES / EN)
- Modern glassmorphism UI
- **Configurable llamafile parameters from the web panel**
- Built-in help with links to download llamafile and models
- No installation required — just run the `.bat`

---

## Project structure

```
Your folder/
├── Iniciar IA.bat          # Double-click to start
├── Iniciar_IA.ps1          # Main script
├── llamafile.exe           # Download & rename from releases
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
3. Rename it to **`llamafile.exe`** and place it next to the scripts

### 2. Get models
1. Go to [Hugging Face Models](https://huggingface.co/models)
2. Search for models in **`.gguf`** format
3. Put the `.gguf` files inside the `Models` folder (extract first if compressed)

### 3. Run
1. Double-click `Iniciar IA.bat`
2. The control panel opens in your browser (`http://localhost:8765`)
3. Select a model → optionally open **Server configuration (advanced)** → click **START SERVER**
4. Click **OPEN LLAMA** to open the chat UI

---

## Buttons

| Button | Action |
|--------|--------|
| **START SERVER** | Launches the selected model with the current settings |
| **OPEN LLAMA** | Opens the chat UI (default `http://127.0.0.1:8080`) |
| **STOP MODEL** | Stops the running llamafile process |
| **Server configuration** | Shows / hides advanced parameters |

---

## Advanced server parameters

You can edit these from the web panel (or as defaults at the top of `Iniciar_IA.ps1`).

| Parameter | Default | What it does |
|-----------|---------|--------------|
| **n-gpu-layers** | 99 | How many model layers go to the GPU. 99 = almost all. Lower if you run out of VRAM. |
| **ctx-size** | 131072 | Context window in tokens. 128K uses a lot of RAM/VRAM. Prefer 8192-32768 for speed. |
| **cache-type-k** | q4_0 | Attention K cache format. `q4_0` saves VRAM with little quality loss. |
| **cache-type-v** | q4_0 | Attention V cache format (same idea as K). |
| **flash-attn** | on | Flash Attention: faster and lower memory. Keep `on` if your GPU supports it. |
| **parallel** | 1 | Parallel requests. `1` = one conversation (more stable, less VRAM). |
| **host** | 127.0.0.1 | IP where the model server listens (local only). |
| **port** | 8080 | Port of the llamafile chat UI. |
| **spec-type** | ngram-mod | Speculative decoding type (can speed up generation). Leave empty if unsupported. |
| **spec n-match** | 24 | Tokens that must match to accept a speculation. |
| **spec n-min** | 48 | Minimum n-gram size. |
| **spec n-max** | 64 | Maximum n-gram size. |
| **reasoning** | on | Step-by-step reasoning mode (if the model supports it). Turn `off` for faster replies. |

### If the model feels slow

Try this profile in the config panel:

- **ctx-size** → `8192` (or `16384`)
- **reasoning** → `off`
- **spec-type** → empty
- **n-gpu-layers** → `99` (or lower if VRAM is limited)
- **flash-attn** → `on`
- **parallel** → `1`

Then **STOP MODEL** and **START SERVER** again.

> Note: Some speculative-decoding flags may not exist in every llamafile version. If startup fails, clear `spec-type` and related fields.

---

## Requirements

- Windows
- PowerShell (included with Windows)
- A modern browser (Chrome, Edge, Firefox)
- Optional but recommended: NVIDIA GPU with enough VRAM for your model

---

## Notes

- Control panel: `http://localhost:8765`
- Chat UI: `http://127.0.0.1:8080` (or whatever host/port you set)
- Switching models automatically stops the previous one
- The `Models` folder is created automatically if missing
- Always rename the binary to `llamafile.exe` so updates are easy

---

<br>

# IA Auto-Scanner (Español)

**Español** | [English](#ia-auto-scanner)

---

## ¿Qué es esto?

**IA Auto-Scanner** es un pequeño panel web local que facilita el uso de modelos [llamafile](https://github.com/mozilla-ai/llamafile) en Windows.

En lugar de editar un `.bat` cada vez que cambias de modelo, esta herramienta:

- Detecta automáticamente todos los `.gguf` de la carpeta `Models`
- Muestra una interfaz web moderna y oscura para elegirlos y lanzarlos
- Permite iniciar y apagar el servidor con un clic
- Abre la interfaz de chat de llamafile
- Soporta **Español** e **Inglés**
- Incluye un **panel de configuración avanzada** (capas GPU, contexto, flash attention, speculative decoding, etc.)

Ideal si tienes varios modelos locales y quieres cambiar entre ellos y ajustar el rendimiento fácilmente.

---

## Características

- Escaneo automático de `.gguf` (incluye subcarpetas)
- Inicio / apagado del servidor llamafile con un clic
- Enlace directo a la interfaz de chat
- Selector de idioma (ES / EN)
- Interfaz moderna tipo glassmorphism
- **Parámetros de llamafile configurables desde el panel web**
- Ayuda integrada con enlaces de descarga
- Sin instalación: solo ejecuta el `.bat`

---

## Estructura del proyecto

```
Tu carpeta/
├── Iniciar IA.bat          # Doble clic para arrancar
├── Iniciar_IA.ps1          # Script principal
├── llamafile.exe           # Descargar y renombrar desde releases
└── Models/
    ├── modelo-a.gguf
    ├── modelo-b.gguf
    └── ...
```

---

## Cómo usarlo

### 1. Obtener llamafile
1. Entra en [mozilla-ai/llamafile releases](https://github.com/mozilla-ai/llamafile/releases)
2. Descarga la versión Windows (`llamafile-x.xx.x`)
3. Renómbralo a **`llamafile.exe`** y colócalo junto a los scripts

### 2. Obtener modelos
1. Entra en [Hugging Face Models](https://huggingface.co/models)
2. Busca modelos en formato **`.gguf`**
3. Guarda los `.gguf` dentro de la carpeta `Models` (descomprime antes si hace falta)

### 3. Ejecutar
1. Haz doble clic en `Iniciar IA.bat`
2. Se abre el panel en el navegador (`http://localhost:8765`)
3. Elige un modelo → opcionalmente abre **Configuración del servidor (avanzado)** → pulsa **INICIAR SERVIDOR**
4. Pulsa **ABRIR LLAMA** para entrar al chat

---

## Botones

| Botón | Acción |
|-------|--------|
| **INICIAR SERVIDOR** | Lanza el modelo con la configuración actual |
| **ABRIR LLAMA** | Abre la interfaz de chat (por defecto `http://127.0.0.1:8080`) |
| **APAGAR MODELO** | Cierra el proceso de llamafile |
| **Configuración del servidor** | Muestra / oculta los parámetros avanzados |

---

## Parámetros avanzados del servidor

Se pueden editar desde el panel web (o como valores por defecto al inicio de `Iniciar_IA.ps1`).

| Parámetro | Por defecto | Para qué sirve |
|-----------|-------------|----------------|
| **n-gpu-layers** | 99 | Capas del modelo en la GPU. 99 = casi todo. Bájalo si te quedas sin VRAM. |
| **ctx-size** | 131072 | Tamaño de contexto en tokens. 128K usa mucha RAM/VRAM. Para ir rápido usa 8192-32768. |
| **cache-type-k** | q4_0 | Formato de caché K de atención. `q4_0` ahorra VRAM con poca pérdida de calidad. |
| **cache-type-v** | q4_0 | Formato de caché V (igual idea que K). |
| **flash-attn** | on | Flash Attention: más velocidad y menos memoria. Déjalo en `on` si tu GPU lo soporta. |
| **parallel** | 1 | Peticiones en paralelo. `1` = una sola conversación (más estable, menos VRAM). |
| **host** | 127.0.0.1 | IP donde escucha el servidor del modelo (solo local). |
| **port** | 8080 | Puerto de la interfaz de chat de llamafile. |
| **spec-type** | ngram-mod | Speculative decoding (puede acelerar). Déjalo vacío si no está soportado. |
| **spec n-match** | 24 | Tokens que deben coincidir para aceptar la predicción. |
| **spec n-min** | 48 | Tamaño mínimo del n-grama. |
| **spec n-max** | 64 | Tamaño máximo del n-grama. |
| **reasoning** | on | Modo de razonamiento paso a paso (si el modelo lo soporta). Pon `off` para respuestas más rápidas. |

### Si la IA va lenta

Prueba este perfil en la configuración:

- **ctx-size** → `8192` (o `16384`)
- **reasoning** → `off`
- **spec-type** → vacío
- **n-gpu-layers** → `99` (o menos si hay poca VRAM)
- **flash-attn** → `on`
- **parallel** → `1`

Luego **APAGAR MODELO** e **INICIAR SERVIDOR** otra vez.

> Nota: algunos flags de speculative decoding no existen en todas las versiones de llamafile. Si falla el arranque, vacía `spec-type` y los campos relacionados.

---

## Requisitos

- Windows
- PowerShell (incluido en Windows)
- Navegador moderno (Chrome, Edge, Firefox)
- Recomendado: GPU NVIDIA con VRAM suficiente para tu modelo

---

## Notas

- Panel de control: `http://localhost:8765`
- Interfaz de chat: `http://127.0.0.1:8080` (o el host/puerto que configures)
- Al cambiar de modelo se cierra automáticamente el anterior
- La carpeta `Models` se crea sola si no existe
- Renombra siempre el binario a `llamafile.exe` para facilitar las actualizaciones
