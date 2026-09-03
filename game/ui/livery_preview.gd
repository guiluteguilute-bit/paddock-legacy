class_name LiveryPreview
extends Control

var primary := Color("19dcc6")
var secondary := Color("102a38")
var accent := Color("ffcf4a")
var pattern := 0

func set_livery(colors: Array, selected_pattern: int) -> void:
	primary = Color(colors[0]); secondary = Color(colors[1]); accent = Color(colors[2]); pattern = selected_pattern
	queue_redraw()

func _draw() -> void:
	var w := size.x; var y := size.y * 0.55
	draw_circle(Vector2(w * .25, y + 34), 28, Color("071117")); draw_circle(Vector2(w * .75, y + 34), 28, Color("071117"))
	draw_colored_polygon(PackedVector2Array([Vector2(w*.15,y),Vector2(w*.30,y-45),Vector2(w*.67,y-45),Vector2(w*.86,y),Vector2(w*.78,y+28),Vector2(w*.22,y+28)]), primary)
	draw_colored_polygon(PackedVector2Array([Vector2(w*.32,y-45),Vector2(w*.46,y-82),Vector2(w*.60,y-82),Vector2(w*.68,y-45)]), secondary)
	if pattern % 3 == 0: draw_line(Vector2(w*.22,y+4), Vector2(w*.81,y+4), accent, 12)
	elif pattern % 3 == 1: draw_colored_polygon(PackedVector2Array([Vector2(w*.38,y-45),Vector2(w*.52,y-45),Vector2(w*.38,y+28),Vector2(w*.25,y+28)]), accent)
	else:
		for i in 4: draw_line(Vector2(w*(.28+i*.12),y-42),Vector2(w*(.20+i*.12),y+25),accent,5)
	draw_string(ThemeDB.fallback_font, Vector2(w*.48,y-54), "#", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color.WHITE)
