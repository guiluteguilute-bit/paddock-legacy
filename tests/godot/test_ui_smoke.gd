extends Node

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_manager_components()
	var packed: PackedScene = load("res://game/ui/main.tscn") as PackedScene
	if packed == null:
		push_error("Main UI scene cannot load")
		get_tree().quit(1)
		return

	for viewport_size: Vector2i in [Vector2i(1080, 1920), Vector2i(390, 844)]:
		get_tree().root.size = viewport_size
		GameState.data = GameState.defaults()

		var main: Control = packed.instantiate() as Control
		add_child(main)
		await get_tree().process_frame

		# Onboarding/no-career path.
		main.call("show_creation")
		await get_tree().process_frame
		_assert_valid_size(main, "show_creation")

		# Career-only screens are exercised with a complete in-memory fixture.
		_install_smoke_career()
		for method: String in ["show_dashboard", "show_career", "show_race_prep", "show_team", "show_settings"]:
			if not main.has_method(method):
				push_error("Missing smoke-tested UI method: " + method)
				get_tree().quit(1)
				return
			main.call(method)
			await get_tree().process_frame
			_assert_valid_size(main, method)

		main.free()
		await get_tree().process_frame
		await get_tree().process_frame

	GameState.data = GameState.defaults()
	print("UI smoke checks passed at portrait and narrow viewport sizes")
	get_tree().quit(0)

func _install_smoke_career() -> void:
	var smoke_data: Dictionary = GameState.defaults()
	smoke_data.team = {
		"name": "Smoke Racing",
		"short_name": "SMOKE",
		"country": "France",
		"number": 27,
		"colors": ["#19dcc6", "#102a38", "#ffcf4a"],
		"livery_pattern": 0
	}
	smoke_data.driver = {
		"first_name": "Test",
		"last_name": "Driver",
		"nationality": "France",
		"number": 27,
		"hidden_potential": 82,
		"xp_multiplier": 1.0,
		"stats": {
			"speed": 60,
			"control": 60,
			"mental": 60,
			"start": 55,
			"overtaking": 55,
			"defence": 55,
			"rain": 55,
			"tyre_management": 55
		}
	}
	smoke_data.team_dna = GameState.neutral_dna()
	GameState.data = smoke_data
	GameState.data.calendar = GameState.make_calendar("KART")
	GameState.data.standings = GameState.make_standings()

func _assert_valid_size(main: Control, method: String) -> void:
	if main.size.x < 0.0 or main.size.y < 0.0:
		push_error("Invalid UI dimensions after " + method)
		get_tree().quit(1)

func _test_manager_components() -> void:
	var bar_script: Script = load("res://game/ui/components/cartoon_stat_bar.gd") as Script
	if bar_script == null:
		push_error("CartoonStatBar script cannot load")
		return

	for kind: String in ["technical", "strategy", "business"]:
		for score: int in [0, 25, 50, 75, 100]:
			var bar: Control = bar_script.new() as Control
			add_child(bar)
			bar.call("configure", float(score), kind)
			bar.set("atlas", null)
			bar.queue_redraw()
			bar.free()

	var stats_script: Script = load("res://game/ui/components/manager_stats_card.gd") as Script
	if stats_script == null:
		push_error("ManagerStatsCard script cannot load")
		return

	for manager: Dictionary in [
		{"attributes": {"technical": 75, "strategy": 50, "business": 25}, "advantages": ["Rapide"], "drawbacks": ["Cher"]},
		{"attributes": {"technical": 50}},
	]:
		var card: Control = stats_script.new() as Control
		add_child(card)
		card.call("setup", manager)
		card.free()
