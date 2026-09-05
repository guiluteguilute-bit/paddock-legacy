# Protecting `main`

Repository administrators must configure **Settings → Rules → Rulesets**, target `main`, enable **Require status checks to pass before merging**, and select `Deploy Web Preview / build`. Enable **Require branches to be up to date before merging**. Do not grant bypass permission to routine contributors. The workflow itself cannot enforce GitHub's server-side merge policy.
