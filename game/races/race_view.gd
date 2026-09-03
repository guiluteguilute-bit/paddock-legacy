class_name RaceView
extends Control

signal finished(result)

const NAMES := ["MOREL", "ROSSI", "MARTIN", "DUBOIS", "NOVAK", "SMITH", "SATO", "GARCIA", "KLEIN", "COSTA", "WILSON", "BERNARD"]
const STRATEGIES := {"CONSERVE": 0.96, "NORMAL": 1.0, "PUSH": 1.035, "ATTACK": 1.06}
var racers: Array = []
var running = false
var qualifying = true
var elapsed = 0.0
var laps = 8
var strategy = "NORMAL"
var risk = "NORMAL"
var camera_mode = "TV"
var weather = "SEC"
var category = "KART"
var tyre = "MEDIUM"
var tyre_temperature = "OPTIMAL"
var weather_phase = 0
var start_position = 12
var yellow_timer = 0.0
var start_lights = 0
var pit_requested = false
var player_name = "PILOTE"
var event_text = "Qualifications prêtes"
var rng = RandomNumberGenerator.new()

func setup(driver_name: String, race_laps: int, rain_probability: float = 0.0, race_category: String = "KART") -> void:
	player_name = driver_name.to_upper()
	laps = race_laps
	category = race_category
	weather = "RAIN" if rain_probability > 0.55 else "SEC"
	tyre = "MEDIUM" if category == "F4" else "KART"
	reset_session()

func reset_session() -> void:
	rng.seed = 4200 + int(GameState.data.get("race_index", 0))
	racers.clear(); elapsed = 0.0; running = false; qualifying = true; strategy = "NORMAL"; risk = "NORMAL"; pit_requested = false; yellow_timer = 0.0; start_lights = 0; weather_phase = 0
	for i in 12:
		var rival_name: String = NAMES[i]
		if i>0 and GameState.career_config.get("rivals",[]).size()>=i:rival_name=GameState.career_config.rivals[i-1].name
		racers.append({"name": player_name if i == 0 else rival_name, "progress": -float(i) * 0.008, "lap": 0, "speed": (0.091 if category == "F4" else 0.078) + rng.randf_range(-0.005, 0.005), "wear": 100.0, "fuel": 100.0, "condition": 100.0, "position": i + 1, "best": 999.0, "last": 0.0, "lap_start": 0.0, "lane": 0.0, "pit": 0.0, "color": Color("19dcc6") if i == 0 else Color.from_hsv(float(i) / 12.0, 0.65, 0.9), "strategy":["AGGRESSIVE","BALANCED","CONSERVATIVE","OPPORTUNIST"][i%4]})
	event_text = "QUALIFICATIONS PRÊTES"
	queue_redraw()

func start_qualifying() -> void:
	qualifying = true; running = true; elapsed = 0.0; event_text = "QUALIFICATIONS EN COURS"

func start_race() -> void:
	start_position = int(racers[0].position)
	for i in racers.size():
		var r: Dictionary = racers[i]; r.progress = -float(i) * 0.008; r.lap = 0; r.wear = 100.0; r.fuel = 100.0; r.lap_start = 0.0; r.lane = -0.35 if i % 2 == 0 else 0.35
	qualifying = false; running = true; elapsed = 0.0; start_lights = 1; event_text = "SÉQUENCE DE DÉPART"

func set_strategy(value: String) -> void:
	if STRATEGIES.has(value): strategy = value; event_text = "RYTHME %s" % value

func set_risk(value: String) -> void: risk = value; event_text = "RISQUE %s" % value
func set_camera(value: String) -> void: camera_mode = value; event_text = "CAMÉRA %s" % value; queue_redraw()
func request_pit(new_tyre: String = "MEDIUM") -> void: pit_requested = true; tyre = new_tyre; event_text = "BOX CONFIRME • %s AU PROCHAIN TOUR" % tyre

