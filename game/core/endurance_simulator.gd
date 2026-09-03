class_name EnduranceSimulator
extends RefCounted

const CLASSES := {"GT3":1.0,"PROTOTYPE":1.16,"HYPERCAR":1.22}
const PACE := {"FUEL SAVE":0.965,"BALANCED":1.0,"PUSH":1.025}
var cars:Array=[]
var elapsed_minutes:=0.0
var duration_minutes:=360.0
var weather:="DRY"
var phase:="DAY"
var neutralisation:="GREEN"
var rng:=RandomNumberGenerator.new()

func configure(grid:Dictionary, duration:float, seed:int=24)->void:
	cars.clear();duration_minutes=duration;elapsed_minutes=0.0;rng.seed=seed
	for class_name in ["HYPERCAR","PROTOTYPE","GT3"]:
		for i in int(grid.get(class_name,0)):
			cars.append({"id":"%s_%02d"%[class_name,i+1],"class":class_name,"distance":-i*0.04,"fuel_laps":10.0+rng.randf_range(-1.0,1.0),"tyre":"MEDIUM","tyre_wear":100.0,"driver_index":i%3,"drivers":_crew(i),"stint_laps":0,"condition":{"AERO":100.0,"SUSPENSION":100.0,"ENGINE":100.0,"GEARBOX":100.0,"BRAKES":100.0,"BODYWORK":100.0},"pace":"BALANCED","pit_time":0.0,"overall_position":0,"class_position":0})
	_update_positions()

func _crew(seed:int)->Array:
	return [{"name":"DRIVER 1","grade":"PRO","fitness":82-seed%5,"fatigue":0.0},{"name":"DRIVER 2","grade":"SEMI-PRO","fitness":76+seed%6,"fatigue":0.0},{"name":"DRIVER 3","grade":"AMATEUR","fitness":72+seed%4,"fatigue":0.0}]

func simulate(minutes:float)->void:
	var step:=minf(minutes,maxf(0.0,duration_minutes-elapsed_minutes));if step<=0.0:return
	elapsed_minutes+=step;_update_environment()
	for car in cars:
		var driver:Dictionary=car.drivers[car.driver_index];var traffic:=_traffic_factor(car)
		var fatigue_factor:=1.0-maxf(0.0,float(driver.fatigue)-65.0)*0.0018
		var wet_factor:=0.92 if weather in ["RAIN","HEAVY RAIN"] and car.tyre not in ["INTERMEDIATE","WET"] else 1.0
		var flag_factor:=0.62 if neutralisation!="GREEN" else 1.0
		car.distance+=step/4.0*float(CLASSES[car.class])*float(PACE[car.pace])*traffic*fatigue_factor*wet_factor*flag_factor
		car.fuel_laps=maxf(0.0,float(car.fuel_laps)-step/4.0*(0.86 if car.pace=="FUEL SAVE" else 1.0));car.tyre_wear=maxf(0.0,float(car.tyre_wear)-step*(0.28 if car.pace=="PUSH" else 0.20));car.stint_laps+=int(step/4.0)
		driver.fatigue=minf(100.0,float(driver.fatigue)+step*(0.32 if car.pace=="PUSH" else 0.23)*(100.0/float(driver.fitness)))
	_update_positions()

func _traffic_factor(car:Dictionary)->float:
	if car.class=="GT3":return 0.985
	var traffic:=0
	for other in cars:
		if other.class=="GT3" and absf(float(other.distance)-float(car.distance))<0.35:traffic+=1
	return maxf(0.91,1.0-traffic*0.012)

func _update_environment()->void:
	var progress:=elapsed_minutes/duration_minutes
	phase="DAY" if progress<0.18 or progress>=0.82 else ("SUNSET" if progress<0.28 else ("NIGHT" if progress<0.66 else "DAWN"))
	weather="DRY" if progress<0.32 else ("RAIN" if progress<0.48 else ("HEAVY RAIN" if progress<0.58 else ("DRYING" if progress<0.76 else "DRY")))

func pit(car_id:String, operations:Dictionary)->float:
	var car:=get_car(car_id);if car.is_empty():return 0.0
	var time:=5.0
	if operations.get("fuel",false):car.fuel_laps=12.0;time+=24.0
	if operations.get("tyres",false):car.tyre=operations.get("compound","MEDIUM");car.tyre_wear=100.0;time+=14.0
	if operations.get("driver_change",false):car.driver_index=(int(car.driver_index)+1)%car.drivers.size();car.stint_laps=0;time+=8.0
	if operations.get("repairs","")=="QUICK":time+=20.0;_repair(car,35.0)
	elif operations.get("repairs","")=="FULL":time+=90.0;_repair(car,85.0)
	if neutralisation!="GREEN":time*=0.62
	car.pit_time+=time;car.distance-=time/240.0;return time

func _repair(car:Dictionary,amount:float)->void:
	for part in car.condition:car.condition[part]=minf(100.0,float(car.condition[part])+amount)
func get_car(car_id:String)->Dictionary:
	for car in cars:
		if car.id==car_id:return car
	return {}
func _update_positions()->void:
	var overall:=cars.duplicate();overall.sort_custom(func(a,b):return float(a.distance)>float(b.distance))
	for i in overall.size():overall[i].overall_position=i+1
	for class_name in CLASSES:
		var group:=cars.filter(func(car):return car.class==class_name);group.sort_custom(func(a,b):return float(a.distance)>float(b.distance))
		for i in group.size():group[i].class_position=i+1
