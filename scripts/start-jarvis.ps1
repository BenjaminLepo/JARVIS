<#
  Démarre le serveur Jarvis (OpenJarvis, API compatible OpenAI) sur l'IP Tailscale.
  Usage : .\scripts\start-jarvis.ps1
#>
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root "jarvis.config.ps1")

$bind = $JarvisHost
if (-not $bind) {
    $bind = (& tailscale ip -4 2>$null | Select-Object -First 1)
    if (-not $bind) {
        Write-Warning "Tailscale n'est pas connecté : Jarvis n'écoutera que sur ce PC (127.0.0.1)."
        $bind = "127.0.0.1"
    }
}
if ($bind -eq "0.0.0.0") {
    throw "Refus d'écouter sur 0.0.0.0 : le serveur n'a pas de mot de passe. Voir docs\SECURITE.md."
}

# Ollama doit tourner (normalement lancé par son application au démarrage)
if (-not (Get-Process ollama -ErrorAction SilentlyContinue)) {
    Start-Process ollama -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 3
}

$log = Join-Path $root "jarvis.log"
Write-Host "Jarvis démarre sur http://${bind}:$JarvisPort  (modèle $JarvisModel, agent $JarvisAgent)"
Write-Host "Journal : $log"
jarvis serve --host $bind --port $JarvisPort --engine $JarvisEngine `
             --model $JarvisModel --agent $JarvisAgent *>&1 | Tee-Object -FilePath $log
