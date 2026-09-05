# Development workflow

1. Update `main`, then create a feature branch.
2. During development run `./scripts/check_fast.sh`.
3. Before opening a PR run `./scripts/ci_web.sh` with Godot 4.3 and Web templates installed.
4. Push, open a PR, and wait for **Deploy Web Preview / build** to pass.
5. Merge only while green. A green merge to `main` automatically rebuilds and deploys GitHub Pages.

Use `./scripts/diagnose_project.sh` to collect environment and resource diagnostics.
