# Réparation du déploiement Web GitHub Pages

## Cause exacte de l'échec

Le changement `d7964e5` avait ajouté au **milieu de chaque exécution** un appel
administratif :

```sh
gh api --method PUT "repos/${GITHUB_REPOSITORY}/pages" --field build_type=workflow
```

Cette mutation de la configuration du dépôt n'est pas une étape de build et le
`GITHUB_TOKEN` du job, limité à `contents`, `pages` et `id-token`, n'accorde pas
l'administration du dépôt. L'étape `Select GitHub Actions as Pages source` était
donc la première cause déterministe d'échec (`403 / Resource not accessible by
integration`) après la génération de l'artefact. La source Pages ayant désormais
été choisie dans les réglages du dépôt, cet appel est aussi inutile. Il a été
supprimé : le workflow ne modifie plus sa propre configuration Pages.

L'accès aux exécutions distantes depuis l'environnement de réparation a été tenté
avec `gh run list` puis l'API publique GitHub. Le conteneur ne possède aucun jeton
GitHub et son proxy refuse l'API publique ; il n'a donc pas été possible d'archiver
une nouvelle copie des logs dans le dépôt. Le diagnostic ci-dessus est confirmé
par le diff du commit fautif, qui n'ajoutait que cette étape avant l'échec observé.

## Correctifs

- Le binaire officiel **Godot 4.3-stable** et ses templates **4.3.stable** restent
  strictement appairés avec `config/features=PackedStringArray("4.3")` du projet.
- Le binaire est installé dans `.tools/` au lieu d'écrire dans `/usr/local/bin`.
- L'import headless, les validations statiques, les tests Godot, le chargement réel
  de `res://game/ui/main.tscn`, puis l'export release sont des étapes bloquantes.
- Le validateur d'artefact exige un `index.html`, un JavaScript, un WebAssembly et
  un PCK non vides, l'expansion des jetons du shell, le canvas, l'écran de chargement
  et `.nojekyll`. Il refuse aussi une page README ou un `alert()` dans l'entrée HTML.
- Les chemins `res://` sont contrôlés avec leur casse Linux ; tous les JSON et SVG
  du dépôt sont parsés lors de la validation statique.
- Les pull requests construisent et testent sans configurer, uploader ni déployer
  Pages. Seuls `push`/fusion sur `main` et un lancement manuel depuis `main` publient.
- Le groupe de concurrence `pages` annule un ancien déploiement au profit du plus
  récent. Les permissions minimales Pages restent explicites.

Le projet conserve son unique scène principale `game/ui/main.tscn`, son rendu
Compatibility sans threads, son format portrait et le shell à chemins relatifs.
Le shell affiche « Paddock Legacy », une progression et une erreur dans la page ;
il n'utilise ni redirection vers le README, ni prototype JavaScript, ni boîte
`alert()` bloquante. `viewport-fit=cover` et les marges CSS/Godot protègent les safe
areas mobiles.

## Fichiers modifiés

- `.github/workflows/deploy-web.yml`
- `tests/validate_project.py`
- `tests/validate_web_build.py` (nouveau)
- `docs/WEB_DEPLOY_FIX_REPORT.md` (ce rapport)

## Commandes et résultats

| Commande | Résultat |
| --- | --- |
| `python3 tests/validate_project.py` | Succès : structure, JSON, SVG, ressources, données et intégration validés. |
| `python3 -m py_compile tests/validate_project.py tests/validate_web_build.py` | Succès. |
| `git diff --check` | Succès. |
| `gh run list --repo guiluteguilute-bit/paddock-legacy --workflow 'Deploy Web Preview'` | Limitation : authentification GitHub absente du conteneur. |
| `curl …github.com/godotengine/godot/releases…` | Limitation : proxy du conteneur (HTTP 403), donc pas d'export local. |

L'import, le test Godot, le chargement de scène et l'export complet sont néanmoins
reproductibles dans le runner Ubuntu via le workflow et doivent tous réussir avant
que l'upload Pages soit exécuté.

## Résultat attendu après fusion

Après fusion sur `main`, `Deploy Web Preview` construit `build/web`, y ajoute
`.nojekyll`, charge cet artefact avec `actions/upload-pages-artifact`, puis le publie
avec `actions/deploy-pages`. L'URL
<https://guiluteguilute-bit.github.io/paddock-legacy/> doit servir directement
`index.html` et lancer la scène `game/ui/main.tscn` : le premier écran présente le
véritable menu Paddock Legacy et le bouton **CRÉER UNE ÉCURIE**, jamais le README.

À vérifier après fusion : exécution verte des jobs `build` et `deploy`, environnement
`github-pages` associé à l'URL ci-dessus, disparition du README après purge du cache,
fin de l'écran « Chargement… », présence du bouton principal et absence d'erreur
console sur Safari iPhone, Chrome Android, Chrome/Edge/Firefox desktop.
