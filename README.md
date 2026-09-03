# Paddock Legacy

Paddock Legacy est désormais une application **Godot unique**. Le site publié par
GitHub Pages est l'export Web de `project.godot`; l'ancien prototype JavaScript a
été retiré après transfert de sa sauvegarde, de son énergie, de ses objectifs et
de sa simulation stratégique vers les systèmes Godot.

## Lancer le projet

```bash
godot --path . --editor
godot --path .
```

Le point d'entrée est `game/ui/main.tscn`. Les données de carrière sont
sauvegardées dans `user://career.json` avec un numéro de version. Pour exporter :

```bash
mkdir -p build/web
godot --headless --path . --export-release "Web Preview" build/web/index.html
```

## Tests

```bash
python3 tests/validate_project.py
godot --headless --path . --script tests/godot/test_core.gd
```

Consulter `docs/GLOBAL_INTEGRATION_REPORT.md` pour l'audit, le périmètre jouable
et les limites connues de cette première tranche verticale.

Jeu mobile de gestion automobile, du karting au sommet de la monoplace.

## PLAY DEVELOPMENT BUILD

[![Deploy Web Preview](https://github.com/guiluteguilute-bit/paddock-legacy/actions/workflows/deploy-web.yml/badge.svg?branch=main)](https://github.com/guiluteguilute-bit/paddock-legacy/actions/workflows/deploy-web.yml)

La dernière version Godot de développement intégrée à `main` est exportée et
publiée automatiquement. **[Jouer à Paddock Legacy dans le navigateur](https://guiluteguilute-bit.github.io/paddock-legacy/).**

Le libellé discret `DEVELOPMENT BUILD` dans le jeu permet de vérifier le commit
effectivement affiché. Le premier déploiement nécessite éventuellement l'activation
de GitHub Pages décrite dans [`docs/GITHUB_PAGES_SETUP.md`](docs/GITHUB_PAGES_SETUP.md).

## Lancer le jeu

```bash
python3 -m http.server 4173
```

Puis ouvrez <http://localhost:4173> dans un navigateur. La progression est sauvegardée
localement dans le navigateur.

Pour travailler sur le véritable projet Godot, ouvrez le fichier `project.godot`
avec Godot 4.3. Le prototype HTML historique à la racine est conservé et ne constitue
pas le build Pages : GitHub Pages reçoit exclusivement l'export Godot automatisé.
