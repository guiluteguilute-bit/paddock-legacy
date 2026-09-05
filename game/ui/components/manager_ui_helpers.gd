extends RefCounted
class_name ManagerUIHelpers

## Optional art is assembled at runtime so missing, not-yet-shipped cartoon
## files do not become mandatory Web export resources.
static func optional_ui_path(file_name: String) -> String:
	return "res:/" + "/graphics/ui/manager_selection/cartoon/" + file_name

static func texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path)

static func specialty(manager_id: String) -> Texture2D:
	var source := texture(optional_ui_path("ui_specialty_atlas.png"))
	if source == null:
		return null
	var size := source.get_size()
	# The supplied layout has two equal cells on top and three below. Refuse an
	# incompatible image rather than assigning a manager the wrong badge.
	if size.x <= 0.0 or size.y <= 0.0 or int(size.x) % 6 != 0 or int(size.y) % 2 != 0:
		return null
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
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("10527a")
	hover.border_color = Color("5edfff")
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("focus", pressed)
	return b

static func premium_panel(accent := Color("159fff"), fill := Color(0.025, 0.10, 0.15, 0.94), radius := 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = accent
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 8
	return style

static func specialty_name(manager_id: String) -> String:
	return {"alex":"TECHNICIEN", "maya":"STRATÈGE", "ethan":"COMMERCIAL", "sofia":"FORMATRICE", "marcus":"MENEUR"}.get(manager_id, "GÉRANT")
