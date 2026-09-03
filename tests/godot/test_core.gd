extends SceneTree

func _result(state, player_position:int) -> Dictionary:
	var rows:=[]
	for i in state.career_config.rivals.size():
		var position:=i+1
		if position>=player_position:position+=1
		rows.append({"name":state.career_config.rivals[i].name,"position":position,"best_lap":49.0+i,"fastest_lap":false})
	return {"position":player_position,"start_position":8,"best_lap":48.2,"total_time":480.0,"tyres_remaining":72,"strategy":"NORMAL","incidents":[],"standings":rows,"track":"Test"}

func _init() -> void:
	var state=load("res://game/core/game_state.gd").new();state.creation_config=state.load_creation_config();state.career_config=state.load_career_config();state.data=state.defaults()
	assert(state.data.save_version==3);assert(state.career_config.kart_calendar.size()==6);assert(state.career_config.rivals.size()==11);assert(state.points_for(1)==25 and state.points_for(10)==1 and state.points_for(11)==0)
	var points={"workshop":2,"technical":2,"simulator":2,"scouting":1,"marketing":1,"strategy":2};var dna=state.build_team_dna("family_garage","pure_performance","technician","reach_apex",points)
	state.new_career({"name":"Test Team","colors":["#112233","#445566","#778899"],"livery_pattern":1},{"first_name":"Ada","last_name":"Test","nationality":"France","number":27,"hidden_potential":88,"xp_multiplier":1.12,"stats":{"speed":54,"control":62,"mental":65}},dna)
	assert(state.data.calendar.size()==6 and state.data.standings.size()==12);assert(state.data.calendar[0].status=="AVAILABLE" and state.data.calendar[1].status=="LOCKED")
	assert(state.sign_sponsor("nova_energy"));var money_after_sponsor:int=state.data.money;assert(money_after_sponsor>11500)
	for race in 6:state.complete_race(_result(state,1))
	assert(state.data.season_complete);assert(state.data.race_history.size()==6);assert(state.data.standings[0].points==150);assert(state.data.trophies.size()==1);assert(state.data.career_history.size()==1);assert(state.data.offers.size()>=3)
	state.data.reputation=35
	# Regeneration verifies the explicit F4 gate before promotion.
	state._generate_offers(1);assert(state.data.offers[2].eligible);state.data.money=50000;assert(state.accept_offer("f4"));assert(state.data.category=="F4" and state.data.calendar.size()==3);assert(state.data.vehicles.has("kart") and state.data.team.name=="Test Team")
	assert(state.spend_skill("speed"));var race=load("res://game/races/race_view.gd").new();state.data.race_index=0;race.setup("Ada Test",3,0.7,"F4");assert(race.racers.size()==12 and race.weather=="RAIN" and race.tyre=="MEDIUM");race.request_pit("WET");assert(race.pit_requested and race.tyre=="WET")
	assert(state.save_game());var reload=load("res://game/core/game_state.gd").new();reload.creation_config=state.creation_config;reload.career_config=state.career_config;assert(reload.load_game());assert(reload.data.category=="F4" and reload.data.team.name=="Test Team" and reload.data.career_history.size()==1)
	print("Full kart-to-F4 career checks passed");quit(0)
