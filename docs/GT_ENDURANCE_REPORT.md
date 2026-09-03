# Rapport GT / Endurance — vertical slice

## GT4

La **Continental GT4 Cup** constitue la première bifurcation après le karting. Quatre modèles fictifs proposent des architectures et compromis distincts (moteur avant, central, arrière et compacte légère). L'achat par l'écurie est persisté, avec un tarif de départ de 165 000 €.

## GT3

L'**International GT3 Series** ajoute cinq modèles plus performants. Leurs identités couvrent vitesse de pointe, virage, gestion des pneus, fiabilité et performance agressive difficile à exploiter. La première tranche fournit le catalogue, le format Pro-Am et les fondations de stratégie; les nouveaux visuels de carrosserie 2.5D restent à produire.

## Endurance, multiclass et Hypercar

La **World Endurance Series** et la **Legacy 24** sont des marques entièrement fictives. Une grille de référence rassemble 8 Hypercars, 8 Prototypes et 16 GT3. Chaque concurrent conserve sa position générale et sa position de classe. Les prototypes perdent du temps dans le trafic GT plutôt que de traverser les voitures sans conséquence.

Trois prototypes/Hypercars fictifs complètent les quatre GT4 du périmètre minimum. Sept tracés originaux décrivent les styles européen rapide, vallonné, nocturne, désertique, américain, japonais et grande boucle de 24 heures.

## Driver stints et fatigue

Chaque voiture reçoit un équipage de trois pilotes classés Elite, Pro, Semi-Pro ou Amateur. La simulation suit pilote actif, tours du relais, fitness et fatigue. Un relais excessif dégrade progressivement la performance; un changement de pilote remet le compteur de relais à zéro sans effacer la fatigue individuelle.

## Pit, fuel et pneus

Le carburant est exprimé en tours restants. Les allures Fuel Save, Balanced et Push modifient consommation et rythme. Un arrêt combine carburant, pneus, changement de pilote et réparation. Ne pas changer de pneus réalise naturellement un double stint. Les gommes Soft, Medium, Hard, Intermediate et Wet sont data-driven.

## Météo, jour/nuit et neutralisations

Une épreuve longue traverse jour, coucher du soleil, nuit, aube puis jour. Le scénario météo de référence passe du sec à la pluie forte avant une piste séchante. Yellow Flag, Full Course Yellow et Safety Car sont prévus dans l'état de simulation; un arrêt sous neutralisation coûte 38 % de moins.

## Career branch, prestige et sauvegarde

La sauvegarde v4 ajoute `career_path`, `championship_class`, `owned_gt_cars`, `driver_roster`, `endurance_results`, `class_results`, `prestige` et `endurance_trophies`. L'écran Carrière présente désormais les deux rêves côte à côte, sans enfermer le joueur: les offres et données peuvent supporter les futures passerelles F3 → GT3, F2 → Hypercar et GT3 → test Formula Apex.

## Tests

Les contrôles rapides valident le volume minimal, les grilles multiclasses, les pneus, le Performance Balance System, la persistance et les points d'entrée UI. Le test Godot construit une grille de 32 voitures, simule trois heures et vérifie classement général/de classe, relais et arrêt combiné.

## Limitations

- Ce vertical slice livre les données, l'économie, la sauvegarde, l'interface de découverte et le moteur déterministe, mais pas encore une saison GT complète jouable de bout en bout.
- Les phares, carrosseries GT/Prototype/Hypercar, pluie nocturne et dépassements 2.5D détaillés restent à intégrer dans `RaceView`.
- Les règles de temps de conduite, calendriers concurrents, évolution intersaison des constructeurs et IA opportuniste sous Safety Car sont préparés conceptuellement mais pas finalisés.
- L'accélération x1 à x16 et « Simulate to next event » sont exposées dans le HUD de stratégie; leurs commandes live seront raccordées avec la vue de course endurance.
