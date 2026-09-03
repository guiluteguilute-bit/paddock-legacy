class_name EnduranceSimulator
extends RefCounted

const CLASS_PACE := {"GT3": 1.0, "PROTOTYPE": 1.16, "HYPERCAR": 1.22}
const PACE := {"FUEL SAVE": 0.965, "BALANCED": 1.0, "PUSH": 1.025}
const FUEL_USE := {"FUEL SAVE": 0.84, "BALANCED": 1.0, "PUSH": 1.12}
const TIME_SCALES := [1, 2, 4, 8, 16]
const DAMAGE_PARTS := ["AERO", "SUSPENSION", "ENGINE", "GEARBOX", "BRAKES", "BODYWORK"]

var cars: Array = []
var elapsed_minutes = 0.0
var duration_minutes = 360.0
var weather = "DRY"
var phase = "DAY"
var neutralisation = "GREEN"
var time_scale = 1
var track_temperature = 31.0
var event_log: Array = []
var rng = RandomNumberGenerator.new()

func configure(grid: Dictionary, duration: float, seed: int = 24) -> void:
	cars.clear()
	event_log.clear()
	duration_minutes = duration
	elapsed_minutes = 0.0
	weather = "DRY"
	phase = "DAY"
	neutralisation = "GREEN"
	rng.seed = seed
	for vehicle_class in ["HYPERCAR", "PROTOTYPE", "GT3"]:
		for i in int(grid.get(vehicle_class, 0)):
			var strategy: String = ["FUEL SAVE", "BALANCED", "PUSH"][i % 3]
			cars.append({
				"id": "%s_%02d" % [vehicle_class, i + 1], "class": vehicle_class,
				"distance": -i * 0.04, "fuel_laps": 10.0 + rng.randf_range(-1.0, 1.0),
				"tyre": "MEDIUM", "tyre_wear": 100.0, "driver_index": i % 3,
				"drivers": _crew(i), "stint_laps": 0, "strategy": strategy,
				"condition": _new_condition(), "pace": strategy, "pit_time": 0.0,
				"pit_stops": 0, "overall_position": 0, "class_position": 0,
				"traffic_loss": 0.0, "retired": false
			})
	_update_positions()

func _new_condition() -> Dictionary:
	var result: Dictionary = {}
	for part in DAMAGE_PARTS:
		result[part] = 100.0
	return result

func _crew(seed: int) -> Array:
	return [
		{"name": "DRIVER 1", "grade": "PRO", "fitness": 82 - seed % 5, "fatigue": 0.0},
		{"name": "DRIVER 2", "grade": "SEMI-PRO", "fitness": 76 + seed % 6, "fatigue": 0.0},
		{"name": "DRIVER 3", "grade": "AMATEUR", "fitness": 72 + seed % 4, "fatigue": 0.0}
	]

func set_time_scale(value: int) -> bool:
	if value not in TIME_SCALES:
		return false
	time_scale = value
	return true

func set_pace(car_id: String, value: String) -> bool:
	var car: Dictionary = get_car(car_id)
	if car.is_empty() or value not in PACE:
		return false
	car.pace = value
	return true

func simulate(minutes: float) -> void:
	var remaining = minf(minutes, maxf(0.0, duration_minutes - elapsed_minutes))
	while remaining > 0.0:
		# Small deterministic ticks prevent a 24-hour fast-forward from skipping strategy.
		var step = minf(5.0, remaining)
		elapsed_minutes += step
		_update_environment()
		_update_neutralisation()
		for car in cars:
			_simulate_car(car, step)
		_update_positions()
		remaining -= step

