<#
  Test rapide : .\scripts\test-jarvis.ps1 "Bonjour Jarvis"
#>
param([string]$Question = "Bonjour Jarvis, présente-toi en une phrase.")
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root "jarvis.config.ps1")

$h = $JarvisHost
if (-not $h) { $h = (& tailscale ip -4 2>$null | Select-Object -First 1) }
if (-not $h) { $h = "127.0.0.1" }
$url = "http://${h}:$JarvisPort/v1/chat/completions"

$body = @{
    model    = $JarvisModel
    messages = @(
        @{ role = "system"; content = "Tu es Jarvis, l'assistant personnel de Benjamin. Réponds en français, brièvement." },
        @{ role = "user";   content = $Question }
    )
} | ConvertTo-Json -Depth 5

Write-Host "POST $url"
$r = Invoke-RestMethod -Uri $url -Method Post -ContentType "application/json; charset=utf-8" `
     -Body ([Text.Encoding]::UTF8.GetBytes($body))
$r.choices[0].message.content
