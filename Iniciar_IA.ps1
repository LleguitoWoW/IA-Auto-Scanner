# ============================================
#  Panel Web - IA Auto-Scanner (UI Overhaul)
# ============================================

# --- CONFIGURACION ---
$llamafile = ".\llamafile.exe"
$modelPath = ".\Models"
$port      = 8765

$script:llamaProcess = $null

# Crear carpeta Models si no existe
if (-not (Test-Path $modelPath)) {
    New-Item -ItemType Directory -Path $modelPath -Force | Out-Null
}

# --- Buscar modelos ---
$models = Get-ChildItem -Path $modelPath -Filter "*.gguf" -File -Recurse -ErrorAction SilentlyContinue | Sort-Object Name

# --- Generar HTML ---
$html = @"
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>IA Auto-Scanner</title>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');

    :root {
        --bg-dark: #0f172a;
        --bg-card: rgba(30, 41, 59, 0.7);
        --primary: #38bdf8;
        --primary-glow: rgba(56, 189, 248, 0.4);
        --text-main: #f8fafc;
        --text-muted: #94a3b8;
        --border: rgba(148, 163, 184, 0.15);
        --shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.5);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
        font-family: 'Inter', system-ui, -apple-system, sans-serif;
        background-color: var(--bg-dark);
        color: var(--text-main);
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        padding: 20px;
        background-image:
            radial-gradient(circle at 10% 20%, rgba(56, 189, 248, 0.05) 0%, transparent 40%),
            radial-gradient(circle at 90% 80%, rgba(16, 185, 129, 0.05) 0%, transparent 40%);
        background-attachment: fixed;
    }

    .container {
        background: var(--bg-card);
        backdrop-filter: blur(12px);
        -webkit-backdrop-filter: blur(12px);
        padding: 2.5rem;
        border-radius: 20px;
        box-shadow: var(--shadow);
        text-align: center;
        width: 100%;
        max-width: 620px;
        border: 1px solid var(--border);
        position: relative;
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .container:hover {
        box-shadow: 0 20px 40px -10px rgba(0, 0, 0, 0.6);
        border-color: rgba(56, 189, 248, 0.3);
    }

    .lang-switch {
        position: absolute;
        top: 18px;
        right: 18px;
        display: flex;
        gap: 6px;
    }
    .lang-btn {
        padding: 6px 14px;
        font-size: 0.75rem;
        border-radius: 20px;
        border: 1px solid var(--border);
        background: rgba(15, 23, 42, 0.5);
        color: var(--text-muted);
        cursor: pointer;
        font-weight: 600;
        transition: all 0.2s ease;
    }
    .lang-btn:hover { color: var(--text-main); background: rgba(255,255,255,0.05); }
    .lang-btn.active {
        background: var(--primary);
        color: #0f172a;
        border-color: var(--primary);
        box-shadow: 0 0 12px var(--primary-glow);
    }

    h1 {
        font-size: 1.8rem;
        margin-bottom: 0.2rem;
        background: linear-gradient(to right, #38bdf8, #818cf8);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 800;
        letter-spacing: -0.02em;
    }
    .subtitle { color: var(--text-muted); margin-bottom: 1.2rem; font-size: 0.95rem; }

    .path-info {
        font-size: 0.8rem;
        color: var(--text-muted);
        margin-bottom: 1.2rem;
    }

    select {
        width: 100%;
        padding: 14px 16px;
        margin-bottom: 1.5rem;
        border-radius: 12px;
        border: 2px solid var(--border);
        background-color: rgba(15, 23, 42, 0.6);
        color: var(--text-main);
        font-size: 1rem;
        cursor: pointer;
        outline: none;
        transition: all 0.2s ease;
        font-family: inherit;
        appearance: none;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2394a3b8'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
        background-repeat: no-repeat;
        background-position: right 1rem center;
        background-size: 1.2em;
    }
    select:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.1); }
    select:hover { border-color: #475569; }

    .btn-row {
        display: flex;
        gap: 12px;
        margin-bottom: 1rem;
        flex-wrap: wrap;
        justify-content: center;
    }

    button.action {
        flex: 1;
        min-width: 140px;
        padding: 14px 16px;
        border: none;
        border-radius: 12px;
        font-size: 0.95rem;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.2s ease;
        font-family: inherit;
    }
    button.action:hover:not(:disabled) {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    button.action:active:not(:disabled) { transform: translateY(0); }
    button.action:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none;
    }

    .btn-start {
        background: linear-gradient(135deg, #38bdf8, #0ea5e9);
        color: #0f172a;
    }
    .btn-start:hover:not(:disabled) {
        box-shadow: 0 0 20px var(--primary-glow);
    }

    .btn-llama {
        background: rgba(34, 197, 94, 0.1);
        color: #4ade80;
        border: 1px solid rgba(74, 222, 128, 0.3);
    }
    .btn-llama:hover:not(:disabled) {
        background: rgba(34, 197, 94, 0.2);
        border-color: #4ade80;
    }

    .btn-stop {
        background: rgba(239, 68, 68, 0.1);
        color: #f87171;
        border: 1px solid rgba(239, 68, 68, 0.3);
    }
    .btn-stop:hover:not(:disabled) {
        background: rgba(239, 68, 68, 0.2);
        border-color: #f87171;
    }

    .status {
        margin-top: 1.5rem;
        padding: 1rem 1.25rem;
        border-radius: 10px;
        font-size: 0.85rem;
        font-weight: 500;
        display: none;
        animation: slideUp 0.3s ease;
        word-break: break-word;
        border: 1px solid transparent;
    }
    .status.success {
        background: rgba(16, 185, 129, 0.15);
        color: #4ade80;
        border-color: rgba(16, 185, 129, 0.3);
    }
    .status.error {
        background: rgba(239, 68, 68, 0.15);
        color: #f87171;
        border-color: rgba(239, 68, 68, 0.3);
    }
    .status.loading {
        background: rgba(245, 158, 11, 0.15);
        color: #facc15;
        border-color: rgba(245, 158, 11, 0.3);
    }

    @keyframes slideUp {
        from { opacity: 0; transform: translateY(10px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .info-section {
        margin-top: 2rem;
        background: rgba(15, 23, 42, 0.4);
        border: 1px solid var(--border);
        border-radius: 12px;
        padding: 1.2rem;
        text-align: left;
        font-size: 0.85rem;
        color: var(--text-muted);
        line-height: 1.6;
    }
    .info-section h3 {
        color: var(--text-main);
        font-size: 0.9rem;
        margin-bottom: 0.7rem;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .info-section h3::before {
        content: '';
        display: block;
        width: 4px;
        height: 16px;
        background: var(--primary);
        border-radius: 2px;
    }
    .info-section a { color: var(--primary); text-decoration: none; }
    .info-section a:hover { color: #7dd3fc; text-decoration: underline; }
    .info-section b { color: var(--text-main); }
</style>
</head>
<body>
<div class="container">
    <div class="lang-switch">
        <button class="lang-btn active" id="btnES" onclick="setLang('es')">ES</button>
        <button class="lang-btn" id="btnEN" onclick="setLang('en')">EN</button>
    </div>

    <h1 id="t-title">IA Auto-Scanner</h1>
    <p class="subtitle" id="t-subtitle">Selecciona un modelo .gguf y ejecuta el servidor</p>
    <p class="path-info" id="t-path">Carpeta de modelos: Models\</p>

    <select id="modeloSelect">
        <option value="" disabled selected id="t-placeholder">Selecciona un modelo...</option>
"@

if ($models.Count -eq 0) {
    $html += "        <option value='' disabled data-empty='1'>No se encontraron modelos .gguf</option>`n"
} else {
    foreach ($m in $models) {
        $size = [math]::Round($m.Length / 1GB, 2)
        try {
            $base = (Resolve-Path $modelPath).Path
            $relPath = $m.FullName.Replace($base + "\", "").Replace($base + "/", "")
        } catch {
            $relPath = $m.Name
        }
        $html += "        <option value=`"$($m.FullName)`">$relPath ($size GB)</option>`n"
    }
}

$html += @"
    </select>

    <div class="btn-row">
        <button class="action btn-start" onclick="iniciar()" id="btnIniciar">INICIAR SERVIDOR</button>
        <button class="action btn-llama" onclick="abrirLlama()" id="btnLlama">ABRIR LLAMA</button>
        <button class="action btn-stop" onclick="apagar()" id="btnStop">APAGAR MODELO</button>
    </div>

    <div id="status" class="status"></div>

    <div class="info-section">
        <h3 id="t-info1-title">Como obtener llamafile</h3>
        <p id="t-info1-body">
            1. Entra en: <a href="https://github.com/mozilla-ai/llamafile/releases" target="_blank">github.com/mozilla-ai/llamafile/releases</a><br>
            2. Descarga la version <b>llamafile-x.xx.x</b> (Windows)<br>
            3. Renombra el archivo a <b>llamafile.exe</b> y ponlo en esta misma carpeta
        </p>

        <h3 id="t-info2-title">Como obtener modelos</h3>
        <p id="t-info2-body">
            1. Entra en: <a href="https://huggingface.co/models" target="_blank">huggingface.co/models</a><br>
            2. Busca modelos en formato <b>.gguf</b><br>
            3. Descomprime si es necesario y guarda los archivos <b>.gguf</b> dentro de la carpeta <b>Models</b>
        </p>
    </div>
</div>

<script>
    const texts = {
        es: {
            title: "IA Auto-Scanner",
            subtitle: "Selecciona un modelo .gguf y ejecuta el servidor",
            path: "Carpeta de modelos: Models\\",
            placeholder: "Selecciona un modelo...",
            empty: "No se encontraron modelos .gguf",
            btnStart: "INICIAR SERVIDOR",
            btnLlama: "ABRIR LLAMA",
            btnStop: "APAGAR MODELO",
            info1Title: "Como obtener llamafile",
            info1Body: '1. Entra en: <a href="https://github.com/mozilla-ai/llamafile/releases" target="_blank">github.com/mozilla-ai/llamafile/releases</a><br>2. Descarga la version <b>llamafile-x.xx.x</b> (Windows)<br>3. Renombra el archivo a <b>llamafile.exe</b> y ponlo en esta misma carpeta',
            info2Title: "Como obtener modelos",
            info2Body: '1. Entra en: <a href="https://huggingface.co/models" target="_blank">huggingface.co/models</a><br>2. Busca modelos en formato <b>.gguf</b><br>3. Descomprime si es necesario y guarda los archivos <b>.gguf</b> dentro de la carpeta <b>Models</b>',
            errSelect: "Por favor selecciona un modelo primero.",
            loadingStart: "Iniciando servidor con el modelo seleccionado...",
            starting: "INICIANDO...",
            errStart: "Error al iniciar el modelo. Verifica que llamafile.exe este en la carpeta.",
            loadingStop: "Cerrando el servidor...",
            errStop: "Error al apagar el modelo."
        },
        en: {
            title: "AI Auto-Scanner",
            subtitle: "Select a .gguf model and start the server",
            path: "Models folder: Models\\",
            placeholder: "Select a model...",
            empty: "No .gguf models found",
            btnStart: "START SERVER",
            btnLlama: "OPEN LLAMA",
            btnStop: "STOP MODEL",
            info1Title: "How to get llamafile",
            info1Body: '1. Go to: <a href="https://github.com/mozilla-ai/llamafile/releases" target="_blank">github.com/mozilla-ai/llamafile/releases</a><br>2. Download <b>llamafile-x.xx.x</b> (Windows)<br>3. Rename the file to <b>llamafile.exe</b> and place it in this folder',
            info2Title: "How to get models",
            info2Body: '1. Go to: <a href="https://huggingface.co/models" target="_blank">huggingface.co/models</a><br>2. Search for models in <b>.gguf</b> format<br>3. Extract if needed and put the <b>.gguf</b> files inside the <b>Models</b> folder',
            errSelect: "Please select a model first.",
            loadingStart: "Starting server with the selected model...",
            starting: "STARTING...",
            errStart: "Error starting the model. Ensure llamafile.exe is in the folder.",
            loadingStop: "Stopping the server...",
            errStop: "Error stopping the model."
        }
    };

    let currentLang = 'es';

    function setLang(lang) {
        currentLang = lang;
        const t = texts[lang];

        document.getElementById('t-title').textContent = t.title;
        document.getElementById('t-subtitle').textContent = t.subtitle;
        document.getElementById('t-path').textContent = t.path;
        document.getElementById('btnIniciar').textContent = t.btnStart;
        document.getElementById('btnLlama').textContent = t.btnLlama;
        document.getElementById('btnStop').textContent = t.btnStop;
        document.getElementById('t-info1-title').textContent = t.info1Title;
        document.getElementById('t-info1-body').innerHTML = t.info1Body;
        document.getElementById('t-info2-title').textContent = t.info2Title;
        document.getElementById('t-info2-body').innerHTML = t.info2Body;

        const placeholder = document.getElementById('t-placeholder');
        if (placeholder) placeholder.textContent = t.placeholder;

        const emptyOpt = document.querySelector('option[data-empty="1"]');
        if (emptyOpt) emptyOpt.textContent = t.empty;

        document.getElementById('btnES').classList.toggle('active', lang === 'es');
        document.getElementById('btnEN').classList.toggle('active', lang === 'en');
        document.documentElement.lang = lang;
    }

    function mostrarStatus(tipo, mensaje) {
        const el = document.getElementById('status');
        el.className = 'status ' + tipo;
        el.style.display = 'block';
        el.innerHTML = mensaje.replace(/\n/g, '<br>');

        if (tipo === 'success') {
            setTimeout(function() {
                el.style.display = 'none';
            }, 4000);
        }
    }

    function iniciar() {
        const select = document.getElementById('modeloSelect');
        const btn = document.getElementById('btnIniciar');
        const modelo = select.value;
        const t = texts[currentLang];

        if (!modelo) {
            mostrarStatus('error', t.errSelect);
            return;
        }

        btn.disabled = true;
        btn.textContent = t.starting;
        mostrarStatus('loading', t.loadingStart);

        fetch('/launch?model=' + encodeURIComponent(modelo))
            .then(function(r) { return r.text(); })
            .then(function(texto) {
                mostrarStatus('success', texto);
                btn.textContent = t.btnStart;
                btn.disabled = false;
            })
            .catch(function() {
                mostrarStatus('error', t.errStart);
                btn.textContent = t.btnStart;
                btn.disabled = false;
            });
    }

    function apagar() {
        const t = texts[currentLang];
        mostrarStatus('loading', t.loadingStop);

        fetch('/stop')
            .then(function(r) { return r.text(); })
            .then(function(texto) {
                mostrarStatus('success', texto);
            })
            .catch(function() {
                mostrarStatus('error', t.errStop);
            });
    }

    function abrirLlama() {
        window.open('http://127.0.0.1:8080/', '_blank');
    }
</script>
</body>
</html>
"@

# --- Servidor HTTP ---
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host ""
Write-Host "  Panel listo -> http://localhost:$port" -ForegroundColor Cyan
Write-Host "  Carpeta de modelos: $modelPath" -ForegroundColor DarkGray
Write-Host "  Cierra esta ventana para detener el panel" -ForegroundColor DarkGray
Write-Host ""

Start-Process "http://localhost:$port"

try {
    while ($listener.IsListening) {
        $context  = $listener.GetContext()
        $request  = $context.Request
        $response = $context.Response
        $path     = $request.Url.AbsolutePath

        if ($path -eq "/launch") {
            $modelFullPath = $request.QueryString["model"]

            if ($modelFullPath -and (Test-Path -LiteralPath $modelFullPath)) {
                if ($script:llamaProcess -and -not $script:llamaProcess.HasExited) {
                    try { Stop-Process -Id $script:llamaProcess.Id -Force -ErrorAction SilentlyContinue } catch {}
                }

                Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*llamafile*" } | Stop-Process -Force -ErrorAction SilentlyContinue

                $script:llamaProcess = Start-Process -FilePath $llamafile -ArgumentList "--server","--model","`"$modelFullPath`"" -PassThru
                $msg = "Servidor iniciado / Server started:`n$(Split-Path $modelFullPath -Leaf)"
            } else {
                $msg = "Modelo no encontrado / Model not found"
            }

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($msg)
            $response.ContentType = "text/plain; charset=utf-8"
        }
        elseif ($path -eq "/stop") {
            $killed = $false

            if ($script:llamaProcess -and -not $script:llamaProcess.HasExited) {
                try {
                    Stop-Process -Id $script:llamaProcess.Id -Force -ErrorAction SilentlyContinue
                    $killed = $true
                } catch {}
            }

            $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*llamafile*" }
            if ($procs) {
                $procs | Stop-Process -Force -ErrorAction SilentlyContinue
                $killed = $true
            }

            if ($killed) {
                $msg = "Modelo apagado / Model stopped"
            } else {
                $msg = "No habia modelo en ejecucion / No model was running"
            }

            $script:llamaProcess = $null

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($msg)
            $response.ContentType = "text/plain; charset=utf-8"
        }
        else {
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $response.ContentType = "text/html; charset=utf-8"
        }

        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    }
}
finally {
    $listener.Stop()
}
