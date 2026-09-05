extends Node

signal changed
const SAVE_VERSION := 6
const SAVE_PATH := "user://career.json"
const CREATION_DATA_PATH := "res://game/data/team_creation.json"
const CAREER_DATA_PATH := "res://game/data/career.json"
const ENDURANCE_DATA_PATH := "res://game/data/endurance.json"
const DNA_DOMAINS := ["workshop", "technical", "simulator", "scouting", "marketing", "strategy"]
var data: Dictionary = {}
var creation_config: Dictionary = {}
var career_config: Dictionary = {}
var endurance_config: Dictionary = {}

func _ready() -> void:
	print("[BOOT] GameState loading")
	creation_config = _load_json(CREATION_DATA_PATH)
	career_config = _load_json(CAREER_DATA_PATH)
	endurance_config = _load_json(ENDURANCE_DATA_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		if not load_game(): push_error("[BOOT] SAVE_INVALID: career save could not be loaded")
	print("[BOOT] GameState ready")
	print("[BOOT] Save checked: %s" % ("valid career" if has_career() else "no career"))

func _load_json(path: String) -> Variant:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed != null else {}
func load_creation_config() -> Dictionary: return _load_json(CREATION_DATA_PATH)
func load_career_config() -> Dictionary: return _load_json(CAREER_DATA_PATH)
func load_endurance_config() -> Dictionary: return _load_json(ENDURANCE_DATA_PATH)

func defaults() -> Dictionary:
	return {"save_version":SAVE_VERSION,"career_year":2027,"career_date":"2027-03-01","category":"KART","championship":"kart_regional","career_path":"UNDECIDED","championship_class":"KART","owned_gt_cars":[],"driver_roster":[],"endurance_results":[],"class_results":[],"prestige":0,"endurance_trophies":[],"season":1,"team":{},"driver":{},"team_dna":neutral_dna(),"calendar":[],"race_history":[],"standings":[],"money":12000,"reputation":0,"vehicles":{"kart":{"level":1,"reliability":92,"condition":100,"livery":{},"components":{"engine":1,"chassis":1,"brakes":1,"reliability":1}},"f4":{"level":1,"reliability":86,"condition":100,"aero":1,"components":{"engine":1,"chassis":1,"brakes":1,"reliability":1}},"gt4":{"level":1,"reliability":84,"condition":100,"aero":1,"components":{"engine":1,"chassis":1,"brakes":1,"reliability":1}}},"upgrades":[],"development_queue":[],"facilities":{"workshop":1,"technical":0,"simulator":0,"scouting":0,"marketing":0,"strategy":0,"pit_crew":0},"personnel":[],"sponsor":{},"sponsors":[],"offers":[],"trophies":[],"career_history":[],"career_events":[],"culture":{"technical":0.0,"finance":0.0,"driver":0.0,"strategy":0.0,"innovation":0.0},"objectives":{"race":{"type":"finish_position","target":8,"completed":false},"season":{"type":"championship_position","target":5,"completed":false}},"experience":0,"level":1,"skill_points":0,"energy":5,"settings":{"master":80,"music":55,"music_volume":55,"music_enabled":true,"sfx":80,"language":"fr"},"transactions":[],"season_income":0,"season_expenses":0,"season_xp":0,"season_reputation":0,"race_index":0,"season_complete":false,"promotion_pending":false,"audio_buses":["KART_ENGINE","F4_ENGINE","GT_ENGINE","PROTOTYPE_ENGINE","TYRES","CONTACT","RAIN","PIT","UI"]}

func neutral_dna() -> Dictionary:
	var affinities = {}; var ratings = {}
	for domain in DNA_DOMAINS: affinities[domain] = 0.0; ratings[domain] = 40
	return {"origin":"independent","philosophy":"balanced","management_style":"neutral","long_term_goal":"reach_apex","foundation_points":{"workshop":2,"technical":2,"simulator":2,"scouting":1,"marketing":1,"strategy":2},"affinities":affinities,"ratings":ratings,"modifiers":{},"advantages":[],"drawbacks":[],"founded_year":2027,"initial_influence":1.0}

func has_career() -> bool: return not data.get("team", {}).is_empty() and not data.get("driver", {}).is_empty()
func build_team_dna(origin_id:String, philosophy_id:String, style_id:String, goal_id:String, points:Dictionary)->Dictionary:
	if creation_config.is_empty(): creation_config=load_creation_config()
	var dna =neutral_dna(); dna.origin=origin_id; dna.philosophy=philosophy_id; dna.management_style=style_id; dna.long_term_goal=goal_id; dna.foundation_points=points.duplicate(true)
	var advantages:Array=[]; var drawbacks:Array=[]; var modifiers:Dictionary={}; var affinities:Dictionary=dna.affinities
	for pair in [["origins",origin_id],["philosophies",philosophy_id],["manager_styles",style_id]]:
		var choice:Dictionary=creation_config.get(pair[0],{}).get(pair[1],{})
		advantages.append_array(choice.get("advantages",[])); drawbacks.append_array(choice.get("drawbacks",[]))
		for key in choice.get("modifiers",{}): modifiers[key]=float(modifiers.get(key,0.0))+float(choice.modifiers[key])
		for key in choice.get("affinities",{}): affinities[key]=float(affinities.get(key,0.0))+float(choice.affinities[key])
	var ratings ={}
	for domain in DNA_DOMAINS: ratings[domain]=clampi(30+int(points.get(domain,0))*9+int(float(affinities.get(domain,0.0))*50.0),20,90)
	dna.affinities=affinities; dna.ratings=ratings; dna.modifiers=modifiers; dna.advantages=advantages; dna.drawbacks=drawbacks
	return dna

func new_career(team:Dictionary, driver:Dictionary, dna:Dictionary={}) -> void:
	if career_config.is_empty(): career_config=load_career_config()
	data=defaults(); data.team=team.duplicate(true); data.driver=driver.duplicate(true); data.team_dna=dna.duplicate(true) if not dna.is_empty() else neutral_dna()
	_prepare_driver_stats(); var origin:Dictionary=creation_config.get("origins",{}).get(data.team_dna.origin,{})
	data.money=int(origin.get("budget",12000)); data.objectives.race.target=6 if data.team_dna.origin=="private_investor" else 8
	data.objectives.season.target=3 if data.team_dna.origin=="private_investor" else (8 if data.team_dna.origin=="passionate_amateur" else 5)
	data.vehicles.kart.livery={"colors":team.get("colors",[]),"pattern":team.get("livery_pattern",0)}
	data.driver_roster=[_endurance_driver(data.driver,"PRO")]
	data.calendar=make_calendar("KART"); data.standings=make_standings(); transaction(-500,"Inscription Regional Kart Series"); save_game(); changed.emit()

func _prepare_driver_stats() -> void:
	var stats:Dictionary=data.driver.get("stats",{})
	for key in ["speed","control","mental"]: stats[key]=int(stats.get(key,55))
	for key in ["start","overtaking","defence","rain","tyre_management"]: stats[key]=int(stats.get(key,50))
	data.driver.stats=stats

func _endurance_driver(source:Dictionary,grade:String)->Dictionary:
	return {"id":"player","name":str(source.get("first_name","PILOTE"))+" "+str(source.get("last_name","")),"grade":grade,"fitness":int(source.get("stats",{}).get("mental",55)),"fatigue":0.0,"contract_months":12}

func choose_career_path(path:String)->bool:
	if path not in ["SINGLE_SEATER","GT_ENDURANCE"]:return false
	data.career_path=path;save_game();changed.emit();return true

func buy_gt_car(car_id:String)->bool:
	if endurance_config.is_empty():endurance_config=load_endurance_config()
	for car in endurance_config.get("cars",[]):
		if car.id==car_id and car.class in ["GT4","GT3"]:
			if data.owned_gt_cars.any(func(item):return item.id==car_id) or int(data.money)<int(car.price):return false
			transaction(-int(car.price),"Achat — "+car.name);data.owned_gt_cars.append({"id":car.id,"name":car.name,"class":car.class,"condition":100,"mileage_km":0,"bop":car.bop.duplicate(true)});save_game();changed.emit();return true
	return false

func recruit_endurance_driver(candidate:Dictionary)->bool:
	if data.driver_roster.size()>=3 or candidate.get("grade","") not in ["ELITE","PRO","SEMI-PRO","AMATEUR"]:return false
	data.driver_roster.append(candidate.duplicate(true));save_game();changed.emit();return true

func can_enter_endurance_class(target_class: String) -> bool:
	if endurance_config.is_empty(): endurance_config = load_endurance_config()
	if target_class == "GT4" and data.category in ["KART", "GT4"]: return int(data.reputation) >= 18
	if target_class == "GT3" and data.category in ["F3", "GT4", "GT3"]: return int(data.reputation) >= 45
	if target_class == "HYPERCAR" and data.category in ["F2", "GT3", "HYPERCAR"]: return int(data.reputation) >= 80
	return false

func complete_endurance_event(series_id: String, overall_position: int, class_position: int, car_class: String) -> bool:
	if endurance_config.is_empty(): endurance_config = load_endurance_config()
	var selected: Dictionary = {}
	for series in endurance_config.get("series", []):
		if series.id == series_id:
			selected = series
			break
	if selected.is_empty() or overall_position < 1 or class_position < 1:
		return false
	var result = {"year": data.career_year, "series_id": series_id, "series": selected.name, "class": car_class, "overall_position": overall_position, "class_position": class_position, "prestige": int(selected.prestige)}
	data.endurance_results.append(result)
	data.class_results.append({"series_id": series_id, "class": car_class, "position": class_position})
	var prestige_gain = maxi(1, int(round(float(selected.prestige) * (1.0 if class_position == 1 else 0.25))))
	data.prestige += prestige_gain
	if class_position == 1:
		var trophy_name = "24H WINNER" if series_id == "legacy_24" else ("%s CHAMPION" % car_class)
		if trophy_name not in data.endurance_trophies:
			data.endurance_trophies.append(trophy_name)
	data.career_path = "GT_ENDURANCE"
	data.championship_class = car_class
	save_game(); changed.emit(); return true

func modifier(key:String)->float: return float(data.get("team_dna",{}).get("modifiers",{}).get(key,0.0))
func effective_cost(base_cost:int, kind:String)->int:
	var value =float(base_cost)
	if kind=="repair": value*=1.0+modifier("repair_cost")-float(data.facilities.get("workshop",1)-1)*0.05
	elif kind=="development": value*=1.0+modifier("development_cost")
	elif kind=="facility": value*=1.0+modifier("facility_cost")
	return maxi(1,int(round(value*(1.0+modifier("operating_cost")))))
func potential_estimate()->Vector2i:
	var potential =int(data.get("driver",{}).get("hidden_potential",80)); var scouting =int(data.facilities.get("scouting",0))*10+int(data.get("team_dna",{}).get("ratings",{}).get("scouting",40)); var width =clampi(22-scouting/5,4,18)
	return Vector2i(maxi(50,potential-width),mini(99,potential+width))

func make_calendar(category:Variant="KART") -> Array:
	if category is int: category="KART" # compatibility with v2 tests
	if career_config.is_empty(): career_config=load_career_config()
	var source:Array=career_config.get("f4_calendar" if category=="F4" else "kart_calendar",[]); var result =[]
	for i in source.size():
		var event:Dictionary=source[i].duplicate(true); event.status="AVAILABLE" if i==0 else "LOCKED"; event.results=[]; result.append(event)
	return result
func make_standings()->Array:
	if career_config.is_empty(): career_config=load_career_config()
	var rows =[]; rows.append({"id":"player","name":str(data.driver.get("first_name","PILOTE"))+" "+str(data.driver.get("last_name","")),"team":data.team.get("name","Legacy"),"nationality":data.driver.get("nationality","France"),"number":data.driver.get("number",27),"points":0,"wins":0,"podiums":0,"fastest_laps":0,"finishes":[],"player":true})
	for rival in career_config.get("rivals",[]): var row:Dictionary=rival.duplicate(true); row.points=0; row.wins=0; row.podiums=0; row.fastest_laps=0; row.finishes=[]; row.player=false; rows.append(row)
	return rows
func points_for(position:int)->int:
	if career_config.is_empty(): career_config=load_career_config()
	var table:Array=career_config.get("points",[25,18,15,12,10,8,6,4,2,1]); return int(table[position-1]) if position>0 and position<=table.size() else 0
func _standing_less(a:Dictionary,b:Dictionary)->bool:
	if int(a.points)!=int(b.points): return int(a.points)>int(b.points)
	for place in [1,2,3]:
		var ac =a.finishes.count(place); var bc =b.finishes.count(place)
		if ac!=bc: return ac>bc
	var count:int=mini(a.finishes.size(),b.finishes.size())
	for offset in count:
		var ar:int=a.finishes[a.finishes.size()-1-offset]; var br:int=b.finishes[b.finishes.size()-1-offset]
		if ar!=br:return ar<br
	return str(a.name)<str(b.name)
func sorted_standings()->Array: var rows =data.standings.duplicate(true); rows.sort_custom(_standing_less); return rows

func transaction(amount:int,label:String)->void:
	data.money=int(data.get("money",0))+amount
	if amount>=0:data.season_income=int(data.get("season_income",0))+amount
	else:data.season_expenses=int(data.get("season_expenses",0))-amount
	data.transactions.push_front({"amount":amount,"label":label,"date":data.get("career_date","")}); data.transactions.resize(mini(50,data.transactions.size()))
func advance_days(days:int)->void:
	var date =Time.get_datetime_dict_from_datetime_string(data.career_date,false); var unix =Time.get_unix_time_from_datetime_dict(date)+days*86400; data.career_date=Time.get_datetime_string_from_unix_time(unix).left(10)
	for job in data.development_queue: job.days=maxi(0,int(job.days)-days)
	for job in data.development_queue.duplicate():
		if int(job.days)==0: data.vehicles[data.category.to_lower()].components[job.component]+=1; data.development_queue.erase(job)
func buy_upgrade(component:String,base_cost:int)->bool:
	var cost =effective_cost(base_cost,"development"); if int(data.money)<cost:return false
	var vehicle:Dictionary=data.vehicles[data.category.to_lower()]; if data.development_queue.any(func(j):return j.component==component):return false
	transaction(-cost,"Développement %s"%component.capitalize()); data.development_queue.append({"component":component,"cost":cost,"days":3,"effect":"performance +2"}); data.upgrades.append({"category":data.category,"component":component,"cost":cost}); save_game(); changed.emit(); return true
func repair_vehicle()->bool:
	var vehicle:Dictionary=data.vehicles[data.category.to_lower()]; var missing =100-int(vehicle.condition); var cost =effective_cost(missing*45,"repair"); if missing<=0 or int(data.money)<cost:return false
	transaction(-cost,"Réparation %s"%data.category); vehicle.condition=100; advance_days(1); save_game(); changed.emit(); return true
func train_driver()->bool:
	var cost =effective_cost(600,"development"); if int(data.money)<cost:return false
	transaction(-cost,"Entraînement pilote"); add_xp(180); advance_days(2); data.energy=maxi(0,int(data.energy)-1); save_game(); changed.emit(); return true
func spend_skill(stat:String)->bool:
	if int(data.skill_points)<=0 or not data.driver.stats.has(stat):return false
	data.skill_points-=1; data.driver.stats[stat]=mini(99,int(data.driver.stats[stat])+1); save_game(); changed.emit(); return true
func sign_sponsor(id:String)->bool:
	if career_config.is_empty():career_config=load_career_config()
	for sponsor in career_config.sponsors:
		if sponsor.id==id and int(data.reputation)>=int(sponsor.reputation): data.sponsor=sponsor.duplicate(true); data.sponsor.remaining=int(sponsor.duration); transaction(int(round(float(sponsor.fixed)*(1.0+modifier("sponsor")))),"Contrat sponsor — "+sponsor.name); save_game(); changed.emit(); return true
	return false
func buy_facility(kind:String)->bool:
	var next_level =int(data.facilities.get(kind,0))+1; var cost =effective_cost(5000*next_level,"facility"); if int(data.money)<cost:return false
	transaction(-cost,"%s niveau %d"%[kind.capitalize(),next_level]); data.facilities[kind]=next_level; advance_days(5); save_game(); changed.emit(); return true

func complete_race(result:Dictionary)->void:
	var index =int(data.race_index); if index>=data.calendar.size():return
	var start_position =int(result.get("start_position",12)); var position =int(result.position); var incidents:Array=result.get("incidents",[])
	var enriched =result.duplicate(true); enriched.start_position=start_position; enriched.positions_gained=start_position-position; enriched.points=points_for(position)
	var prize =maxi(350,2200-(position-1)*160); var xp =140+maxi(0,11-position)*20; var rep =maxi(1,12-position)
	enriched.money=prize; enriched.xp=xp; enriched.reputation=rep; enriched.race_objective=position<=int(data.objectives.race.target)
	data.race_history.append(enriched); data.calendar[index].status="COMPLETED"; data.calendar[index].results=enriched.get("standings",[]); data.race_index=index+1
	if data.race_index<data.calendar.size():data.calendar[data.race_index].status="AVAILABLE"
	_update_standings(enriched); transaction(prize,"Prime course — P%d"%position); add_xp(xp); data.reputation+=rep; data.season_reputation+=rep
	if enriched.race_objective:transaction(750,"Objectif course")
	_apply_sponsor_bonus(position); var vehicle:Dictionary=data.vehicles[data.category.to_lower()]; vehicle.condition=maxi(35,int(vehicle.condition)-3-incidents.size()*8-(2 if result.get("strategy","")=="ATTACK" else 0))
	advance_days(7); data.energy=5
	if data.race_index>=data.calendar.size():finish_season()
	save_game(); changed.emit()
func _update_standings(result:Dictionary)->void:
	for row in data.standings:
		var finish =0; var fastest =false
		if row.player: finish=int(result.position); fastest=bool(result.get("player_fastest_lap",false))
		else:
			for entry in result.get("standings",[]):
				if entry.name==row.name:finish=int(entry.position); fastest=bool(entry.get("fastest_lap",false)); break
		if finish==0:continue
		row.finishes.append(finish); row.points+=points_for(finish); row.wins+=1 if finish==1 else 0; row.podiums+=1 if finish<=3 else 0; row.fastest_laps+=1 if fastest else 0
func _apply_sponsor_bonus(position:int)->void:
	if data.sponsor.is_empty():return
	var objective:String=data.sponsor.objective; var achieved:bool=(objective=="podium" and position<=3) or (objective=="win" and position==1) or (objective=="top8" and position<=8)
	if achieved:transaction(int(data.sponsor.bonus),"Bonus sponsor — "+data.sponsor.name)
	data.sponsor.remaining=maxi(0,int(data.sponsor.remaining)-1)
func add_xp(amount:int)->void:
	var gained =int(round(amount*(1.0+modifier("driver_xp"))*float(data.get("driver",{}).get("xp_multiplier",1.0)))); data.experience+=gained; data.season_xp+=gained
	while int(data.experience)>=int(data.level)*500:data.experience-=int(data.level)*500;data.level+=1;data.skill_points+=1

func finish_season()->void:
	if data.season_complete:return
	data.season_complete=true; var table =sorted_standings(); var position =1
	for i in table.size():
		if table[i].player:
			position=i+1
			break
	data.objectives.season.completed=position<=int(data.objectives.season.target); var player:Dictionary=data.standings[0]
	var record={"year":data.career_year,"championship":"Regional Kart Series" if data.category=="KART" else "Formula Junior 4","position":position,"points":player.points,"wins":player.wins,"podiums":player.podiums}
	data.career_history.append(record)
	if position<=3:data.trophies.append({"year":data.career_year,"name":record.championship,"position":position});transaction([9000,6000,4000][position-1],"Prime championnat")
	_generate_offers(position); data.promotion_pending=true
func _generate_offers(position:int)->void:
	data.offers=[{"id":"stay","title":"RESTER EN KART RÉGIONAL","category":"KART","eligible":true,"cost":1000,"objective":"Top 5"},{"id":"national","title":"KART NATIONAL","category":"KART","eligible":position<=8,"cost":2500,"objective":"Top 5"}]
	var eligible =int(data.reputation)>=35 and position<=3
	data.offers.append({"id":"f4","title":"FORMULA JUNIOR 4","category":"F4","eligible":eligible,"cost":5000,"objective":"Top 8","prestige":5,"team":data.team.name})
	data.offers.append({"id":"gt4","title":"CONTINENTAL GT4 CUP","category":"GT4","eligible":position<=8,"cost":18000,"objective":"Top 10","prestige":25,"team":data.team.name})
func accept_offer(id:String)->bool:
	var offer:Dictionary={}
	for item in data.offers:
		if item.id==id:
			offer=item
			break
	if offer.is_empty() or not offer.eligible or int(data.money)<int(offer.cost):return false
	transaction(-int(offer.cost),"Inscription — "+offer.title); data.category=offer.category;data.career_path="GT_ENDURANCE" if offer.category=="GT4" else ("SINGLE_SEATER" if offer.category=="F4" else data.career_path);data.championship_class=offer.category; data.championship="continental_gt4_cup" if offer.category=="GT4" else ("formula_4" if offer.category=="F4" else ("kart_national" if id=="national" else "kart_regional")); data.season+=1;data.career_year+=1;data.career_date="%d-03-01"%data.career_year;data.calendar=make_calendar("KART" if offer.category=="GT4" else data.category);data.race_index=0;data.race_history=[];data.standings=make_standings();data.season_complete=false;data.promotion_pending=false;data.offers=[];data.season_income=0;data.season_expenses=0;data.season_xp=0;data.season_reputation=0;save_game();changed.emit();return true

func save_game()->bool:
	if data.is_empty():return false
	data.save_version=SAVE_VERSION; var file =FileAccess.open(SAVE_PATH,FileAccess.WRITE); if file==null:return false
	file.store_string(JSON.stringify(data,"\t"));return true
func load_game()->bool:
	var file =FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file==null:return false
	var parsed=JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:return false
	data=migrate(parsed);changed.emit();return true
func migrate(old:Dictionary)->Dictionary:
	var fresh =defaults();for key in old:fresh[key]=old[key]
	if not old.has("team_dna"):fresh.team_dna=neutral_dna()
	if not fresh.driver.has("hidden_potential"):fresh.driver.hidden_potential=82;fresh.driver.profile="versatile";fresh.driver.xp_multiplier=1.0
	if not fresh.team.has("short_name"):fresh.team.short_name=str(fresh.team.get("name","Legacy Team")).left(12)
	var manager_aliases := {"alex_martin":"alex","maya_chen":"maya","sofia_reyes":"ethan","idris_kone":"sofia","victor_bauer":"marcus"}
	var legacy_manager: String = str(fresh.team.get("manager_id",""))
	if manager_aliases.has(legacy_manager): fresh.team.manager_id = manager_aliases[legacy_manager]
	if fresh.team_dna.has("manager_id"):
		var legacy_dna_manager: String = str(fresh.team_dna.get("manager_id",""))
		if manager_aliases.has(legacy_dna_manager): fresh.team_dna.manager_id = manager_aliases[legacy_dna_manager]
	elif fresh.team.has("manager_id"):
		fresh.team_dna.manager_id = fresh.team.manager_id
	data=fresh;_prepare_driver_stats()
	if not old.has("standings"):fresh.standings=make_standings()
	if old.get("save_version",0)<3 and fresh.calendar.size()<6:fresh.calendar=make_calendar(fresh.category);fresh.race_index=mini(int(fresh.race_index),fresh.calendar.size())
	fresh.save_version=SAVE_VERSION;return fresh
func reset_save()->void:
	data={}
	if FileAccess.file_exists(SAVE_PATH):DirAccess.remove_absolute(SAVE_PATH)
	changed.emit()