func _simulate_car(car: Dictionary, step: float) -> void:
	if car.retired:
		return
	_ai_strategy(car)
	var driver: Dictionary = car.drivers[car.driver_index]
	var traffic: float = _traffic_factor(car)
	var fatigue_factor = 1.0 - maxf(0.0, float(driver.fatigue) - 65.0) * 0.0018
	var tyre_factor = clampf(0.88 + float(car.tyre_wear) * 0.0012, 0.88, 1.0)
	var wet_factor = _weather_factor(car.tyre)
	var flag_factor = 0.62 if neutralisation != "GREEN" else 1.0
	var damage_factor = _damage_factor(car.condition)
	var gain = step / 4.0 * float(CLASS_PACE[car.class]) * float(PACE[car.pace])
	gain *= traffic * fatigue_factor * tyre_factor * wet_factor * flag_factor * damage_factor
	car.distance += gain
	car.traffic_loss += step / 4.0 * maxf(0.0, 1.0 - traffic)
	car.fuel_laps = maxf(0.0, float(car.fuel_laps) - step / 4.0 * float(FUEL_USE[car.pace]))
	car.tyre_wear = maxf(0.0, float(car.tyre_wear) - step * (0.28 if car.pace == "PUSH" else 0.20))
	car.stint_laps += int(step / 4.0)
	driver.fatigue = minf(100.0, float(driver.fatigue) + step * (0.32 if car.pace == "PUSH" else 0.23) * (100.0 / float(driver.fitness)))
	_apply_reliability(car, step)

func _weather_factor(compound: String) -> float:
	if weather == "HEAVY RAIN":
		return 1.0 if compound == "WET" else (0.96 if compound == "INTERMEDIATE" else 0.78)
	if weather in ["RAIN", "DRYING"]:
		return 1.0 if compound == "INTERMEDIATE" else (0.97 if compound == "WET" else 0.88)
	return 0.94 if compound in ["INTERMEDIATE", "WET"] else 1.0

func _damage_factor(condition: Dictionary) -> float:
	var weakest = 100.0
	for value in condition.values():
		weakest = minf(weakest, float(value))
	return clampf(0.82 + weakest * 0.0018, 0.82, 1.0)

func _apply_reliability(car: Dictionary, step: float) -> void:
	var stress = (1.5 if car.pace == "PUSH" else 1.0) * (1.25 if track_temperature > 38.0 else 1.0)
	car.condition.ENGINE = maxf(0.0, float(car.condition.ENGINE) - step * 0.002 * stress)
	car.condition.BRAKES = maxf(0.0, float(car.condition.BRAKES) - step * 0.0015 * stress)
	if car.condition.ENGINE <= 0.0 or car.condition.GEARBOX <= 0.0:
		car.retired = true
		event_log.append({"minute": elapsed_minutes, "type": "RETIREMENT", "car": car.id})

func _ai_strategy(car: Dictionary) -> void:
	if float(car.fuel_laps) <= 1.2:
		pit(car.id, {"fuel": true, "tyres": float(car.tyre_wear) < 45.0, "compound": _ideal_tyre(), "driver_change": float(car.drivers[car.driver_index].fatigue) > 48.0, "repairs": ""})
	elif weather in ["RAIN", "HEAVY RAIN"] and car.tyre not in ["INTERMEDIATE", "WET"]:
		pit(car.id, {"fuel": false, "tyres": true, "compound": _ideal_tyre(), "driver_change": false, "repairs": ""})

func _ideal_tyre() -> String:
	return "WET" if weather == "HEAVY RAIN" else ("INTERMEDIATE" if weather in ["RAIN", "DRYING"] else "MEDIUM")

func _traffic_factor(car: Dictionary) -> float:
	var factor = 0.985 if car.class == "GT3" else 1.0
	for other in cars:
		if other == car or other.retired:
			continue
		if car.class != "GT3" and other.class == "GT3" and absf(float(other.distance) - float(car.distance)) < 0.35:
			factor -= 0.012
		elif car.class == "GT3" and other.class != "GT3" and absf(float(other.distance) - float(car.distance)) < 0.18:
			factor -= 0.006
	return maxf(0.90, factor)

