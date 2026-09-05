# GDScript safety (Godot 4.3)

Godot **4.3 stable** is the sole supported version. `validate_gdscript_safety.py` intentionally enforces only regressions seen in this project: inferred locals sourced directly from `Dictionary.get`, `JSON.parse`, or dynamic loads in critical UI/core code, and inferred locals inside literal floating-point loops. Use explicit types/casts for Variant data. Ordinary `:=` with a statically typed expression remains allowed.
