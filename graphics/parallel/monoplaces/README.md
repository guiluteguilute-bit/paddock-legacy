# Bibliothèque visuelle des monoplaces

Bibliothèque **locale, fictive et indépendante** destinée à une intégration ultérieure dans Paddock Legacy. Aucun constructeur, championnat, sponsor ou emblème réel n'est représenté.

## Catégories et vues

| Catégorie | ID local | Lecture visuelle | Vues |
|---|---|---|---|
| F4-like | `future_car_f4_01` | compacte, ailes simples, école de pilotage | `race`, `side`, `top` |
| Regional-like | `future_car_regional_01` | plus large, diffuseur et cockpit intégrés | `race`, `side`, `top` |
| F3-like | `future_car_f3_01` | basse, pontons et nez travaillés | `race`, `side`, `top` |
| F2-like | `future_car_f2_01` | imposante, enveloppante, professionnelle | `race`, `side`, `top` |
| Formula Apex | `future_car_apex_01` | très basse, spectaculaire, architecture en lame | `race`, `side`, `top` |

Les sources SVG conservent un `viewBox` stable par type de vue. Les planches `preview/` montrent la voiture seule, une livrée, la vue course et la vue garage. `comparison/monoplane_progression_preview.svg` place les cinq profils à une échelle commune. `comparison/mobile_silhouette_check.svg` contrôle la lecture à 64, 128 et 256 px.

## Livrées et couleurs dynamiques

Chaque SVG principal définit les variables CSS `--primary`, `--primary-dark`, `--secondary` et `--accent`. À l'import Godot, deux méthodes sont possibles :

1. générer la variante SVG en remplaçant les variables avant import ;
2. importer les quatre masques monochromes (`mask_primary`, `mask_secondary`, `mask_accent`, `mask_sponsors`) et les composer dans un `CanvasItem`/shader avec quatre couleurs uniformes.

Les huit motifs de `common/liveries/` sont des masques monochromes 256 × 256 : solide, bande centrale, double bande, diagonale, séparation, géométrique, vitesse et vague. Ils sont indépendants du châssis. `livery_team_examples.svg` documente six palettes fictives de test, sans implication gameplay. La zone sponsors est seulement un espace de composition ; aucun logo réel n'est inclus.

## Numéros

`number_plate_template.svg` définit une zone dynamique. Le nombre doit rester un `Label`, un atlas de chiffres ou une texture générée par Godot, jamais une carrosserie dédiée. `number_example_27.svg` est uniquement un exemple de visualisation ; le « 27 » des planches n'est pas un identifiant imposé.

## Casques, roues et effets

- huit casques recolorables (`helmet_pattern_01` à `08`) répartis sur trois familles graphiques de coque/motif ;
- trois roues mutualisées : junior (F4/Regional), professional (F3/F2), Apex ;
- ombre, flou de mouvement, lignes de vitesse, glow pluie et spray arrière très légers ;
- pièces génériques de dommages : aileron avant, roue, fumée et étincelles. Ce sont des calques visuels, sans logique physique.

## Variantes Apex

`future_car_apex_variant_a`, `b` et `c` modifient respectivement le nez/lame, les pontons et le capot/entrée d'air. Ce sont des calques SVG alignés sur le `viewBox` 960 × 480 de la vue course, compatibles avec les mêmes masques et palettes.

## Intégration future

1. Lire uniquement `local_manifest.json`, sans remplacer les manifestes globaux.
2. Copier/importer les SVG choisis avec filtrage activé et mipmaps selon leur taille d'affichage.
3. Composer carrosserie, masque de motif, couleurs, numéro, casque, roues et ombre dans cet ordre.
4. Conserver le ratio des vues et vérifier à nouveau les paliers 64/128/256 px.
5. Attribuer les Asset IDs globaux uniquement pendant la mission d'intégration dédiée.

Cette bibliothèque ne contient ni scène, ni script, ni shader global, ni donnée de performance ou de carrière.
