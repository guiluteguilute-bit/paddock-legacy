extends Control
class_name ManagerStatsCard

const BAR := preload("res://game/ui/components/cartoon_stat_bar.gd")
const HELP := preload("res://game/ui/components/manager_ui_helpers.gd")
func setup(manager: Dictionary) -> void:
	custom_minimum_size = Vector2(0, 218)
	var panel_texture := HELP.texture(HELP.optional_ui_path("ui_stats_panel.png"))
	if panel_texture == null:
		var fallback := Panel.new()
		fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var style := HELP.premium_panel(Color(0.08, 0.58, 0.75, 0.9))
		fallback.add_theme_stylebox_override("panel", style)
		add_child(fallback)
	var art := TextureRect.new()
	art.texture = panel_texture
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if panel_texture != null:
		add_child(art)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.offset_left = 20; box.offset_right = -20; box.offset_top = 18; box.offset_bottom = -14
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	var a: Dictionary = manager.get("attributes", {})
	_stat(box, "TECHNIQUE", "technical", int(a.get("technical", 50)), true)
	_stat(box, "STRATÉGIE", "strategy", int(a.get("strategy", 50)), false)
	_stat(box, "BUSINESS", "business", int(a.get("business", 50)), false)
	var divider := HSeparator.new(); divider.modulate = Color(0.2, 0.75, 0.9, 0.45); box.add_child(divider)
	var effects := HBoxContainer.new(); effects.add_theme_constant_override("separation", 12); box.add_child(effects)
	var advantages: Array = manager.get("advantages", [])
	var drawbacks: Array = manager.get("drawbacks", [])
	_effect(effects, "+ " + (str(advantages[0]) if not advantages.is_empty() else "Profil équilibré"), Color("79f19b"))
	_effect(effects, "− " + (str(drawbacks[0]) if not drawbacks.is_empty() else "Aucun malus majeur"), Color("ff766d"))

func _stat(box: VBoxContainer, title: String, kind: String, score: int, show_icon: bool) -> void:
	var row := HBoxContainer.new(); box.add_child(row)
	if show_icon:
		var icon_texture := HELP.texture(HELP.optional_ui_path("ui_icon_technique.png"))
		if icon_texture != null:
			var icon := TextureRect.new(); icon.texture = icon_texture; icon.custom_minimum_size = Vector2(28, 28); icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; row.add_child(icon)
	var name := Label.new(); name.text = title; name.custom_minimum_size.x = 105; row.add_child(name)
	var bar = BAR.new(); bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL; bar.custom_minimum_size.y = 28; bar.configure(score, kind); row.add_child(bar)
	var value := Label.new(); value.text = str(score); value.custom_minimum_size.x = 34; value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT; value.add_theme_color_override("font_color", Color("ffcc42")); row.add_child(value)

func _effect(row: HBoxContainer, text: String, color: Color) -> void:
	var label := Label.new(); label.text = text; label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12); label.add_theme_color_override("font_color", color); row.add_child(label)
