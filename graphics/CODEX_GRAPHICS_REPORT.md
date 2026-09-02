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

---

## MISSION 2 — KARTING CAREER VISUAL KIT

### Assets créés

- Une identité complète **Regional Kart Series** : logo, trophée, header et badge régional.
- Le kit modulaire `regional_kart_environment_01` : asphalte, vibreur, herbe, gravier, pneus, barrière, grillage, panneau, ligne de départ, grille, pitlane, paddock, bâtiment chrono, tribune, arbre, lampadaire et commissaire.
- Trois circuits fictifs partageant ce kit : `track_kart_regional_01` technique, `02` rapide et `03` mixte.
- Deux nouvelles variantes du kart V2, sept composants séparés et huit motifs de casque. Les trois karts utilisent les couleurs sentinelles primaire, secondaire et accent.
- Six logos d'écurie supplémentaires (12 au total) et quatre sponsors supplémentaires (12 au total), tous fictifs et lisibles en petite taille.
- Quatre têtes et quatre coiffures supplémentaires, portant le système à 8 têtes et 10 coiffures, plus quatre fonds modulaires. Les combinaisons, tons de peau et portraits assemblés de Mission 1 restent disponibles.
- Cinq scènes UI réutilisables : carte championnat, carte événement, carte sponsor, cinq feux de départ et collection des cinq notifications.

### Assets modifiés

- `car_kart_01` passe en version visuelle 2 avec roues, moteur, châssis, pilote/casque et carrosserie plus détaillés. Son Asset ID est conservé.
- `race_visual_demo` passe en version 2 : cadrage incliné, piste régionale, ligne idéale subtile, trois karts numérotés, classement, tours, chrono, météo, drapeau, position, pneus et rythme.
- `graphics/README_GRAPHICS.md` documente le kit régional et le parcours carrière.

### Nouvelles scènes

- `team_creation_demo.tscn`
- `driver_profile_demo.tscn`
- `championship_demo.tscn`
- `kart_garage_demo.tscn`
- `race_preparation_demo.tscn`
- `qualifying_demo.tscn`
- `race_results_demo.tscn`
- `season_end_demo.tscn`
- `ui/components/event_card.tscn`
- `ui/components/championship_card.tscn`
- `ui/components/sponsor_card.tscn`
- `ui/components/start_lights.tscn`
- `ui/components/notifications_demo.tscn`

Avec les scènes existantes `dashboard_demo` et `race_visual_demo`, le parcours visuel complet de création d'écurie à fin de saison est présent. Toutes les données affichées sont fictives et portées par des nœuds Godot, sans logique métier.

### Nouveaux Asset IDs

76 nouveaux identifiants stables ont été ajoutés, pour un manifeste total de **186** entrées. Ils couvrent les scènes ci-dessus, `track_kart_regional_01..03`, `car_kart_02..03`, `helmet_pattern_01..08`, `driver_head_05..08`, `driver_hair_07..10`, `driver_background_01..04`, les modules `prop_regional_*`, l'identité championnat, les écuries et les sponsors. Aucun des 110 IDs d'origine n'a été supprimé ou renommé.

### Taille ajoutée

Environ **130 Ko** de sources légères ont été ajoutés (SVG, scènes, générateur et documentation), sans texture raster, vidéo, spritesheet géante ou modèle 3D.

### Tests

- Parsing JSON des quatre registres `shared/`.
- Parsing XML des 163 SVG.
- Parité exacte entre les 186 clés du manifeste et celles du registre d'Asset IDs.
- Existence de chaque fichier déclaré par un chemin `res://` dans le manifeste.
- Vérification statique de tous les chemins `res://` des scènes et ressources.
- Vérification statique des 20 scènes `.tscn` et de leurs références externes.
- Contrôle qu'aucun fichier du shell Web, workflow ou export existant n'a été modifié.

### Limitations

- Godot n'est pas installé dans l'environnement de production : l'import, le rendu et le contrôle sur appareils physiques n'ont pas pu être exécutés. Les scènes ont été validées statiquement.
- La référence est 1920 × 1080 avec marges sûres ; les ratios 19.5:9 et encoches devront être confirmés sur appareils réels après intégration.
- Les feux, notifications, classements, numéros, couleurs et états sont volontairement non animés/non calculés. Claude doit les alimenter depuis ses systèmes.

### Éléments prêts pour Claude

`graphics/CLAUDE_GRAPHICS_HANDOFF.md` résume les scènes, Asset IDs, portraits, recoloration, numéros dynamiques, composants championnat, HUD course, départ et résultats. Claude peut intégrer ce kit sans parcourir tout le dossier graphique et sans dépendance à une logique ajoutée par Codex.
