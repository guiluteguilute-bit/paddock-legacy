# Rapport — système de course en direct

## Système créé

Le prototype Web passe d'un résultat instantané à une course top-down complète : qualification, grille, cinq feux, huit tours, arrivée progressive sous le drapeau à damier et classement final. Douze karts possèdent une distance réelle sur le tour, un nombre de tours et une distance totale. Le classement découle exclusivement de cette progression.

## Architecture

- `race/race-data.js` centralise la configuration du Riviera Sprint, les stratégies et les onze adversaires.
- `race/race-engine.js` contient l'état et les règles indépendantes du DOM : qualification, chrono, progression, pneus, température, trafic, erreurs, IA et arrivée.
- `race/race-ui.js` anime le SVG, les panneaux broadcast, la grille, les contrôles et les résultats.
- `app.js` assure la migration tolérante de l'ancienne sauvegarde, le garage et l'intégration carrière.

Le moteur est extensible par configuration (`laps`, longueur, temps de référence, météo, performance véhicule). Un générateur congruentiel seedé remplace `Math.random()` dans la simulation et rend une course reproductible.

## Course et concurrents

La course par défaut comporte **8 tours** et **12 concurrents** (le joueur et onze IA). Chaque pilote a un nom, numéro, équipe, vitesse, contrôle, mental, agressivité, régularité et gestion des pneus. La qualification tient compte des aptitudes et d'une variation seedée limitée ; le joueur n'est donc pas placé artificiellement en tête.

Le circuit réemploie fidèlement la géométrie de `track_kart_regional_01.svg`, enrichie d'une pitlane, d'une ligne, de zones de dégagement, d'herbe, de bâtiments et de végétation. Les karts progressent continûment le long du tracé SVG ; l'outline, la flèche et le vert acide identifient le joueur.

## Stratégies, IA et pneus

Les rythmes **CONSERVE**, **NORMAL** et **ATTACK** modifient effectivement allure, usure, température et risque. **OVERTAKE** et **DEFEND** durent cinq secondes et partagent un cooldown de treize secondes. Les pneus disposent d'un pourcentage de gomme et des états FROID, OPTIMAL, CHAUD et SURCHAUFFE.

Les IA appliquent les mêmes coefficients que le joueur avec cinq profils : agressif, gestionnaire, finisseur, spécialiste du départ et équilibré. Elles changent de rythme selon la phase de course et leur gomme. Les batailles utilisent vitesse, contrôle, agressivité, mental, rythme et actions temporaires. Les erreurs rares dépendent du risque, du contrôle et du mental.

## Interface et événements

L'écran plein format inclut classement et écarts live, tour, météo, drapeau, chrono, meilleur tour, télémétrie, radio, notifications animées, pause, vitesses ×1/×2/×4 et vues circuit/suivi. Le flux signale positions gagnées ou perdues, erreurs, meilleurs tours, dernier tour et damier. Le premier arrivé ne clôt pas la simulation : chaque concurrent doit franchir la ligne.

La mise en page conserve le fond sombre, les surfaces techniques et le vert acide. Trois breakpoints maintiennent de grandes commandes tactiles et une piste lisible en portrait, tablette et paysage.

## Sauvegarde, objectifs et récompenses

La clé historique `paddockLegacy` reste utilisée. Les champs absents sont ajoutés sans invalider les anciennes statistiques. Après une arrivée uniquement, énergie, XP, réputation, objectifs et `raceHistory` sont sauvegardés. L'historique conserve jusqu'à trente courses avec circuit, date, départ, arrivée, meilleur tour, XP et seed.

Le podium n'est validé que pour P1–P3 et l'objectif chrono seulement sous 48.210. Les récompenses varient avec la position, le podium et le meilleur tour.

## Tests réalisés

La suite Node vérifie la grille unique, les tours et arrivées, l'absence de double arrivée, le classement final, les impacts de stratégie sur allure/usure/température, les modes bataille et leur cooldown, la reproductibilité d'une seed et quatre simulations (attaque continue, conservation, équilibre, attaque finale).

## Performances

La simulation n'emploie aucune physique : douze objets reçoivent des calculs scalaires à chaque frame, et douze groupes SVG sont transformés. Le delta est borné et le moteur reste léger à ×4. Aucun asset bitmap lourd ni requête réseau n'est nécessaire pendant la course.

## Bugs connus

- La météo est architecturée dans la configuration et affichée, mais la première course reste volontairement sèche.
- La vue suivi agrandit la piste autour de sa zone centrale ; une vraie caméra recentrée dynamiquement sur le joueur serait plus précise.
- Les contacts et drapeaux jaunes sont représentés par l'architecture d'événements, sans neutralisation complète.
- GitHub Pages exporte actuellement la scène Godot via son workflow ; le prototype HTML est exécutable directement mais n'est pas encore la cible du workflow Pages existant, préservé conformément à la mission.

## Prochaine amélioration recommandée

Ajouter une caméra TV dynamique et un second circuit configuré, puis brancher météo évolutive et drapeau jaune sur le même moteur avant d'introduire arrêts, carburant et règles propres aux monoplaces.
