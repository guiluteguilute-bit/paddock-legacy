# RAPPORT D’INTÉGRATION GLOBALE

## MISSION

**Grande intégration Paddock Legacy.** Cette livraison privilégie les priorités demandées : une source Godot unique, un shell Web non bloquant, une navigation réelle, une sauvegarde versionnée et une tranche verticale karting. Elle ne prétend pas achever les 67 phases.

## ÉTAT INITIAL / AUDIT

- `project.godot` lançait une démonstration graphique statique et déclarait explicitement le gameplay absent.
- Le gameplay jouable vivait dans `index.html`, `app.js` et `race/*.js`; Godot et le prototype Web étaient donc deux applications distinctes.
- Les onze scènes `graphics/demo/*.tscn` étaient des maquettes sans contrôleur commun. Les boutons du menu principal Godot n'étaient pas connectés.
- Le prototype JS proposait énergie, trois statistiques améliorables gratuitement, trois objectifs, sauvegarde `localStorage` et une course à douze karts avec rythme/attaque/défense. Sa navigation affichait principalement « bientôt disponible ».
- Le dépôt contient une bibliothèque SVG riche (karts, monoplaces, circuits, bâtiments, portraits, sponsors, météo et icônes), mais la majorité n'était reliée à aucune scène de jeu.
- Le workflow Pages exportait déjà Godot 4.3 et vérifiait `.html`, `.js`, `.wasm` et `.pck`. Le shell Godot possédait un chargement progressif et une gestion d'erreur intégrée sans `alert()`.

## VERSION GODOT

Godot **4.3**, rendu `gl_compatibility`, cible principale paysage 1920×1080 avec étirement `canvas_items`. Le point d'entrée définitif est `game/ui/main.tscn`; `GameState` est un autoload.

## WEB

### Erreurs corrigées

- Le prototype racine pouvant être publié accidentellement n'existe plus.
- Aucun appel `alert()` dans le shell.
- Le shell conserve `viewport-fit=cover`, un canvas plein écran, une progression et un message d'erreur non bloquant.
- L'interface ajoute des marges permanentes pour éloigner les commandes critiques des encoches et coins.

### Export

Le preset produit `build/web/index.html`. Le workflow exige des fichiers HTML, JavaScript Godot, WASM et PCK non vides et refuse les placeholders `$GODOT_` ou un `alert()`.

### GitHub Pages

Le workflow push `main` → validation → export → contrôle artefact → upload → Pages est préservé et renforcé par les tests cœur Godot.

## UNIFICATION HTML / GODOT

`index.html`, `styles.css`, `app.js` et `race/*.js` ont été retirés après inventaire. Le seul HTML restant est le template technique `web/shell.html`; aucun gameplay n'y vit. Les concepts utiles du prototype (course visible, classement, stratégie, pneus, carburant, énergie, objectifs et historique) sont désormais dans Godot.

## NAVIGATION

Une barre globale ouvre Accueil, Carrière, Calendrier, Championnat, Écurie, Véhicule/Développement, Finances, Course et Paramètres. Chaque bouton visible agit réellement. Les vues Sponsors, Personnel, Infrastructures et Boutique restent à construire plutôt que d'afficher de faux systèmes.

## SAUVEGARDE

Sauvegarde JSON dans `user://career.json`, `save_version=1`, fusion migratoire avec les valeurs par défaut, chargement, autosave création/achat/avant/après course et suppression réelle. Une nouvelle carrière reconstruit toutes les collections et évite l'état résiduel.

## CRÉATION PILOTE

Flux fonctionnel avec prénom, nom, nationalité et numéro, validation des noms et statistiques initiales cohérentes. L'apparence est réservée dans les données; son sélecteur visuel reste à faire.

## CRÉATION ÉCURIE

Nom et nationalité sont modifiables. Une livrée kart détaillée existante est prévisualisée. Les couleurs et le logo ont des valeurs initiales persistées; les sélecteurs interactifs restent à ajouter.

## CARRIÈRE

La carrière commence en Kart Club avec 12 000 €, cinq unités d'énergie, une inscription payée, quatre manches et une progression de réputation. La pyramide complète est consultable et verrouillée par réputation.

## CHAMPIONNATS

Neuf niveaux data-driven couvrent Kart Club à Formula Apex avec prestige, coût, courses, barème, âge, réputation, prime et ruleset. Kart Club est la tranche jouable; les catégories suivantes sont préparées, pas simulées en saison complète.

## CALENDRIER

Quatre manches possèdent circuit, date, tours, probabilité météo, règles, statut et résultats. Les transitions `UPCOMING`, `AVAILABLE`, `COMPLETED` sont persistées.

## ÉCONOMIE

Les inscriptions, primes, objectifs et développements passent par un registre de transactions unique. Solde, revenus et dépenses saison sont réellement modifiés.

## SPONSORS

Le modèle de sauvegarde accepte les contrats; les assets de douze sponsors sont inventoriés. Sélection, objectifs et versements périodiques restent à implémenter.

## PERSONNEL

