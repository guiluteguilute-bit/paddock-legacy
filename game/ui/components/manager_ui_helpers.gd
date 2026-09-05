extends RefCounted
class_name ManagerUIHelpers

const UI_DIR := "res://graphics/ui/manager_selection/cartoon/"
const SPECIALTY_ATLAS := UI_DIR + "ui_specialty_atlas.png"

static func texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path)

static func specialty(manager_id: String) -> Texture2D:
	var source := texture(SPECIALTY_ATLAS)
	if source == null:
		return null
	var size := source.get_size()
	var region := Rect2()
	match manager_id:
		"alex": region = Rect2(0, 0, size.x / 2.0, size.y / 2.0)
		"maya": region = Rect2(size.x / 2.0, 0, size.x / 2.0, size.y / 2.0)
		"ethan": region = Rect2(0, size.y / 2.0, size.x / 3.0, size.y / 2.0)
		"sofia": region = Rect2(size.x / 3.0, size.y / 2.0, size.x / 3.0, size.y / 2.0)
		"marcus": region = Rect2(size.x * 2.0 / 3.0, size.y / 2.0, size.x / 3.0, size.y / 2.0)
		_: return null
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	return atlas

static func game_button(text_value: String, height := 72) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size = Vector2(0, height)
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_color_override("font_color", Color("f4f8fb"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("0b3150")
	normal.border_color = Color("159fff")
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(10)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("071f35")
	pressed.border_color = Color("ffcc42")
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", normal)
	b.add_theme_stylebox_override("pressed", pressed)
	return b
