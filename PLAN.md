# Plan — Déployer l'agent Hermès et l'utiliser depuis Discord

Objectif final : pouvoir écrire un message dans Discord et obtenir une réponse de l'agent
[Hermes Agent](https://github.com/NousResearch/hermes-agent) (Nous Research), qui tourne en
permanence sur [Railway](https://railway.app).

Contexte de départ (23/06/2026) :
- Fournisseur LLM choisi : **OpenRouter** (clé API déjà disponible)
- Compte **Railway** déjà créé
- Compte **GitHub** créé : `Julianb26`
- `gh` (GitHub CLI) installé et connecté

---

## Étape 0 — Préparer ce repo (fait le 23/06/2026)
- [x] Créer le repo GitHub `agent-prospection-hermes`
- [x] Créer `PLAN.md` (ce fichier) et `JOURNAL.md` (carnet de bord)

## Étape 1 — Installer et tester Hermes Agent en local (Windows, sans Docker)
But : vérifier que tout fonctionne sur ta machine avant de mettre en ligne sur Railway.
On installe Hermes nativement (pas de conteneur), via le script officiel qui se charge
lui-même d'installer Python, Node.js, etc.
- [x] Dans PowerShell, lancer : `iex (irm https://hermes-agent.nousresearch.com/install.ps1)`
- [x] Lancer `hermes setup` et choisir **OpenRouter** comme fournisseur de modèle, coller la clé API
- [x] Vérifier qu'on peut discuter avec l'agent (validé via Discord, voir Étape 3 — modèle finalement
      réglé sur `nvidia/nemotron-3-super-120b-a12b:free` car le compte OpenRouter n'avait pas de
      crédits pour `openai/gpt-5.4-mini`, qui était payant)

## Étape 2 — Créer le bot Discord (fait le 24/06/2026)
But : avoir un "robot" Discord que Hermes pourra piloter.
- [x] Aller sur https://discord.com/developers/applications et créer une nouvelle application (`Agent_Hermes`)
- [x] Dans l'onglet "Bot", créer le bot et récupérer son **Token** (à garder secret, jamais dans Git)
- [x] Activer les intents nécessaires (Message Content Intent)
- [x] Générer un lien d'invitation (OAuth2 > URL Generator, scope `bot`, permissions de base :
      lire/envoyer des messages) et inviter le bot sur le serveur Discord de test (visible hors ligne dans la liste des membres)

## Étape 3 — Connecter Hermes à Discord en local (fait le 25/06/2026)
But : valider la connexion Discord <-> Hermes avant de la mettre sur Railway.
- [x] Token Discord configuré via `hermes setup` (allowlist restreinte à l'utilisateur `julian_cm_`)
- [x] Lancer `hermes gateway run` (pas `gateway start`, qui exige d'installer un service — voir
      Notes/pièges ci-dessous)
- [x] Envoyer un message au bot sur Discord et vérifier qu'il répond — **fonctionne**
- [ ] (Optionnel) Définir un "home channel" avec `/sethome` dans un canal Discord

## Étape 4 — Déploiement sur Railway (sans Docker) — FAIT le 27/06/2026
But : Railway construit et lance le service à partir d'une commande de build et d'un script
de démarrage — pas de Dockerfile.
- [x] Créer `railway.json` dans le repo (config Nixpacks, sans Docker) :
      build = `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`,
      start = `bash start.sh`
- [x] Créer le projet Railway (Deploy from GitHub repo) et connecter `agent-prospection-hermes`
- [x] Définir les variables d'environnement sur Railway (penser à cliquer **Deploy** pour les
      appliquer ! cf. Notes) :
      - `OPENROUTER_API_KEY`
      - `DISCORD_BOT_TOKEN`
      - `DISCORD_ALLOWED_USERS` (= 700267933410000916)
- [x] Créer `start.sh` qui, au démarrage du conteneur :
      - écrit les secrets dans `/root/.hermes/.env` (Hermes lit un fichier, pas les env vars)
      - force le modèle gratuit `nvidia/nemotron-3-super-120b-a12b:free` (sinon le config.yaml
        régénéré au build repart sur un modèle payant -> erreur 402)
      - règle `discord.auto_thread` (réponses dans le canal principal plutôt qu'en fil)
- [x] Déploiement réussi, service "healthy", aucune erreur bloquante dans les logs

## Étape 5 — Test final en production — FAIT le 27/06/2026
- [x] Message envoyé au bot Discord, **réponse reçue** ("Oui, je suis là ! 👋 ...")
- [x] Confirmé : la réponse vient de l'instance Railway (le terminal local n'était PAS lancé,
      le bot apparaît "en ligne" tout seul)
- [x] Pas d'instance locale à arrêter (on n'a pas installé `hermes gateway` en service local)

