# Facilities & Paddock — bibliothèque visuelle locale

Bibliothèque SVG autonome destinée à une intégration ultérieure. Elle illustre la croissance d'un garage de karting modeste jusqu'à un campus Formula Apex mondial, sans logique de gameplay, données métier, marque réelle ni véhicule monoplace détaillé.

## Structure et niveaux

- `progression/` : cinq vues 2.5D (`facility_level_1` à `facility_level_5`). Le niveau 1 est volontairement compact et artisanal ; les volumes, vitrages, départements et transporteurs s'accumulent jusqu'au campus.
- `workshop/`, `engineering/`, `simulator/`, `scouting/`, `fitness/`, `weather/`, `pitcrew/`, `marketing/`, `academy/`, `headquarters/` : planches de cinq niveaux. Les silhouettes sont suggérées par du mobilier et des postes, afin de rester lisibles sur mobile.
- `factory/` : modules du campus et kit de construction (échafaudage, grue, bâche, panneau).
- `paddock/` et `garage/` : kit paddock, cinq transporteurs, pit wall et garage circuit modulaires.
- `props/` : objets réutilisables. `icons/` : départements et états visuels. `backgrounds/` : ambiance jour et calque nuit. `previews/` : progression complète et promesse de carrière.

## Recoloration et emplacements dynamiques

Les bandes d'accent portent des identifiants SVG `team_color_slot` (ou suffixés par niveau). Les zones blanches en pointillés `dynamic_logo_slot` sont réservées au logo, au nom ou aux sponsors injectés lors de l'intégration. Le béton, le métal et les vitrages restent neutres : seule une petite surface est recolorée, pour préserver la crédibilité architecturale.

Couleurs de base : accent équipe `#E5484D`, accent technique `#24B6A6`, encre `#17202A`, métal clair `#DCE5E8`, vitrage `#82C8D8`. L'intégrateur peut remplacer les accents au chargement, par variante de matériau ou par shader.

## Composants

Les écrans (`engineering/screen_library.svg`) présentent exclusivement des courbes et valeurs décoratives fictives. Les trophées sont des formes originales génériques. Le kit d'états couvre : disponible, améliorable, en construction, verrouillé et niveau maximum. Les éléments de construction sont séparés afin d'être superposés avec modération.

## Jour / nuit

`campus_day.svg` fournit un fond léger. `campus_night_overlay.svg` est un calque translucide à combiner avec les mêmes bâtiments (modulation/matériau CanvasItem), évitant de dupliquer toutes les textures.

## Intégration future

1. Copier/importer uniquement les entrées nécessaires depuis `local_manifest.json`.
2. Conserver les SVG comme sources ou laisser Godot les rasteriser à la taille cible.
3. Remplacer les couleurs des nœuds `team_color_slot*` et alimenter `dynamic_logo_slot*`.
4. Brancher ultérieurement niveaux, états, données et conditions depuis le gameplay ; aucun de ces concepts n'est codé ici.
5. Tester les vues à environ 320 px de large : les grandes masses, bandes colorées et silhouettes d'équipement sont conçues pour rester distinctes.
