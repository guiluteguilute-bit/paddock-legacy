extends Control

var content: VBoxContainer
var nav: HBoxContainer
var title: Label
var race_view: RaceView
var notice: Label
var colors := {"bg":Color("061017"),"panel":Color("0d1d26"),"accent":Color("19dcc6"),"text":Color("e8f2f1"),"muted":Color("8da2a5"),"danger":Color("ff6b65")}

func _ready() -> void:
	build_shell()
	if GameState.has_career(): show_dashboard()
	else: show_welcome()

func build_shell() -> void:
	var bg:=ColorRect.new(); bg.color=colors.bg; bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var safe:=MarginContainer.new(); safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); safe.add_theme_constant_override("margin_left",32); safe.add_theme_constant_override("margin_right",32); safe.add_theme_constant_override("margin_top",20); safe.add_theme_constant_override("margin_bottom",20); add_child(safe)
	var root:=VBoxContainer.new(); root.add_theme_constant_override("separation",12); safe.add_child(root)
	var header:=HBoxContainer.new(); root.add_child(header)
	title=Label.new(); title.text="PADDOCK LEGACY"; title.add_theme_font_size_override("font_size",28); title.add_theme_color_override("font_color",colors.accent); title.size_flags_horizontal=Control.SIZE_EXPAND_FILL; header.add_child(title)
	notice=Label.new(); notice.add_theme_color_override("font_color",colors.muted); header.add_child(notice)
	content=VBoxContainer.new(); content.size_flags_vertical=Control.SIZE_EXPAND_FILL; content.add_theme_constant_override("separation",10); root.add_child(content)
	nav=HBoxContainer.new(); nav.alignment=BoxContainer.ALIGNMENT_CENTER; nav.add_theme_constant_override("separation",6); root.add_child(nav)
	for item in [["ACCUEIL",show_dashboard],["CARRIÈRE",show_career],["CALENDRIER",show_calendar],["CHAMPIONNAT",show_championship],["ÉCURIE",show_team],["VÉHICULE",show_vehicle],["FINANCES",show_finance],["COURSE",show_race_prep],["PARAMÈTRES",show_settings]]:
		var b:=button(item[0],item[1]); b.custom_minimum_size.x=104; nav.add_child(b)

func clear(page_title:String) -> void:
	for child in content.get_children(): child.queue_free()
	title.text="PADDOCK LEGACY  /  "+page_title
	notice.text=("%s  •  %s  •  %s €  •  ÉNERGIE %s/5" % [GameState.data.get("championship","—").to_upper(),GameState.data.get("career_date",""),money(GameState.data.get("money",0)),GameState.data.get("energy",0)]) if GameState.has_career() else "GODOT • WEB • MOBILE"

func show_welcome() -> void:
	clear("BIENVENUE"); heading("BÂTISSEZ L'ÉCURIE. FORMEZ LE PILOTE. LAISSEZ UNE TRACE.",32); label("Une carrière automobile complète, du karting à la Formula Apex.",colors.muted,20)
	set_navigation_enabled(false)
	var row:=HBoxContainer.new(); row.alignment=BoxContainer.ALIGNMENT_CENTER; content.add_child(row); row.add_child(button("NOUVELLE CARRIÈRE",show_creation))
	if FileAccess.file_exists(GameState.SAVE_PATH): row.add_child(button("CHARGER",func(): GameState.load_game(); show_dashboard()))

func show_creation() -> void:
	clear("NOUVELLE CARRIÈRE"); heading("CRÉATION ÉCURIE & PILOTE",26)
	var grid:=GridContainer.new(); grid.columns=2; grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL; content.add_child(grid)
	var fields:={}
	for entry in [["team","Nom de l'écurie","Nova Kart Racing"],["nationality","Nationalité","France"],["first","Prénom","Noa"],["last","Nom","Morel"],["number","Numéro","27"]]:
		var caption:=Label.new()
		caption.text=entry[1]
		caption.add_theme_color_override("font_color",colors.muted)
		grid.add_child(caption)
		var edit:=LineEdit.new()
		edit.text=entry[2]
		edit.custom_minimum_size=Vector2(320,42)
		fields[entry[0]]=edit
		grid.add_child(edit)
	var preview:=TextureRect.new(); preview.texture=load("res://graphics/cars/kart/car_kart_01.svg"); preview.custom_minimum_size=Vector2(420,180); preview.expand_mode=TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL; preview.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; content.add_child(preview)
	content.add_child(button("COMMENCER EN KARTING",func():
		if fields.team.text.strip_edges().is_empty() or fields.first.text.strip_edges().is_empty() or fields.last.text.strip_edges().is_empty(): toast("Tous les noms sont requis"); return
		GameState.new_career({"name":fields.team.text,"nationality":fields.nationality.text,"colors":["#19dcc6","#102a38","#ffcf4a"],"logo":"apex_nova"},{"first_name":fields.first.text,"last_name":fields.last.text,"nationality":fields.nationality.text,"number":int(fields.number.text),"appearance":0,"stats":{"speed":58,"control":61,"mental":57}}); show_dashboard()))

