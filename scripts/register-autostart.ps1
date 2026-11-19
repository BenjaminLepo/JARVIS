<#
  Crée une tâche planifiée « Jarvis » qui lance start-jarvis.ps1 à l'ouverture de session.
  Supprimer :  Unregister-ScheduledTask -TaskName Jarvis -Confirm:$false
#>
$ErrorActionPreference = "Stop"
$script = Join-Path $PSScriptRoot "start-jarvis.ps1"

$action  = New-ScheduledTaskAction -Execute "powershell.exe" `
           -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
# Délai de 60 s pour laisser Tailscale se connecter
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$trigger.Delay = "PT60S"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
            -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 2) -ExecutionTimeLimit 0

Register-ScheduledTask -TaskName "Jarvis" -Action $action -Trigger $trigger `
    -Settings $settings -Description "Serveur Jarvis (OpenJarvis) sur l'IP Tailscale" -Force | Out-Null

Write-Host "Tâche 'Jarvis' créée : Jarvis démarrera à chaque ouverture de session." -ForegroundColor Green
