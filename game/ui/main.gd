extends Control

var content: VBoxContainer
var nav: HBoxContainer
var title: Label
var subtitle: Label
var notice: Label
var scroll: ScrollContainer
var race_view: RaceView
var creation_step := 0
var creation_draft: Dictionary = {}
var creation_controls: Dictionary = {}
const CREATION_STEPS := ["IDENTITÉ", "ORIGINE", "PHILOSOPHIE", "DIRECTION", "FONDATION", "PILOTE", "OBJECTIF", "RÉCAPITULATIF"]
var colors := {"bg": Color("071117"), "panel": Color("10232c"), "panel_2": Color("162f39"), "accent": Color("19dcc6"), "gold": Color("ffcc58"), "text": Color("eff7f5"), "muted": Color("91a8aa"), "danger": Color("ff6b65")}

func _ready() -> void:
	build_shell()
	get_viewport().size_changed.connect(_apply_safe_area)
	if GameState.has_career(): show_dashboard()
	else: show_welcome()

func build_shell() -> void:
	var bg := ColorRect.new(); bg.color = colors.bg; bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(bg)
	var glow := ColorRect.new(); glow.color = Color(0.04, 0.28, 0.27, 0.16); glow.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE); glow.custom_minimum_size.y = 270; add_child(glow)
	var safe := MarginContainer.new(); safe.name = "SafeArea"; safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(safe)
	var root := VBoxContainer.new(); root.add_theme_constant_override("separation", 12); safe.add_child(root)
	var header := VBoxContainer.new(); header.add_theme_constant_override("separation", 0); root.add_child(header)
	title = Label.new(); title.text = "PADDOCK LEGACY"; title.add_theme_font_size_override("font_size", 27); title.add_theme_color_override("font_color", colors.text); header.add_child(title)
	subtitle = Label.new(); subtitle.add_theme_font_size_override("font_size", 13); subtitle.add_theme_color_override("font_color", colors.accent); header.add_child(subtitle)
	notice = Label.new(); notice.add_theme_font_size_override("font_size", 12); notice.add_theme_color_override("font_color", colors.gold); notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; header.add_child(notice)
	scroll = ScrollContainer.new(); scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL; scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; root.add_child(scroll)
	content = VBoxContainer.new(); content.size_flags_horizontal = Control.SIZE_EXPAND_FILL; content.add_theme_constant_override("separation", 12); scroll.add_child(content)
	nav = HBoxContainer.new(); nav.name = "MobileBottomNavigation"; nav.add_theme_constant_override("separation", 5); root.add_child(nav)
	for item in [["⌂\nACCUEIL", show_dashboard], ["▥\nCARRIÈRE", show_career], ["●\nCOURSE", show_race_prep], ["◆\nÉCURIE", show_team], ["•••\nPLUS", show_more]]:
		var b := button(item[0], item[1], true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; b.custom_minimum_size = Vector2(0, 64); nav.add_child(b)
	_apply_safe_area()

func _apply_safe_area() -> void:
	var safe := get_node_or_null("SafeArea") as MarginContainer
	if safe == null: return
	# Conservative fallback protects notches and the home indicator on Web, where OS safe-area data is unavailable.
	var top := 28; var bottom := 22; var side := 18
	var screen_safe := DisplayServer.get_display_safe_area()
	if screen_safe.size.x > 0 and DisplayServer.window_get_size().x > 0:
		var scale := size.x / float(DisplayServer.window_get_size().x)
		top = maxi(top, int(screen_safe.position.y * scale)); side = maxi(side, int(screen_safe.position.x * scale))
		bottom = maxi(bottom, int((DisplayServer.window_get_size().y - screen_safe.end.y) * scale))
	safe.add_theme_constant_override("margin_left", side); safe.add_theme_constant_override("margin_right", side); safe.add_theme_constant_override("margin_top", top); safe.add_theme_constant_override("margin_bottom", bottom)

func clear(page_title: String) -> void:
	if GameState.has_career() and GameState.data.team.get("colors", []).size() >= 3:
		colors.accent = Color(GameState.data.team.colors[2])
	for child in content.get_children(): child.queue_free()
	scroll.scroll_vertical = 0
	title.text = "PADDOCK LEGACY"
	subtitle.text = page_title + (("  •  " + GameState.data.get("team", {}).get("name", "").to_upper()) if GameState.has_career() else "")
	notice.text = ("SAISON %d  •  %s €  •  RÉP. %d  •  ÉNERGIE %s/5" % [GameState.data.get("career_year", 2026), money(GameState.data.get("money", 0)), GameState.data.get("reputation", 0), GameState.data.get("energy", 0)]) if GameState.has_career() else "GODOT • PORTRAIT • WEB"

func show_welcome() -> void:
	clear("BIENVENUE"); heading("CHAQUE LÉGENDE COMMENCE QUELQUE PART.", 22); heading("BÂTISSEZ VOTRE LÉGENDE", 31); label("DU KARTING À FORMULA APEX", colors.accent, 15)
	var hero := TextureRect.new(); hero.texture = load("res://graphics/ui/backgrounds/main_menu_garage.svg"); hero.custom_minimum_size.y = 330; hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; content.add_child(hero)
	label("Management automobile, stratégie et retransmission miniature 2.5D.", colors.muted, 17)
	content.add_child(button("CRÉER UNE ÉCURIE", show_creation))
	if FileAccess.file_exists(GameState.SAVE_PATH): content.add_child(button("REPRENDRE LA CARRIÈRE", func(): GameState.load_game(); show_dashboard()))
	set_navigation_enabled(false)

func show_creation() -> void:
	if creation_draft.is_empty():
		creation_draft = {"team_name":"Nova Kart Racing","short_name":"NOVA","country":"France","team_number":27,"colors":["#19dcc6","#102a38","#ffcf4a"],"logo_shape":0,"logo_symbol":0,"logo_outline":0,"livery_pattern":0,"origin":"family_garage","philosophy":"pure_performance","style":"technician","points":{"workshop":2,"technical":2,"simulator":2,"scouting":1,"marketing":1,"strategy":2},"driver_first":"Noa","driver_last":"Martin","driver_country":"France","driver_number":27,"driver_age":14,"driver_appearance":0,"helmet":0,"driver_profile":"worker","goal":"reach_apex"}
	show_creation_step()

func show_creation_step() -> void:
	clear("ÉTAPE %d / 8  •  %s" % [creation_step + 1, CREATION_STEPS[creation_step]]); set_navigation_enabled(false); creation_controls.clear()
	match creation_step:
		0: creation_identity()
		1: creation_choice("CHOISISSEZ VOTRE ORIGINE", "origins", "origin")
		2: creation_choice("QUELLE EST VOTRE PHILOSOPHIE ?", "philosophies", "philosophy")
		3: creation_choice("STYLE DE DIRECTION", "manager_styles", "style")
		4: creation_foundation()
		5: creation_driver()
		6: creation_goal()
		7: creation_summary()
	if creation_step < 7: creation_navigation()

func creation_identity() -> void:
	heading("CRÉEZ VOTRE ÉCURIE", 28); label("Une identité qui vous suivra du karting à Formula Apex.", colors.muted, 14)
	var preview := LiveryPreview.new(); preview.custom_minimum_size = Vector2(0, 220); preview.set_livery(creation_draft.colors, creation_draft.livery_pattern); content.add_child(preview); creation_controls.preview = preview
	for field in [["team_name","NOM COMPLET",24],["short_name","NOM COURT",10],["country","PAYS",20],["team_number","NUMÉRO PRINCIPAL",3]]:
		label(field[1],colors.muted,12); var edit:=LineEdit.new(); edit.text=str(creation_draft[field[0]]); edit.max_length=field[2]; edit.custom_minimum_size.y=50; edit.text_changed.connect(func(value,k=field[0]): creation_draft[k]=int(value) if k=="team_number" else value); content.add_child(edit)
	label("COULEURS DE L'ÉCURIE",colors.muted,12)
	for i in 3:
		var picker:=ColorPickerButton.new(); picker.color=Color(creation_draft.colors[i]); picker.custom_minimum_size.y=48; picker.color_changed.connect(func(value,index=i): creation_draft.colors[index]=value.to_html(); preview.set_livery(creation_draft.colors,creation_draft.livery_pattern)); content.add_child(picker)
	choice_buttons("MOTIF DE LIVRÉE", ["BANDE","DIAGONALE","GÉOMÉTRIQUE","DOUBLE BANDE","DÉGRADÉ","UNI"], "livery_pattern", func(): preview.set_livery(creation_draft.colors,creation_draft.livery_pattern))
	choice_buttons("FORME DU LOGO", ["ÉCUSSON","CERCLE","HEXAGONE","AILE","BLASON","POINTE","OVALE","BOUCLIER","LOSANGE","ANNEAU","DRAPEAU","MONOGRAMME"], "logo_shape")
	choice_buttons("SYMBOLE", ["ÉCLAIR","COURONNE","VOLANT","ÉTOILE","FAUCON","LION","FLÈCHE","PISTON","DAMIER","CASQUE","ROUE","AILE","TORO","COMÈTE","MONTAGNE","FEU","GRIFFE","NUMÉRO","MOTEUR","LAURIER"], "logo_symbol")

func creation_choice(page_title: String, section: String, draft_key: String) -> void:
	heading(page_title, 25)
	var entries: Dictionary = GameState.creation_config.get(section, {})
	for id in entries:
		var option: Dictionary = entries[id]
		var selected := creation_draft[draft_key] == id
		var description := option.get("story", "") + "\n\nAVANTAGES\n• " + "\n• ".join(option.get("advantages", [])) + "\n\nINCONVÉNIENTS\n• " + "\n• ".join(option.get("drawbacks", []))
		var select := func() -> void:
			creation_draft[draft_key] = id
			show_creation_step()
		var choice := button(("✓  " if selected else "") + option.name.to_upper() + "\n" + description, select)
		choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		choice.custom_minimum_size.y = 190
		content.add_child(choice)

func creation_foundation() -> void:
	heading("10 POINTS DE FONDATION",26); label("Niveau actuel et affinité sont distincts. Chaque domaine accepte 0 à 5 points.",colors.muted,14)
	var used:int=foundation_total(); label("POINTS UTILISÉS  %d / 10" % used,colors.gold,19)
	for domain in GameState.DNA_DOMAINS:
		var row:=HBoxContainer.new(); content.add_child(row); var name_label:=Label.new(); name_label.text=domain.to_upper(); name_label.custom_minimum_size.x=240; row.add_child(name_label)
		var decrease := func() -> void:
			if creation_draft.points[domain] > 0:
				creation_draft.points[domain] -= 1
			show_creation_step()
		var minus := button("−", decrease, true)
		row.add_child(minus)
		var value:=Label.new(); value.text=str(creation_draft.points[domain]); value.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; value.custom_minimum_size.x=55; row.add_child(value)
		var increase := func() -> void:
			if creation_draft.points[domain] < 5 and foundation_total() < 10:
				creation_draft.points[domain] += 1
			show_creation_step()
		var plus := button("+", increase, true)
		row.add_child(plus)
	var dna:=draft_dna(); heading("SYNTHÈSE DYNAMIQUE",18)
	for domain in GameState.DNA_DOMAINS:
		var rating:int=dna.ratings[domain]; var tier:="FORCE" if rating>=60 else ("MOYEN" if rating>=45 else "FAIBLESSE"); label("%-11s  %s  %s  %d" % [domain.to_upper(),stars(creation_draft.points[domain]),tier,rating], colors.accent if tier=="FORCE" else colors.muted,14)

func creation_driver() -> void:
	heading("CRÉEZ VOTRE PREMIER PILOTE",26)
	for field in [["driver_first","PRÉNOM"],["driver_last","NOM"],["driver_country","PAYS"],["driver_number","NUMÉRO"],["driver_age","ÂGE (13–16)"]]:
		label(field[1],colors.muted,12); var edit:=LineEdit.new(); edit.text=str(creation_draft[field[0]]); edit.custom_minimum_size.y=48; edit.text_changed.connect(func(value,k=field[0]): creation_draft[k]=clampi(int(value),13,16) if k=="driver_age" else (int(value) if k=="driver_number" else value)); content.add_child(edit)
	choice_buttons("APPARENCE",["PORTRAIT 1","PORTRAIT 2","PORTRAIT 3","PORTRAIT 4"],"driver_appearance")
	choice_buttons("CASQUE",["CLASSIQUE","BANDE","ÉCLAIR","DAMIER","AILE","GRIFFE","GÉO","APEX"],"helmet")
	heading("PROFIL DU PILOTE", 20)
	var profiles: Dictionary = GameState.creation_config.driver_archetypes
	for id in profiles:
		var option: Dictionary = profiles[id]
		var select := func() -> void:
			creation_draft.driver_profile = id
			show_creation_step()
		var choice := button(("✓  " if creation_draft.driver_profile == id else "") + option.name.to_upper() + "\n+ " + " • ".join(option.advantages) + "\n− " + " • ".join(option.drawbacks), select)
		choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		choice.custom_minimum_size.y = 115
		content.add_child(choice)

func creation_goal() -> void:
	heading("QUEL EST VOTRE OBJECTIF ?",26); label("Il guidera vos objectifs, événements, récompenses et succès — sans bonus automatique démesuré.",colors.muted,14)
	for id in GameState.creation_config.goals:
		var b:=button(("✓  " if creation_draft.goal==id else "")+str(GameState.creation_config.goals[id]).to_upper(),func(key=id):creation_draft.goal=key;show_creation_step()); content.add_child(b)

func creation_summary() -> void:
	heading("VOTRE ÉCURIE EST PRÊTE", 29)
	var dna := draft_dna()
	var origin = GameState.creation_config.origins[creation_draft.origin]
	var philosophy = GameState.creation_config.philosophies[creation_draft.philosophy]
	var style = GameState.creation_config.manager_styles[creation_draft.style]
	var profile = GameState.creation_config.driver_archetypes[creation_draft.driver_profile]
	var preview := LiveryPreview.new()
	preview.custom_minimum_size.y = 190
	preview.set_livery(creation_draft.colors, creation_draft.livery_pattern)
	content.add_child(preview)
	content.add_child(card(creation_draft.team_name.to_upper(), creation_draft.country + "  •  FONDÉE EN 2027\nORIGINE : " + origin.name + "\nPHILOSOPHIE : " + philosophy.name + "\nFONDATEUR : " + style.name + "\nOBJECTIF : " + GameState.creation_config.goals[creation_draft.goal], 190))
	heading("ADN DE L'ÉCURIE", 18)
	for domain in GameState.DNA_DOMAINS:
		label("%-11s  %d  %s" % [domain.to_upper(), dna.ratings[domain], rating_bar(dna.ratings[domain])], colors.accent, 14)
	heading("AVANTAGES", 18)
	label("• " + "\n• ".join(dna.advantages), colors.text, 14)
	heading("INCONVÉNIENTS", 18)
	label("• " + "\n• ".join(dna.drawbacks), colors.danger, 14)
	var potential = profile.potential
	content.add_child(card("PILOTE  •  %s %s" % [creation_draft.driver_first, creation_draft.driver_last], "%d ANS  •  #%d  •  %s\nPOTENTIEL ESTIMÉ %d — %d" % [creation_draft.driver_age, creation_draft.driver_number, profile.name, potential[0] - 5, potential[1]], 120))
	content.add_child(button("‹  MODIFIER", func(): creation_step = 6; show_creation_step()))
	content.add_child(button("COMMENCER LA CARRIÈRE", confirm_creation))

func creation_navigation() -> void:
	var row := HBoxContainer.new()
	content.add_child(row)
	if creation_step > 0:
		var go_back := func() -> void:
			creation_step -= 1
			show_creation_step()
		var back := button("‹ RETOUR", go_back)
		back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(back)
	var go_next := func() -> void:
		if validate_creation_step():
			creation_step += 1
			show_creation_step()
	var next := button("CONTINUER ›", go_next)
	next.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(next)

func validate_creation_step() -> bool:
	if creation_step == 0 and (str(creation_draft.team_name).strip_edges().is_empty() or str(creation_draft.short_name).strip_edges().is_empty()):
		toast("Le nom complet et le nom court sont requis")
		return false
	if creation_step == 4 and foundation_total() != 10:
		toast("Répartissez exactement 10 points")
		return false
	if creation_step == 5 and (str(creation_draft.driver_first).strip_edges().is_empty() or str(creation_draft.driver_last).strip_edges().is_empty()):
		toast("Le nom du pilote est requis")
		return false
	return true

func foundation_total() -> int:
	var total := 0
	for value in creation_draft.points.values():
		total += int(value)
	return total

func draft_dna() -> Dictionary:
	return GameState.build_team_dna(creation_draft.origin, creation_draft.philosophy, creation_draft.style, creation_draft.goal, creation_draft.points)

func stars(value: int) -> String:
	return "★".repeat(value) + "☆".repeat(5 - value)

func rating_bar(value: int) -> String:
	var filled := clampi(int(value / 10.0), 1, 10)
	return "▰".repeat(filled) + "▱".repeat(10 - filled)

func choice_buttons(page_title: String, options: Array, key: String, callback: Callable = Callable()) -> void:
	label(page_title, colors.muted, 12)
	var grid := GridContainer.new()
	grid.columns = 2
	content.add_child(grid)
	for i in options.size():
		var select := func() -> void:
			creation_draft[key] = i
			if callback.is_valid():
				callback.call()
			show_creation_step()
		var choice := button(("✓ " if int(creation_draft[key]) == i else "") + options[i], select, true)
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(choice)

func confirm_creation() -> void:
	var dialog:=ConfirmationDialog.new(); dialog.title="COMMENCER LA CARRIÈRE"; dialog.dialog_text="Ces choix définiront définitivement l'histoire de votre écurie. Prêt pour le petit garage ?"; dialog.ok_button_text="COMMENCER"; dialog.cancel_button_text="RETOUR"; add_child(dialog); dialog.confirmed.connect(finalize_creation); dialog.popup_centered(Vector2i(480,260))
func finalize_creation() -> void:
	var profile:Dictionary=GameState.creation_config.driver_archetypes[creation_draft.driver_profile]; var rng:=RandomNumberGenerator.new(); rng.randomize(); var hidden:=rng.randi_range(int(profile.potential[0]),int(profile.potential[1]))
	var team={"name":creation_draft.team_name,"short_name":creation_draft.short_name,"nationality":creation_draft.country,"country":creation_draft.country,"number":creation_draft.team_number,"colors":creation_draft.colors.duplicate(),"logo":{"shape":creation_draft.logo_shape,"symbol":creation_draft.logo_symbol,"outline":creation_draft.logo_outline},"livery_pattern":creation_draft.livery_pattern}
	var driver={"first_name":creation_draft.driver_first,"last_name":creation_draft.driver_last,"nationality":creation_draft.driver_country,"number":creation_draft.driver_number,"age":creation_draft.driver_age,"appearance":creation_draft.driver_appearance,"helmet":creation_draft.helmet,"colors":creation_draft.colors.duplicate(),"profile":creation_draft.driver_profile,"hidden_potential":hidden,"xp_multiplier":profile.xp,"traits":profile.traits.duplicate(true),"stats":profile.stats.duplicate(true)}
	GameState.new_career(team,driver,draft_dna()); creation_draft.clear(); creation_step=0; show_dashboard()

func show_dashboard() -> void:
	if not GameState.has_career(): show_welcome(); return
	set_navigation_enabled(true); clear("ACCUEIL")
	if GameState.data.season_complete:
		show_season_end()
		return
	var event: Dictionary = GameState.data.calendar[GameState.data.race_index] if int(GameState.data.race_index) < GameState.data.calendar.size() else {}
	heading("PROCHAINE COURSE", 16)
	var race_card := card(event.get("track", "SAISON TERMINÉE").to_upper(), "%d TOURS  •  KARTING  •  ☁ %d%%\nOBJECTIF TOP %d" % [event.get("laps", 0), int(event.get("weather_probability", 0.0) * 100), GameState.data.objectives.race.target], 150)
	content.add_child(race_card)
	heading("PILOTE", 16)
	var driver_row := HBoxContainer.new(); content.add_child(driver_row)
	var portrait := TextureRect.new(); portrait.texture = load("res://graphics/portraits/generated/portrait_driver_01.svg"); portrait.custom_minimum_size = Vector2(120, 150); portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; driver_row.add_child(portrait)
	var driver_card := card((GameState.data.driver.first_name + " " + GameState.data.driver.last_name).to_upper(), "NIVEAU %d  •  %d XP\nVIT %d  CTRL %d  MENTAL %d" % [GameState.data.level, GameState.data.experience, GameState.data.driver.stats.speed, GameState.data.driver.stats.control, GameState.data.driver.stats.mental], 150); driver_row.add_child(driver_card)
	heading("OBJECTIFS", 16); content.add_child(card("TOP %d À LA PROCHAINE MANCHE" % GameState.data.objectives.race.target, "+750 €  •  RÉPUTATION", 92))
	content.add_child(button("LANCER LA COURSE  ›", show_race_prep))

func show_career() -> void:
	clear("CARRIÈRE"); heading("PYRAMIDE DE CARRIÈRE", 24)
	var championships = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/championships.json"))
	for c in championships:
		var unlocked := int(GameState.data.reputation) >= int(c.minimum_reputation); content.add_child(card(("DÉBLOQUÉ  •  " if unlocked else "VERROUILLÉ  •  ") + c.name, "RÉPUTATION %d  •  %s €" % [c.minimum_reputation, money(c.entry_cost)], 78))

func show_team() -> void:
	clear("ÉCURIE"); heading(GameState.data.team.name.to_upper(), 25)
	var image := TextureRect.new(); image.texture = load("res://graphics/parallel/facilities/backgrounds/campus_day.svg"); image.custom_minimum_size.y = 300; image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; content.add_child(image)
	content.add_child(card("ATELIER N%d" % GameState.data.facilities.workshop, "SIMULATEUR N%d  •  PIT CREW N%d" % [GameState.data.facilities.simulator, GameState.data.facilities.pit_crew], 86))
	var dna:Dictionary=GameState.data.team_dna; heading("HISTORIQUE",18); content.add_child(card("FONDÉE EN %d" % dna.founded_year,"ORIGINE : %s\nPHILOSOPHIE : %s\nFONDATEUR : %s" % [choice_name("origins",dna.origin),choice_name("philosophies",dna.philosophy),choice_name("manager_styles",dna.management_style)],125)); heading("ADN DE L'ÉCURIE",18)
	for domain in GameState.DNA_DOMAINS: label("%-11s  %d  %s" % [domain.to_upper(),dna.ratings[domain],rating_bar(dna.ratings[domain])],colors.accent,14)

func choice_name(section:String,id:String)->String: return GameState.creation_config.get(section,{}).get(id,{}).get("name",id.capitalize())

func show_more() -> void:
	clear("PLUS"); heading("GESTION DE L'ÉCURIE", 24)
	for item in [["DÉVELOPPEMENT PILOTE", show_driver_development], ["VÉHICULE & DÉVELOPPEMENT", show_vehicle], ["SPONSORS", show_sponsors], ["PERSONNEL & INFRASTRUCTURES", show_operations], ["FINANCES", show_finance], ["CALENDRIER", show_calendar], ["CHAMPIONNAT", show_championship], ["PALMARÈS", show_honours], ["PARAMÈTRES", show_settings]]: content.add_child(button(item[0] + "  ›", item[1]))

func show_calendar() -> void:
	clear("CALENDRIER"); heading("SAISON %d" % GameState.data.career_year, 24)
	for i in GameState.data.calendar.size():
		var e: Dictionary = GameState.data.calendar[i]; content.add_child(card("M%02d  •  %s" % [i + 1, e.track.to_upper()], "%s  •  %d TOURS  •  %s" % [e.date, e.laps, e.status], 80))

func show_championship() -> void:
	clear("CHAMPIONNAT"); heading("CLASSEMENT PILOTES", 24)
	var rows:=GameState.sorted_standings()
	for i in rows.size():
		var row:Dictionary=rows[i]; content.add_child(card(("★ " if row.player else "")+"P%d  %s"%[i+1,str(row.name).to_upper()], "%d PTS  •  %d V  •  %d PODIUMS  •  %d MT"%[row.points,row.wins,row.podiums,row.fastest_laps], 82))

func show_vehicle() -> void:
	clear("VÉHICULE"); var vehicle:Dictionary=GameState.data.vehicles[GameState.data.category.to_lower()]; heading("%s N%d  •  CONDITION %d%%" % [GameState.data.category,vehicle.level,vehicle.condition], 23)
	if GameState.data.category=="F4":
		var f4:=TextureRect.new();f4.texture=load("res://graphics/cars/f4/car_f4_01.svg");f4.custom_minimum_size.y=230;f4.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;f4.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;content.add_child(f4)
	else:
		var image:=LiveryPreview.new();image.custom_minimum_size.y=230;image.set_livery(GameState.data.team.get("colors",["#19dcc6","#102a38","#ffcf4a"]),int(GameState.data.team.get("livery_pattern",0)));content.add_child(image)
	label("FIABILITÉ %d%%"%vehicle.reliability,colors.accent,18)
	content.add_child(button("RÉPARER",repair_from_vehicle))
	for component in vehicle.components:
		var base_cost:=1500*int(vehicle.components[component]);var shown_cost:=GameState.effective_cost(base_cost,"development");content.add_child(button("%s N%d → N%d  •  %s €  •  3 JOURS"%[component.to_upper(),vehicle.components[component],int(vehicle.components[component])+1,money(shown_cost)],func(c=component,p=base_cost):buy_vehicle_upgrade(c,p)))
	for job in GameState.data.development_queue:label("EN COURS • %s • %d JOURS"%[job.component.to_upper(),job.days],colors.gold,14)

func buy_vehicle_upgrade(component: String, cost: int) -> void:
	if not GameState.buy_upgrade(component, cost): toast("Solde insuffisant")
	else: show_vehicle()

func repair_from_vehicle() -> void:
	if GameState.repair_vehicle():show_vehicle()
	else:toast("Réparation impossible")

func show_finance() -> void:
	clear("FINANCES"); heading("SOLDE  %s €" % money(GameState.data.money), 28)
	for tx in GameState.data.transactions: content.add_child(card(tx.label, ("+" if int(tx.amount) >= 0 else "") + money(tx.amount) + " €", 68))

func show_race_prep() -> void:
	clear("COURSE")
	if int(GameState.data.race_index) >= GameState.data.calendar.size(): show_season_end(); return
	var event: Dictionary = GameState.data.calendar[GameState.data.race_index]; heading(event.track.to_upper(), 28); content.add_child(card("PROCHAINE MANCHE", "%d TOURS  •  PLUIE %d%%  •  OBJECTIF TOP %d" % [event.laps, int(event.weather_probability * 100), GameState.data.objectives.race.target], 110))
	if int(GameState.data.energy) <= 0: label("ÉNERGIE INSUFFISANTE", colors.danger, 18); return
	heading("ENTRE DEUX COURSES",16);var actions:=HBoxContainer.new();content.add_child(actions);for item in [["ENTRAÎNER",func():GameState.train_driver();show_race_prep()],["RÉPARER",func():GameState.repair_vehicle();show_race_prep()],["GARAGE",show_vehicle]]:var a:=button(item[0],item[1],true);a.size_flags_horizontal=Control.SIZE_EXPAND_FILL;actions.add_child(a)
	content.add_child(button("OUVRIR LA SESSION  ›", func(): GameState.save_game(); open_race(event)))

func open_race(event: Dictionary) -> void:
	clear("LIVE • " + event.track.to_upper()); race_view = RaceView.new(); race_view.custom_minimum_size = Vector2(0, 570); race_view.setup(GameState.data.driver.first_name + " " + GameState.data.driver.last_name, event.laps, event.weather_probability, GameState.data.category); race_view.finished.connect(_race_finished); content.add_child(race_view)
	var camera := HBoxContainer.new(); content.add_child(camera)
	for mode in ["TV", "PILOTE", "CIRCUIT"]: var b := button(mode, func(m = mode): race_view.set_camera(m), true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; camera.add_child(b)
	var sessions := HBoxContainer.new(); content.add_child(sessions)
	for item in [["QUALIFS", race_view.start_qualifying], ["DÉPART", race_view.start_race]]: var b := button(item[0], item[1], true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; sessions.add_child(b)
	label("RYTHME", colors.muted, 12); var pace := HBoxContainer.new(); content.add_child(pace)
	for mode in ["CONSERVE", "NORMAL", "PUSH", "ATTACK"]: var b := button(mode, func(m = mode): race_view.set_strategy(m), true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; b.add_theme_font_size_override("font_size", 11); pace.add_child(b)
	var quick := HBoxContainer.new(); content.add_child(quick)
	for item in [["OVERTAKE", func(): race_view.set_risk("HIGH")], ["DEFEND", func(): race_view.set_risk("LOW")], ["PIT", open_pit_sheet]]: var b := button(item[0], item[1], true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; quick.add_child(b)

func open_pit_sheet() -> void:
	var sheet := PanelContainer.new(); sheet.name = "PitStrategySheet"; content.add_child(sheet); content.move_child(sheet, content.get_child_count() - 1)
	var v := VBoxContainer.new(); sheet.add_child(v); var h := Label.new(); h.text = "STRATÉGIE D'ARRÊT"; h.add_theme_font_size_override("font_size", 20); v.add_child(h)
	for tyre in ["SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET"]: var b := button(tyre, func(t = tyre): race_view.request_pit(t); sheet.queue_free(), true); v.add_child(b)

func _race_finished(result: Dictionary) -> void:
	GameState.complete_race(result);var saved:Dictionary=GameState.data.race_history[-1];clear("RÉSULTATS");heading("DRAPEAU À DAMIER",18);heading("P%d"%saved.position,52);content.add_child(card("DÉPART P%d  →  ARRIVÉE P%d  •  %+d"%[saved.start_position,saved.position,saved.positions_gained],"MEILLEUR TOUR %.3f s  •  TEMPS %.1f s\nPNEUS %d%%  •  INCIDENTS %d\n%d PTS  •  +%s €  •  +%d XP  •  +%d RÉP."%[saved.best_lap,saved.get("total_time",0.0),saved.get("tyres_remaining",0),saved.incidents.size(),saved.points,money(saved.money),saved.xp,saved.reputation],190));content.add_child(button("CONTINUER",show_dashboard))

func show_driver_development() -> void:
	clear("DÉVELOPPEMENT PILOTE");heading("NIVEAU %d"%GameState.data.level,28);label("%d XP  •  %d POINT(S) DE COMPÉTENCE"%[GameState.data.experience,GameState.data.skill_points],colors.gold,18)
	var estimate:=GameState.potential_estimate();content.add_child(card("POTENTIEL ESTIMÉ","%d — %d  •  précision scouting"%[estimate.x,estimate.y],85))
	for stat in GameState.data.driver.stats:
		content.add_child(button("%s  %d  •  +1 POINT"%[stat.to_upper(),GameState.data.driver.stats[stat]],func(s=stat):GameState.spend_skill(s);show_driver_development()))

func show_sponsors() -> void:
	clear("SPONSORS");heading("CONTRATS",26)
	if not GameState.data.sponsor.is_empty():content.add_child(card(GameState.data.sponsor.name,"%d COURSE(S) • OBJECTIF %s • BONUS %s €"%[GameState.data.sponsor.remaining,GameState.data.sponsor.objective.to_upper(),money(GameState.data.sponsor.bonus)],105));return
	for sponsor in GameState.career_config.sponsors:
		content.add_child(button("%s\nFIXE %s €  •  BONUS %s €  •  %s"%[sponsor.name,money(sponsor.fixed),money(sponsor.bonus),sponsor.objective.to_upper()],func(id=sponsor.id):GameState.sign_sponsor(id);show_sponsors()))

func show_operations() -> void:
	clear("OPÉRATIONS");heading("PERSONNEL",24)
	for employee in GameState.career_config.staff:content.add_child(card(employee.role+" • "+employee.name,"COMPÉTENCE %d • SALAIRE %s € • %d MOIS"%[employee.skill,money(employee.salary),employee.contract],80))
	heading("INFRASTRUCTURES",24)
	for kind in ["workshop","simulator","scouting","pit_crew"]:content.add_child(button("%s NIV. %d  •  AMÉLIORER"%[kind.to_upper(),GameState.data.facilities[kind]],func(k=kind):GameState.buy_facility(k);show_operations()))

func show_honours() -> void:
	clear("PALMARÈS");heading("TROPHÉES",26)
	if GameState.data.trophies.is_empty():label("Aucun trophée pour le moment.",colors.muted,16)
	for trophy in GameState.data.trophies:content.add_child(card("🏆  "+trophy.name,"%d  •  P%d"%[trophy.year,trophy.position],78))
	heading("HISTORIQUE CARRIÈRE",22)
	for season in GameState.data.career_history:content.add_child(card("%d  •  %s"%[season.year,season.championship],"P%d  •  %d PTS  •  %d VICTOIRE(S)"%[season.position,season.points,season.wins],85))

func show_season_end() -> void:
	clear("SAISON TERMINÉE")
	var rows:=GameState.sorted_standings();var position:=1
	for i in rows.size():
		if rows[i].player:
			position=i+1
			break
	var player:Dictionary=GameState.data.standings[0];heading("SAISON TERMINÉE",31)
	if position<=3:
		var trophy:=TextureRect.new();trophy.texture=load("res://graphics/championship/regional_kart_series/trophy_regional_kart_series.svg");trophy.custom_minimum_size.y=220;trophy.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;trophy.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;content.add_child(trophy)
	content.add_child(card("CHAMPIONNAT • P%d"%position,"%d PTS • %d VICTOIRES • %d PODIUMS • %d MEILLEURS TOURS\n%s € GAGNÉS • %d XP • +%d RÉPUTATION"%[player.points,player.wins,player.podiums,player.fastest_laps,money(GameState.data.season_income),GameState.data.season_xp,GameState.data.season_reputation],155));content.add_child(button("VOIR LES OFFRES",show_offers))

func show_offers() -> void:
	clear("NOUVELLE OPPORTUNITÉ");heading("CHOIX DE CARRIÈRE",28)
	for offer in GameState.data.offers:
		var state:="DISPONIBLE" if offer.eligible else "CONDITIONS NON REMPLIES"
		var b:=button(offer.title+"\n"+state+" • COÛT "+money(offer.cost)+" € • OBJECTIF "+offer.objective,func(id=offer.id):accept_career_offer(id));b.disabled=not offer.eligible;content.add_child(b)
	content.add_child(button("REFUSER POUR LE MOMENT",show_dashboard))

func accept_career_offer(id:String) -> void:
	if GameState.accept_offer(id):show_dashboard()
	else:toast("Offre indisponible ou solde insuffisant")

func show_settings() -> void:
	clear("PARAMÈTRES"); heading("AUDIO & JEU", 24)
	for key in ["master", "music", "sfx"]:
		label(key.to_upper(), colors.muted, 12); var slider := HSlider.new(); slider.min_value = 0; slider.max_value = 100; slider.value = GameState.data.settings.get(key, 80); slider.custom_minimum_size.y = 48; slider.value_changed.connect(func(v, k = key): GameState.data.settings[k] = int(v); GameState.save_game()); content.add_child(slider)
	content.add_child(button("NOUVELLE CARRIÈRE / EFFACER", confirm_reset))

func confirm_reset() -> void:
	var dialog:=ConfirmationDialog.new(); dialog.title="NOUVELLE CARRIÈRE"; dialog.dialog_text="Toute la progression actuelle sera définitivement supprimée."; dialog.ok_button_text="EFFACER ET RECOMMENCER"; add_child(dialog); dialog.confirmed.connect(func():GameState.reset_save();creation_draft.clear();creation_step=0;show_welcome()); dialog.popup_centered(Vector2i(480,240))

func heading(text: String, size_px: int) -> Label: var l := label(text, colors.text, size_px); l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; return l
func label(text: String, color: Color, size_px: int) -> Label: var l := Label.new(); l.text = text; l.add_theme_color_override("font_color", color); l.add_theme_font_size_override("font_size", size_px); l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; content.add_child(l); return l
func button(text: String, callable: Callable, compact := false) -> Button: var b := Button.new(); b.text = text; b.custom_minimum_size = Vector2(0, 48 if compact else 58); b.pressed.connect(callable); return b
func card(top: String, bottom: String, height: float) -> PanelContainer:
	var p := PanelContainer.new(); p.custom_minimum_size = Vector2(0, height); p.size_flags_horizontal = Control.SIZE_EXPAND_FILL; var style := StyleBoxFlat.new(); style.bg_color = colors.panel; style.border_color = Color(0.12, 0.35, 0.38, 0.7); style.set_border_width_all(1); style.set_corner_radius_all(16); style.content_margin_left = 18; style.content_margin_right = 18; style.content_margin_top = 15; style.content_margin_bottom = 15; p.add_theme_stylebox_override("panel", style)
	var v := VBoxContainer.new(); p.add_child(v); var a := Label.new(); a.text = top; a.add_theme_font_size_override("font_size", 18); a.add_theme_color_override("font_color", colors.text); a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; v.add_child(a); var b := Label.new(); b.text = bottom; b.add_theme_font_size_override("font_size", 15); b.add_theme_color_override("font_color", colors.accent); b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; v.add_child(b); return p
func toast(text: String) -> void: notice.text = text
func money(value) -> String: return str(int(value))
func set_navigation_enabled(enabled: bool) -> void:
	for child in nav.get_children(): child.disabled = not enabled