Collection persistante et niveau pit crew préparés. Recrutement, salaires, contrats et moral restent à implémenter.

## INFRASTRUCTURES

Les niveaux atelier, simulateur et pit crew sont persistants, et le campus SVG existant est affiché dans la vue Écurie. Les achats et bonus de bâtiment restent à connecter.

## VÉHICULES

Le kart détaillé est utilisé à la création et dans le garage. État, fiabilité et composants moteur/châssis/freins sont persistés. Les monoplaces F4, Regional, F3, F2 et Apex sont cataloguées mais attendent la promotion jouable.

## COURSES

Douze concurrents parcourent réellement une ligne de piste paramétrique. Chaque concurrent conserve progression, tour, vitesse, position, usure, carburant, dernier et meilleur tour. Le classement vient de la distance, pas d'une liste aléatoire. Chaque session est reconstruite par `reset_session()`.

## QUALIFICATIONS

Une session chronométrée de qualification calcule la position de grille avec les mêmes concurrents. Une phase de préparation enrichie (choix pneus/météo/trafic) reste à faire.

## PNEUS

Usure live réelle, liée au rythme. Les composés et températures détaillées restent à ajouter.

## MÉTÉO

Probabilité par manche disponible dans préparation et données. La transition dynamique pluie/séchage n'est pas encore simulée.

## CARBURANT

Pourcentage live consommé selon le rythme. Le kart utilise ce modèle simplifié; ravitaillement et règles par catégorie restent à configurer.

## PIT STOPS

Non implémentés dans cette tranche karting de base. L'architecture `ruleset` permettra de les activer dans les catégories concernées.

## INCIDENTS

Le résultat accepte un historique d'incidents, mais accidents, pannes et drapeaux dynamiques restent à implémenter.

## OBJECTIFS

L'objectif course Top 8 est évalué après arrivée, récompensé une seule fois puis persisté. Un objectif saison existe dans la sauvegarde; sa validation de fin de saison reste à faire.

## XP

Une course attribue de l'XP selon le résultat. Les seuils croissants donnent un niveau et un point de compétence; l'écran de dépense des points reste à faire.

## ÉNERGIE

Affichage global `n/5`, contrôle avant ouverture et décrément réel après course. Aucun achat ni paiement réel n'est associé.

## AUDIO

Paramètres master, musique et SFX persistés. Aucun fichier audio libre n'était présent : bus, synthèse/placeholders et mixage restent à produire; aucun son protégé n'a été ajouté.

## GRAPHISMES

Le kart et le campus détaillés existants sont intégrés. La course affiche les véhicules en mouvement avec couleurs d'équipe et focus joueur. Les autres assets demeurent une bibliothèque préparée; circuits texturés, météo, effets et monoplaces doivent être branchés progressivement.

## OPTIMISATION WEB

Le menu ne charge que le kart ou le campus lorsqu'une vue en a besoin. Les bibliothèques de monoplaces, bâtiments et circuits ne sont pas préchargées. Les SVG maintiennent un dépôt léger (environ 2,4 Mo avant export).

## TESTS

- Validation statique Python : point d'entrée/autoload, shell, données des neuf championnats, fichiers requis, absence du gameplay JS historique.
- Test Godot : valeurs initiales, économie d'une amélioration, énergie, historique et transition calendrier après course.
- Pipeline : import Godot headless, tests cœur, export release, présence/poids des quatre familles d'artefacts et absence de placeholder/alerte.

## TESTS RÉUSSIS

- Validation statique et JSON locale.
- Tests historiques Node réussissaient avant retrait et ont servi à inventorier le moteur prototype.

## TESTS ÉCHOUÉS

- Aucun échec de code constaté par les contrôles disponibles.
- L'export et le smoke test navigateur n'ont pas pu être exécutés localement faute de binaire/templates Godot dans l'environnement et blocage réseau HTTP 403; le CI les exécute sur GitHub.

## BUGS CONNUS

- Navigation dense sur les téléphones les plus étroits; une barre défilante ou un menu secondaire sera nécessaire.
- La qualification ne verrouille pas encore le bouton départ et sa position ne réordonne pas physiquement le départ.
- Fin de saison, régénération d'énergie et écoulement du temps carrière sont incomplets.
- La vue course dessine des marqueurs colorés sur une piste procédurale plutôt que les sprites karts détaillés afin de garder douze véhicules lisibles.

## FONCTIONNALITÉS RESTANTES

Sponsors, personnel complet, infrastructures achetables, boutique cosmétique, fin de saison/promotion, récupération d'énergie, IA de pit, composés, température, météo dynamique, incidents, drapeaux, audio, localisation, choix de livrée, classements IA complets, tests navigateur et contenu F4+.

## PROCHAINE MISSION RECOMMANDÉE

Finaliser la boucle de saison Kart Club : temps carrière et énergie, classement complet des douze pilotes/équipes, objectifs saison/sponsor, météo et composés, incidents/drapeaux, écran de fin de saison et promotion Kart Régional/F4. Ensuite seulement intégrer les pits avancés et les catégories supérieures.
