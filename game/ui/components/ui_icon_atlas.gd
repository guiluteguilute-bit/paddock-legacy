extends RefCounted
class_name UIIconAtlas

const HELPERS := preload("res://game/ui/components/manager_ui_helpers.gd")
const COLUMNS := 3
const ROWS := 4
const ICON_MAP := {
	"accueil": Vector2i(0, 0),
	"equipe": Vector2i(1, 0),
	"voitures": Vector2i(2, 0),
	"recherche": Vector2i(0, 1),
	"ameliorations": Vector2i(1, 1),
	"courses": Vector2i(2, 1),
	"sponsors": Vector2i(0, 2),
	"finances": Vector2i(1, 2),
	"academie": Vector2i(2, 2),
	"classements": Vector2i(0, 3),
	"boutique": Vector2i(1, 3),
	"parametres": Vector2i(2, 3)
}

static func get_icon(icon_id: String) -> Texture2D:
	if not ICON_MAP.has(icon_id):
		return null
	var texture := HELPERS.texture(HELPERS.optional_ui_path("ui_navigation_icon_atlas.png"))
	if texture == null:
		return null
	if texture.get_width() % COLUMNS != 0 or texture.get_height() % ROWS != 0:
		return null
	var cell := Vector2(texture.get_width() / float(COLUMNS), texture.get_height() / float(ROWS))
	if not is_equal_approx(cell.x, cell.y):
		return null
	var grid: Vector2i = ICON_MAP[icon_id]
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(Vector2(grid.x * cell.x, grid.y * cell.y), cell)
	return atlas
