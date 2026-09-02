# Rapport de déploiement Web

## MISSION

**GitHub Pages / Web Development Build**

## VERSION GODOT

Godot **4.3-stable**, projet Godot 4 (`config_version=5`) situé dans
`/workspace/paddock-legacy/project.godot` lors de la mission.

## PRESET WEB

**Web Preview** — renderer Compatibility, export Web single-thread, shell responsive
et feature `development_build`.

## WORKFLOW CRÉÉ

`.github/workflows/deploy-web.yml` : import, export, contrôles d'intégrité, artefact
Pages et déploiement officiel.

## FICHIERS MODIFIÉS

- `README.md`
- `graphics/demo/ui_demo.tscn`
- `project.godot`

## FICHIERS CRÉÉS

- `.github/workflows/deploy-web.yml`
- `.gitignore`
- `export_presets.cfg`
- `web/shell.html`
- `web/build_info.gd`
- `docs/WEB_BUILD.md`
- `docs/GITHUB_PAGES_SETUP.md`
- `docs/CODEX_WEB_DEPLOY_REPORT.md`

## TESTS EFFECTUÉS

- Inventaire complet des fichiers suivis, scènes, ressources et documentation.
- Audit des workflows et presets existants : aucun n'existait.
- Audit Web : aucune extension, dépendance native, API système, chemin Windows ou
  fonctionnalité multithread détectée.
- Validation syntaxique des JSON, XML/SVG, scènes, ressources et YAML.
- Import headless et export Web local tentés selon les outils disponibles.
- Vérification de `index.html`, JavaScript, WebAssembly et PCK prévue et bloquante
  dans GitHub Actions.

## EXPORT WEB

**ÉCHEC EN LOCAL (Godot absent de l’environnement)** ; export automatisé configuré dans
le pipeline vers `build/web/`, non commité. Le workflow réalisera et validera le premier
export avec Godot 4.3-stable avant tout déploiement.

## GITHUB ACTIONS

**CONFIGURÉ**

## GITHUB PAGES

**ACTION MANUELLE REQUISE** si la source Pages du dépôt n'est pas encore réglée sur
GitHub Actions. Codex ne disposait ni d'un remote configuré ni d'une authentification
GitHub permettant de vérifier ou modifier ce paramètre.

## URL DU JEU

<https://guiluteguilute-bit.github.io/paddock-legacy/>

Cette URL est déduite du propriétaire visible dans l'historique et du nom du dépôt ;
elle deviendra active après l'activation Pages et un déploiement réussi.

## BRANCHE DÉPLOYÉE

`main`

## DÉCLENCHEMENT AUTOMATIQUE

**OUI**, sur push vers `main`.

## DÉCLENCHEMENT MANUEL

**OUI**, via `workflow_dispatch`.

## COMPATIBILITÉ MOBILE

Shell plein écran responsive, paysage Godot conservé, viewport mobile et safe areas,
sans dépendance à `SharedArrayBuffer`. Cibles raisonnables : Safari iOS, Chrome,
Edge et Firefox récents. Une validation finale sur appareils physiques reste requise.

## LIMITATIONS

- La scène principale est la démonstration visuelle existante, sans faux gameplay.
- Les performances et gestes doivent être confirmés sur appareils réels.
- Le stockage Web local dépend du navigateur et de l'origine GitHub Pages.
- Les caches CDN/navigateur peuvent retarder brièvement l'affichage ; le SHA visible
  sert de contrôle et aucune PWA n'ajoute de cache persistant.

## ÉTAPES MANUELLES RESTANTES

Si nécessaire seulement : **Settings → Pages → Build and deployment → Source →
GitHub Actions**, puis lancer `Deploy Web Preview` depuis l'onglet Actions.
