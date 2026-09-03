extends Node

signal changed
const SAVE_VERSION := 1
const SAVE_PATH := "user://career.json"
const TRACKS := ["Riviera Sprint", "Horizon Ring", "Val d'Or", "Circuit des Pins"]
var data: Dictionary = {}

func _ready() -> void:
	if FileAccess.file_exists(SAVE_PATH): load_game()

func defaults() -> Dictionary:
	return {"save_version": SAVE_VERSION, "career_year": 2026, "career_date": "2026-03-01", "team": {}, "driver": {}, "championship": "kart_club", "calendar": [], "race_history": [], "money": 12000, "reputation": 0, "vehicles": {"kart":{"level":1,"reliability":92,"condition":100,"components":{"engine":1,"chassis":1,"brakes":1}}}, "upgrades": [], "facilities": {"workshop":1,"simulator":0,"pit_crew":0}, "personnel": [], "sponsors": [], "objectives": {"race":{"target":8,"completed":false,"rewarded":false},"season":{"target":5,"completed":false,"rewarded":false}}, "experience": 0, "level": 1, "skill_points": 0, "energy": 5, "settings": {"master":80,"music":55,"sfx":80,"language":"fr"}, "transactions": [], "season_income":0, "season_expenses":0, "race_index":0}

func has_career() -> bool: return not data.get("team", {}).is_empty() and not data.get("driver", {}).is_empty()

func new_career(team: Dictionary, driver: Dictionary) -> void:
	data = defaults()
	data.team = team.duplicate(true); data.driver = driver.duplicate(true)
	data.calendar = make_calendar(4)
	transaction(-500, "Inscription Kart Club")
	save_game()

func make_calendar(count: int) -> Array:
	var result := []
	for i in count:
		result.append({"track":TRACKS[i % TRACKS.size()],"date":"2026-%02d-%02d" % [3 + i, 8 + i * 3],"laps":8 + i * 2,"weather_probability":0.15 + i * 0.05,"rules":"kart_basic","status":"AVAILABLE" if i == 0 else "UPCOMING","results":[]})
	return result

func transaction(amount: int, label: String) -> void:
	data.money = int(data.get("money",0)) + amount
	if amount >= 0: data.season_income = int(data.get("season_income",0)) + amount
	else: data.season_expenses = int(data.get("season_expenses",0)) - amount
	data.transactions.push_front({"amount":amount,"label":label,"date":data.get("career_date","")})
	if data.transactions.size() > 20: data.transactions.resize(20)

func buy_upgrade(component: String, cost: int) -> bool:
	if int(data.money) < cost: return false
	transaction(-cost, "Développement %s N%d" % [component.capitalize(), int(data.vehicles.kart.components.get(component,1)) + 1])
	data.vehicles.kart.components[component] = int(data.vehicles.kart.components.get(component,1)) + 1
	data.upgrades.append({"component":component,"cost":cost,"development_time":3,"effect":"performance +2"})
	save_game(); changed.emit(); return true

func complete_race(result: Dictionary) -> void:
	data.energy = maxi(0, int(data.energy) - 1)
	data.race_history.append(result.duplicate(true))
	var index := int(data.race_index)
	data.calendar[index].status = "COMPLETED"; data.calendar[index].results = result.standings
	data.race_index = index + 1
	if data.race_index < data.calendar.size(): data.calendar[data.race_index].status = "AVAILABLE"
	var prize := maxi(250, 1800 - (int(result.position)-1)*150)
	transaction(prize, "Prime course — P%d" % result.position)
	add_xp(120 + maxi(0, 11-int(result.position))*20)
	data.reputation += maxi(1, 11-int(result.position))
	if int(result.position) <= int(data.objectives.race.target) and not data.objectives.race.rewarded:
		data.objectives.race.completed = true; data.objectives.race.rewarded = true; transaction(750,"Objectif course")
	save_game(); changed.emit()

func add_xp(amount: int) -> void:
	data.experience += amount
	while int(data.experience) >= int(data.level) * 500:
		data.experience -= int(data.level) * 500; data.level += 1; data.skill_points += 1

func save_game() -> bool:
	if data.is_empty(): return false
	data.save_version = SAVE_VERSION
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data, "\t")); return true

func load_game() -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null: return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary: return false
	data = migrate(parsed); changed.emit(); return true

func migrate(old: Dictionary) -> Dictionary:
	var fresh := defaults()
	for key in old: fresh[key] = old[key]
	fresh.save_version = SAVE_VERSION
	return fresh

func reset_save() -> void:
	data = {}
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	changed.emit()
