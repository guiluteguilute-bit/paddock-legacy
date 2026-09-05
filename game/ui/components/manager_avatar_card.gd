extends Control
class_name ManagerAvatarCard

signal chosen(manager_id: String)

const HELPERS := preload("res://game/ui/components/manager_ui_helpers.gd")
const UI_DIR := "res://graphics/ui/manager_selection/cartoon/"
const FRAME_NORMAL := UI_DIR + "ui_avatar_frame_normal.png"
const FRAME_SELECTED := UI_DIR + "ui_avatar_frame_selected.png"

func setup(manager_id: String, item: Dictionary, avatar_path: String, selected: bool) -> void:
	custom_minimum_size = Vector2(0, 176)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var portrait := TextureRect.new()
	portrait.texture = HELPERS.texture(avatar_path)
	portrait.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait.offset_left = 12
	portrait.offset_right = -12
	portrait.offset_top = 8
	portrait.offset_bottom = -18
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	var frame := TextureRect.new()
	frame.texture = HELPERS.texture(FRAME_SELECTED if selected else FRAME_NORMAL)
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

	var name := Label.new()
	name.text = str(item.get("first_name", manager_id)).to_upper()
	name.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name.offset_top = -40
	name.offset_bottom = -12
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
		modulate = Color(1.08, 1.08, 1.08, 1.0)
