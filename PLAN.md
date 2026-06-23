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
- [ ] Dans PowerShell, lancer : `iex (irm https://hermes-agent.nousresearch.com/install.ps1)`
- [ ] Lancer `hermes setup` et choisir **OpenRouter** comme fournisseur de modèle, coller la clé API
- [ ] Lancer `hermes` en mode terminal et vérifier qu'on peut discuter avec l'agent en local

## Étape 2 — Créer le bot Discord
But : avoir un "robot" Discord que Hermes pourra piloter.
- [ ] Aller sur https://discord.com/developers/applications et créer une nouvelle application
- [ ] Dans l'onglet "Bot", créer le bot et récupérer son **Token** (à garder secret, jamais dans Git)
- [ ] Activer les intents nécessaires (Message Content Intent)
- [ ] Générer un lien d'invitation (OAuth2 > URL Generator, scope `bot`, permissions de base :
      lire/envoyer des messages) et inviter le bot sur ton serveur Discord de test

## Étape 3 — Connecter Hermes à Discord en local
But : valider la connexion Discord <-> Hermes avant de la mettre sur Railway.
- [ ] Lancer `hermes gateway setup` et renseigner le token du bot Discord
- [ ] Lancer `hermes gateway start`
- [ ] Envoyer un message au bot sur Discord et vérifier qu'il répond

## Étape 4 — Préparer le déploiement sur Railway (sans Docker)
But : Railway peut construire et lancer le service à partir d'une simple commande de build
et d'une commande de démarrage — pas besoin d'écrire de Dockerfile.
- [ ] Créer un nouveau projet sur Railway (railway.app > New Project)
- [ ] Ajouter un service "Empty Service" (ou connecté à ce repo GitHub)
- [ ] Dans les Settings du service Railway, définir :
      - **Build Command** : `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`
      - **Start Command** : la commande qui lance la passerelle Hermes/Discord (à confirmer
        une fois l'installation locale faite, ex. `hermes gateway start`)
- [ ] Définir les variables d'environnement sur Railway :
      - clé API OpenRouter
      - token du bot Discord
      - toute autre variable demandée par `hermes setup` en local
- [ ] Lancer le déploiement et suivre les logs Railway jusqu'à ce que le service soit "healthy"

## Étape 5 — Test final en production
- [ ] Envoyer un message au bot Discord (le même serveur de test, ou un serveur définitif)
- [ ] Vérifier que la réponse vient bien de l'instance Railway (et plus de ta machine locale)
- [ ] Arrêter le `hermes gateway start` en local pour ne pas avoir deux instances qui répondent en même temps

## Étape 6 — Suivi
- [ ] Après chaque session de travail, ajouter une entrée dans `JOURNAL.md` (voir le modèle dans ce fichier)
- [ ] Documenter ici toute étape qui aurait changé par rapport à ce plan initial

---

## Notes / pièges connus
- Ne jamais committer un token (Discord, OpenRouter) dans le repo. Utiliser des variables
  d'environnement (`.env` local, ignoré par Git ; variables Railway en production).
- Une seule passerelle Discord doit être active à la fois (locale OU Railway), sinon le bot
  répond en double ou en conflit.
