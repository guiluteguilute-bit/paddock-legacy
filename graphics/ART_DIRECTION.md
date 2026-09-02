# Paddock Legacy — direction artistique « Technical Theatre »

## Intention

**Technical Theatre** confronte la précision froide d'un outil d'ingénierie à la tension d'une retransmission sportive. Le paddock est sombre, construit et matériel ; l'information critique est lumineuse. L'image doit rester crédible à l'échelle mobile et ne jamais imiter une licence réelle.

## Langage visuel

- **Structure** : panneaux denses, angles techniques de 4 à 6 px, filets métalliques d'un pixel, rail coloré pour la sélection. Les grands arrondis « application générique » sont proscrits.
- **Lumière** : fond bleu-noir, surfaces en verre fumé, accent turquoise réservé à l'action, au focus et à la télémétrie. Les ombres sont courtes, profondes et non décoratives.
- **Typographie** : capitales espacées pour les sourcils et données ; casse naturelle pour les noms ; nombres tabulaires recommandés. Le texte dynamique reste toujours un nœud Godot.
- **Composition** : règle 60/30/10 (obscur/neutre/accent), asymétrie contrôlée, grande image produit, données alignées sur une grille de 8 px.

## Matières

| Matière | Traitement | Usage |
|---|---|---|
| Carbone stylisé | noir bleuté, trame discrète, arête gris froid | aéro, cadres techniques |
| Peinture compétition | trois valeurs, reflet net, ombre colorée | carrosserie et identité |
| Gomme | noir chaud, flanc satiné, jante lisible | pneus, barrières |
| Verre technique | cyan très désaturé, faible opacité | écrans, visières |
| Métal brossé | gris moyen, reflet directionnel fin | châssis, atelier |
| Asphalte | grains multi-échelle, raccord sans couture visible | piste et pitlane |

Les valeurs canoniques sont dans `shared/ui_tokens.json`. Les textures doivent être répétables, inférieures à 512 px quand un SVG procédural suffit et sans texte rasterisé.

## Véhicules et progression

La silhouette prime à 160 px. Un véhicule doit montrer pneus, suspensions, cellule centrale, refroidissement, sécurité et appendices cohérents. La progression va d'une F4 haute et étroite vers une Apex basse, large et complexe. Les bibliothèques `graphics/parallel/monoplaces/` fournissent top/side/race, masques couleur et effets. Le kart conserve moteur latéral, essieu, tubes, protections et posture pilote identifiables.

## Environnements et infrastructures

Les circuits utilisent trois couches : sol matière, infrastructure fonctionnelle, vie (commissaires, signalétique, véhicules, éclairage). Les installations progressent par densité, qualité des enveloppes, outils et éclairage — jamais par simple changement d'échelle. La bibliothèque `graphics/parallel/facilities/` est désormais enregistrée dans le manifeste principal.

## Portraits et humains

Cadrage poitrine, lumière latérale froide, fond d'équipe, combinaison structurée. Les visages restent stylisés mais présentent mâchoire, nez, oreilles, sourcils et volumes capillaires. Préserver diversité d'âge, de carnation et de coiffure sans associer apparence et statistiques.

## Effets et mouvement

120 ms pour le retour tactile, 220 ms pour un panneau, 420 ms pour une transition. Le glow ne remplace jamais le contraste. Pluie, spray et poussière sont orientés par la vitesse ; les étincelles sont brèves et rares. Les paramètres sont centralisés sous `motion` dans les tokens.

## Accessibilité et mobile

Cible tactile minimale 48 px, texte courant 18 px à 1920 × 1080, état indiqué par couleur **et** symbole. Tester en 1280 × 720 et en simulation de daltonisme. Le contraste du texte essentiel vise WCAG AA ; les données ne sont jamais posées directement sur une zone visuelle agitée sans scrim.
