# Conception de la base de données de prospection (Supabase)

> ⚠️ PHASE DE CONCEPTION uniquement. Rien n'est encore créé sur Supabase.
> Ce document décrit la structure cible, à implémenter lors d'une prochaine session.

## Objectif
Permettre à l'agent Hermès de :
1. **Mémoriser** les contacts et les entreprises prospectées
2. **Rappeler** les relances à faire (suivi des dates)
3. **Rédiger** les messages de prospection en s'appuyant sur l'historique stocké
4. **Mettre à jour** automatiquement le statut et l'historique après chaque action

## Principe : base multi-ICP
La base ne doit PAS être figée sur l'automobile. Elle gère plusieurs cibles (ICP) :
- ICP principal : concessions / pros de l'auto (IA vocale de RDV atelier connectée **Mecaplanning**)
- ICP : **Formation IA** — entreprises/pros à qui Julian vend ses formations en IA (B2B)
- ICP futurs : artisans sous **Interfast**, et d'autres à venir

👉 Ajouter un nouvel ICP = **une simple ligne dans la table `icp`**, aucune modification de
structure. Les champs propres à l'auto (`marque_reseau`, `logiciel_metier=Mecaplanning`)
restent simplement vides pour les autres ICP.

Pour cela : une table `icp` liste les cibles, et les champs sont génériques
(`secteur`, `logiciel_metier`) plutôt que spécifiques à l'auto.

La base distingue aussi **prospects et clients** (voir section dédiée plus bas) grâce à une
table `contrat`, sans dupliquer les contacts.

> Note : la prospection de l'activité **illustrateur événementiel** (mariages / événements
> pro) fera l'objet d'une **base séparée**, conçue plus tard. Ne pas la mélanger ici.

## Prospect vs Client
Un **prospect** et un **client** ne sont pas dans des tables séparées : c'est la même
entreprise / personne à deux moments de la relation. On les distingue ainsi :
- **prospect** = une `personne` dont le `statut_pipeline` n'est pas encore `gagne`.
- **client** = une `entreprise` qui possède au moins une ligne dans la table `contrat`.

Quand un prospect signe, on ne le déplace nulle part : on crée simplement un `contrat`.
Cela évite les doublons et conserve tout l'historique de prospection.

---

## Les 5 tables

### 1. `icp` — tes profils de cible
| Colonne | Type | Rôle |
|---|---|---|
| id | uuid (PK) | identifiant |
| nom | text | ex : "Concession auto", "Artisan Interfast" |
| secteur | text | ex : "Automobile", "BTP" |
| logiciel_cible | text | ex : "Mecaplanning", "Interfast" |
| description | text | à quoi ressemble un bon prospect |
| criteres | text | critères de qualification |
| priorite | int | 1 = prioritaire |
| actif | bool | cible active ou non |
| created_at | timestamptz | date de création |

### 2. `entreprise` — l'organisation prospectée
| Colonne | Type | Rôle |
|---|---|---|
| id | uuid (PK) | identifiant |
| icp_id | uuid (FK → icp) | à quelle cible elle appartient |
| nom | text | nom de l'entreprise |
| secteur | text | secteur d'activité |
| logiciel_metier | text | Mecaplanning / Interfast / autre / inconnu — **optionnel** (souvent découvert pendant l'échange ou la démo, pas toujours trouvable à l'avance) |
| site_web | text | |
| linkedin_url | text | **page LinkedIn de l'entreprise** |
| marque_reseau | text | marque(s) / réseau auto — spécifique auto, optionnel (vide pour les autres ICP) |
| ville | text | |
| departement | text | |
| region | text | |
| taille | text | nb salariés ou **nb de RDV atelier / mois** (proxy du potentiel) |
| statut_icp | text | cible_prioritaire / secondaire / hors_cible |
| attributs | jsonb | champs spécifiques au secteur (optionnel, avancé) |
| source | text | d'où vient le prospect |
| notes | text | |
| created_at / updated_at | timestamptz | |

