# Rapport — Création initiale et ADN d'écurie

## Mission
Le début de carrière est désormais un parcours portrait en huit étapes. Il construit la même sauvegarde et le même `GameState` que les courses, l'économie et les infrastructures existantes : aucun moteur de carrière parallèle n'a été créé.

## Écrans créés
Identité, origine, philosophie, direction, fondation, premier pilote, objectif et récapitulatif. La navigation Retour/Continuer conserve le brouillon. La validation finale ouvre une confirmation, puis conduit au garage karting. L'accueil présente la phrase d'introduction sans cinématique bloquante ; un joueur qui recommence peut immédiatement toucher « Créer une écurie ».

## Identité écurie
Nom complet/court, pays, numéro, trois couleurs, 12 formes, 20 symboles et six livrées sont persistés. Le kart vectoriel réagit immédiatement aux couleurs et motifs. La livrée est stockée indépendamment du type de véhicule pour être réutilisable en monoplace.

## Origines
Garage familial, Investisseur privé, Ancien pilote, Équipe amateur passionnée, Académie de jeunes pilotes et Petit constructeur disposent d'un récit, d'avantages, de contreparties, d'un budget configurable et d'un événement associé.

## Philosophies
Performance pure, Fiabilité, Excellence pilote, Stratégie, Innovation et Gestion financière orientent les affinités et modificateurs sans bloquer la progression future.

## Styles de direction
Technicien, Businessman, Passionné, Exigeant, Protecteur et Stratège modifient légèrement progression, moral, fidélité, stratégie ou commerce.

## Points fondation
Dix points, chacun limité de 0 à 5, sont distribués entre atelier, technique, simulateur, scouting, marketing et stratégie. La synthèse dynamique affiche étoiles, catégorie et note.

## Pilotes
Le premier pilote possède identité, pays, numéro, âge 13–16, apparence, casque et couleurs d'équipe.

## Archétypes
Prodige, Travailleur, Agressif, Calculateur, Polyvalent et Pari définissent statistiques de départ, progression et traits. Les bonus XP sont appliqués par le vrai système d'expérience.

## Objectifs
Six ambitions long terme sont sauvegardées et disponibles aux systèmes futurs d'objectifs, d'événements, de récompenses et de succès. Elles ne donnent aucun gain de vitesse gratuit.

## Team DNA
`team_dna` sépare explicitement `ratings` (niveau de départ), `affinities` (facilité de progression), `modifiers`, identité historique et points. `culture` prépare une évolution technique, finance, pilote, stratégie et innovation par les décisions futures. `initial_influence` permet une atténuation saisonnière future sans effacer l'histoire.

## Bonus / malus
Les coûts de développement et de réparation, l'XP pilote et la réputation utilisent réellement les multiplicateurs cumulés. Les paramètres restent dans une fourchette raisonnable ; les coûts de fonctionnement et contraintes sportives compensent notamment le capital de l'investisseur.

## Événements
Les origines, philosophies et profils de patron enregistrent leurs événements dans `career_events`. Les cartes configurées couvrent mécanicien familial, pression investisseur, prospect académie, pièces et prototypes, maintenance, sponsor, météo, tensions, soutien et fans. Le moteur de résolution/programmation saisonnière reste une prochaine extension.

## Sauvegarde
La version 2 conserve équipe, identité graphique, `team_dna`, pilote et potentiel caché, objectif, événements et culture dans `career.json`.

## Compatibilité anciennes sauvegardes
La migration conserve toutes les anciennes clés et injecte un ADN neutre `independent`, un profil polyvalent et un potentiel par défaut. La nouvelle carrière/RESET exige une confirmation avant suppression.

## Tests
Les tests Godot couvrent ADN, coûts réels, XP, potentiel estimé, migration, course et trois scénarios de rejouabilité. Le validateur Python contrôle le nombre de choix, les bornes d'équilibrage et la présence de l'intégration UI/état.

## Équilibrage
Tous les choix sont centralisés dans `game/data/team_creation.json`. Aucun modificateur individuel ne dépasse 15 %. Les budgets vont de 8 000 à 20 000 €, avant inscription, avec des contreparties propres.

## Bugs connus
Le dessin vectoriel du logo dans la prévisualisation reste volontairement symbolique. Le pays et les catégories de sponsors sont persistés mais leur marché détaillé attend le futur moteur de contrats. Les événements sont mis en file mais n'ont pas encore leur écran de résolution.

## Prochaine amélioration
Ajouter la résolution calendaire des événements, le marché de sponsors par pays/catégorie, l'amélioration des six infrastructures avec affinités et l'atténuation de l'influence initiale à chaque changement de saison.
