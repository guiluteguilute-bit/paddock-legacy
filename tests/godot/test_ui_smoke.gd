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
		var main: Control = packed.instantiate() as Control
		add_child(main)
		await get_tree().process_frame
		for method: String in ["show_creation", "show_dashboard", "show_career", "show_race_preparation", "show_team", "show_settings"]:
			if main.has_method(method):
				main.call(method)
				await get_tree().process_frame
				if main.size.x < 0.0 or main.size.y < 0.0:
					push_error("Invalid UI dimensions after " + method)
					get_tree().quit(1)
					return
		main.queue_free()
		await get_tree().process_frame
	print("UI smoke checks passed at portrait and narrow viewport sizes")
	get_tree().quit(0)

func _test_manager_components() -> void:
	var bar_script: Script = load("res://game/ui/components/cartoon_stat_bar.gd") as Script
	for kind: String in ["technical", "strategy", "business"]:
		for score: int in [0, 25, 50, 75, 100]:
			var bar: Control = bar_script.new() as Control
			add_child(bar)
			bar.call("configure", float(score), kind)
			bar.set("atlas", null)
			bar.queue_redraw()
			bar.queue_free()
	var stats_script: Script = load("res://game/ui/components/manager_stats_card.gd") as Script
	for manager: Dictionary in [
		{"attributes": {"technical": 75, "strategy": 50, "business": 25}, "advantages": ["Rapide"], "drawbacks": ["Cher"]},
		{"attributes": {"technical": 50}},
	]:
		var card: Control = stats_script.new() as Control
		add_child(card)
		card.call("setup", manager)
		card.queue_free()
