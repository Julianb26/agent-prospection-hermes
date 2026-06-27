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

## 2026-06-27 (suite 3) — Modèle de facturation des contrats
- Fait :
  - Précision de Julian : l'offre concession a un **setup (paiement unique)** ET un **abonnement
    (récurrent)**. Table `contrat` clarifiée : `montant_setup` (unique) + `montant_recurrent`
    + `recurrence` (mensuel/annuel/aucun). Remplace `frais_installation`/`montant_mensuel`.
  - Couvre tous les cas : concession = setup + abonnement ; formation = setup seul.
    (Point "à affiner" précédent désormais résolu.)

## 2026-06-27 (suite 2) — Nouvel ICP "Formation IA"
- Fait :
  - Julian est aussi **formateur en IA** et veut prospecter des clients pour ses formations.
    Ajouté comme **nouvel ICP "Formation IA"** dans la base multi-ICP existante (B2B) — aucune
    modification de structure, juste une ligne dans `icp`. Bonne validation du choix multi-ICP.
  - Noté un point à affiner : une vente de formation est souvent un **paiement unique**, alors
    que la table `contrat` est pensée « abonnement » (`montant_mensuel`). Prévoir `recurrence`
    (mensuel/ponctuel) et/ou `montant` générique à l'implémentation.
  - Rappel : l'activité **illustrateur événementiel** reste sur une base SÉPARÉE (pas un ICP ici).
- Prochaine étape : inchangée (implémentation Supabase). Définir aussi les critères de
  qualification de l'ICP Formation IA (cible, taille, secteur) le moment venu.

## 2026-06-27 (suite) — Conception de la BDD de prospection (PHASE 6, design seulement)
- Fait :
  - Conception du schéma de la base de prospection Supabase (rien créé sur Supabase, design
    uniquement comme demandé par l'instruction du formateur). Document complet :
    `BDD_PROSPECTION.md`.
  - Choix structurants validés avec Julian :
    - Base **multi-ICP** (pas figée sur l'auto) : ajout d'une table `icp` + champs génériques
      `secteur` / `logiciel_metier` (Mecaplanning, Interfast, autres à venir).
    - 4 tables : `icp`, `entreprise`, `personne`, `activite`.
    - Pipeline **détaillé** (13 statuts : a_qualifier → ... → gagne / perdu / en_pause).
    - L'agent doit : mémoriser, rappeler les relances, rédiger avec le contexte, mettre à jour
      les statuts.
  - Noté pour plus tard : Julian a une **2e activité (illustrateur événementiel mariages /
    pro)** qui nécessitera une **base de prospection séparée**, à concevoir distinctement.
  - Ajout (suite à la remarque du formateur sur les relations prospects/entreprises/clients) :
    distinction **prospect / client** modélisée proprement via une **5e table `contrat`**
    (option "contacts + table contrat" choisie par Julian, qui veut suivre offre, montant,
    date de signature, statut d'abonnement). Un client = une entreprise ayant ≥ 1 contrat.
    Pas de tables séparées prospect/client (éviter les doublons). Schéma final = 5 tables :
    `icp`, `entreprise`, `personne`, `activite`, `contrat`.
  - Précisions sur les champs (selon les priorités terrain de Julian) : ajout de
    `entreprise.linkedin_url` (page LinkedIn de l'entreprise) et `entreprise.marque_reseau`
    (marque/réseau auto, optionnel). `logiciel_metier` rendu explicitement optionnel (pas
    toujours trouvable à l'avance). Critères de qualif. importants pour lui : taille/volume
    (nb RDV atelier/mois), localisation, marque. Pour un contact : coordonnées (email/tél) et
    fonction exacte. Principe retenu : démarrer avec les champs essentiels, ajouter le reste
    plus tard (Supabase permet d'ajouter une colonne sans rien casser).
- État actuel :
  - Schéma conçu et documenté (5 tables). Pas encore implémenté sur Supabase.
- Prochaine étape :
  - Implémentation sur Supabase : créer le projet/les tables, décider comment l'agent y accède
    (clé service / MCP Supabase), et configurer la sécurité (RLS).

## 2026-06-27 — 🎯 OBJECTIF PRINCIPAL ATTEINT
- Fait :
  - **Déploiement de Hermes sur Railway réussi : le bot répond sur Discord, hébergé dans le
    cloud 24h/24, sans terminal local.** Premier message-réponse confirmé.
  - Projet Railway créé (Deploy from GitHub repo), connecté à `agent-prospection-hermes`.
  - Variables d'environnement ajoutées sur Railway : `OPENROUTER_API_KEY`, `DISCORD_BOT_TOKEN`,
    `DISCORD_ALLOWED_USERS`.
  - Création d'un script `start.sh` (lancé par Railway via `railway.json` -> `bash start.sh`)
    qui, au démarrage du conteneur : écrit les secrets dans `/root/.hermes/.env`, force le
    modèle gratuit, fixe provider/base_url OpenRouter, et règle `discord.auto_thread`.
- Blocages rencontrés et résolus (dans l'ordre) :
  1. `hermes: command not found` sur Railway -> utiliser le chemin complet
     `/usr/local/bin/hermes` (le PATH n'est pas fiable sur l'image Nixpacks).
  2. Variables d'env vides dans le conteneur -> Hermes lit le fichier `~/.hermes/.env`, pas les
     variables d'environnement directement : `start.sh` les y recopie au démarrage.
  3. Variables toujours vides malgré tout -> **les variables Railway étaient en attente
     ("Apply N changes" / staged), jamais appliquées : il faut cliquer le bouton "Deploy"
     pour les activer réellement.** (Cause racine du plus gros blocage.)
  4. `DISCORD_ALLOWED_USERS` restait vide (les 2 autres ok) -> valeur de secours codée en dur
     dans `start.sh` (un ID Discord n'est pas une donnée secrète).
  5. Erreur `HTTP 402 Insufficient credits` avec `anthropic/claude-opus-4.6` -> le config.yaml
     de Railway est régénéré à neuf au build (modèle payant par défaut) ; `start.sh` force
     désormais le modèle gratuit `nvidia/nemotron-3-super-120b-a12b:free` à chaque démarrage.
  - NB : le bouton "Redeploy" de Railway réutilise parfois une image obsolète ; pour forcer un
    vrai rebuild, pousser un commit sur GitHub.
- État actuel :
  - **Agent Hermès opérationnel en production sur Railway, interagit via Discord.** Modèle
    gratuit OpenRouter. Réponses dans le canal principal (auto_thread désactivé au dernier
    commit).
- Prochaines étapes (sessions futures, cf. PHASE 6 de l'instruction du formateur) :
  - Réfléchir à la base de données (tables `personne`, `entreprise`, `activite`) AVANT de
    passer sur Supabase.
  - Éventuellement : ajouter des crédits OpenRouter pour utiliser un modèle plus performant,
    définir un "home channel" Discord, activer des skills/outils.

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
