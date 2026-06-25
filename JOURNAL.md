# Carnet de bord

But de ce fichier : à la fin de chaque session de travail sur ce projet, ajouter une entrée
ci-dessous (la plus récente en haut). Ça permet de reprendre rapidement la prochaine fois :
ce qui a été fait, ce qui bloque, et la prochaine action concrète à faire.

Modèle à copier-coller pour une nouvelle entrée :

```
## AAAA-MM-JJ
- Fait :
- Blocages / problèmes rencontrés :
- État actuel :
- Prochaine étape :
```

---

## 2026-06-25
- Fait :
  - Résolution du blocage Discord : les 3 "Privileged Gateway Intents" (Presence, Server
    Members, Message Content) ont été activés ET sauvegardés dans le Developer Portal — le
    toggle semblait s'activer sans se sauvegarder réellement, il a fallu les cocher tous les
    trois (pas seulement Message Content) pour que ça persiste.
  - `hermes gateway run` (mode foreground) lancé avec succès en local : `Agent_Hermes` répond
    bien aux messages envoyés sur Discord, l'utilisateur `julian_cm_` est reconnu et autorisé.
  - Résolution d'un second blocage : le compte OpenRouter n'avait pas de crédits pour le modèle
    payant `openai/gpt-5.4-mini` (erreur HTTP 402). Changement du modèle par défaut vers
    `nvidia/nemotron-3-super-120b-a12b:free` (gratuit) via `hermes config set model.default`.
  - Création de `railway.json` dans le repo (config Nixpacks sans Docker : build via
    `install.sh`, démarrage via `hermes gateway run`), commité et poussé sur GitHub.
  - Reprise du déroulé sous la forme imposée par l'instruction du formateur (numérotation
    ÉTAPE 1 à 9), en conservant le travail déjà fait — vérifié via la transcription de la vidéo
    du formateur que l'Étape 1 (lier GitHub à Claude) correspond bien à `gh auth login`, déjà
    réalisé.
  - Résolution d'un troisième blocage : malgré la résolution apparente de `julian_cm_` vers son
    ID Discord dans les logs (`[Discord] Resolved 'julian_cm_' -> 700267933410000916`), le bot
    rejetait quand même les messages (`Unauthorized user`). Corrigé en configurant directement
    l'ID numérique dans `DISCORD_ALLOWED_USERS` (au lieu du nom d'utilisateur texte) via
    `hermes config set DISCORD_ALLOWED_USERS 700267933410000916`, puis relance de la gateway.
    **Confirmé fonctionnel.**