func _process(delta: float) -> void:
	if not running: return
	elapsed += delta
	if not qualifying and elapsed < 3.0:
		start_lights = mini(5, int(elapsed / 0.5) + 1); queue_redraw(); return
	elif not qualifying and start_lights > 0: start_lights = 0; event_text = "EXTINCTION DES FEUX • DÉPART"
	if yellow_timer > 0.0: yellow_timer -= delta
	if category == "F4" and weather_phase == 0 and int(racers[0].lap) >= laps / 2 and rng.randf() < 0.01:
		weather = "LIGHT RAIN" if weather == "SEC" else "DRYING"; weather_phase = 1; event_text = "MÉTÉO • " + weather
	for i in racers.size():
		var r: Dictionary = racers[i]
		var multiplier: float = float(STRATEGIES[strategy] if i == 0 else {"AGGRESSIVE":1.025,"BALANCED":1.0,"CONSERVATIVE":0.98,"OPPORTUNIST":1.01}[r.strategy])
		if yellow_timer > 0.0: multiplier *= 0.72
		if i == 0: multiplier *= {"LOW": 0.985, "NORMAL": 1.0, "HIGH": 1.018}[risk]
		var phase = fmod(float(r.progress), 1.0)
		var corner_factor = 0.88 + 0.12 * absf(sin(phase * TAU * 2.0))
		var tyre_factor: float = lerpf(0.88, 1.0, float(r.wear) / 100.0)
		var old_progress: float = r.progress
		var near_car: bool = _near_car(i)
		var target_lane = (0.62 if i % 2 == 0 else -0.62) if near_car else 0.0
		r.lane = lerpf(float(r.lane), target_lane, delta * (2.2 if near_car else 1.2))
		var pit_slow = 0.42 if float(r.pit) > 0.0 else 1.0
		r.progress += delta * float(r.speed) * multiplier * tyre_factor * corner_factor * pit_slow
		r.wear = maxf(0.0, float(r.wear) - delta * ({"CONSERVE": 0.20, "NORMAL": 0.28, "PUSH": 0.40, "ATTACK": 0.55}.get(strategy, 0.3) if i == 0 else 0.3))
		r.fuel = maxf(0.0, float(r.fuel) - delta * 0.20 * multiplier)
		if i == 0 and category == "F4":
			var temp_value =float(r.wear); tyre_temperature="OVERHEATED" if strategy=="ATTACK" and temp_value<55 else ("HOT" if strategy=="PUSH" else ("COLD" if strategy=="CONSERVE" else "OPTIMAL"))
			var incident_chance =0.00012*(2.2 if risk=="HIGH" else 1.0)*(2.0 if weather in ["RAIN","LIGHT RAIN"] else 1.0)
			if rng.randf()<incident_chance: event_text=["LOCK UP","SPIN","CONTACT","OFF TRACK"][rng.randi_range(0,3)];r.progress-=0.025;r.condition-=6.0;yellow_timer=2.0
		if float(r.pit) > 0.0:
			r.pit -= delta
			if float(r.pit) <= 0.0: r.wear = 100.0; r.condition = minf(100.0, float(r.condition) + 8.0); event_text = "SORTIE DES STANDS • " + tyre
		if int(old_progress) < int(r.progress):
			r.lap += 1; r.last = elapsed - float(r.lap_start); r.lap_start = elapsed; r.best = minf(float(r.best), float(r.last))
			if i == 0 and pit_requested: r.pit = maxf(2.2,3.2-float(GameState.data.facilities.get("pit_crew",0))*0.15); pit_requested = false; r.lane = 1.15; event_text = "ARRÊT AU BOX"
	_sort_positions()
	if qualifying and elapsed >= 15.0: running = false; event_text = "QUALIFICATIONS TERMINÉES • P%d" % int(racers[0].position)
	elif not qualifying and int(racers[0].lap) >= laps: _finish_race()
	queue_redraw()

func _near_car(index: int) -> bool:
	for j in racers.size():
		if j != index and absf(float(racers[j].progress) - float(racers[index].progress)) < 0.018: return true
	return false

func _sort_positions() -> void:
	var order: Array = racers.duplicate(); order.sort_custom(func(a, b): return float(a.progress) > float(b.progress))
	for i in order.size(): order[i].position = i + 1

func _finish_race() -> void:
	running = false; event_text = "DRAPEAU À DAMIER"
	var standing: Array = racers.duplicate(); standing.sort_custom(func(a, b): return int(a.position) < int(b.position))
	var rows: Array = []
	for r in standing: rows.append({"name": r.name, "position": r.position, "best_lap": r.best, "fastest_lap": r.best == standing.map(func(x):return x.best).min()})
	finished.emit({"position": racers[0].position, "start_position":start_position, "best_lap": racers[0].best, "total_time":elapsed, "tyres_remaining":int(racers[0].wear), "strategy": strategy, "tyre":tyre, "weather":weather, "incidents": [], "standings": rows, "track": GameState.data.calendar[GameState.data.race_index].track})

func _track_point(progress: float, lane: float, area: Rect2) -> Dictionary:
	var a = TAU * fmod(progress, 1.0)
	var radius = Vector2(area.size.x * 0.34, area.size.y * 0.32)
	var bend = 1.0 + 0.12 * sin(a * 3.0)
	var center = area.get_center()
	var p = center + Vector2(cos(a) * radius.x, sin(a) * radius.y) * bend
	var tangent = Vector2(-sin(a) * radius.x, cos(a) * radius.y).normalized()
	var normal = Vector2(-tangent.y, tangent.x)
	return {"point": p + normal * lane * 16.0, "angle": tangent.angle(), "normal": normal}

