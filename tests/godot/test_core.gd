extends Node

var _failures: Array[String] = []


func _ready() -> void:
	# Defer the suite by one frame so project autoloads have completed _ready().
	_run_tests.call_deferred()


func _result(state: Node, player_position: int) -> Dictionary:
	var rows: Array = []
	for i: int in range(state.career_config.rivals.size()):
		var position: int = i + 1
		if position >= player_position:
			position += 1
		rows.append({"name": state.career_config.rivals[i].name, "position": position, "best_lap": 49.0 + i, "fastest_lap": false})
	return {"position": player_position, "start_position": 8, "best_lap": 48.2, "total_time": 480.0, "tyres_remaining": 72, "strategy": "NORMAL", "incidents": [], "standings": rows, "track": "Test"}


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("TEST FAILED: " + message)


func _run_tests() -> void:
	# Use the actual project singleton. Loading this scene through the project is what
	# makes GameState available while dependencies such as RaceView are compiled.
	var state = GameState
	state.creation_config = state.load_creation_config()
	state.career_config = state.load_career_config()
	state.data = state.defaults()
	_check(state.data.save_version == 5, "save version")
	_check(state.career_config.kart_calendar.size() == 6, "kart calendar")
	_check(state.career_config.rivals.size() == 11, "rival count")
	_check(state.points_for(1) == 25 and state.points_for(10) == 1 and state.points_for(11) == 0, "points table")

	var points: Dictionary = {"workshop": 2, "technical": 2, "simulator": 2, "scouting": 1, "marketing": 1, "strategy": 2}
	var dna: Dictionary = state.build_team_dna("family_garage", "pure_performance", "technician", "reach_apex", points)
	state.new_career({"name": "Test Team", "colors": ["#112233", "#445566", "#778899"], "livery_pattern": 1}, {"first_name": "Ada", "last_name": "Test", "nationality": "France", "number": 27, "hidden_potential": 88, "xp_multiplier": 1.12, "stats": {"speed": 54, "control": 62, "mental": 65}}, dna)
	_check(state.data.calendar.size() == 6 and state.data.standings.size() == 12, "new career grids")
	_check(state.data.calendar[0].status == "AVAILABLE" and state.data.calendar[1].status == "LOCKED", "calendar availability")
	_check(state.sign_sponsor("nova_energy"), "sponsor signing")
	_check(int(state.data.money) > 11500, "sponsor payment")
	for _race_index in 6:
		state.complete_race(_result(state, 1))
	_check(state.data.season_complete, "season completion")
	_check(state.data.race_history.size() == 6 and state.data.standings[0].points == 150, "season results")
	_check(state.data.trophies.size() == 1 and state.data.career_history.size() == 1 and state.data.offers.size() >= 3, "season rewards")

	state.data.reputation = 35
	state._generate_offers(1)
	_check(state.data.offers[2].eligible, "F4 offer gate")
	state.data.money = 50000
	_check(state.accept_offer("f4"), "F4 offer acceptance")
	_check(state.data.category == "F4" and state.data.calendar.size() == 3, "F4 promotion")
	_check(state.data.vehicles.has("kart") and state.data.team.name == "Test Team", "career continuity")
	_check(state.spend_skill("speed"), "skill spending")

	var race: RaceView = RaceView.new()
	add_child(race)
	state.data.race_index = 0
	race.setup("Ada Test", 3, 0.7, "F4")
	_check(race.racers.size() == 12 and race.weather == "RAIN" and race.tyre == "MEDIUM", "F4 race setup")
	race.request_pit("WET")
	_check(race.pit_requested and race.tyre == "WET", "pit request")
	race.queue_free()

	_check(state.save_game(), "career save")
	var game_state_script: Script = load("res://game/core/game_state.gd") as Script
	var reloaded_state = game_state_script.new()
	reloaded_state.creation_config = state.creation_config
	reloaded_state.career_config = state.career_config
	_check(reloaded_state.load_game(), "career reload")
	_check(reloaded_state.data.category == "F4" and reloaded_state.data.team.name == "Test Team" and reloaded_state.data.career_history.size() == 1, "reloaded career data")
	reloaded_state.free()

	var endurance: EnduranceSimulator = EnduranceSimulator.new()
	endurance.configure({"HYPERCAR": 8, "PROTOTYPE": 8, "GT3": 16}, 360.0, 77)
	_check(endurance.cars.size() == 32, "endurance grid")
	endurance.simulate(180.0)
	var gt: Dictionary = endurance.get_car("GT3_01")
	_check(gt.overall_position > 0 and gt.class_position > 0 and gt.drivers.size() == 3, "GT standings")
	var stop: float = endurance.pit("GT3_01", {"fuel": true, "tyres": false, "driver_change": true, "repairs": "QUICK"})
	_check(stop > 40.0 and gt.driver_index == 1 and gt.fuel_laps == 12.0, "GT pit stop")
	_check(endurance.apply_damage("GT3_01", "AERO", 25.0) and gt.condition.AERO == 75.0, "GT damage")
	_check(endurance.set_time_scale(16) and not endurance.set_time_scale(3), "endurance time scale")
	var before: float = endurance.elapsed_minutes
	_check(endurance.simulate_to_next_event() > 0.0 and endurance.elapsed_minutes > before, "endurance next event")

	state.endurance_config = state.load_endurance_config()
	# Hypercar entry requires an eligible feeder category as well as reputation.
	# Keep the production eligibility rules intact and give this focused test the
	# GT3 career state it is intended to exercise.
	state.data.category = "GT3"
	state.data.reputation = 100
	_check(state.can_enter_endurance_class("HYPERCAR"), "Hypercar eligibility")
	_check(state.complete_endurance_event("legacy_24", 4, 1, "HYPERCAR"), "endurance event completion")
	_check("24H WINNER" in state.data.endurance_trophies and state.data.prestige == 100, "endurance rewards")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(state.SAVE_PATH))

	if _failures.is_empty():
		print("Full kart-to-F4 career checks passed")
		get_tree().quit(0)
	else:
		printerr("%d core test(s) failed" % _failures.size())
		get_tree().quit(1)
