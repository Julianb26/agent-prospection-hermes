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