func _update_environment() -> void:
	var progress = elapsed_minutes / duration_minutes
	phase = "DAY" if progress < 0.18 or progress >= 0.82 else ("SUNSET" if progress < 0.28 else ("NIGHT" if progress < 0.66 else "DAWN"))
	weather = "DRY" if progress < 0.32 else ("RAIN" if progress < 0.48 else ("HEAVY RAIN" if progress < 0.58 else ("DRYING" if progress < 0.76 else "DRY")))
	track_temperature = 19.0 if phase == "NIGHT" else (24.0 if weather in ["RAIN", "HEAVY RAIN"] else 31.0)

func _update_neutralisation() -> void:
	# Scripted windows are deterministic and make strategic testing reproducible.
	var progress = elapsed_minutes / duration_minutes
	var previous = neutralisation
	neutralisation = "FULL COURSE YELLOW" if progress >= 0.405 and progress < 0.42 else ("SAFETY CAR" if progress >= 0.70 and progress < 0.72 else "GREEN")
	if neutralisation != previous:
		event_log.append({"minute": elapsed_minutes, "type": neutralisation})

func next_event_minutes() -> float:
	var milestones = [duration_minutes * 0.18, duration_minutes * 0.28, duration_minutes * 0.32, duration_minutes * 0.405, duration_minutes * 0.42, duration_minutes * 0.48, duration_minutes * 0.58, duration_minutes * 0.66, duration_minutes * 0.70, duration_minutes * 0.72, duration_minutes * 0.76, duration_minutes * 0.82, duration_minutes]
	for milestone in milestones:
		if milestone > elapsed_minutes + 0.01:
			return milestone
	return duration_minutes

func simulate_to_next_event() -> float:
	var target = next_event_minutes()
	var simulated = target - elapsed_minutes
	simulate(simulated)
	return simulated

func pit(car_id: String, operations: Dictionary) -> float:
	var car: Dictionary = get_car(car_id)
	if car.is_empty() or car.retired:
		return 0.0
	var stop_time = 5.0
	if operations.get("fuel", false):
		car.fuel_laps = 12.0
		stop_time += 24.0
	if operations.get("tyres", false):
		car.tyre = operations.get("compound", "MEDIUM")
		car.tyre_wear = 100.0
		stop_time += 14.0
	if operations.get("driver_change", false):
		car.driver_index = (int(car.driver_index) + 1) % car.drivers.size()
		car.stint_laps = 0
		stop_time += 8.0
	if operations.get("repairs", "") == "QUICK":
		stop_time += 20.0
		_repair(car, 35.0)
	elif operations.get("repairs", "") == "FULL":
		stop_time += 90.0
		_repair(car, 85.0)
	if neutralisation != "GREEN":
		stop_time *= 0.62
	car.pit_stops += 1
	car.pit_time += stop_time
	car.distance -= stop_time / 240.0
	event_log.append({"minute": elapsed_minutes, "type": "PIT", "car": car.id, "seconds": stop_time})
	return stop_time

func apply_damage(car_id: String, part: String, amount: float) -> bool:
	var car: Dictionary = get_car(car_id)
	if car.is_empty() or part not in DAMAGE_PARTS or amount <= 0.0:
		return false
	car.condition[part] = maxf(0.0, float(car.condition[part]) - amount)
	return true

func _repair(car: Dictionary, amount: float) -> void:
	for part in car.condition:
		car.condition[part] = minf(100.0, float(car.condition[part]) + amount)

func get_car(car_id: String) -> Dictionary:
	for car in cars:
		if car.id == car_id:
			return car
	return {}

func classification() -> Array:
	var result: Array = cars.duplicate()
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.distance) > float(b.distance))
	return result

func _update_positions() -> void:
	var overall: Array = classification()
	for i in overall.size():
		overall[i].overall_position = i + 1
	for vehicle_class in CLASS_PACE:
		var group: Array = cars.filter(func(car: Dictionary) -> bool: return car.class == vehicle_class)
		group.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.distance) > float(b.distance))
		for i in group.size():
			group[i].class_position = i + 1
