# Musiques d’ambiance

Déposer ici les trois masters **OGG Vorbis** (sans boucle intégrée) :

- `ambient_01.ogg`
- `ambient_02.ogg`
- `ambient_03.ogg`

`AudioManager` les découvre à l’exécution. Leur absence est volontairement non bloquante : le jeu reste entièrement utilisable et écrit un avertissement explicite dans le journal. La playlist boucle dans cet ordre et réalise un crossfade de cinq secondes entre deux lecteurs globaux.
