# ============================================
#  Panel Web - IA Auto-Scanner (UI + Config)
# ============================================

# --- CONFIGURACION GENERAL ---
$llamafile = ".\llamafile.exe"
$modelPath = ".\Models"
$port      = 8765

# Valores por defecto (se pueden cambiar tambien desde el panel web)
$nGpuLayers        = 99
$ctxSize           = 131072
$cacheTypeK        = "q4_0"
$cacheTypeV        = "q4_0"
$flashAttn         = "on"
$parallel          = 1
$hostAddr          = "127.0.0.1"
$modelPort         = 8080
$specType          = "ngram-mod"
$specNgramNMatch   = 24
$specNgramNMin     = 48
$specNgramNMax     = 64
$reasoning         = "on"

$script:llamaProcess = $null

if (-not (Test-Path $modelPath)) {
    New-Item -ItemType Directory -Path $modelPath -Force | Out-Null
}

$models = Get-ChildItem -Path $modelPath -Filter "*.gguf" -File -Recurse -ErrorAction SilentlyContinue | Sort-Object Name

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
        --bg-card: rgba(30, 41, 59, 0.75);
        --primary: #38bdf8;
        --primary-glow: rgba(56, 189, 248, 0.35);
        --text-main: #f8fafc;
        --text-muted: #94a3b8;
        --border: rgba(148, 163, 184, 0.15);
        --shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.5);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
        font-family: 'Inter', system-ui, sans-serif;
        background-color: var(--bg-dark);
        color: var(--text-main);
        display: flex;
        justify-content: center;
        align-items: flex-start;
        min-height: 100vh;
        padding: 24px 16px;
        background-image:
            radial-gradient(circle at 10% 20%, rgba(56, 189, 248, 0.05) 0%, transparent 40%),
            radial-gradient(circle at 90% 80%, rgba(16, 185, 129, 0.05) 0%, transparent 40%);
    }
    .container {
        background: var(--bg-card);
        backdrop-filter: blur(12px);
        padding: 2rem;
        border-radius: 20px;
        box-shadow: var(--shadow);
        width: 100%;
        max-width: 720px;
        border: 1px solid var(--border);
        position: relative;
    }
    .lang-switch {
        position: absolute;
        top: 16px;
        right: 16px;
        display: flex;
        gap: 6px;
    }
    .lang-btn {
        padding: 6px 12px;
        font-size: 0.75rem;
        border-radius: 20px;
        border: 1px solid var(--border);
        background: rgba(15, 23, 42, 0.5);
        color: var(--text-muted);
        cursor: pointer;
        font-weight: 600;
    }
    .lang-btn.active {
        background: var(--primary);
        color: #0f172a;
        border-color: var(--primary);
        box-shadow: 0 0 12px var(--primary-glow);
    }
    h1 {
        font-size: 1.7rem;
        margin-bottom: 0.25rem;
        background: linear-gradient(to right, #38bdf8, #818cf8);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight: 800;
        text-align: center;
    }
    .subtitle { color: var(--text-muted); margin-bottom: 0.8rem; font-size: 0.9rem; text-align: center; }
    .path-info { font-size: 0.8rem; color: var(--text-muted); margin-bottom: 1rem; text-align: center; }

    select, input, .cfg-select {
        width: 100%;
        padding: 12px 14px;
        border-radius: 10px;
        border: 2px solid var(--border);
        background-color: rgba(15, 23, 42, 0.6);
        color: var(--text-main);
        font-size: 0.95rem;
        font-family: inherit;
        outline: none;
    }
    select { margin-bottom: 1.2rem; cursor: pointer; }
    select:focus, input:focus, .cfg-select:focus { border-color: var(--primary); }

    .btn-row {
        display: flex;
        gap: 10px;
        margin-bottom: 1rem;
        flex-wrap: wrap;
        justify-content: center;
    }
    button.action {
        flex: 1;
        min-width: 130px;
        padding: 12px 14px;
        border: none;
        border-radius: 12px;
        font-size: 0.9rem;
        font-weight: 600;
        cursor: pointer;
        font-family: inherit;
        transition: all 0.2s ease;
    }
    button.action:hover:not(:disabled) { transform: translateY(-2px); }
    button.action:disabled { opacity: 0.5; cursor: not-allowed; }

    .btn-start { background: linear-gradient(135deg, #38bdf8, #0ea5e9); color: #0f172a; }
    .btn-llama {
        background: rgba(34, 197, 94, 0.12);
        color: #4ade80;
        border: 1px solid rgba(74, 222, 128, 0.3);
    }
    .btn-stop {
        background: rgba(239, 68, 68, 0.12);
        color: #f87171;
        border: 1px solid rgba(239, 68, 68, 0.3);
    }

    .status {
        margin: 0.8rem 0 1rem;
        padding: 0.9rem 1rem;
        border-radius: 10px;
        font-size: 0.85rem;
        display: none;
        border: 1px solid transparent;
    }
    .status.success { display:block; background: rgba(16,185,129,0.15); color:#4ade80; border-color:rgba(16,185,129,0.3); }
    .status.error { display:block; background: rgba(239,68,68,0.15); color:#f87171; border-color:rgba(239,68,68,0.3); }
    .status.loading { display:block; background: rgba(245,158,11,0.15); color:#facc15; border-color:rgba(245,158,11,0.3); }

    /* CONFIG PANEL */
    .config-toggle {
        width: 100%;
        padding: 10px;
        margin-bottom: 0.8rem;
        background: rgba(15, 23, 42, 0.5);
        border: 1px solid var(--border);
        border-radius: 10px;
        color: var(--text-muted);
        cursor: pointer;
        font-family: inherit;
        font-size: 0.85rem;
        font-weight: 600;
        text-align: left;
    }
    .config-toggle:hover { color: var(--text-main); border-color: #475569; }
    .config-panel {
        display: none;
        margin-bottom: 1.2rem;
        padding: 1rem;
        background: rgba(15, 23, 42, 0.45);
        border: 1px solid var(--border);
        border-radius: 12px;
        text-align: left;
    }
    .config-panel.open { display: block; }
    .config-panel h3 {
        font-size: 0.9rem;
        color: var(--primary);
        margin-bottom: 0.8rem;
    }
    .cfg-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px 14px;
    }
    @media (max-width: 560px) { .cfg-grid { grid-template-columns: 1fr; } }
    .cfg-item label {
        display: block;
        font-size: 0.72rem;
        color: var(--text-muted);
        margin-bottom: 4px;
    }
    .cfg-item .hint {
        font-size: 0.68rem;
        color: #64748b;
        margin-top: 3px;
        line-height: 1.3;
    }
    .cfg-item.full { grid-column: 1 / -1; }

    .info-section {
        margin-top: 1.2rem;
        background: rgba(15, 23, 42, 0.4);
        border: 1px solid var(--border);
        border-radius: 12px;
        padding: 1rem;
        text-align: left;
        font-size: 0.82rem;
        color: var(--text-muted);
        line-height: 1.55;
    }
    .info-section h3 {
        color: var(--text-main);
        font-size: 0.88rem;
        margin: 0.6rem 0 0.4rem;
    }
    .info-section h3:first-child { margin-top: 0; }
    .info-section a { color: var(--primary); text-decoration: none; }
    .info-section a:hover { text-decoration: underline; }
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
        } catch { $relPath = $m.Name }
        $html += "        <option value=`"$($m.FullName)`">$relPath ($size GB)</option>`n"
    }
}

$html += @"
    </select>

    <button class="config-toggle" id="cfgToggle" onclick="toggleConfig()">&#9881; Configuracion del servidor (avanzado)</button>

    <div class="config-panel" id="configPanel">
        <h3 id="t-cfg-title">Parametros de llamafile</h3>
        <div class="cfg-grid">
            <div class="cfg-item">
                <label id="l-gpu">n-gpu-layers</label>
                <input type="number" id="cfg_nGpuLayers" value="$nGpuLayers">
                <div class="hint" id="h-gpu">Capas en GPU. 99 = casi todo. Baja si no hay VRAM.</div>
            </div>
            <div class="cfg-item">
                <label id="l-ctx">ctx-size</label>
                <input type="number" id="cfg_ctxSize" value="$ctxSize">
                <div class="hint" id="h-ctx">Contexto en tokens (128K usa mucha memoria).</div>
            </div>
            <div class="cfg-item">
                <label id="l-ck">cache-type-k</label>
                <input type="text" id="cfg_cacheTypeK" value="$cacheTypeK">
                <div class="hint" id="h-ck">Cache K (q4_0 ahorra VRAM).</div>
            </div>
            <div class="cfg-item">
                <label id="l-cv">cache-type-v</label>
                <input type="text" id="cfg_cacheTypeV" value="$cacheTypeV">
                <div class="hint" id="h-cv">Cache V (igual que K).</div>
            </div>
            <div class="cfg-item">
                <label id="l-fa">flash-attn</label>
                <select class="cfg-select" id="cfg_flashAttn">
                    <option value="on" $(if($flashAttn -eq 'on'){'selected'})>on</option>
                    <option value="off" $(if($flashAttn -eq 'off'){'selected'})>off</option>
                </select>
                <div class="hint" id="h-fa">Acelera atencion y reduce memoria.</div>
            </div>
            <div class="cfg-item">
                <label id="l-par">parallel</label>
                <input type="number" id="cfg_parallel" value="$parallel">
                <div class="hint" id="h-par">Peticiones en paralelo (1 = mas estable).</div>
            </div>
            <div class="cfg-item">
                <label id="l-host">host</label>
                <input type="text" id="cfg_host" value="$hostAddr">
                <div class="hint" id="h-host">IP del servidor del modelo.</div>
            </div>
            <div class="cfg-item">
                <label id="l-port">port</label>
                <input type="number" id="cfg_port" value="$modelPort">
                <div class="hint" id="h-port">Puerto de la interfaz de chat.</div>
            </div>
            <div class="cfg-item">
                <label id="l-spec">spec-type</label>
                <input type="text" id="cfg_specType" value="$specType">
                <div class="hint" id="h-spec">Speculative decoding (ngram-mod).</div>
            </div>
            <div class="cfg-item">
                <label id="l-match">spec n-match</label>
                <input type="number" id="cfg_specMatch" value="$specNgramNMatch">
                <div class="hint" id="h-match">Tokens que deben coincidir.</div>
            </div>
            <div class="cfg-item">
                <label id="l-min">spec n-min</label>
                <input type="number" id="cfg_specMin" value="$specNgramNMin">
                <div class="hint" id="h-min">Tamano minimo n-grama.</div>
            </div>
            <div class="cfg-item">
                <label id="l-max">spec n-max</label>
                <input type="number" id="cfg_specMax" value="$specNgramNMax">
                <div class="hint" id="h-max">Tamano maximo n-grama.</div>
            </div>
            <div class="cfg-item full">
                <label id="l-reason">reasoning</label>
                <select class="cfg-select" id="cfg_reasoning">
                    <option value="on" $(if($reasoning -eq 'on'){'selected'})>on</option>
                    <option value="off" $(if($reasoning -eq 'off'){'selected'})>off</option>
                </select>
                <div class="hint" id="h-reason">Modo razonamiento paso a paso (si el modelo lo soporta).</div>
            </div>
        </div>
    </div>

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
            cfgToggle: "Configuracion del servidor (avanzado)",
            cfgTitle: "Parametros de llamafile",
            info1Title: "Como obtener llamafile",
            info1Body: '1. Entra en: <a href="https://github.com/mozilla-ai/llamafile/releases" target="_blank">github.com/mozilla-ai/llamafile/releases</a><br>2. Descarga la version <b>llamafile-x.xx.x</b> (Windows)<br>3. Renombra el archivo a <b>llamafile.exe</b> y ponlo en esta misma carpeta',
            info2Title: "Como obtener modelos",
            info2Body: '1. Entra en: <a href="https://huggingface.co/models" target="_blank">huggingface.co/models</a><br>2. Busca modelos en formato <b>.gguf</b><br>3. Descomprime si es necesario y guarda los archivos <b>.gguf</b> dentro de la carpeta <b>Models</b>',
            errSelect: "Por favor selecciona un modelo primero.",
            loadingStart: "Iniciando servidor con el modelo seleccionado...",
            starting: "INICIANDO...",
            errStart: "Error al iniciar el modelo. Verifica llamafile.exe y los parametros.",
            loadingStop: "Cerrando el servidor...",
            errStop: "Error al apagar el modelo.",
            hGpu: "Capas en GPU. 99 = casi todo. Baja si no hay VRAM.",
            hCtx: "Contexto en tokens (128K usa mucha memoria).",
            hCk: "Cache K (q4_0 ahorra VRAM).",
            hCv: "Cache V (igual que K).",
            hFa: "Acelera atencion y reduce memoria.",
            hPar: "Peticiones en paralelo (1 = mas estable).",
            hHost: "IP del servidor del modelo.",
            hPort: "Puerto de la interfaz de chat.",
            hSpec: "Speculative decoding (ngram-mod).",
            hMatch: "Tokens que deben coincidir.",
            hMin: "Tamano minimo n-grama.",
            hMax: "Tamano maximo n-grama.",
            hReason: "Modo razonamiento paso a paso (si el modelo lo soporta)."
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
            cfgToggle: "Server configuration (advanced)",
            cfgTitle: "llamafile parameters",
            info1Title: "How to get llamafile",
            info1Body: '1. Go to: <a href="https://github.com/mozilla-ai/llamafile/releases" target="_blank">github.com/mozilla-ai/llamafile/releases</a><br>2. Download <b>llamafile-x.xx.x</b> (Windows)<br>3. Rename the file to <b>llamafile.exe</b> and place it in this folder',
            info2Title: "How to get models",
            info2Body: '1. Go to: <a href="https://huggingface.co/models" target="_blank">huggingface.co/models</a><br>2. Search for models in <b>.gguf</b> format<br>3. Extract if needed and put the <b>.gguf</b> files inside the <b>Models</b> folder',
            errSelect: "Please select a model first.",
            loadingStart: "Starting server with the selected model...",
            starting: "STARTING...",
            errStart: "Error starting the model. Check llamafile.exe and parameters.",
            loadingStop: "Stopping the server...",
            errStop: "Error stopping the model.",
            hGpu: "Layers on GPU. 99 = almost all. Lower if out of VRAM.",
            hCtx: "Context size in tokens (128K uses a lot of memory).",
            hCk: "K cache (q4_0 saves VRAM).",
            hCv: "V cache (same as K).",
            hFa: "Speeds up attention and reduces memory.",
            hPar: "Parallel requests (1 = more stable).",
            hHost: "Model server IP.",
            hPort: "Chat UI port.",
            hSpec: "Speculative decoding (ngram-mod).",
            hMatch: "Tokens that must match.",
            hMin: "Min n-gram size.",
            hMax: "Max n-gram size.",
            hReason: "Step-by-step reasoning mode (if model supports it)."
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
        document.getElementById('cfgToggle').innerHTML = '&#9881; ' + t.cfgToggle;
        document.getElementById('t-cfg-title').textContent = t.cfgTitle;
        document.getElementById('t-info1-title').textContent = t.info1Title;
        document.getElementById('t-info1-body').innerHTML = t.info1Body;
        document.getElementById('t-info2-title').textContent = t.info2Title;
        document.getElementById('t-info2-body').innerHTML = t.info2Body;
        const ph = document.getElementById('t-placeholder');
        if (ph) ph.textContent = t.placeholder;
        const empty = document.querySelector('option[data-empty="1"]');
        if (empty) empty.textContent = t.empty;
        document.getElementById('h-gpu').textContent = t.hGpu;
        document.getElementById('h-ctx').textContent = t.hCtx;
        document.getElementById('h-ck').textContent = t.hCk;
        document.getElementById('h-cv').textContent = t.hCv;
        document.getElementById('h-fa').textContent = t.hFa;
        document.getElementById('h-par').textContent = t.hPar;
        document.getElementById('h-host').textContent = t.hHost;
        document.getElementById('h-port').textContent = t.hPort;
        document.getElementById('h-spec').textContent = t.hSpec;
        document.getElementById('h-match').textContent = t.hMatch;
        document.getElementById('h-min').textContent = t.hMin;
        document.getElementById('h-max').textContent = t.hMax;
        document.getElementById('h-reason').textContent = t.hReason;
        document.getElementById('btnES').classList.toggle('active', lang === 'es');
        document.getElementById('btnEN').classList.toggle('active', lang === 'en');
        document.documentElement.lang = lang;
    }

    function toggleConfig() {
        document.getElementById('configPanel').classList.toggle('open');
    }

    function getCfg() {
        return {
            nGpuLayers: document.getElementById('cfg_nGpuLayers').value,
            ctxSize: document.getElementById('cfg_ctxSize').value,
            cacheTypeK: document.getElementById('cfg_cacheTypeK').value,
            cacheTypeV: document.getElementById('cfg_cacheTypeV').value,
            flashAttn: document.getElementById('cfg_flashAttn').value,
            parallel: document.getElementById('cfg_parallel').value,
            host: document.getElementById('cfg_host').value,
            port: document.getElementById('cfg_port').value,
            specType: document.getElementById('cfg_specType').value,
            specMatch: document.getElementById('cfg_specMatch').value,
            specMin: document.getElementById('cfg_specMin').value,
            specMax: document.getElementById('cfg_specMax').value,
            reasoning: document.getElementById('cfg_reasoning').value
        };
    }

    function mostrarStatus(tipo, mensaje) {
        const el = document.getElementById('status');
        el.className = 'status ' + tipo;
        el.innerHTML = mensaje.replace(/\n/g, '<br>');
        if (tipo === 'success') {
            setTimeout(function() { el.className = 'status'; el.style.display = 'none'; }, 4500);
        }
    }

    function iniciar() {
        const select = document.getElementById('modeloSelect');
        const btn = document.getElementById('btnIniciar');
        const modelo = select.value;
        const t = texts[currentLang];
        if (!modelo) { mostrarStatus('error', t.errSelect); return; }

        const c = getCfg();
        btn.disabled = true;
        btn.textContent = t.starting;
        mostrarStatus('loading', t.loadingStart);

        const params = new URLSearchParams({
            model: modelo,
            nGpuLayers: c.nGpuLayers,
            ctxSize: c.ctxSize,
            cacheTypeK: c.cacheTypeK,
            cacheTypeV: c.cacheTypeV,
            flashAttn: c.flashAttn,
            parallel: c.parallel,
            host: c.host,
            port: c.port,
            specType: c.specType,
            specMatch: c.specMatch,
            specMin: c.specMin,
            specMax: c.specMax,
            reasoning: c.reasoning
        });

        fetch('/launch?' + params.toString())
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
            .then(function(texto) { mostrarStatus('success', texto); })
            .catch(function() { mostrarStatus('error', t.errStop); });
    }

    function abrirLlama() {
        const host = document.getElementById('cfg_host').value || '127.0.0.1';
        const port = document.getElementById('cfg_port').value || '8080';
        window.open('http://' + host + ':' + port + '/', '_blank');
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

function Get-QS([System.Collections.Specialized.NameValueCollection]$qs, [string]$key, $default) {
    $v = $qs[$key]
    if ([string]::IsNullOrWhiteSpace($v)) { return $default }
    return $v
}

try {
    while ($listener.IsListening) {
        $context  = $listener.GetContext()
        $request  = $context.Request
        $response = $context.Response
        $path     = $request.Url.AbsolutePath

        if ($path -eq "/launch") {
            $qs = $request.QueryString
            $modelFullPath = Get-QS $qs "model" $null

            if ($modelFullPath -and (Test-Path -LiteralPath $modelFullPath)) {
                if ($script:llamaProcess -and -not $script:llamaProcess.HasExited) {
                    try { Stop-Process -Id $script:llamaProcess.Id -Force -ErrorAction SilentlyContinue } catch {}
                }
                Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*llamafile*" } | Stop-Process -Force -ErrorAction SilentlyContinue

                $vGpu    = Get-QS $qs "nGpuLayers" $nGpuLayers
                $vCtx    = Get-QS $qs "ctxSize" $ctxSize
                $vCk     = Get-QS $qs "cacheTypeK" $cacheTypeK
                $vCv     = Get-QS $qs "cacheTypeV" $cacheTypeV
                $vFa     = Get-QS $qs "flashAttn" $flashAttn
                $vPar    = Get-QS $qs "parallel" $parallel
                $vHost   = Get-QS $qs "host" $hostAddr
                $vPort   = Get-QS $qs "port" $modelPort
                $vSpec   = Get-QS $qs "specType" $specType
                $vMatch  = Get-QS $qs "specMatch" $specNgramNMatch
                $vMin    = Get-QS $qs "specMin" $specNgramNMin
                $vMax    = Get-QS $qs "specMax" $specNgramNMax
                $vReason = Get-QS $qs "reasoning" $reasoning

                $argsList = @(
                    "--server",
                    "--model", "`"$modelFullPath`"",
                    "--n-gpu-layers", "$vGpu",
                    "--ctx-size", "$vCtx",
                    "--cache-type-k", "$vCk",
                    "--cache-type-v", "$vCv",
                    "--flash-attn", "$vFa",
                    "--parallel", "$vPar",
                    "--host", "$vHost",
                    "--port", "$vPort",
                    "--spec-type", "$vSpec",
                    "--spec-ngram-mod-n-match", "$vMatch",
                    "--spec-ngram-mod-n-min", "$vMin",
                    "--spec-ngram-mod-n-max", "$vMax",
                    "--reasoning", "$vReason"
                )

                $script:llamaProcess = Start-Process -FilePath $llamafile -ArgumentList $argsList -PassThru
                $msg = "Servidor iniciado / Server started:`n$(Split-Path $modelFullPath -Leaf)`nhttp://${vHost}:${vPort}/"
            } else {
                $msg = "Modelo no encontrado / Model not found"
            }

            $buffer = [System.Text.Encoding]::UTF8.GetBytes($msg)
            $response.ContentType = "text/plain; charset=utf-8"
        }
        elseif ($path -eq "/stop") {
            $killed = $false
            if ($script:llamaProcess -and -not $script:llamaProcess.HasExited) {
                try { Stop-Process -Id $script:llamaProcess.Id -Force -ErrorAction SilentlyContinue; $killed = $true } catch {}
            }
            $procs = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*llamafile*" }
            if ($procs) { $procs | Stop-Process -Force -ErrorAction SilentlyContinue; $killed = $true }
            $msg = if ($killed) { "Modelo apagado / Model stopped" } else { "No habia modelo en ejecucion / No model was running" }
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

