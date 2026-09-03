extends Node

signal changed
const SAVE_VERSION := 2
const SAVE_PATH := "user://career.json"
const CREATION_DATA_PATH := "res://game/data/team_creation.json"
const TRACKS := ["Riviera Sprint", "Horizon Ring", "Val d'Or", "Circuit des Pins"]
const DNA_DOMAINS := ["workshop", "technical", "simulator", "scouting", "marketing", "strategy"]
var data: Dictionary = {}
var creation_config: Dictionary = {}

func _ready() -> void:
	creation_config = load_creation_config()
	if FileAccess.file_exists(SAVE_PATH): load_game()

func load_creation_config() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CREATION_DATA_PATH))
	return parsed if parsed is Dictionary else {}

func defaults() -> Dictionary:
	return {"save_version":SAVE_VERSION,"career_year":2027,"career_date":"2027-03-01","team":{},"driver":{},"team_dna":neutral_dna(),"championship":"kart_club","calendar":[],"race_history":[],"money":12000,"reputation":0,"vehicles":{"kart":{"level":1,"reliability":92,"condition":100,"livery":{},"components":{"engine":1,"chassis":1,"brakes":1}}},"upgrades":[],"facilities":{"workshop":1,"technical":0,"simulator":0,"scouting":0,"marketing":0,"strategy":0,"pit_crew":0},"personnel":[],"sponsors":[],"career_events":[],"culture":{"technical":0.0,"finance":0.0,"driver":0.0,"strategy":0.0,"innovation":0.0},"objectives":{"race":{"target":8,"completed":false,"rewarded":false},"season":{"target":5,"completed":false,"rewarded":false},"long_term":"reach_apex"},"experience":0,"level":1,"skill_points":0,"energy":5,"settings":{"master":80,"music":55,"sfx":80,"language":"fr","intro_seen":false},"transactions":[],"season_income":0,"season_expenses":0,"race_index":0}

func neutral_dna() -> Dictionary:
	var affinities := {}; var ratings := {}
	for domain in DNA_DOMAINS: affinities[domain] = 0.0; ratings[domain] = 40
	return {"origin":"independent","philosophy":"balanced","management_style":"neutral","long_term_goal":"reach_apex","foundation_points":{"workshop":2,"technical":2,"simulator":2,"scouting":1,"marketing":1,"strategy":2},"affinities":affinities,"ratings":ratings,"modifiers":{},"advantages":[],"drawbacks":[],"founded_year":2027,"initial_influence":1.0}

func has_career() -> bool: return not data.get("team", {}).is_empty() and not data.get("driver", {}).is_empty()

func build_team_dna(origin_id: String, philosophy_id: String, style_id: String, goal_id: String, points: Dictionary) -> Dictionary:
	if creation_config.is_empty(): creation_config = load_creation_config()
	var dna := neutral_dna(); dna.origin = origin_id; dna.philosophy = philosophy_id; dna.management_style = style_id; dna.long_term_goal = goal_id; dna.foundation_points = points.duplicate(true)
	var advantages: Array = []; var drawbacks: Array = []; var modifiers: Dictionary = {}; var affinities: Dictionary = dna.affinities
	for pair in [["origins",origin_id],["philosophies",philosophy_id],["manager_styles",style_id]]:
		var choice: Dictionary = creation_config.get(pair[0], {}).get(pair[1], {})
		advantages.append_array(choice.get("advantages", [])); drawbacks.append_array(choice.get("drawbacks", []))
		for key in choice.get("modifiers", {}): modifiers[key] = float(modifiers.get(key, 0.0)) + float(choice.modifiers[key])
		for key in choice.get("affinities", {}): affinities[key] = float(affinities.get(key, 0.0)) + float(choice.affinities[key])
	var ratings := {}
	for domain in DNA_DOMAINS: ratings[domain] = clampi(30 + int(points.get(domain,0)) * 9 + int(float(affinities.get(domain,0.0)) * 50.0), 20, 90)
	dna.affinities = affinities; dna.ratings = ratings; dna.modifiers = modifiers; dna.advantages = advantages; dna.drawbacks = drawbacks
	return dna

func new_career(team: Dictionary, driver: Dictionary, dna: Dictionary = {}) -> void:
	data = defaults(); data.team = team.duplicate(true); data.driver = driver.duplicate(true); data.team_dna = dna.duplicate(true) if not dna.is_empty() else neutral_dna()
	var origin: Dictionary = creation_config.get("origins", {}).get(data.team_dna.origin, {})
	data.money = int(origin.get("budget",12000)); data.objectives.long_term = data.team_dna.long_term_goal
	data.objectives.race.target = 6 if data.team_dna.origin == "private_investor" else 8
	data.vehicles.kart.livery = {"colors":team.get("colors",[]),"pattern":team.get("livery_pattern",0)}
	for source in [origin, creation_config.get("philosophies",{}).get(data.team_dna.philosophy,{}), creation_config.get("manager_styles",{}).get(data.team_dna.management_style,{})]:
		if source.has("event"): data.career_events.append({"id":source.event,"status":"PENDING","season":2027})
	data.calendar = make_calendar(4); transaction(-500, "Inscription Kart Club"); save_game(); changed.emit()

