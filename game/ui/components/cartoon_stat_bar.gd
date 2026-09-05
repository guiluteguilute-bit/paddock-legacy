extends Control
class_name CartoonStatBar

const HELPERS = preload("res://game/ui/components/manager_ui_helpers.gd")

var value: float = 50.0:
	set(new_value):
		value = clampf(float(new_value), 0.0, 100.0)
		queue_redraw()

var stat_kind: String = "technical":
	set(new_kind):
		stat_kind = str(new_kind)
		queue_redraw()

var atlas: Texture2D = null

func _ready() -> void:
	custom_minimum_size = Vector2(0, 26)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	atlas = HELPERS.texture(HELPERS.optional_ui_path("ui_stat_gauges_atlas.png"))
	queue_redraw()

func configure(new_value: float, new_kind: String) -> void:
	value = new_value
	stat_kind = new_kind

func _draw() -> void:
	if atlas == null:
		_draw_fallback()
		return

	var tex_size: Vector2 = atlas.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		_draw_fallback()
		return

	var background_region: Rect2 = _scaled_region(Rect2(14, 48, 573, 67), tex_size)
	var fill_region: Rect2 = _scaled_region(_fill_region_for_kind(), tex_size)
	var dest: Rect2 = Rect2(Vector2.ZERO, size)
	var fill_ratio: float = value / 100.0
	var inset_x: float = size.x * 0.055
	var inset_y: float = size.y * 0.23
	var fill_width: float = maxf(0.0, (size.x - inset_x * 2.0) * fill_ratio)
	var fill_area: Rect2 = Rect2(inset_x, inset_y, fill_width, size.y * 0.54)

	if fill_area.size.x > 0.0:
		var source_width: float = fill_region.size.x * fill_ratio
		var source_region: Rect2 = Rect2(
			fill_region.position,
			Vector2(source_width, fill_region.size.y)
		)
		draw_texture_rect_region(atlas, fill_area, source_region)

	draw_texture_rect_region(atlas, dest, background_region)

func _fill_region_for_kind() -> Rect2:
	match stat_kind:
		"strategy":
			return Rect2(40, 189, 523, 52)
		"business":
			return Rect2(40, 249, 523, 53)
		_:
			return Rect2(40, 129, 524, 52)

func _scaled_region(source: Rect2, texture_size: Vector2) -> Rect2:
	return Rect2(
		source.position.x / 600.0 * texture_size.x,
		source.position.y / 450.0 * texture_size.y,
		source.size.x / 600.0 * texture_size.x,
		source.size.y / 450.0 * texture_size.y
	)

func _draw_fallback() -> void:
	var radius: float = minf(size.y * 0.45, 10.0)
	var background_box: StyleBoxFlat = _fallback_box(
		Color(0.01, 0.03, 0.05, 0.95),
		radius
	)
	draw_style_box(background_box, Rect2(Vector2.ZERO, size))

	var fill_color: Color = Color("19dcc6")
	if stat_kind == "strategy":
		fill_color = Color("ffcc3d")
	elif stat_kind == "business":
		fill_color = Color("ff5f4f")

	var width: float = size.x * value / 100.0
	if width > 0.0:
		var fill_box: StyleBoxFlat = _fallback_box(fill_color, radius)
		draw_style_box(fill_box, Rect2(0, 0, width, size.y))

	var gloss_width: float = maxf(0.0, width - 8.0)
	if gloss_width > 0.0:
		draw_rect(Rect2(4, 3, gloss_width, 3), Color(1, 1, 1, 0.22))

	# Explicit float locals avoid Godot 4.3 Variant inference failures.
	var x_25: float = size.x * 0.25
	var x_50: float = size.x * 0.50
	var x_75: float = size.x * 0.75
	var tick_color: Color = Color(0, 0, 0, 0.28)
	draw_line(Vector2(x_25, 4), Vector2(x_25, size.y - 4), tick_color, 1.0)
	draw_line(Vector2(x_50, 4), Vector2(x_50, size.y - 4), tick_color, 1.0)
	draw_line(Vector2(x_75, 4), Vector2(x_75, size.y - 4), tick_color, 1.0)

func _fallback_box(color: Color, radius: float) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(int(radius))
	return box
