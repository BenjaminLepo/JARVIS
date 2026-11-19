# Raccourci iPhone « Jarvis »

Le raccourci écoute votre question, l'envoie à Jarvis sur le PC (via Tailscale) et lit la réponse à voix haute.

**Prérequis** : Tailscale installé et **activé** sur l'iPhone, Jarvis démarré sur le PC, et la clé d'accès Jarvis (créée par `scripts\setup-key.ps1`, copiée dans `secrets\jarvis-key.txt`).
Astuce pour la transférer sur l'iPhone sans la retaper : ouvrez `secrets\jarvis-key.txt`, copiez la clé, puis envoyez-la-vous (note, mail à vous-même) et supprimez ce message une fois le raccourci créé.
Adresse du PC : `http://ADRESSE-PC:8000`, où `ADRESSE-PC` est le nom Tailscale du PC (`sp-nord-b-lepot.tailXXXX.ts.net`) ou son IP `100.x.y.z` (commande `tailscale ip -4` sur le PC).

## Créer le raccourci (app Raccourcis)

1. **Raccourcis** → **+** → renommer le raccourci **Jarvis**.
2. Action **Dicter le texte**
   - Langue : Français
   - Arrêter l'écoute : *Après une pause*
3. Action **Obtenir le contenu de l'URL**
   - URL : `http://ADRESSE-PC:8000/v1/chat/completions`
   - Toucher **›** pour déplier :
     - Méthode : **POST**
     - En-têtes :
       - `Content-Type` = `application/json`
       - `Authorization` = `Bearer ` suivi de la clé Jarvis (fichier `secrets\jarvis-key.txt` sur le PC, ex. `Bearer jv_3f9a…`)
     - Corps de la requête : **JSON**, avec les champs :
       | Clé | Type | Valeur |
       |-----|------|--------|
       | `model` | Texte | `qwen3:8b` (le même que dans `jarvis.config.ps1`) |
       | `messages` | Tableau | 2 éléments de type **Dictionnaire** (ci-dessous) |
     - Élément 1 du tableau : `role` = `system` ; `content` = `Tu es Jarvis, l'assistant personnel de Benjamin. Réponds en français, en deux ou trois phrases, sans mise en forme.`
     - Élément 2 du tableau : `role` = `user` ; `content` = variable **Texte dicté**
4. Action **Obtenir la valeur du dictionnaire** → clé `choices.1.message.content` dans *Contenu de l'URL* (une seule action suffit grâce à ce chemin)
5. Action **Énoncer le texte** → *Valeur du dictionnaire* (voix française, ex. Thomas)
6. *(facultatif)* Action **Afficher le résultat** pour voir la réponse écrite.

## Le lancer à la place de Siri

| Méthode | Réglage |
|--------|---------|
| **Bouton Action** (iPhone 15 Pro et plus récents) | Réglages → Bouton Action → **Raccourci** → *Jarvis* |
| **Toucher le dos** (tous les iPhone récents) | Réglages → Accessibilité → Toucher → Toucher le dos → Toucher deux fois → *Jarvis* |
| **À la voix** | « Dis Siri, Jarvis » |
| **Écran d'accueil / verrouillé** | Widget Raccourcis, ou contrôle dans le Centre de contrôle |

## Dépannage

- **« Impossible de se connecter au serveur »** : Tailscale est-il activé sur l'iPhone ? Le PC est-il allumé avec la session ouverte ? Testez sur le PC avec `.\scripts\test-jarvis.ps1`.
- **Erreur 401 / « Unauthorized »** : la clé dans l'en-tête `Authorization` est absente ou fausse. Format exact : `Bearer ` + clé, avec un espace.
- **Réponse très lente** : prenez un modèle plus léger (`qwen3:4b`) dans `jarvis.config.ps1` et sur le raccourci, puis `ollama pull qwen3:4b` et redémarrez Jarvis.
- **Le raccourci coupe avant la réponse** : dans l'action « Obtenir le contenu de l'URL », iOS attend jusqu'à environ 60 s. Raccourcissez la consigne système ou prenez un modèle plus léger.