func modifier(key: String) -> float: return float(data.get("team_dna",{}).get("modifiers",{}).get(key,0.0))
func effective_cost(base_cost: int, kind: String) -> int:
	var value := float(base_cost)
	if kind == "repair": value *= 1.0 + modifier("repair_cost")
	elif kind == "development": value *= 1.0 + modifier("development_cost")
	elif kind == "facility": value *= 1.0 + modifier("facility_cost")
	value *= 1.0 + modifier("operating_cost")
	return maxi(1, int(round(value)))
func potential_estimate() -> Vector2i:
	var potential := int(data.get("driver",{}).get("hidden_potential",80)); var scouting := int(data.get("team_dna",{}).get("ratings",{}).get("scouting",40)); var width := clampi(22 - scouting / 5, 5, 18)
	return Vector2i(maxi(50,potential-width), mini(99,potential+width))

func make_calendar(count: int) -> Array:
	var result := []
	for i in count: result.append({"track":TRACKS[i % TRACKS.size()],"date":"2027-%02d-%02d" % [3+i,8+i*3],"laps":8+i*2,"weather_probability":0.15+i*0.05,"rules":"kart_basic","status":"AVAILABLE" if i==0 else "UPCOMING","results":[]})
	return result
func transaction(amount: int, label: String) -> void:
	data.money = int(data.get("money",0))+amount
	if amount>=0: data.season_income=int(data.get("season_income",0))+amount
	else: data.season_expenses=int(data.get("season_expenses",0))-amount
	data.transactions.push_front({"amount": amount, "label": label, "date": data.get("career_date", "")})
	if data.transactions.size() > 20:
		data.transactions.resize(20)
func buy_upgrade(component: String, base_cost: int) -> bool:
	var cost := effective_cost(base_cost,"development")
	if int(data.money)<cost: return false
	transaction(-cost,"Développement %s N%d" % [component.capitalize(),int(data.vehicles.kart.components.get(component,1))+1]); data.vehicles.kart.components[component]=int(data.vehicles.kart.components.get(component,1))+1; data.upgrades.append({"component":component,"cost":cost,"development_time":3,"effect":"performance +2"}); save_game(); changed.emit(); return true
func complete_race(result: Dictionary) -> void:
	data.energy=maxi(0,int(data.energy)-1); data.race_history.append(result.duplicate(true)); var index:=int(data.race_index); data.calendar[index].status="COMPLETED"; data.calendar[index].results=result.standings; data.race_index=index+1
	if data.race_index<data.calendar.size(): data.calendar[data.race_index].status="AVAILABLE"
	var prize:=maxi(250,1800-(int(result.position)-1)*150); transaction(prize,"Prime course — P%d" % result.position); add_xp(120+maxi(0,11-int(result.position))*20); data.reputation+=maxi(1,int(round((11-int(result.position))*(1.0+modifier("fan_reputation")))))
	if int(result.position)<=int(data.objectives.race.target) and not data.objectives.race.rewarded: data.objectives.race.completed=true; data.objectives.race.rewarded=true; transaction(750,"Objectif course")
	save_game(); changed.emit()
func add_xp(amount: int) -> void:
	var driver_multiplier := float(data.get("driver",{}).get("xp_multiplier",1.0)); data.experience += int(round(amount*(1.0+modifier("driver_xp"))*driver_multiplier))
	while int(data.experience)>=int(data.level)*500: data.experience-=int(data.level)*500; data.level+=1; data.skill_points+=1
func save_game() -> bool:
	if data.is_empty(): return false
	data.save_version = SAVE_VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data,"\t")); return true
func load_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return false
	data=migrate(parsed); changed.emit(); return true
func migrate(old: Dictionary) -> Dictionary:
	var fresh := defaults()
	for key in old:
		fresh[key] = old[key]
	if not old.has("team_dna"): fresh.team_dna=neutral_dna()
	if not fresh.driver.has("hidden_potential"): fresh.driver.hidden_potential=82; fresh.driver.profile="versatile"; fresh.driver.xp_multiplier=1.0
	if not fresh.team.has("short_name"): fresh.team.short_name=str(fresh.team.get("name","Legacy Team")).left(12)
	fresh.save_version=SAVE_VERSION; return fresh
func reset_save() -> void:
	data = {}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	changed.emit()
