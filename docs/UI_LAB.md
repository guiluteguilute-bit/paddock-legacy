# Paddock Legacy — UI Lab

Le UI Lab sert à inspecter les vrais écrans du jeu sans modifier la sauvegarde du joueur.

## Accès Web

Sur la version GitHub Pages, ajouter le hash suivant à l'URL du jeu :

`#ui-lab/01`

Exemples :

- `#ui-lab/01` — choix du gérant
- `#ui-lab/02` — identité de l'écurie
- `#ui-lab/03` — résumé avant carrière
- `#ui-lab/04` — tableau de bord
- `#ui-lab/15` — préparation de course
- `#ui-lab/16` — session LIVE
- `#ui-lab/17` — stratégie Pit Stop
- `#ui-lab/18` — résultats de course
- `#ui-lab/25` — paramètres

Une barre développeur apparaît en haut de l'écran avec :

- le numéro SCREEN-XX ;
- le groupe ;
- le nom exact de l'écran ;
- précédent / suivant ;
- un sélecteur de tous les écrans ;
- un bouton pour masquer la barre ;
- un bouton pour quitter le UI Lab.

## Sécurité

Le UI Lab :

- garde une copie en mémoire de la vraie sauvegarde ;
- remplace temporairement les données par une carrière de démonstration ;
- désactive les boutons, champs et sliders des écrans prévisualisés ;
- ne lance aucune action d'achat, d'entraînement ou de progression depuis les écrans inspectés ;
- restaure les données d'origine quand on quitte le mode ;
- ne change pas le fichier `user://career.json`.

## Catalogue canonique

Le catalogue est stocké dans :

`game/data/screen_catalog.json`

Les IDs sont séquentiels et stables. Pour les demandes de modification, utiliser toujours la forme :

`SCREEN-05 : modifier ...`

Le test `tests/validate_ui_catalog.py` vérifie automatiquement :

- les IDs ;
- l'unicité du catalogue ;
- l'existence de chaque méthode de rendu ;
- l'activation de l'autoload ScreenLab ;
- les garde-fous d'isolation de sauvegarde.

## Liste actuelle

01. Choix du gérant
02. Identité de l'écurie
03. Résumé avant carrière
04. Tableau de bord
05. Pyramide de carrière
06. Hub GT / Endurance
07. Concession GT
08. Stratégie Endurance
09. Vue écurie
10. Menu Plus
11. Calendrier
12. Championnat
13. Véhicule et développement
14. Finances
15. Préparation de course
16. Session LIVE
17. Feuille de stratégie Pit Stop
18. Résultats de course
19. Développement pilote
20. Sponsors
21. Personnel et infrastructures
22. Palmarès
23. Fin de saison
24. Offres de carrière
25. Paramètres

Le catalogue doit être mis à jour dès qu'un nouvel écran important est ajouté ou supprimé.
