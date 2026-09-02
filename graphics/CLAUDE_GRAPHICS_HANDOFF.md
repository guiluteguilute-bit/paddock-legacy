# Handoff graphique pour Claude — Technical Theatre

## Contrat stable

Résoudre les ressources avec `res://shared/graphics_manifest.json`; les constantes miroir vivent dans `asset_ids.json`. Ne jamais renommer un ID existant. Le schéma 2 des tokens est additif : toutes les anciennes clés restent valides.

## Scène et thème

La scène principale `ui_demo.tscn` démontre le nouveau menu. `paddock_theme.tres` peut être appliqué au Control racine des écrans. Les textes visibles restent des nœuds dynamiques : remplacer `text` ou brancher la traduction sans éditer le SVG de fond.

## Véhicules recolorables

Pour chaque monoplace, superposer la vue neutre puis les masques `_mask_primary`, `_mask_secondary`, `_mask_accent` et `_mask_sponsors`. Appliquer les couleurs équipe par `modulate`, ou le shader `livery_recolor.gdshader` lorsque les sentinelles sont dans une texture combinée. Ajouter numéro, logo et sponsor comme enfants séparés. Le même contrat s'applique aux karts avec `#18d3c5`, `#3d7cff`, `#ffb547`.

## Infrastructures

Les IDs `future_facility_*` pointent maintenant vers les planches de progression. Utiliser la planche correspondant au département, découper la région/variante requise ou l'afficher dans une vue technique. Le niveau affiché provient toujours du gameplay ; les assets ne portent aucun coût ni bonus.

## États visuels

- Action/focus : accent cyan + déplacement/transition 120 ms.
- Panneau : 220 ms, `cubic_out`.
- Succès/alerte/erreur : couleur **et** icône/texte.
- Minimum tactile : 48 px ; conserver les safe areas des tokens.
- Éviter glow permanent, texte sur image sans scrim et animation des données critiques.

## Performance

Les SVG sont adaptés aux tailles de présentation et importés une seule fois par Godot. Réutiliser textures/matériaux, éviter les duplications par équipe et ne rasteriser que si le profiling mobile le justifie. Aucun élément de cette passe ne modifie économie, carrière, IA ou course.
