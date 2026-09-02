# Passerelle Claude — kit visuel carrière karting

Ce document est le point d'entrée court pour brancher les données métier. Le kit est **visuel uniquement** : Claude conserve la simulation, les points, l'économie, les sauvegardes et la logique de course.

## Scènes prêtes à alimenter

| Étape | Asset ID | Scène |
|---|---|---|
| Création d'écurie | `team_creation_demo` | `res://graphics/demo/team_creation_demo.tscn` |
| Dashboard | `dashboard_demo` | `res://graphics/demo/dashboard_demo.tscn` |
| Pilote | `driver_profile_demo` | `res://graphics/demo/driver_profile_demo.tscn` |
| Garage kart | `kart_garage_demo` | `res://graphics/demo/kart_garage_demo.tscn` |
| Championnat et calendrier | `championship_demo` | `res://graphics/demo/championship_demo.tscn` |
| Préparation | `race_preparation_demo` | `res://graphics/demo/race_preparation_demo.tscn` |
| Qualifications | `qualifying_demo` | `res://graphics/demo/qualifying_demo.tscn` |
| Course | `race_visual_demo` | `res://graphics/demo/race_visual_demo.tscn` |
| Résultats | `race_results_demo` | `res://graphics/demo/race_results_demo.tscn` |
| Fin de saison | `season_end_demo` | `res://graphics/demo/season_end_demo.tscn` |

Les valeurs fictives sont des `Label` Godot. Remplacer leur propriété `text` sans modifier les SVG. Les écrans sont construits sur une référence 1920 × 1080 avec marges latérales sûres ; les conteneurs et ancrages peuvent être repris dans les écrans finaux.

## Portraits

- Têtes : `driver_head_01` à `driver_head_08`.
- Coiffures : `driver_hair_01` à `driver_hair_10`.
- Combinaisons : `driver_suit_01` à `driver_suit_03`.
- Fonds : `driver_background_01` à `driver_background_04`.
- Exemples assemblés : `portrait_driver_01` à `portrait_driver_04`.

Empiler dans cet ordre : fond, combinaison, tête, coiffure, détails. Tous partagent un canevas 128 × 128. La couleur de cheveux peut être changée avec `modulate` ou via une variante de matériau ; les tons de peau sont portés par les têtes.

## Karts, couleurs et numéro

Les Asset IDs `car_kart_01`, `car_kart_02` et `car_kart_03` sont les variantes équilibrée, agressive et compacte. Elles n'embarquent aucune statistique. Les SVG utilisent les couleurs sentinelles suivantes :

- primaire `#18d3c5` ;
- secondaire `#3d7cff` ;
- accent `#ffb547`.

Utiliser `res://graphics/shaders/livery_recolor.gdshader` avec un `ShaderMaterial`, renseigner `primary_color`, `secondary_color`, `accent_color`, puis choisir un `livery_pattern_*`. Le numéro final est un `Label` enfant superposé (voir `Kart27/Number` dans la scène course), et non du texte à rasteriser. Les composants séparés `kart_chassis`, `kart_bodywork`, `kart_wheels`, `kart_engine`, `kart_driver`, `kart_helmet` et `kart_number_plate` servent aux vues techniques. Les motifs `helmet_pattern_01` à `helmet_pattern_08` acceptent la même palette d'équipe.

## Championnat et calendrier

L'identité repose sur `logo_regional_kart_series`, `trophy_regional_kart_series`, `header_regional_kart_series` et `badge_regional_level`. La synthèse réutilisable est `championship_card`. Les trois pistes sont `track_kart_regional_01`, `track_kart_regional_02` et `track_kart_regional_03`. La carte `event_card` accepte le numéro, nom, date, météo, longueur et statut via ses Labels. Représenter chaque statut par symbole **et** couleur : terminé `✓`, sélectionné `●`, à venir `○`, verrouillé `▣`.

Le tableau de `championship_demo` montre 20 lignes et les colonnes attendues. Remplacer les lignes depuis les données de championnat calculées côté gameplay ; le composant n'effectue aucun tri ni calcul.

## HUD course et départ

Dans `race_visual_demo`, alimenter `TopHud`, `Leaderboard`, `DriverHud` et `FlagStatus`. Les karts ont chacun un nœud numéro distinct. Le fond peut être remplacé par l'un des trois tracés sans changer le HUD. `start_lights` fournit les cinq feux : Claude peut animer leur couleur puis masquer le composant à l'extinction. Aucune logique de départ n'est incluse.

## Résultats, sponsors et notifications

`race_results_demo` sépare `Podium`, `Player` et `Full` : injecter les résultats déjà calculés dans ces zones. `season_end_demo` reçoit de la même façon le bilan agrégé. `sponsor_card` est uniquement une présentation (logo, contrat, récompense, objectif, durée), pas un système de contrat. `notifications_demo` contient les cinq variantes Information, Succès, Avertissement, Erreur et Nouvelle offre.

Tous les chemins et types sont résolus depuis `res://shared/graphics_manifest.json`. Ne jamais renommer un Asset ID existant ; ajouter une nouvelle entrée pour toute variante incompatible.
