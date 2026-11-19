﻿<#
  Démarrage automatique de Jarvis à l'ouverture de session, SANS droits administrateur :
  un raccourci est placé dans le dossier Démarrage de Windows. Jarvis est aussi lancé tout de suite.
  Désactiver : supprimer "Jarvis.lnk" du dossier shell:startup.
#>
$ErrorActionPreference = "Stop"
$script  = Join-Path $PSScriptRoot "start-jarvis.ps1"
$startup = [Environment]::GetFolderPath("Startup")
$lnkPath = Join-Path $startup "Jarvis.lnk"

$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath       = "powershell.exe"
# 60 s d'attente pour laisser Tailscale se connecter après l'ouverture de session
$lnk.Arguments        = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command `"Start-Sleep 60; & '$script'`""
$lnk.WorkingDirectory = Split-Path -Parent $PSScriptRoot
$lnk.WindowStyle      = 7
$lnk.Description      = "Serveur Jarvis (OpenJarvis) sur l'IP Tailscale"
$lnk.Save()
Write-Host "Démarrage automatique activé : $lnkPath" -ForegroundColor Green

# Lancement immédiat, en arrière-plan
Start-Process powershell.exe -WindowStyle Hidden -ArgumentList `
    "-NoProfile -ExecutionPolicy Bypass -File `"$script`""
Write-Host "Jarvis démarre en arrière-plan (journal : jarvis.log dans le dossier JARVIS)." -ForegroundColor Green
