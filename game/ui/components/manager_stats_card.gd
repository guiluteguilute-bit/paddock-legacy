extends Control
class_name ManagerStatsCard

const BAR := preload("res://game/ui/components/cartoon_stat_bar.gd")
const HELP := preload("res://game/ui/components/manager_ui_helpers.gd")
const PANEL := "res://graphics/ui/manager_selection/cartoon/ui_stats_panel.png"
const TECH := "res://graphics/ui/manager_selection/cartoon/ui_icon_technique.png"

func setup(manager: Dictionary) -> void:
	custom_minimum_size = Vector2(0, 410)
	var art := TextureRect.new()
	art.texture = HELP.texture(PANEL)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(art)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 175; box.offset_right = -175; box.offset_top = 86; box.offset_bottom = -90
	add_child(box)
	var a: Dictionary = manager.get("attributes", {})
	_stat(box, "TECHNIQUE", "technical", int(a.get("technical", 50)), true)
	_stat(box, "STRATÉGIE", "strategy", int(a.get("strategy", 50)), false)
	_stat(box, "BUSINESS", "business", int(a.get("business", 50)), false)
	_effects(manager)

func _stat(box: VBoxContainer, title: String, kind: String, score: int, show_icon: bool) -> void:
	var row := HBoxContainer.new(); box.add_child(row)
	if show_icon:
		var icon := TextureRect.new(); icon.texture = HELP.texture(TECH); icon.custom_minimum_size = Vector2(28, 28); icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; row.add_child(icon)
	var name := Label.new(); name.text = title; name.custom_minimum_size.x = 105; row.add_child(name)
	var bar = BAR.new(); bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bar.custom_minimum_size.y = 28; bar.configure(score, kind); row.add_child(bar)
	var value := Label.new(); value.text = str(score); value.custom_minimum_size.x = 34; value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; value.add_theme_color_override("font_color", Color("ffcc42")); row.add_child(value)