### 3. `personne` — le décideur / contact
| Colonne | Type | Rôle |
|---|---|---|
| id | uuid (PK) | identifiant |
| entreprise_id | uuid (FK → entreprise) | rattachement à l'entreprise |
| prenom | text | |
| nom | text | |
| fonction | text | DG, chef après-vente, gérant… |
| linkedin_url | text | |
| email | text | |
| telephone | text | |
| statut_pipeline | text | étape (voir pipeline ci-dessous) |
| sous_statut | text | précision (ex : type d'objection) |
| nb_relances | int | compteur de relances |
| concurrent_en_test | text | solution concurrente éventuelle |
| raison_perte | text | si perdu, pourquoi |
| proprietaire | text | qui gère ce contact (toi) |
| date_dernier_contact | date | |
| date_prochaine_relance | date | **clé du suivi** |
| source | text | LinkedIn, salon, reco… |
| notes | text | |
| created_at / updated_at | timestamptz | |

### 4. `activite` — l'historique des interactions
| Colonne | Type | Rôle |
|---|---|---|
| id | uuid (PK) | identifiant |
| personne_id | uuid (FK → personne) | contact concerné |
| entreprise_id | uuid (FK → entreprise) | (dénormalisé, pratique pour filtrer) |
| type | text | message_linkedin, relance, email, appel, demo_envoyee, demo_faite, reponse, note, statut_change |
| canal | text | linkedin / email / telephone / whatsapp / autre |
| direction | text | sortant / entrant |
| date | timestamptz | quand |
| resume | text | contenu / résumé de l'échange |
| resultat | text | positif / neutre / negatif / objection / sans_reponse |
| prochaine_action | text | ce qu'il faut faire ensuite |
| date_prochaine_action | date | |
| created_at | timestamptz | |

### 5. `contrat` — l'abonnement d'un client
| Colonne | Type | Rôle |
|---|---|---|
| id | uuid (PK) | identifiant |
| entreprise_id | uuid (FK → entreprise) | le client (l'entreprise) |
| personne_id | uuid (FK → personne) | contact signataire / référent (optionnel) |
| offre | text | ex : "IA vocale RDV atelier" |
| date_signature | date | |
| date_debut | date | début de l'abonnement |
| date_fin | date | null si toujours actif |
| montant_setup | numeric | **paiement unique initial** : setup concession, ou prix d'une formation |
| montant_recurrent | numeric | **montant de l'abonnement** récurrent (vide/0 si pas d'abonnement) |
| recurrence | text | mensuel / annuel / aucun |
| statut_abonnement | text | actif / en_pause / resilie / impaye (concerne la partie récurrente) |
| date_prochain_renouvellement | date | pour anticiper les renouvellements |
| notes | text | |
| created_at / updated_at | timestamptz | |

---

## Pipeline détaillé (valeurs de `statut_pipeline`)
1. `a_qualifier` — prospect repéré, pas encore vérifié
2. `a_contacter` — qualifié, à contacter
3. `contacte` — 1er message envoyé
4. `relance` — relancé (voir `nb_relances`)
5. `en_conversation` — a répondu, échange en cours
6. `objection` — objection à traiter (préciser dans `sous_statut`)
7. `demo_proposee` — démo proposée
8. `demo_faite` — démo réalisée
9. `en_test` — en test / POC (noter `concurrent_en_test` si pertinent)
10. `en_negociation` — discussion commerciale / attente de signature
11. `gagne` — client signé
12. `perdu` — perdu (préciser `raison_perte`)
13. `en_pause` — à recontacter plus tard

---

## Relations (résumé)
- un `icp` → plusieurs `entreprise`
- une `entreprise` → plusieurs `personne` (les prospects/contacts)
- une `entreprise` → plusieurs `contrat` (devient cliente dès qu'elle en a un)
- une `personne` → plusieurs `activite`
- une `personne` → plusieurs `contrat` (en tant que signataire, lien optionnel)

## Choix techniques retenus
- Identifiants en `uuid` (standard Supabase).
- Statuts et types stockés en `text` (avec liste de valeurs documentée ici) plutôt qu'en
  type enum figé : plus simple à faire évoluer quand on ajoute un ICP ou une étape.
- `attributs jsonb` sur `entreprise` pour les champs propres à un secteur, sans casser la
  structure commune (optionnel, à n'utiliser que si besoin).

## Importer une liste existante (ex : fichier Excel Mecaplanning)
Julian dispose déjà d'un fichier Excel listant des entreprises **utilisant Mecaplanning**.
Supabase permet d'importer directement un CSV/Excel dans une table.

Distinction importante à respecter à l'import :
- **`source`** = la provenance de la donnée → `"Import Excel Mecaplanning"`.
- **`logiciel_metier`** = la caractéristique de l'entreprise → `"Mecaplanning"` (c'est CE champ
  qui rend la liste exploitable : on peut filtrer "toutes les entreprises sous Mecaplanning"
  quelle que soit leur provenance).
- **`statut_icp`** = `"cible_prioritaire"` (les utilisateurs Mecaplanning sont les prospects
  les plus chauds, puisque l'IA vocale s'y connecte directement).

Plan d'import (à faire lors de l'implémentation) : créer la table `entreprise`, puis importer
l'Excel en remplissant ces 3 champs pour tout le lot. Ne PAS coder "utilise Mecaplanning"
uniquement dans `source` (sinon non filtrable proprement).

## Modèle de facturation d'un contrat (setup + abonnement)
Un `contrat` peut porter **deux composantes** en même temps :
- **`montant_setup`** : paiement unique (le setup en concession, ou le prix d'une formation).
- **`montant_recurrent`** + **`recurrence`** : l'abonnement récurrent (mensuel / annuel).

Exemples :
- **Concession auto** : `montant_setup` (installation) + `montant_recurrent` mensuel (abonnement IA vocale).
- **Formation IA** : `montant_setup` seul (prix de la formation), `montant_recurrent` vide, `recurrence` = `aucun`.

## À décider lors de l'implémentation (prochaine session)
- Comment l'agent écrit/lit dans Supabase (clé API service, ou MCP Supabase, ou table API).
- Sécurité (RLS Postgres) — la base ne doit être accessible que par toi / l'agent.
- Faut-il une table `utilisateur` si plusieurs personnes utilisent l'agent (a priori non pour l'instant).
