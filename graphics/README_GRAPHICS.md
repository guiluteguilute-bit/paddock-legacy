# Paddock Legacy — fondation graphique

## Direction artistique

L'univers combine un paddock contemporain, la lecture immédiate d'une retransmission sportive et la précision d'un tableau de données. Les surfaces bleu-noir, les traits fins et les accents lumineux produisent une identité premium sans reprendre une licence réelle. Le cyan `accent_default` est une valeur de démonstration : en jeu, la couleur de l'écurie doit la remplacer.

Principes : **lisible**, **sobre**, **sportif**, **modulaire**, **léger sur mobile**. Les illustrations réalistes, logos automobiles existants, livrées réelles et textes intégrés aux images sont exclus.

## Source de vérité

- `shared/ui_tokens.json` : couleurs, mesures, typographie et transparences.
- `shared/asset_ids.json` : identifiants stables à ne jamais renommer.
- `shared/graphics_manifest.json` : résolution d'un identifiant vers `res://...`.
- `graphics/ui/paddock_theme.tres` : première traduction Godot des tokens.

## Palette et accessibilité

Le fond `#090e17`, les panneaux `#111927` et le texte `#f5f7fa` donnent un fort contraste. Le cyan `#18d3c5` est l'accent par défaut, avec vert, orange, rouge et bleu réservés aux états. Ne jamais communiquer un état uniquement par sa couleur : associer icône, libellé ou forme. Garder les textes utiles à au moins 18 px sur la référence 1920 × 1080.

## Formats et résolutions

- **SVG** pour UI, icônes, logos, véhicules stylisés, composants de portrait et props.
- **WebP/PNG** uniquement lorsqu'une texture raster apporte un gain réel.
- **GLB** uniquement pour une future pièce low-poly justifiée.
- Les icônes ont un canevas 128 × 128, les véhicules 512 × 256 ou 720 × 288, le circuit 1024 × 576.
- Les SVG monochromes utilisent des formes simples et restent faciles à teinter via `modulate`.

## Design system

Les boutons `Primary`, `Secondary`, `Danger`, `Success`, `Disabled` et `Icon Button` utilisent une même géométrie (56 px, rayon 10). Le thème fournit les états normal, hover/focus, pressed et disabled. `Primary`, `Danger`, `Success` et selected se déclinent avec les couleurs sémantiques des tokens, par variation de thème ou `StyleBoxFlat`, jamais en dupliquant une texture.

Les cartes pilote, écurie, championnat, sponsor, message et amélioration partagent le panneau de base : rayon 16, contour fin, marge 24. Modal, sidebar, dashboard, tooltip et notification emploient la même surface avec élévation/opacité adaptées. Les démos montrent cette grammaire dans le menu, le dashboard et le HUD.

## Livrées procédurales

Les voitures SVG utilisent trois couleurs sentinelles : primaire `#18d3c5`, secondaire `#3d7cff`, accent `#ffb547`. Le numéro est un calque visuel de démonstration ; le numéro final doit être superposé par un `Label` Godot afin de rester dynamique.

Les masques `livery_pattern_*` proposent `solid`, `stripe`, `double_stripe`, `diagonal`, `geometric` et `gradient`. Le shader `livery_recolor.gdshader` expose `primary_color`, `secondary_color`, `accent_color`, `pattern_mask` et `pattern_strength`. Pour une équipe :

1. créer un `ShaderMaterial` utilisant ce shader ;
2. charger un masque depuis le manifeste ;
3. assigner les trois couleurs de l'équipe ;
4. placer numéro et sponsor comme nœuds enfants séparés.

Cette séparation évite une texture par équipe. Pour une recoloration SVG immédiate en prototype, `CanvasItem.modulate` convient, mais ne remplace pas les trois canaux du shader.

## Portraits modulaires

Les composants tête, coiffure et combinaison partagent un canevas 128 × 128 et peuvent être empilés dans cet ordre : fond, combinaison, tête, coiffure, détails. Quatre portraits assemblés servent d'exemples. Les variantes futures doivent préserver l'alignement et représenter clairement des pilotes adolescents plus âgés ou adultes, jamais de jeunes enfants.

## Circuit et effets

`test_track_01.svg` est un tracé fictif compact. Les props 128 × 128 ou 256 × 128 permettent d'étendre la bibliothèque sans atlas gigantesque. Pluie, poussière, étincelles et fumée sont des scènes `GPUParticles2D`; le spray réutilise la fumée avec une couleur bleu-gris et une durée réduite. Le glow et le highlight doivent rester subtils ; `selection_highlight.gdshader` fournit l'état sélectionné. Les animations de notification sont à réaliser avec un `Tween` sur position/opacité, sans spritesheet.

## Ajouter ou modifier un asset

1. Nommer en `minuscules_avec_underscore`, avec préfixe (`icon_`, `car_`, `logo_`, `prop_`).
2. Placer la source dans le sous-dossier métier approprié.
3. Vérifier l'absence de marque, circuit ou livrée réelle.
4. Ajouter l'ID identique dans `shared/asset_ids.json` et son chemin dans `shared/graphics_manifest.json`.
5. Incrémenter `version` dans le manifeste en cas de changement visuel incompatible ; ne jamais changer l'ID stable.
6. Ouvrir les trois scènes `graphics/demo/*_demo.tscn`, contrôler contraste, ratio et chemins.

Le générateur `graphics/source/generate_assets.py` recrée les SVG fondateurs. Toute modification manuelle d'un SVG généré doit donc être reportée dans ce script avant exécution.

## Règles de maintenance mobile

Réutiliser thèmes, matériaux et props ; limiter les superpositions transparentes et les particules ; désactiver les effets hors écran ; préférer un atlas lorsque la bibliothèque grossira. Tester au minimum en 16:9 et sur un ratio mobile plus large, en respectant les safe areas. Aucun texte traduisible ne doit être rasterisé.
