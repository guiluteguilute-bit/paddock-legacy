# BOOT AND MUSIC UPDATE REPORT

## CAUSE ÉCRAN VIDE

Le diagnostic a identifié une régression de déploiement : `web/shell.html`, qui contenait déjà un retour de chargement et un rapport d'erreur JavaScript, n'était **pas utilisé** par le preset (`html/custom_html_shell=""`). Le build publié retombait donc sur le shell standard : son fond et son canvas pouvaient rester seuls visibles sur Safari quand le chargement du moteur/PCK/WASM échouait. En parallèle, la scène principale n'avait ni journalisation par phase ni repli visuel lorsqu'une configuration critique était vide. Ce cumul expliquait l'échec silencieux.

## CORRECTION

Le preset utilise maintenant le shell du dépôt. Celui-ci montre `PADDOCK LEGACY — CHARGEMENT…`, la progression, l'erreur de lancement et un bouton **RÉESSAYER**. La scène `Main` valide les données critiques et fournit aussi un écran d'erreur Godot identifié (`BOOT_DATA_001`). Les logs `[BOOT]` couvrent GameState, sauvegarde, routage d'onboarding et UI prête.

## TEST WEB

La validation statique contrôle la scène principale, les autoloads, les ressources et le shell. La CI importe le projet, exécute les tests Godot, charge réellement la scène principale pendant deux secondes, exporte `Web Preview`, puis exige des artefacts HTML/JS/WASM/PCK non vides.

## TEST SAFARI / LIMITATIONS

Le viewport utilise `viewport-fit=cover`, le canvas remplit la surface disponible et l'UI Godot conserve des marges de safe area. Le renderer reste `gl_compatibility`, sans threads Web. Aucun Safari/iPhone physique n'était connecté à cet environnement : la validation finale sur appareil reste recommandée. L'audio attend explicitement une interaction et ne participe jamais au boot de l'UI.

## ANCIEN ÉCRAN SUPPRIMÉ

L'écran « Chaque légende commence quelque part / Bâtissez votre légende / Créer une écurie » et sa fonction ont été supprimés du parcours et du code.

## NOUVEAU POINT D'ENTRÉE

Sans carrière valide, `Main` ouvre directement l'étape **Choisissez votre gérant** parmi cinq profils, sans champ texte et sans barre principale. Avec une carrière valide, il ouvre directement le dashboard. Après confirmation d'une nouvelle carrière, la sauvegarde est effacée puis le choix du gérant est affiché.

## AUDIO MANAGER

`AudioManager` est un autoload global. Il crée un bus `Music` et exactement deux `AudioStreamPlayer` (`MusicPlayerA/B`). Il persiste pendant la navigation et expose les points d'extension `enter_race_music()`, `exit_race_music()`, `fade_out_music()` et `fade_in_music()`.

## PLAYLIST

Les pistes attendues sont `res://audio/music/ambient_01.ogg`, `ambient_02.ogg`, puis `ambient_03.ogg`. Aucun faux son n'a été généré. Seule la piste active et la suivante lors du fondu sont chargées. Les fichiers absents sont ignorés avec un warning non bloquant. Les consignes de dépôt sont dans `audio/music/README.md`.

## CROSSFADE

Cinq secondes avant la fin, le second lecteur démarre à -60 dB tandis que le premier descend de -14 dB à -60 dB. Le second monte simultanément à -14 dB, puis les rôles sont inversés. La playlist boucle sur les pistes disponibles.

## GESTION AUTOPLAY IOS

Aucune lecture n'est lancée dans `_ready()`. Le premier touch, clic ou appui clavier demande la lecture. Un refus du navigateur ne bloque ni scène ni navigation. Pause et reprise d'application suspendent/reprennent les lecteurs existants sans en créer d'autres.

## VOLUME

Les réglages de carrière contiennent `settings.music_volume` (55 %) et `settings.music_enabled`. PARAMÈTRES propose un slider 0–100 et un bouton ON/OFF, reliés au bus Music et sauvegardés.

## PERFORMANCE

Les OGG ne sont pas préchargés par constantes. `ResourceLoader.exists()` découvre les fichiers, la piste courante est chargée à la demande et l'ancienne ressource est libérée après transition. Le format recommandé reste OGG Vorbis plutôt que WAV.

## TESTS

`tests/validate_project.py` vérifie désormais l'autoload, l'entrée directe, l'absence de l'ancien welcome, les cinq gérants, le gestionnaire audio et sa tolérance aux fichiers absents. Les validations export/artefact et les tests cœur Godot restent dans la CI.

## BUGS RESTANTS

- Les trois masters OGG ne sont pas présents et doivent être fournis par la production audio.
- Un essai manuel sur Safari iPhone réel reste nécessaire pour qualifier le mix, le geste d'activation audio et chaque version iOS ciblée.
