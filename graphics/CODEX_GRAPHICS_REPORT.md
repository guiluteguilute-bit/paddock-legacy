# Rapport Codex Graphics

## MISSION

**Fondation graphique / Vertical Slice** — identité sombre premium, bibliothèque modulaire légère et démonstrations Godot 4 pour Paddock Legacy. Aucun gameplay, aucune simulation et aucune donnée de carrière n'ont été implémentés.

## ASSETS CRÉÉS

- 100 SVG enregistrés : kart, F4, circuit, 12 props, 6 motifs de livrée, 33 icônes, 8 sponsors, 6 écuries, 8 drapeaux, 4 portraits assemblés, 13 composants de portrait et 6 placeholders.
- Un thème Godot centralisé et deux shaders CanvasItem.
- Quatre effets de particules : pluie, poussière, étincelles et fumée. Le spray dérive de la fumée conformément au guide, le glow de sélection utilise le shader dédié, et la notification est prévue par Tween.
- Un système de tokens, d'identifiants stables et de manifeste versionné.

## ASSETS MODIFIÉS

Aucun asset antérieur n'existait dans le dépôt.

## ASSETS SUPPRIMÉS

Aucun.

## DOSSIERS CRÉÉS

La hiérarchie `graphics/` demandée a été créée : UI, icônes par domaine, véhicules, circuits, bâtiments, portraits, drapeaux, logos, sponsors, effets, shaders, sources, placeholders, manifeste et démonstrations. Le dossier `shared/` contient les quatre registres communs.

## MANIFESTE MODIFIÉ

`shared/graphics_manifest.json` recense 110 entrées avec chemin Godot, type et version. `shared/asset_ids.json` expose les mêmes 110 identifiants stables.

## SCÈNES DE DÉMONSTRATION

- `graphics/demo/ui_demo.tscn` : menu principal, ambiance paddock et sauvegarde active.
- `graphics/demo/dashboard_demo.tscn` : barre d'état, navigation, prochaine course, pilote, objectifs et messages.
- `graphics/demo/race_visual_demo.tscn` : circuit, deux karts et HUD course (classement, tour, météo, pneu, rythme, carburant et état voiture).
- `graphics/effects/*.tscn` : émetteurs graphiques réutilisables, sans logique métier.

## TAILLE APPROXIMATIVE DES NOUVEAUX ASSETS

Environ **700 Ko** non compressés pour l'ensemble de la fondation (sources et documentation comprises). Les assets visuels reposent principalement sur des SVG compacts ; aucune texture géante ni dépendance 3D n'est incluse.

## TESTS / VÉRIFICATIONS EFFECTUÉS

- Parsing XML de tous les SVG.
- Parsing JSON des fichiers shared.
- Vérification de toutes les entrées du manifeste et de tous les chemins `res://` des scènes.
- Vérification de la présence des catégories, IDs et variantes demandés.
- Godot n'est pas installé dans l'environnement : l'import et le rendu final n'ont pas pu être exécutés ici.

## LIMITATIONS ACTUELLES

- Les démonstrations sont purement visuelles et statiques, par séparation volontaire avec le gameplay de Claude.
- Les numéros visibles sur les véhicules illustrent leur emplacement ; l'intégration finale doit les superposer avec des Labels dynamiques.
- Les composants de portrait constituent une base (4 têtes, 6 coiffures, 4 tons de peau, 3 combinaisons), pas un générateur complet.
- Le circuit est une vertical slice SVG ; une future intégration pourra le découper en TileMap ou Path2D selon les besoins de simulation.
- Les variations avancées safe-area et ultrawide restent à contrôler sur appareils réels.

## ASSETS PLACEHOLDERS RESTANTS

Des placeholders sont prévus pour voiture, pilote, équipe, circuit, logo et icône. Restent volontairement à produire : véhicules supplémentaires, environnements régionaux, bâtiments détaillés, portraits en volume, panneaux partenaires additionnels et variantes nocturnes.

## PROPOSITION POUR LA PROCHAINE MISSION

Après retour d'intégration de Claude : valider les scènes sur appareils Android/iOS, construire un atlas UI, ajouter une seconde vue/direction pour chaque véhicule si la caméra de course l'exige, puis produire un kit de circuit régional et des variations de cartes sans modifier les IDs existants.
