<#
  Installation de Jarvis (OpenJarvis + Ollama + Tailscale) sur Windows.
  Usage :  .\scripts\install-windows.ps1 [-Model qwen3:8b]
#>
param([string]$Model = "")

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root "jarvis.config.ps1")
if ($Model) {
    $JarvisModel = $Model
    (Get-Content (Join-Path $root "jarvis.config.ps1")) `
        -replace '^\$JarvisModel\s*=.*', "`$JarvisModel  = `"$Model`"" |
        Set-Content (Join-Path $root "jarvis.config.ps1") -Encoding UTF8
}

function Step($t) { Write-Host "`n==> $t" -ForegroundColor Cyan }
function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path","User")
}

if (-not (Has winget)) {
    throw "winget est introuvable. Installez 'App Installer' depuis le Microsoft Store puis relancez."
}

Step "1/4 Ollama (moteur qui fait tourner le modèle en local)"
if (-not (Has ollama)) {
    winget install -e --id Ollama.Ollama --accept-source-agreements --accept-package-agreements
    Refresh-Path
} else { Write-Host "Ollama déjà installé." }

Step "2/4 Tailscale (liaison privée iPhone <-> PC)"
if (-not (Has tailscale)) {
    winget install -e --id Tailscale.Tailscale --accept-source-agreements --accept-package-agreements
    Refresh-Path
} else { Write-Host "Tailscale déjà installé." }

Step "3/4 OpenJarvis (installeur officiel Windows)"
if (-not (Has jarvis)) {
    Invoke-RestMethod https://open-jarvis.github.io/OpenJarvis/install.ps1 | Invoke-Expression
    Refresh-Path
} else { Write-Host "OpenJarvis déjà installé." }

Step "4/4 Téléchargement du modèle $JarvisModel (plusieurs Go, patience)"
if (-not (Get-Process ollama -ErrorAction SilentlyContinue)) {
    Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 5
}
ollama pull $JarvisModel
if ($LASTEXITCODE -ne 0) { throw "Échec du téléchargement du modèle $JarvisModel" }

Step "Diagnostic OpenJarvis"
try { jarvis doctor } catch { Write-Warning "jarvis doctor a signalé un problème : $_" }

Write-Host @"

Installation terminée.
Étapes suivantes :
  1. Cliquez sur l'icône Tailscale (barre des tâches) -> Log in. Faites de même sur l'iPhone.
  2. .\scripts\register-autostart.ps1   (démarrage automatique)
  3. .\scripts\start-jarvis.ps1         (démarrer maintenant)
  4. Raccourci iPhone : iphone\RACCOURCI-IPHONE.md
"@ -ForegroundColor Green
