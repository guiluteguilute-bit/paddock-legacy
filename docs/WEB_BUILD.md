# Build Web de développement

## Vue d'ensemble

Chaque push intégré à `main` déclenche `.github/workflows/deploy-web.yml`. Le job
télécharge Godot **4.3-stable** et ses templates officiels, importe le projet,
exporte le preset **Web Preview**, contrôle les fichiers essentiels puis transmet
l'artefact au mécanisme officiel GitHub Pages. Aucun export généré n'est commité.

- Projet Godot : `project.godot` à la racine du dépôt.
- Scène principale : `graphics/demo/ui_demo.tscn`.
- Preset : `Web Preview` dans `export_presets.cfg`.
- Build temporaire : `build/web/` ; point d'entrée `build/web/index.html`.
- Branche publiée automatiquement : `main` uniquement.
- URL : <https://guiluteguilute-bit.github.io/paddock-legacy/>.

La version 4.3 a été fixée pour rendre les builds reproductibles. Le format du
projet (`config_version=5`), les scènes (`format=3`) et le renderer Compatibility
identifient un projet Godot 4 ; 4.3-stable est la version documentée et utilisée
par le pipeline à compter de cette mise en place.

## Compatibilité Web et mobile

Le preset utilise le renderer Compatibility existant et désactive les threads Web.
Il ne requiert donc ni `SharedArrayBuffer`, ni en-têtes COOP/COEP, ce qui convient à
GitHub Pages et simplifie l'ouverture sous Safari iOS, Chrome, Edge et Firefox. Le
shell `web/shell.html` occupe tout le viewport, respecte la safe area du navigateur,
supprime scroll et overscroll, conserve le redimensionnement Godot et présente un
écran de chargement léger avec progression.

L'audit du dépôt n'a trouvé ni GDExtension, plugin, bibliothèque native, script
d'accès système, chemin Windows, appel OS, dépendance native ou code multithread.
Les deux shaders sont des shaders CanvasItem simples. Les scènes visuelles et SVG
sont compatibles avec l'export Web. Aucun réglage des futures plateformes Windows,
Android ou iOS n'a été ajouté ou remplacé.

Les sauvegardes Godot éventuelles sous `user://` restent propres à l'origine du site
et au stockage local du navigateur. Elles peuvent être effacées par l'utilisateur,
le mode privé ou le nettoyage des données Safari ; ce pipeline n'ajoute ni migration
ni synchronisation cloud.

## Build et cache

Le workflow remplace `local` dans `web/build_info.gd` par les sept premiers caractères
du SHA avant l'import. Le label `DEVELOPMENT BUILD` permet donc de reconnaître
immédiatement la version servie. Il est contrôlé par la feature d'export
`development_build`, qu'il suffit de retirer d'un futur preset commercial.

GitHub Pages et les navigateurs peuvent conserver brièvement les fichiers statiques.
En cas de doute, comparer le SHA affiché à celui du workflow, puis recharger la page
(ou fermer et rouvrir l'onglet). Le build n'active pas de service worker/PWA afin
d'éviter qu'une couche de cache applicative conserve une ancienne version.

## Lancement manuel

Ouvrir **GitHub → Actions → Deploy Web Preview → Run workflow**, sélectionner la
branche `main`, puis confirmer **Run workflow**. Les branches de travail ne déclenchent
jamais de publication automatique.

## Diagnostiquer un workflow rouge

1. Ouvrir le run dans **Actions**, puis le job `build`.
2. Consulter **Import and validate Godot project** pour les erreurs de ressource,
   de scène ou de parsing.
3. Consulter **Export Web Preview** pour un preset/template ou export défaillant.
4. Consulter **Validate Web artifact** : l'étape exige un `index.html` non vide et
   au moins un fichier `.js`, `.wasm` et `.pck` non vide.
5. Le job `deploy` ne démarre qu'après un build totalement valide : une version
   cassée n'est donc pas publiée silencieusement.

Si Pages n'a jamais été activé, suivre uniquement `docs/GITHUB_PAGES_SETUP.md`.