func _draw() -> void:
	var track = Rect2(Vector2(8, 48), Vector2(size.x - 16, maxf(260.0, size.y - 172)))
	draw_rect(track, Color("183627"), true)
	# Mown grass, gravel, pit building and miniature grandstand give the circuit depth.
	for y in range(int(track.position.y), int(track.end.y), 18): draw_line(Vector2(track.position.x, y), Vector2(track.end.x, y), Color(0.12, 0.27, 0.19, 0.35), 8.0)
	var points = PackedVector2Array()
	for n in 97: points.append(_track_point(float(n) / 96.0, 0.0, track).point)
	draw_polyline(points, Color("d4d8cf"), 54.0, true)
	draw_polyline(points, Color("252b30" if weather == "SEC" else "17242b"), 46.0, true)
	draw_polyline(points, Color(0.03, 0.03, 0.03, 0.35), 3.0, true)
	for n in range(0, 96, 4):
		var curb = _track_point(float(n) / 96.0, 0.0, track); draw_circle(curb.point + curb.normal * 25.0, 4.0, Color("ef494f") if n % 8 == 0 else Color.WHITE)
	var pit_y = track.end.y - 34.0
	draw_rect(Rect2(track.position.x + 70, pit_y, track.size.x - 140, 17), Color("3b4549"), true)
	for x in range(int(track.position.x + 85), int(track.end.x - 85), 42): draw_rect(Rect2(x, pit_y - 14, 32, 12), Color("53636a"), true)
	if weather == "PLUIE":
		draw_rect(track, Color(0.15, 0.28, 0.37, 0.24), true)
		for x in range(int(track.position.x), int(track.end.x), 24): draw_line(Vector2(x, track.position.y), Vector2(x - 30, track.end.y), Color(0.7, 0.85, 1.0, 0.18), 1.0)
	for i in range(racers.size() - 1, -1, -1):
		var r: Dictionary = racers[i]; var pose = _track_point(float(r.progress), float(r.lane), track); _draw_car(pose.point, pose.angle, r.color, i == 0, float(r.pit) > 0.0)
	draw_string(ThemeDB.fallback_font, Vector2(18, 28), "%s  •  TOUR %d / %d" % [weather, int(racers[0].lap), laps], HORIZONTAL_ALIGNMENT_LEFT, -1, 19, Color("edf7f4"))
	if start_lights > 0:
		for light in 5: draw_circle(Vector2(size.x * 0.5 - 72 + light * 36, 72), 13, Color("ed3b45") if light < start_lights else Color("342f34"))
	if yellow_timer > 0.0: draw_string(ThemeDB.fallback_font,Vector2(18,52),"YELLOW FLAG • NO OVERTAKING",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("ffcf4a"))
	draw_string(ThemeDB.fallback_font, Vector2(size.x - 230, 28), "CAM %s" % camera_mode, HORIZONTAL_ALIGNMENT_RIGHT, 210, 15, Color("19dcc6"))
	draw_string(ThemeDB.fallback_font, Vector2(18, track.end.y + 25), event_text, HORIZONTAL_ALIGNMENT_LEFT, size.x - 36, 16, Color("ffcf4a"))
	var standing: Array = racers.duplicate(); standing.sort_custom(func(a, b): return int(a.position) < int(b.position))
	var visible: Array = standing.slice(0, 4)
	if not visible.has(racers[0]): visible.append(racers[0])
	for i in visible.size():
		var r: Dictionary = visible[i]; draw_string(ThemeDB.fallback_font, Vector2(18 + (i % 2) * size.x * 0.48, track.end.y + 50 + int(i / 2) * 20), "P%d  %s" % [r.position, r.name], HORIZONTAL_ALIGNMENT_LEFT, size.x * 0.44, 14, r.color if r.name == player_name else Color("b8c5c5"))
	draw_string(ThemeDB.fallback_font, Vector2(18, size.y - 8), "%s %s %s • %d%%   CARBURANT %d%%   MOTEUR %d%%" % [category,tyre,tyre_temperature,int(racers[0].wear),int(racers[0].fuel),int(racers[0].condition)], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("19dcc6"))

func _draw_car(position: Vector2, angle: float, color: Color, selected: bool, in_pit: bool) -> void:
	var transform = Transform2D(angle, position)
	var shadow = PackedVector2Array([transform * Vector2(-11, -6), transform * Vector2(13, -5), transform * Vector2(13, 7), transform * Vector2(-11, 8)])
	draw_colored_polygon(shadow, Color(0, 0, 0, 0.38))
	var body = PackedVector2Array([transform * Vector2(14, 0), transform * Vector2(6, -6), transform * Vector2(-10, -6), transform * Vector2(-14, -3), transform * Vector2(-14, 3), transform * Vector2(-10, 6), transform * Vector2(6, 6)])
	draw_colored_polygon(body, color.darkened(0.12))
	draw_line(transform * Vector2(-8, -7), transform * Vector2(-8, 7), Color("11171b"), 4.0)
	draw_line(transform * Vector2(8, -7), transform * Vector2(8, 7), Color("11171b"), 4.0)
	draw_circle(transform * Vector2(-1, 0), 3.5, Color("dbe6e8")); draw_line(transform * Vector2(1, -4), transform * Vector2(8, -2), color.lightened(0.35), 2.0)
	if selected: draw_arc(position, 18, 0, TAU, 20, Color.WHITE, 2.0)
	if in_pit: draw_string(ThemeDB.fallback_font, position + Vector2(-14, -17), "PIT", HORIZONTAL_ALIGNMENT_CENTER, 28, 10, Color("ffcf4a"))
