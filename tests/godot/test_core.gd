extends SceneTree

func _init() -> void:
	var state = load("res://game/core/game_state.gd").new()
	state.data = state.defaults()
	assert(state.data.save_version == 1)
	assert(state.data.energy == 5)
	var initial_money: int = state.data.money
	assert(state.buy_upgrade("engine", 1500))
	assert(state.data.money == initial_money - 1500)
	assert(state.data.vehicles.kart.components.engine == 2)
	state.data.team = {"name":"Test Team"}
	state.data.driver = {"first_name":"Ada","last_name":"Test"}
	state.data.calendar = state.make_calendar(4)
	state.complete_race({"position":3,"best_lap":48.2,"strategy":"NORMAL","standings":[]})
	assert(state.data.energy == 4)
	assert(state.data.race_history.size() == 1)
	assert(state.data.calendar[0].status == "COMPLETED")
	assert(state.data.calendar[1].status == "AVAILABLE")
	var race = load("res://game/races/race_view.gd").new()
	race.setup("Ada Test", 8, 0.7)
	assert(race.racers.size() == 12)
	assert(race.weather == "PLUIE")
	race.start_race()
	var start_progress: float = race.racers[0].progress
	race._process(1.0)
	assert(race.racers[0].progress > start_progress)
	race.set_strategy("ATTACK")
	assert(race.strategy == "ATTACK")
	race.request_pit("WET")
	assert(race.pit_requested)
	race.set_camera("PILOTE")
	assert(race.camera_mode == "PILOTE")
	print("Core career checks passed")
	quit(0)
