# KART TO F4 — RAPPORT DE MISSION

## MISSION
Cette étape transforme la base Godot unique en une boucle de carrière persistante : création Team DNA, saison karting, gestion, fin de saison, offres et première campagne F4. Aucun prototype HTML n'a été ajouté.

## SAISON KARTING
La Regional Kart Series comporte six manches jouables, avec qualification et course 2.5D. Chaque résultat enrichi conserve grille, arrivée, gain de positions, chrono, pneus, incidents, points et récompenses.

## CALENDRIER
Valmont, Saint-Roch, Belle-Rive, Grand-Lac, Montbrun et Valmont Finale ont date, tours, météo et type. Les états `LOCKED`, `AVAILABLE`, `COMPLETED` sont persistants et séquentiels.

## ADVERSAIRES
Onze rivaux nommés rejoignent le joueur pour former un plateau persistant de douze pilotes. Leurs nationalité, numéro, équipe, sept attributs sportifs et profil stratégique sont data-driven.

## CLASSEMENTS
Le barème 25–18–15–12–10–8–6–4–2–1 vient des données. Le classement conserve points, victoires, podiums, meilleurs tours et résultats. Les égalités utilisent victoires, P2, P3 puis résultat récent.

## OBJECTIFS
L'origine ajuste l'objectif de saison et l'objectif Top 8 par course. Leur réussite est calculée sur le résultat réel et déclenche la prime correspondante.

## ÉCONOMIE
Le journal enregistre inscriptions, primes, objectifs, sponsors, réparations, entraînements, infrastructures et développements. Les totaux saisonniers distinguent revenus et dépenses.

## PILOTE
Niveau, XP et points de compétence sont actifs. Un point est gagné par niveau et peut être dépensé dans vitesse, contrôle, mental, départ, dépassement, défense, pluie ou gestion pneus. Le potentiel reste caché et sa fourchette se resserre avec le scouting.

## VÉHICULE
Kart et F4 coexistent dans la sauvegarde. Condition, moteur, châssis, freins et fiabilité sont affichés. Les réparations coûtent de l'argent. Les développements coûtent de l'argent et attendent trois jours de carrière.

## SPONSORS
Nova Energy, Vector Tech et Atlas Logistics proposent fixe, bonus conditionnel, durée, objectif et réputation minimum. Un contrat signé et ses courses restantes persistent.

## PERSONNEL
Les fiches mécanicien, ingénieur et stratège exposent compétence, salaire et contrat. Le pit crew réduit effectivement le temps d'arrêt. Le modèle de données prépare l'embauche et les salaires récurrents, non finalisés dans cette étape.

## INFRASTRUCTURES
Atelier, simulateur, scouting et pit crew sont achetables. L'atelier réduit les réparations, le scouting précise le potentiel et le pit crew accélère les arrêts.

## FIN DE SAISON
La dernière course clôt automatiquement la saison, calcule la position et affiche le bilan complet. Un Top 3 accorde prime et trophée.

## OFFRES
Trois voies sont générées : rester, Kart National et Formula Junior 4. Elles ont éligibilité, coût et objectif. Refuser laisse la carrière intacte.

## PROMOTION
La F4 exige une réputation de 35 et un Top 3. L'acceptation conserve écurie, ADN, pilote, finances, palmarès et véhicules dans la même sauvegarde.

## F4
Trois circuits (rapide, technique, mixte) constituent la première saison. La voiture F4 existante est utilisée dans le garage. Le même `RaceView` adapte vitesse, carburant, pneus, météo et stratégie : aucun second moteur de course.

## PNEUS
Soft, Medium, Hard, Intermediate et Wet possèdent grip, durée et température dans les données. La course expose Cold, Optimal, Hot et Overheated selon le rythme.

## PIT STOPS
Le joueur choisit le composé du prochain arrêt. L'arrêt restaure les pneus, peut réparer légèrement et sa durée dépend du pit crew.

## MÉTÉO
Sec, Light Rain, Rain et Drying sont préparés et une transition simple peut intervenir à mi-course F4. Intermediate et Wet sont sélectionnables.

## ACCIDENTS
Lock up, spin, contact et off track sont simulés selon risque et pluie, avec perte de temps et condition. Les pannes Engine/Gearbox/Brakes restent préparées conceptuellement mais ne sont pas encore des abandons complets.

## DRAPEAUX
Un incident déclenche un Yellow Flag temporaire et ralentit tout le plateau. La Safety Car complète reste volontairement hors MVP pour préserver la stabilité.

## SAUVEGARDE
La version 3 persiste catégorie, championnat, calendrier, classements, résultats, économie, véhicules, développements, pilote, personnel, sponsor, infrastructures, offres, trophées et historique. Une migration conserve les sauvegardes v2.

## UI PORTRAIT
Les ajouts réutilisent la coque portrait : cartes verticales, scrolling, larges boutons, navigation basse et feuilles d'arrêt.

## GRAPHISMES
Les previews kart, la F4 SVG, le campus et le trophée existants sont réutilisés. Aucun placeholder HTML ou moteur alternatif n'a été créé.

## PERFORMANCE
La course reste un `Control` 2.5D dessiné, avec douze véhicules et géométrie légère. Aucun pipeline 3D lourd n'a été introduit.

## TESTS
Le test Godot simule six victoires, titre, trophée, offres, promotion F4, pneus/pit et rechargement. Le validateur Python contrôle données et points d'intégration sans nécessiter le binaire Godot.

## BUGS CONNUS
- Safety Car et panneau complet escamotable en direct ne sont pas finalisés.
- Les pannes mécaniques terminales et les réparations choisies pendant l'arrêt restent à compléter.
- Le personnel est présenté et ses points d'effet sont préparés, mais embauche/licenciement et paie périodique ne sont pas encore actifs.
- Les prévisions météo ne disposent pas encore d'un écran d'incertitude dédié.
- Les qualifications F4 réutilisent la session chronométrée actuelle ; trafic et timing de sortie ne sont pas encore sélectionnables.
- Les sons ne sont pas fournis : les catégories d'intégration sont persistées, sans faux audio.

## PROCHAINE ÉTAPE
Finaliser le panneau live douze pilotes, les pannes/abandons, la Safety Car, l'embauche et les salaires, puis enrichir qualification et prévision météo F4 sans changer de moteur 2.5D.