func show_dashboard() -> void:
	if not GameState.has_career(): show_welcome(); return
	set_navigation_enabled(true)
	clear("ACCUEIL"); heading("BON RETOUR, %s" % GameState.data.driver.first_name.to_upper(),28)
	var cards:=HBoxContainer.new(); content.add_child(cards)
	for pair in [["PROCHAINE MANCHE",next_event_text()],["PILOTE","NIV. %d  •  %d XP" % [GameState.data.level,GameState.data.experience]],["RÉPUTATION","%d" % GameState.data.reputation],["SOLDE",money(GameState.data.money)+" €"]]: cards.add_child(card(pair[0],pair[1]))
	label("OBJECTIF COURSE  •  TERMINER DANS LE TOP %d  •  RÉCOMPENSE 750 €" % GameState.data.objectives.race.target,colors.text,18)
	content.add_child(button("PRÉPARER LA PROCHAINE COURSE",show_race_prep))

func show_career() -> void:
	clear("CARRIÈRE"); heading("PYRAMIDE DE CARRIÈRE",24)
	var json=JSON.parse_string(FileAccess.get_file_as_string("res://game/data/championships.json"))
	for c in json:
		var unlocked:=int(GameState.data.reputation)>=int(c.minimum_reputation)
		label(("● " if unlocked else "○ ")+c.name+"  — réputation %d  — inscription %s €" % [c.minimum_reputation,money(c.entry_cost)],colors.accent if unlocked else colors.muted,17)

func show_calendar() -> void:
	clear("CALENDRIER"); heading("SAISON %d" % GameState.data.career_year,24)
	for i in GameState.data.calendar.size():
		var e:Dictionary=GameState.data.calendar[i]
		label("M%02d  %s  •  %s  •  %d tours  •  %s" % [i+1,e.track,e.date,e.laps,e.status],colors.accent if e.status=="AVAILABLE" else colors.text if e.status=="COMPLETED" else colors.muted,17)

func show_championship() -> void:
	clear("CHAMPIONNAT")
	heading("CLASSEMENT PILOTES",24)
	var points:=0
	for race in GameState.data.race_history:
		points += [25,18,15,12,10,8,6,4,2,1][mini(int(race.position)-1,9)] if int(race.position)<=10 else 0
	content.add_child(card("VOTRE PILOTE","%d PTS  •  %d COURSE(S)" % [points,GameState.data.race_history.size()])); label("Les égalités sont départagées par victoires, puis podiums.",colors.muted,15)

func show_team() -> void:
	clear("ÉCURIE"); heading(GameState.data.team.name.to_upper(),26); label("%s  •  Atelier N%d  •  Simulateur N%d  •  Pit crew N%d" % [GameState.data.team.nationality,GameState.data.facilities.workshop,GameState.data.facilities.simulator,GameState.data.facilities.pit_crew],colors.text,18)
	var image:=TextureRect.new(); image.texture=load("res://graphics/parallel/facilities/backgrounds/campus_day.svg"); image.custom_minimum_size=Vector2(600,300); image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; content.add_child(image)

func show_vehicle() -> void:
	clear("VÉHICULE & DÉVELOPPEMENT")
	var kart:Dictionary=GameState.data.vehicles.kart
	heading("KART N%d  •  FIABILITÉ %d%%  •  ÉTAT %d%%" % [kart.level,kart.reliability,kart.condition],24)
	var row:=HBoxContainer.new()
	content.add_child(row)
	var image:=TextureRect.new()
	image.texture=load("res://graphics/cars/kart/car_kart_01.svg")
	image.custom_minimum_size=Vector2(420,230)
	image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(image)
	var upgrades:=VBoxContainer.new(); row.add_child(upgrades)
	for component in ["engine","chassis","brakes"]:
		var cost:=1500*int(kart.components[component])
		upgrades.add_child(button("%s N%d → N%d  •  %s €  •  3 jours" % [component.to_upper(),kart.components[component],int(kart.components[component])+1,money(cost)],func(c=component,p=cost): buy_vehicle_upgrade(c,p)))

func buy_vehicle_upgrade(component:String, cost:int) -> void:
	if not GameState.buy_upgrade(component,cost):
		toast("Solde insuffisant")
	else:
		show_vehicle()

func show_finance() -> void:
	clear("FINANCES"); heading("SOLDE  %s €" % money(GameState.data.money),28); label("REVENUS SAISON  +%s €     DÉPENSES SAISON  -%s €" % [money(GameState.data.season_income),money(GameState.data.season_expenses)],colors.text,18)
	for tx in GameState.data.transactions: label(("+" if int(tx.amount)>=0 else "")+money(tx.amount)+" €    "+tx.label,colors.accent if int(tx.amount)>=0 else colors.danger,16)

