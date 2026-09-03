# MISSION

**Portrait + Graphics + 2.5D Racing** — mise à niveau du projet Godot existant, sans
prototype HTML parallèle et sans suppression des systèmes de carrière.

## PORTRAIT

- Référence native passée à 1080 × 1920, étirement responsive `canvas_items/expand`.
- Écrans recomposés en flux vertical scrollable pour 9:16, 9:19.5 et 9:20.
- Marges sûres Godot calculées via `DisplayServer.get_display_safe_area()`, avec repli
  conservateur pour le Web; `env(safe-area-inset-*)` complète la protection iPhone.
- Contrôles tactiles de 48 à 64 px minimum et navigation fixée en bas.

## UI

- Dashboard portrait: prochaine course, météo, objectif, pilote, progression et CTA.
- Navigation premium limitée à Accueil, Carrière, Course, Écurie et Plus.
- Cartes à bordure subtile, profondeur, hiérarchie typographique et palette motorsport.
- HUD course compact, caméra, rythme et actions rapides accessibles au pouce.
- Sélecteur de pneus PIT présenté comme panneau inférieur dans le flux mobile.

## GRAPHISMES

- Réutilisation des portraits, karts, monoplaces, garages et bâtiments existants.
- Circuit dessiné en couches: herbe tondue, béton, asphalte, gomme, vibreurs et pitlane.
- Véhicules pseudo-3D détaillés avec pneus, carrosserie, cockpit, reflet et ombre.
- Contraste météo sec/pluie et pluie légère sans shader lourd.

## COURSES 2.5D

### Méthode choisie

Approche **2D/pseudo-3D optimisée** avec dessin Canvas Godot. Elle donne une vue
miniature inclinée lisible tout en conservant GL Compatibility et un coût bien plus
faible que douze modèles 3D sur Web mobile.

### Véhicules et circuit

- Douze véhicules visibles, orientés selon la tangente du tracé.
- Trajectoires latérales interpolées quand des concurrents sont proches: les voitures
  se décalent, roulent côte à côte puis reviennent sur la ligne.
- Variation de vitesse en virage, usure, carburant et stratégie conservés.
- Pitlane et garages visibles; arrêt chronométré, changement de pneus et retour piste.

### Caméra, incidents et météo

- Modes TV (défaut), Pilote et Circuit disponibles depuis le HUD.
- Architecture d'état prête pour fumée, poussière et étincelles; destruction complexe
  volontairement exclue.
- Sec et pluie disposent de palettes de piste, voile humide et traits de pluie légers.

## PERFORMANCE

- Un seul `Control` dessine piste et véhicules; pas de scène ou texture par concurrent.
- Géométrie partagée, 12 concurrents, aucune lumière temps réel et aucune ombre coûteuse.
- Chargement du circuit uniquement à l'ouverture de la session.
- Cible: 60 FPS récent / 30 FPS modeste. Mesure matérielle iPhone encore requise.

## WEB

- Godot reste l'unique source et le workflow Pages continue d'exporter `project.godot`.
- Shell compatible `viewport-fit=cover`, unités `dvh` et variables CSS de safe area.

## TESTS

- Validation statique du portrait, du shell Web, de la navigation et des fonctions 2.5D.
- Test Godot de la carrière, achats, progression, énergie et changement de manche.
- Le workflow CI importe le projet, exécute les tests et valide les artefacts Web.

## BUGS CONNUS

- Les safe areas Web dépendent du support `env()` du navigateur; le repli Godot garde
  néanmoins des marges conservatrices.
- L'audio positionnel et les effets d'incident avancés n'ont pas encore d'assets audio.
- La pitlane est une représentation fonctionnelle compacte, sans mécaniciens animés.

## ÉLÉMENTS RESTANTS

- Tests FPS sur plusieurs iPhone/Android physiques.
- Sprites d'incidents, séquence de cinq feux dédiée et podium semi-illustré.
- Circuits visuellement uniques et variantes jour/soir/nuit.
- Classement complet en panneau escamotable et télémétrie d'écarts détaillée.

## PROCHAINE ÉTAPE

Profiler l'export Web sur appareils physiques, puis enrichir les incidents et chaque
environnement de circuit sans augmenter le nombre de draw calls par véhicule.
