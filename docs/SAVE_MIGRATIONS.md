# Save migrations

Never replace the persisted `user://career.json` schema without incrementing `SAVE_VERSION` and adding a backward migration in `GameState._migrate`. Keep the project name and save path stable so Web IndexedDB data remains reachable. Tests must cover both a new career and at least one prior save version.
