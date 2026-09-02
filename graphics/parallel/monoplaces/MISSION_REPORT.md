# Rapport de mission

## MISSION

**Monoplace Visual Library**

## CATÉGORIES CRÉÉES

- F4-like — `future_car_f4_01`
- Formula Regional-like — `future_car_regional_01`
- F3-like — `future_car_f3_01`
- F2-like — `future_car_f2_01`
- Formula Apex — `future_car_apex_01`

## ASSETS CRÉÉS

- 76 sources SVG locales référencées dans `local_manifest.json` ;
- 15 vues de châssis et 20 masques de recoloration ;
- 5 planches de catégorie, 1 comparaison à échelle commune et 1 contrôle mobile ;
- 8 motifs de livrée, 1 planche de 6 palettes fictives et 2 ressources de numéro ;
- 8 casques, 3 roues mutualisées, 5 effets de course et 4 calques de dégâts ;
- 3 variations de carrosserie Formula Apex.

## VUES DISPONIBLES

Chaque catégorie fournit :

- `race` : vue principale 2.5D ;
- `side` : profil latéral ;
- `top` : vue légèrement supérieure pour garage/comparaison.

Les silhouettes ont aussi été composées sur une planche de contrôle à 64, 128 et 256 px.

## LIVRÉES

Huit masques universels : solid, center stripe, double stripe, diagonal, split, geometric, speed et wave. Six palettes fictives de démonstration sont disponibles. Les carrosseries utilisent quatre rôles chromatiques cohérents : primary, secondary, accent et primary-dark.

## MASQUES

Chaque catégorie fournit `mask_primary`, `mask_secondary`, `mask_accent` et `mask_sponsors`, alignés sur la vue course 960 × 480. Ils peuvent être colorisés et composés dans Godot sans dupliquer le châssis.

## CASQUES

Huit motifs fictifs recolorables, distribués entre trois familles graphiques principales. Aucun motif de pilote réel n'est reproduit.

## VARIANTES APEX

- variante A : nez/lame avant ;
- variante B : pontons sculptés ;
- variante C : capot moteur et entrée d'air arqués.

Les calques gardent le même repère que `future_car_apex_01_race.svg`.

## TAILLE DES ASSETS

Environ **110 Ko** pour la bibliothèque complète avant métadonnées Git/import Godot (SVG, JSON et documentation), soit une base vectorielle légère adaptée au mobile.

## VALIDATIONS EFFECTUÉES

- parsing XML de tous les SVG ;
- parsing de tous les JSON locaux ;
- existence de chaque chemin déclaré dans `local_manifest.json` ;
- contrôle du périmètre par `git status --short` et liste des chemins modifiés ;
- contrôle des espaces et erreurs de patch avec `git diff --check`.

## FICHIERS MODIFIÉS HORS DOSSIER AUTORISÉ

**AUCUN**

## PRÊT POUR INTÉGRATION

**OUI**
