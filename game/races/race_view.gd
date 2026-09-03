class_name RaceView
extends Control

signal finished(result)
var racers: Array = []
var running := false
var qualifying := true
var elapsed := 0.0
var laps := 8
var strategy := "NORMAL"
var risk := "NORMAL"
var player_name := "PILOTE"
var event_text := "Qualifications prêtes"
var rng := RandomNumberGenerator.new()
const NAMES := ["MOREL","ROSSI","MARTIN","DUBOIS","NOVAK","SMITH","SATO","GARCIA","KLEIN","COSTA","WILSON","BERNARD"]

func setup(driver_name: String, race_laps: int) -> void:
	player_name = driver_name.to_upper(); laps = race_laps; reset_session()

func reset_session() -> void:
	rng.seed = 4200 + int(GameState.data.get("race_index",0))
	racers.clear(); elapsed = 0.0; running = false; qualifying = true; strategy = "NORMAL"; risk = "NORMAL"
	for i in 12:
		racers.append({"name":player_name if i == 0 else NAMES[i],"progress":0.0,"lap":0,"speed":0.078 + rng.randf_range(-0.005,0.005),"wear":100.0,"fuel":100.0,"position":i+1,"best":999.0,"last":0.0,"lap_start":0.0,"color":Color("19dcc6") if i == 0 else Color.from_hsv(float(i)/12.0,0.65,0.9)})
	event_text = "Qualifications prêtes — la grille dépend du chrono"
	queue_redraw()

func start_qualifying() -> void:
	qualifying = true; running = true; elapsed = 0.0; event_text = "Qualifications en cours"

func start_race() -> void:
	for r in racers: r.progress = 0.0; r.lap = 0; r.wear = 100.0; r.fuel = 100.0; r.lap_start = 0.0
	qualifying = false; running = true; elapsed = 0.0; event_text = "DÉPART — drapeau vert"

func set_strategy(value: String) -> void: strategy = value; event_text = "Stratégie %s appliquée" % value
func set_risk(value: String) -> void: risk = value; event_text = "Prise de risque %s" % value

func _process(delta: float) -> void:
	if not running: return
	elapsed += delta
	for i in racers.size():
		var r: Dictionary = racers[i]
		var multiplier := 1.0
		if i == 0:
			multiplier = {"CONSERVE":0.96,"NORMAL":1.0,"PUSH":1.035,"ATTACK":1.06}[strategy]
			multiplier *= {"LOW":0.985,"NORMAL":1.0,"HIGH":1.018}[risk]
		var tyre_factor: float = lerpf(0.90,1.0,float(r.wear)/100.0)
		var old_progress: float = r.progress
		r.progress += delta * float(r.speed) * multiplier * tyre_factor * rng.randf_range(0.992,1.008)
		r.wear = maxf(0.0,float(r.wear)-delta*({"CONSERVE":0.20,"NORMAL":0.28,"PUSH":0.40,"ATTACK":0.55}.get(strategy,0.3) if i == 0 else 0.3))
		r.fuel = maxf(0.0,float(r.fuel)-delta*0.20*multiplier)
		if int(old_progress) < int(r.progress):
			r.lap += 1; r.last = elapsed-float(r.lap_start); r.lap_start=elapsed; r.best=minf(float(r.best),float(r.last))
	_sort_positions()
	if qualifying and elapsed >= 15.0:
		running=false; event_text="Qualifications terminées — P%d sur la grille" % int(racers[0].position)
	elif not qualifying and int(racers[0].lap) >= laps:
		_finish_race()
	queue_redraw()

func _sort_positions() -> void:
	var order := racers.duplicate(); order.sort_custom(func(a,b): return float(a.progress)>float(b.progress))
	for i in order.size(): order[i].position=i+1

func _finish_race() -> void:
	running=false; event_text="ARRIVÉE — drapeau à damier"
	var standing := racers.duplicate(); standing.sort_custom(func(a,b): return int(a.position)<int(b.position))
	var rows := []
	for r in standing:
		rows.append({"name":r.name,"position":r.position,"best_lap":r.best})
	finished.emit({"position":racers[0].position,"best_lap":racers[0].best,"strategy":strategy,"incidents":[],"standings":rows,"track":GameState.data.calendar[GameState.data.race_index].track})

func _draw() -> void:
	var rect := Rect2(Vector2(16,52),Vector2(size.x-32,size.y-126))
	draw_style_box(_panel(Color("0b1720")),rect)
	var center := rect.get_center()
	var radius := Vector2(rect.size.x*0.38,rect.size.y*0.35)
	var points := PackedVector2Array()
	for n in 65:
		var a := TAU*float(n)/64.0; points.append(center+Vector2(cos(a)*radius.x,sin(a)*radius.y)*(1.0+0.12*sin(a*3.0)))
	draw_polyline(points,Color("283942"),34.0,true); draw_polyline(points,Color("708087"),2.0,true)
	for i in racers.size():
		var r:Dictionary=racers[i]
		var a:=TAU*fmod(float(r.progress),1.0)
		var p:=center+Vector2(cos(a)*radius.x,sin(a)*radius.y)*(1.0+0.12*sin(a*3.0))
		draw_circle(p,8.0 if i==0 else 5.0,r.color)
		if i==0:
			draw_arc(p,12,0,TAU,16,Color.WHITE,2)
	draw_string(ThemeDB.fallback_font,Vector2(26,30),"%s  •  TOUR %d / %d  •  %s" % ["QUALIFICATIONS" if qualifying else "COURSE",int(racers[0].lap),laps,event_text],HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("d8efec"))
	var standing:=racers.duplicate(); standing.sort_custom(func(a,b): return int(a.position)<int(b.position))
	for i in mini(standing.size(),6):
		var r:Dictionary=standing[i]; draw_string(ThemeDB.fallback_font,Vector2(28,rect.end.y+25+i*17),"P%d  %s" % [r.position,r.name],HORIZONTAL_ALIGNMENT_LEFT,210,14,r.color if r.name==player_name else Color("aab9ba"))
	draw_string(ThemeDB.fallback_font,Vector2(size.x-245,rect.end.y+25),"PNEUS %d%%   FUEL %d%%" % [int(racers[0].wear),int(racers[0].fuel)],HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color("19dcc6"))

func _panel(color:Color) -> StyleBoxFlat:
	var box:=StyleBoxFlat.new(); box.bg_color=color; box.corner_radius_top_left=12; box.corner_radius_top_right=12; box.corner_radius_bottom_left=12; box.corner_radius_bottom_right=12; return box