## Étape 6 — Suivi
- [ ] Après chaque session de travail, ajouter une entrée dans `JOURNAL.md` (voir le modèle dans ce fichier)
- [ ] Documenter ici toute étape qui aurait changé par rapport à ce plan initial

---

## Notes / pièges connus
- Ne jamais committer un token (Discord, OpenRouter) dans le repo. Utiliser des variables
  d'environnement (`.env` local, ignoré par Git ; variables Railway en production).
- Une seule passerelle Discord doit être active à la fois (locale OU Railway), sinon le bot
  répond en double ou en conflit.
- `hermes gateway start` exige qu'un service (Windows Scheduled Task / systemd / launchd) soit
  installé au préalable (`hermes gateway install`). Pour un test ponctuel sans installer de
  service permanent, utiliser `hermes gateway run` (mode foreground, recommandé aussi pour
  Docker/WSL/Termux — et donc adapté à Railway).
- Si Discord renvoie `PrivilegedIntentsRequired` au démarrage de la gateway : vérifier que
  les 3 intents (Presence, Server Members, Message Content) sont bien activés ET sauvegardés
  dans Discord Developer Portal > Bot > Privileged Gateway Intents (le toggle peut sembler
  activé sans être réellement enregistré — vérifier après un rechargement de page).
- Si le bot répond `Unauthorized user` malgré une résolution de nom d'utilisateur réussie dans
  les logs : renseigner directement l'**ID numérique Discord** dans `DISCORD_ALLOWED_USERS`
  (`hermes config set DISCORD_ALLOWED_USERS <id>`) plutôt que le nom d'utilisateur texte.
- Si OpenRouter renvoie `HTTP 402 Insufficient credits` : le compte n'a pas de crédits pour le
  modèle payant choisi. Soit ajouter des crédits sur https://openrouter.ai/settings/credits,
  soit choisir un modèle gratuit (suffixe `:free`, ex. `nvidia/nemotron-3-super-120b-a12b:free`)
  via `hermes config set model.default <modèle>`.
- **Railway — variables d'environnement** : après les avoir ajoutées/modifiées, elles restent
  en attente ("Apply N changes" / "Edited") tant qu'on ne clique pas sur le bouton **Deploy**.
  Tant que ce n'est pas fait, elles arrivent **vides** dans le conteneur. C'était la cause
  racine du plus gros blocage de ce projet.
- **Railway — Redeploy vs rebuild** : le bouton "Redeploy" réutilise parfois une image déjà
  construite (code/script obsolète). Pour forcer une vraie reconstruction à partir du dernier
  code, pousser un nouveau commit sur GitHub.
- **Railway — Hermes ne lit pas les env vars directement** : il lit le fichier
  `/root/.hermes/.env`. Le script `start.sh` y recopie donc les secrets au démarrage. De même,
  le `config.yaml` est régénéré à neuf à chaque build (modèle payant par défaut) -> `start.sh`
  force le modèle et les réglages Discord à chaque démarrage.
- **Railway — chemin de la commande** : utiliser `/usr/local/bin/hermes` (PATH non fiable sur
  l'image Nixpacks).
- Des avertissements `Auxiliary Nous client unavailable` peuvent apparaître dans les logs si
  aucun compte Nous Portal n'est lié (`hermes auth`) — sans impact sur le fonctionnement
  principal (chat + Discord) si on n'utilise pas les fonctionnalités liées à Nous Portal.
