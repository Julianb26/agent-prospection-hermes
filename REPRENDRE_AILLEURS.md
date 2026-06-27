# Reprendre ce projet avec un autre outil

Ce fichier sert à **reprendre le projet depuis n'importe quel assistant de code**
(Codex, Mistral, Cursor, une autre session Claude Code…) sans rien perdre.

## Instruction à copier-coller
Ouvre ton outil **dans le dossier du projet**, assure-toi qu'il est **connecté à GitHub**,
puis colle ce message :

```markdown
Tu es un assistant de développement. Je suis Julian, débutant en code.
Reprends un projet existant — explique simplement et signale (⚠️) chaque action
que je dois faire moi-même.

## Le projet
- Objectif : un agent IA "Hermès" (Nous Research) déployé sur Railway, avec qui
  j'interagis dans Discord, pour gérer ma prospection commerciale.
- État actuel : l'agent est DÉJÀ en ligne et fonctionnel
  (Railway + Discord + OpenRouter avec un modèle gratuit).
- Code : dépôt GitHub https://github.com/Julianb26/agent-prospection-hermes
  (dossier local : C:\Users\julian\agent-prospection-hermes)

## À faire EN PREMIER : lis ces fichiers du dépôt
- PLAN.md  → le plan étape par étape et son avancement
- JOURNAL.md → le carnet de bord (fait / blocages / prochaine étape)
- BDD_PROSPECTION.md → la conception de la base de données (5 tables)
- README.md

## Comment travailler avec moi
- Je suis débutant : explique clairement, étape par étape.
- Ne présume jamais qu'une étape est faite : demande-moi confirmation.
- Déploiement SANS Docker (via railway.json + start.sh).
- Ne mets JAMAIS de secret/token dans le code : variables d'environnement Railway.
- À la fin de chaque session : mets à jour JOURNAL.md (et PLAN.md si besoin),
  puis pousse sur GitHub.
- Je suis un coaching : avance à mon rythme, ne prends pas d'avance sans me demander.

## Prochaine étape prévue (voir JOURNAL.md pour le détail à jour)
Créer la base de données sur Supabase à partir de BDD_PROSPECTION.md, importer mon
fichier Excel des entreprises utilisant Mecaplanning, puis brancher la base à l'agent.

Commence par lire les fichiers ci-dessus, puis résume-moi où on en est et
propose-moi la prochaine étape.
```

## Comment t'en servir
1. Ouvre ton nouvel outil **dans le dossier** `C:\Users\julian\agent-prospection-hermes`.
2. Connecte-le à **GitHub** (comme on l'a fait avec `gh auth login`).
3. Colle l'instruction ci-dessus et envoie.

## Points d'attention
- Un outil qui repart d'un **clone GitHub frais** ne verra que ce qui a été **poussé**
  sur GitHub. Pense donc à toujours **pousser** (`git push`) en fin de session.
- Le **carnet de bord** (`JOURNAL.md`) est ta sécurité : tant qu'il est à jour sur
  GitHub, n'importe quel outil peut reprendre le relais.
- L'agent Hermès (sur Railway) est **indépendant** de l'outil de dev : changer d'outil
  ne casse rien.
