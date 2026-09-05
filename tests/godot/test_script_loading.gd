extends Node

const CRITICAL_SCRIPTS: Array[String] = [
	"res://game/ui/main.gd",
	"res://game/ui/components/cartoon_stat_bar.gd",
	"res://game/ui/components/manager_avatar_card.gd",
	"res://game/ui/components/manager_stats_card.gd",
	"res://game/ui/components/manager_ui_helpers.gd",
	"res://game/ui/components/ui_icon_atlas.gd",
	"res://game/core/game_state.gd",
	"res://game/core/audio_manager.gd",
	"res://game/core/screen_lab.gd",
	"res://game/core/endurance_simulator.gd",
	"res://game/races/race_view.gd",
]

func _ready() -> void:
	var failed: bool = false
	for path: String in CRITICAL_SCRIPTS:
		var script: Script = load(path) as Script
		if script == null or not script.can_instantiate():
			push_error("Critical script cannot load: " + path)
			failed = true
	print("Critical script loading checks passed" if not failed else "Critical script loading checks failed")
	get_tree().quit(1 if failed else 0)