- Blocages / problèmes rencontrés :
  - `hermes gateway start` ne fonctionne pas sans avoir installé un service au préalable
    (`hermes gateway install`) — pour un test ponctuel, la bonne commande est
    `hermes gateway run` (mode foreground).
  - Des avertissements `Auxiliary Nous client unavailable` apparaissent en boucle dans les
    logs (lié à l'absence de compte Nous Portal) — sans impact constaté sur le fonctionnement
    réel du chat Discord, donc ignorés pour l'instant.
  - La résolution automatique de nom d'utilisateur Discord (`julian_cm_`) vers un ID dans
    `DISCORD_ALLOWED_USERS` ne semble pas fiable (log de résolution réussi, mais rejet quand
    même) — préférer renseigner directement l'**ID numérique Discord** dans cette variable.
- État actuel :
  - **Hermes fonctionne en local et répond sur Discord** avec un modèle gratuit OpenRouter.
    `railway.json` est prêt dans le repo. Rien n'est encore déployé sur Railway : il reste à
    créer le projet Railway, le connecter au repo GitHub, ajouter les variables d'environnement
    (OPENROUTER_API_KEY, DISCORD_BOT_TOKEN, DISCORD_ALLOWED_USERS) et lancer le premier
    déploiement.
- Prochaine étape :
  - Étape 4 du PLAN.md (Étape 8-9 dans la numérotation de l'instruction du formateur) :
    créer le projet Railway, connecter le repo GitHub, configurer les variables d'environnement,
    et valider le premier déploiement.

## 2026-06-24
- Fait :
  - Installation de Hermes Agent en local sur Windows, sans Docker, via le script officiel
    `install.ps1` (Python 3.11, Node.js, ripgrep, ffmpeg déjà présents ou installés
    automatiquement). NB : une installation Hermes existait déjà sur la machine avant cette
    session (mise à jour effectuée par le script plutôt qu'installation neuve).
  - Configuration via `hermes setup` (mode interactif, dans un terminal séparé) :
    - Fournisseur de modèle : **OpenRouter**, modèle choisi : `openai/gpt-5.4-mini` (peu coûteux)
    - Terminal backend : Local (cohérent avec un futur déploiement Railway sans Docker)
    - Browser tool : Local Browser (gratuit, Chromium headless via Playwright)
    - Génération d'images et TTS : configuration ignorée/passée pour l'instant (non
      nécessaires pour ce projet)
    - Discord : token configuré, accès restreint à l'utilisateur Discord `julian_cm_`
      (allowlist), pas de "home channel" défini pour l'instant
    - Gateway installée comme service au démarrage : **refusé** volontairement, pour éviter
      un conflit plus tard avec l'instance qui tournera sur Railway
  - Création du bot Discord `Agent_Hermes` sur https://discord.com/developers/applications :
    Message Content Intent activé, permissions de base (envoyer/lire messages, fichiers,
    réactions, commandes slash), invité avec succès sur le serveur Discord de test (visible
    hors ligne dans la liste des membres, ce qui est normal tant que la gateway n'est pas
    lancée)
- Blocages / problèmes rencontrés :
  - Le compte GitHub a dû être créé pendant la session précédente avant de pouvoir utiliser
    `gh` (pas de blocage technique aujourd'hui)
  - Erreur de validation Discord "Private application cannot have a default authorization
    link" en sauvegardant l'onglet Bot — résolue en remettant le toggle "Bot public" sur actif
  - Sélection involontaire d'un fournisseur TTS (Google Gemini) au lieu de "Skip" — résolue en
    laissant le champ "Gemini API key" vide et en validant avec Entrée
  - PowerShell fermé par erreur en cours de route — sans conséquence, il suffit de relancer
    `hermes setup`, les étapes déjà validées restent enregistrées
- État actuel :
  - Hermes est installé et configuré en local avec OpenRouter + Discord, mais **la passerelle
    (`hermes gateway start`) n'a pas encore été lancée** : on n'a donc pas encore testé
    l'échange réel de messages avec le bot sur Discord.
  - Rien n'est encore déployé sur Railway.
- Prochaine étape :
  - Étape 3 du PLAN.md : lancer `hermes gateway start` en local et envoyer un message au bot
    Discord pour valider que tout fonctionne, avant de passer au déploiement Railway (Étape 4).

## 2026-06-23
- Fait :
  - Installation de GitHub CLI (`gh`) sur Windows, authentification réussie (compte `Julianb26`)
  - Vérification du repo `NousResearch/hermes-agent` (projet réel, actif, licence MIT)
  - Création du repo GitHub `agent-prospection-hermes` (public)
  - Rédaction de `PLAN.md` (plan étape par étape) et de ce `JOURNAL.md`
- Blocages / problèmes rencontrés :
  - `gh` n'était pas reconnu directement dans le terminal juste après l'installation
    (PATH pas encore rechargé) — contourné en utilisant le chemin complet
    `C:\Program Files\GitHub CLI\gh.exe`. Si ça arrive encore : fermer et rouvrir le terminal.
- État actuel :
  - Le repo existe sur GitHub mais Hermes Agent n'est pas encore installé, ni en local ni
    sur Railway. Aucun bot Discord créé pour l'instant.
- Prochaine étape :
  - Étape 1 du PLAN.md : installer Hermes Agent en local sur Windows et le configurer avec
    la clé API OpenRouter.