func show_race_prep() -> void:
	clear("COURSE")
	if int(GameState.data.race_index)>=GameState.data.calendar.size():
		heading("SAISON TERMINÉE",28)
		label("La synthèse de fin de saison et la promotion seront étendues lors de la prochaine mission.",colors.muted,17)
		return
	var event:Dictionary=GameState.data.calendar[GameState.data.race_index]; heading(event.track.to_upper(),28); label("%s  •  %d TOURS  •  MÉTÉO: %d%% PLUIE  •  %s" % [event.date,event.laps,int(event.weather_probability*100),event.status],colors.text,18)
	if int(GameState.data.energy)<=0: label("ÉNERGIE INSUFFISANTE — la course est désactivée.",colors.danger,18); return
	content.add_child(button("AUTOSAVE & OUVRIR LA SESSION",func(): GameState.save_game(); open_race(event)))

func open_race(event:Dictionary) -> void:
	clear("SESSION LIVE"); race_view=RaceView.new(); race_view.custom_minimum_size=Vector2(900,430); race_view.size_flags_vertical=Control.SIZE_EXPAND_FILL; race_view.setup(GameState.data.driver.first_name+" "+GameState.data.driver.last_name,event.laps); race_view.finished.connect(_race_finished); content.add_child(race_view)
	var controls:=HBoxContainer.new(); controls.alignment=BoxContainer.ALIGNMENT_CENTER; content.add_child(controls)
	controls.add_child(button("QUALIFICATIONS",race_view.start_qualifying)); controls.add_child(button("DÉPART COURSE",race_view.start_race))
	for mode in ["CONSERVE","NORMAL","PUSH","ATTACK"]: controls.add_child(button(mode,func(m=mode): race_view.set_strategy(m)))
	for value in ["LOW","HIGH"]: controls.add_child(button("RISQUE "+value,func(v=value): race_view.set_risk(v)))

func _race_finished(result:Dictionary) -> void:
	GameState.complete_race(result); clear("RÉSULTATS"); heading("ARRIVÉE  •  P%d" % result.position,30); label("Meilleur tour: %.3f s  •  Stratégie: %s  •  + argent, XP et réputation enregistrés" % [result.best_lap,result.strategy],colors.accent,18); content.add_child(button("CONTINUER",show_dashboard))

func show_settings() -> void:
	clear("PARAMÈTRES"); heading("AUDIO & JEU",24)
	for key in ["master","music","sfx"]:
		var row:=HBoxContainer.new()
		content.add_child(row)
		var caption:=Label.new()
		caption.text=key.to_upper()
		caption.add_theme_color_override("font_color",colors.text)
		row.add_child(caption)
		var slider:=HSlider.new()
		slider.min_value=0
		slider.max_value=100
		slider.value=GameState.data.settings.get(key,80)
		slider.custom_minimum_size.x=400
		slider.value_changed.connect(func(v,k=key): GameState.data.settings[k]=int(v); GameState.save_game())
		row.add_child(slider)
	content.add_child(button("EFFACER LA SAUVEGARDE",func(): GameState.reset_save(); show_welcome()))

func next_event_text() -> String:
	if int(GameState.data.race_index)>=GameState.data.calendar.size(): return "SAISON TERMINÉE"
	var e:Dictionary=GameState.data.calendar[GameState.data.race_index]; return "%s  •  %d TOURS" % [e.track,e.laps]

func heading(text:String,size_px:int) -> Label: var l:=label(text,colors.text,size_px); l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; return l
func label(text:String,color:Color,size_px:int) -> Label: var l:=Label.new(); l.text=text; l.add_theme_color_override("font_color",color); l.add_theme_font_size_override("font_size",size_px); content.add_child(l); return l
func button(text:String,callable:Callable) -> Button: var b:=Button.new(); b.text=text; b.custom_minimum_size=Vector2(180,44); b.pressed.connect(callable); return b
func card(top:String,bottom:String) -> PanelContainer:
	var p:=PanelContainer.new()
	p.custom_minimum_size=Vector2(220,90)
	p.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	var v:=VBoxContainer.new()
	p.add_child(v)
	var a:=Label.new()
	a.text=top
	a.add_theme_color_override("font_color",colors.muted)
	v.add_child(a)
	var b:=Label.new()
	b.text=bottom
	b.add_theme_font_size_override("font_size",20)
	b.add_theme_color_override("font_color",colors.accent)
	v.add_child(b)
	return p
func toast(text:String) -> void: notice.text=text
func money(value) -> String: return str(int(value))

func set_navigation_enabled(enabled:bool) -> void:
	for child in nav.get_children():
		child.disabled=not enabled
