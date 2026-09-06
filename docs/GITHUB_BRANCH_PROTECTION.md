# Protection de la branche `main`

Les paramètres de protection GitHub ne sont pas modifiés par le dépôt. Un
administrateur doit configurer **Settings → Branches → Add branch protection
rule** avec les valeurs suivantes :

1. Branch name pattern : `main`.
2. Activer **Require a pull request before merging**.
3. Activer **Require status checks to pass before merging**.
4. Activer **Require branches to be up to date before merging**.
5. Rechercher puis sélectionner le contrôle requis
   **Deploy Web Preview / build**.
6. Activer **Do not allow bypassing the above settings** si la politique du
   dépôt permet de l'imposer aussi aux administrateurs.

Le job `deploy` n'est pas un contrôle de pull request : il ne s'exécute que sur
`main`. Son `needs: build` garantit que Pages ne reçoit jamais un artifact dont
la validation complète a échoué.
