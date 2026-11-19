<#
  Installation complete de Jarvis en une commande (PowerShell) :
    irm https://raw.githubusercontent.com/BenjaminLepo/JARVIS/main/scripts/bootstrap.ps1 | iex
  Telecharge le kit dans Documents\JARVIS, installe Ollama + Tailscale + OpenJarvis,
  telecharge le modele et programme le demarrage automatique.
#>
$ErrorActionPreference = "Stop"
$dest = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "JARVIS"
$log  = Join-Path $env:TEMP "jarvis-install.log"
Start-Transcript -Path $log -Append | Out-Null

try {
    Write-Host "==> Telechargement du kit Jarvis dans $dest" -ForegroundColor Cyan
    $zip = Join-Path $env:TEMP "jarvis-kit.zip"
    Invoke-WebRequest "https://github.com/BenjaminLepo/JARVIS/archive/refs/heads/main.zip" -OutFile $zip -UseBasicParsing
    $tmp = Join-Path $env:TEMP "jarvis-kit"
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    Expand-Archive $zip -DestinationPath $tmp -Force
    $src = Get-ChildItem $tmp -Directory | Select-Object -First 1
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    # garde le reglage du modele si le kit existe deja
    $keepCfg = Test-Path (Join-Path $dest "jarvis.config.ps1")
    Get-ChildItem $src.FullName -Force | ForEach-Object {
        if ($keepCfg -and $_.Name -eq "jarvis.config.ps1") { return }
        Copy-Item $_.FullName -Destination $dest -Recurse -Force
    }
    Get-ChildItem $dest -Recurse -Filter *.ps1 | Unblock-File

    Set-Location $dest
    & (Join-Path $dest "scripts\install-windows.ps1")
    & (Join-Path $dest "scripts\register-autostart.ps1")

    Write-Host @"

=====================================================================
 Jarvis est installe dans : $dest
 IL RESTE A FAIRE (vous) :
  1. Icone Tailscale (barre des taches, pres de l'horloge) -> Log in
  2. iPhone : installer Tailscale (App Store), meme compte, activer
  3. Puis lancer Jarvis :  & "$dest\scripts\start-jarvis.ps1"
 Journal de l'installation : $log
=====================================================================
"@ -ForegroundColor Green
}
catch {
    Write-Host "`nERREUR : $_" -ForegroundColor Red
    Write-Host "Journal : $log  -> envoyez-le a Claude." -ForegroundColor Yellow
}
finally { Stop-Transcript | Out-Null }
