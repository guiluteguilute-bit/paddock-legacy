extends Control
class_name ManagerAvatarCard

signal chosen(manager_id: String)

const HELPERS := preload("res://game/ui/components/manager_ui_helpers.gd")
func setup(manager_id: String, item: Dictionary, avatar_path: String, selected: bool) -> void:
	custom_minimum_size = Vector2(0, 104 if selected else 96)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var frame_path := HELPERS.optional_ui_path("ui_avatar_frame_selected.png" if selected else "ui_avatar_frame_normal.png")
	var frame_texture := HELPERS.texture(frame_path)
	if frame_texture == null:
		var fallback := StyleBoxFlat.new()
		fallback.bg_color = Color(0.025, 0.10, 0.15, 0.96)
		fallback.border_color = Color("ffcc42") if selected else Color("168fc0")
		fallback.set_border_width_all(4 if selected else 2)
		fallback.set_corner_radius_all(12)
		fallback.shadow_color = Color(1.0, 0.72, 0.1, 0.42) if selected else Color(0, 0, 0, 0.4)
		fallback.shadow_size = 8 if selected else 3
		var panel := Panel.new()
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.add_theme_stylebox_override("panel", fallback)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(panel)

	var portrait := TextureRect.new()
	portrait.texture = HELPERS.texture(avatar_path)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 7
	portrait.offset_right = -7
	portrait.offset_top = 5
	portrait.offset_bottom = -15
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	var frame := TextureRect.new()
	frame.texture = frame_texture
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if frame_texture != null:
		add_child(frame)

	var name := Label.new()
	name.text = str(item.get("first_name", manager_id)).to_upper()
	name.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name.offset_top = -31
	name.offset_bottom = -7
	name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name.add_theme_font_size_override("font_size", 13 if selected else 11)
	name.add_theme_color_override("font_color", Color("ffcc42") if selected else Color("f4f8fb"))
	name.add_theme_color_override("font_shadow_color", Color.BLACK)
	name.add_theme_constant_override("shadow_offset_x", 2)
	name.add_theme_constant_override("shadow_offset_y", 2)
	name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name)

	var hit := Button.new()
	hit.flat = true
	hit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hit.tooltip_text = "%s - %s" % [item.get("first_name", manager_id), item.get("title", "")]
	hit.pressed.connect(func(): chosen.emit(manager_id))
	add_child(hit)

	if selected:
		modulate = Color(1.08, 1.08, 1.04, 1.0)
		position.y = -4
