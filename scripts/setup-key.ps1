<#
  Cree la cle d'acces de Jarvis (OPENJARVIS_API_KEY), obligatoire quand Jarvis
  ecoute sur l'adresse Tailscale. La cle est :
   - enregistree comme variable d'environnement utilisateur (Jarvis la lit au demarrage)
   - sauvee dans secrets\jarvis-key.txt (exclu de Git)
   - copiee dans le presse-papiers (a coller dans le raccourci iPhone)
  Usage : powershell -ExecutionPolicy Bypass -File .\scripts\setup-key.ps1 [-Force]
#>
param([switch]$Force)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

$key = [Environment]::GetEnvironmentVariable("OPENJARVIS_API_KEY", "User")
if (-not $key -or $Force) {
    $bytes = New-Object byte[] 32
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $key = "jv_" + (($bytes | ForEach-Object { $_.ToString("x2") }) -join "")
    [Environment]::SetEnvironmentVariable("OPENJARVIS_API_KEY", $key, "User")
    Write-Host "Nouvelle cle Jarvis creee." -ForegroundColor Green
} else {
    Write-Host "Cle Jarvis existante conservee (utiliser -Force pour en creer une nouvelle)." -ForegroundColor Yellow
}
$env:OPENJARVIS_API_KEY = $key

$secrets = Join-Path $root "secrets"
New-Item -ItemType Directory -Force -Path $secrets | Out-Null
Set-Content -Path (Join-Path $secrets "jarvis-key.txt") -Value $key -Encoding ASCII
Set-Clipboard -Value $key

Write-Host "Cle copiee dans le presse-papiers et sauvee dans secrets\jarvis-key.txt"
Write-Host "Ne la partagez pas : elle donne acces a Jarvis." -ForegroundColor Yellow
