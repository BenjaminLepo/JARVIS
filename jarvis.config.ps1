# Réglages Jarvis — modifiez ici puis relancez scripts\start-jarvis.ps1
$JarvisModel  = "qwen3:8b"      # qwen3:4b si le PC n'a pas de carte graphique dédiée
$JarvisPort   = 8000
$JarvisEngine = "ollama"
$JarvisAgent  = "orchestrator"  # simple | orchestrator | react | openhands
# Adresse d'écoute : vide = détection automatique de l'IP Tailscale (recommandé).
# Ne jamais mettre 0.0.0.0 : le serveur n'a pas de mot de passe.
$JarvisHost   = ""
