# Jarvis — assistant IA personnel (OpenJarvis) relié à l'iPhone

Kit d'installation pour faire tourner **[OpenJarvis](https://github.com/open-jarvis/OpenJarvis)** (open source, Apache 2.0, Stanford / Lambda) **en local sur le PC Windows**, et pour l'appeler **à la voix depuis l'iPhone** à la place de Siri.

```
 iPhone                                   PC Windows (sp-nord-b-lepot)
 ┌──────────────────────┐   Tailscale     ┌────────────────────────────────┐
 │ Bouton Action /      │   (réseau privé │  jarvis serve  :8000           │
 │ « Dis Siri, Jarvis » │ ─────chiffré──▶ │   └─ moteur Ollama (modèle     │
 │ Raccourci « Jarvis » │ ◀────────────── │      local, ex. qwen3:8b)      │
 │  dicte → envoie →    │                 │  mémoire, outils, fichiers PC  │
 │  lit la réponse      │                 └────────────────────────────────┘
 └──────────────────────┘
```

- **Tout reste chez vous** : le modèle tourne sur le PC, aucune donnée ne part vers un cloud d'IA.
- **Liaison téléphone ↔ PC** : Tailscale crée un réseau privé chiffré entre les deux appareils, au bureau comme en 4G, sans ouvrir de port sur Internet.
- **Remplacement de Siri** : iOS n'autorise pas à remplacer Siri au niveau système. Le raccourci « Jarvis » se lance par le **bouton Action** (iPhone 15 Pro et plus récents), par **Toucher le dos** ou par **« Dis Siri, Jarvis »**. Siri ne sert alors que de déclencheur ; c'est Jarvis qui répond.

## Installation en 4 étapes

| # | Étape | Où | Durée |
|---|-------|----|-------|
| 1 | `scripts\install-windows.ps1` : installe Ollama, Tailscale, OpenJarvis et télécharge le modèle | PC | 15–30 min |
| 2 | Se connecter à Tailscale sur le PC **et** sur l'iPhone (même compte) | PC + iPhone | 5 min |
| 3 | `scripts\register-autostart.ps1` : Jarvis démarre tout seul à l'ouverture de session (raccourci dans le dossier Démarrage, sans droits admin) | PC | 1 min |
| 4 | Créer le raccourci iPhone → [`iphone/RACCOURCI-IPHONE.md`](iphone/RACCOURCI-IPHONE.md) | iPhone | 10 min |

### 1. Installer sur le PC

**Le plus simple — une seule commande** dans PowerShell (installe tout dans `Documents\JARVIS` et programme le démarrage automatique) :

```powershell
irm https://raw.githubusercontent.com/BenjaminLepo/JARVIS/main/scripts/bootstrap.ps1 | iex
```

Ou manuellement : ouvrir **PowerShell** (pas besoin d'administrateur pour la plupart des étapes) dans le dossier du dépôt :

```powershell
git clone https://github.com/BenjaminLepo/jarvis.git
cd jarvis
Set-ExecutionPolicy -Scope Process Bypass
.\scripts\install-windows.ps1            # modèle par défaut : qwen3:8b
# PC sans carte graphique dédiée : modèle plus léger
.\scripts\install-windows.ps1 -Model qwen3:4b
```

### 2. Tailscale

- PC : l'icône Tailscale apparaît dans la barre des tâches → **Log in**.
- iPhone : App Store → **Tailscale** → même compte → activer le VPN.
- Noter le nom du PC sur le réseau Tailscale (ex. `sp-nord-b-lepot.tailXXXX.ts.net`) ou son adresse `100.x.y.z` : `tailscale ip -4`.

### 3. Démarrage automatique

```powershell
.\scripts\register-autostart.ps1
```

Démarrage manuel possible à tout moment : `.\scripts\start-jarvis.ps1`.
Test depuis le PC :

```powershell
.\scripts\test-jarvis.ps1 "Bonjour Jarvis, qui es-tu ?"
```

### 4. iPhone

Suivre [`iphone/RACCOURCI-IPHONE.md`](iphone/RACCOURCI-IPHONE.md).

## Ce que Jarvis peut faire ensuite

OpenJarvis fournit en plus : mémoire persistante (`jarvis memory`), agents (`orchestrator`, `react`…), compétences importables (standard agentskills.io), modules voix (Whisper, synthèse vocale) et canaux de messagerie (Telegram, WhatsApp, iMessage). Voir la [documentation officielle](https://open-jarvis.github.io/OpenJarvis/).

Pistes pour la suite : donner accès à un dossier du PC (documents d'opérations), brancher Outlook, ou passer par Telegram pour écrire à Jarvis en plus de lui parler.

## Sécurité — à lire

Voir [`docs/SECURITE.md`](docs/SECURITE.md). En résumé : le serveur OpenJarvis **n'a pas de mot de passe**, il ne doit donc écouter **que sur l'adresse Tailscale**, jamais sur `0.0.0.0` ni sur le Wi-Fi du bureau. Les scripts le configurent ainsi.

> ⚠️ **PC professionnel** : installer Ollama/Tailscale et faire tourner un serveur sur un poste SPIRIT peut nécessiter l'accord du service informatique. À valider avant l'étape 1.

## Structure

```
scripts/install-windows.ps1     installation complète
scripts/start-jarvis.ps1        démarre le serveur sur l'IP Tailscale
scripts/register-autostart.ps1  tâche planifiée à l'ouverture de session
scripts/test-jarvis.ps1         test rapide de l'API
iphone/RACCOURCI-IPHONE.md      création pas à pas du raccourci « Jarvis »
docs/SECURITE.md                règles de sécurité
jarvis.config.ps1               réglages (modèle, port, agent)
```

Licence : MIT pour ce kit. OpenJarvis est sous licence Apache 2.0.
