# Sécurité

1. **Double protection.** Le serveur écoute **uniquement sur l'IP Tailscale** du PC (100.x.y.z), joignable seulement par vos appareils Tailscale, **et** exige une clé d'accès (`OPENJARVIS_API_KEY`, créée par `scripts\setup-key.ps1`, envoyée par le raccourci iPhone dans l'en-tête `Authorization: Bearer …`). En cas de doute, régénérez-la : `setup-key.ps1 -Force`, puis mettez à jour le raccourci.
2. **Ne jamais** lancer `jarvis serve --host 0.0.0.0`, ni ouvrir/rediriger le port 8000 sur la box ou le pare-feu. `start-jarvis.ps1` refuse `0.0.0.0`.
3. **Tailscale** : activez la double authentification sur le compte et retirez de la console Tailscale les appareils que vous n'utilisez plus.
4. **PC professionnel** : faites valider par l'informatique SPIRIT l'installation d'Ollama, de Tailscale et d'un serveur local. Un VPN d'entreprise ou un proxy peut aussi bloquer Tailscale.
5. **Données** : le modèle tourne sur le PC, les questions ne partent pas vers un service d'IA en ligne. Si vous configurez plus tard un moteur cloud dans OpenJarvis, ce n'est plus vrai.
6. **Dépôt GitHub** : ne mettez jamais de clé API, mot de passe ou document client dans ce dépôt. Le `.gitignore` exclut `.env`, les journaux et `secrets/`.
