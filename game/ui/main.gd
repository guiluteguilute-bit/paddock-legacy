extends Control

var content: VBoxContainer
var nav: HBoxContainer
var title: Label
var subtitle: Label
var notice: Label
var scroll: ScrollContainer
var race_view: RaceView
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
	for child in content.get_children(): child.queue_free()
	scroll.scroll_vertical = 0
	title.text = "PADDOCK LEGACY"
	subtitle.text = page_title + (("  •  " + GameState.data.get("team", {}).get("name", "").to_upper()) if GameState.has_career() else "")
	notice.text = ("SAISON %d  •  %s €  •  RÉP. %d  •  ÉNERGIE %s/5" % [GameState.data.get("career_year", 2026), money(GameState.data.get("money", 0)), GameState.data.get("reputation", 0), GameState.data.get("energy", 0)]) if GameState.has_career() else "GODOT • PORTRAIT • WEB"

func show_welcome() -> void:
	clear("BIENVENUE"); heading("BÂTISSEZ VOTRE LÉGENDE", 31); label("DU KARTING À FORMULA APEX", colors.accent, 15)
	var hero := TextureRect.new(); hero.texture = load("res://graphics/ui/backgrounds/main_menu_garage.svg"); hero.custom_minimum_size.y = 330; hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; content.add_child(hero)
	label("Management automobile, stratégie et retransmission miniature 2.5D.", colors.muted, 17)
	content.add_child(button("CRÉER UNE ÉCURIE", show_creation))
	if FileAccess.file_exists(GameState.SAVE_PATH): content.add_child(button("REPRENDRE LA CARRIÈRE", func(): GameState.load_game(); show_dashboard()))
	set_navigation_enabled(false)

func show_creation() -> void:
	clear("NOUVELLE CARRIÈRE"); heading("ÉCURIE & PILOTE", 25)
	var fields := {}
	for entry in [["team", "NOM DE L'ÉCURIE", "Nova Kart Racing"], ["nationality", "NATIONALITÉ", "France"], ["first", "PRÉNOM", "Noa"], ["last", "NOM", "Morel"], ["number", "NUMÉRO", "27"]]:
		label(entry[1], colors.muted, 12); var edit := LineEdit.new(); edit.text = entry[2]; edit.custom_minimum_size.y = 52; fields[entry[0]] = edit; content.add_child(edit)
	content.add_child(button("COMMENCER EN KARTING", func():
		if fields.team.text.strip_edges().is_empty() or fields.first.text.strip_edges().is_empty() or fields.last.text.strip_edges().is_empty(): toast("Tous les noms sont requis"); return
		GameState.new_career({"name": fields.team.text, "nationality": fields.nationality.text, "colors": ["#19dcc6", "#102a38", "#ffcf4a"], "logo": "apex_nova"}, {"first_name": fields.first.text, "last_name": fields.last.text, "nationality": fields.nationality.text, "number": int(fields.number.text), "appearance": 0, "stats": {"speed": 58, "control": 61, "mental": 57}}); show_dashboard()))

func show_dashboard() -> void:
	if not GameState.has_career(): show_welcome(); return
	set_navigation_enabled(true); clear("ACCUEIL")
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

func show_more() -> void:
	clear("PLUS"); heading("GESTION DE L'ÉCURIE", 24)
	for item in [["VÉHICULE & DÉVELOPPEMENT", show_vehicle], ["FINANCES & SPONSORS", show_finance], ["CALENDRIER", show_calendar], ["CHAMPIONNAT", show_championship], ["PARAMÈTRES", show_settings]]: content.add_child(button(item[0] + "  ›", item[1]))

func show_calendar() -> void:
	clear("CALENDRIER"); heading("SAISON %d" % GameState.data.career_year, 24)
	for i in GameState.data.calendar.size():
		var e: Dictionary = GameState.data.calendar[i]; content.add_child(card("M%02d  •  %s" % [i + 1, e.track.to_upper()], "%s  •  %d TOURS  •  %s" % [e.date, e.laps, e.status], 80))

func show_championship() -> void:
	clear("CHAMPIONNAT"); heading("CLASSEMENT PILOTES", 24); var points := 0
	for race in GameState.data.race_history: points += [25, 18, 15, 12, 10, 8, 6, 4, 2, 1][mini(int(race.position) - 1, 9)] if int(race.position) <= 10 else 0
	content.add_child(card("VOTRE PILOTE", "%d PTS  •  %d COURSE(S)" % [points, GameState.data.race_history.size()], 100))

func show_vehicle() -> void:
	clear("VÉHICULE"); var kart: Dictionary = GameState.data.vehicles.kart; heading("KART N%d  •  FIABILITÉ %d%%" % [kart.level, kart.reliability], 23)
	var image := TextureRect.new(); image.texture = load("res://graphics/cars/kart/car_kart_01.svg"); image.custom_minimum_size.y = 230; image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; content.add_child(image)
	for component in ["engine", "chassis", "brakes"]:
		var cost := 1500 * int(kart.components[component]); content.add_child(button("%s N%d → N%d  •  %s €" % [component.to_upper(), kart.components[component], int(kart.components[component]) + 1, money(cost)], func(c = component, p = cost): buy_vehicle_upgrade(c, p)))

func buy_vehicle_upgrade(component: String, cost: int) -> void:
	if not GameState.buy_upgrade(component, cost): toast("Solde insuffisant")
	else: show_vehicle()

func show_finance() -> void:
	clear("FINANCES"); heading("SOLDE  %s €" % money(GameState.data.money), 28)
	for tx in GameState.data.transactions: content.add_child(card(tx.label, ("+" if int(tx.amount) >= 0 else "") + money(tx.amount) + " €", 68))

func show_race_prep() -> void:
	clear("COURSE")
	if int(GameState.data.race_index) >= GameState.data.calendar.size(): heading("SAISON TERMINÉE", 28); return
	var event: Dictionary = GameState.data.calendar[GameState.data.race_index]; heading(event.track.to_upper(), 28); content.add_child(card("PROCHAINE MANCHE", "%d TOURS  •  PLUIE %d%%  •  OBJECTIF TOP %d" % [event.laps, int(event.weather_probability * 100), GameState.data.objectives.race.target], 110))
	if int(GameState.data.energy) <= 0: label("ÉNERGIE INSUFFISANTE", colors.danger, 18); return
	content.add_child(button("OUVRIR LA SESSION  ›", func(): GameState.save_game(); open_race(event)))

func open_race(event: Dictionary) -> void:
	clear("LIVE • " + event.track.to_upper()); race_view = RaceView.new(); race_view.custom_minimum_size = Vector2(0, 570); race_view.setup(GameState.data.driver.first_name + " " + GameState.data.driver.last_name, event.laps, event.weather_probability); race_view.finished.connect(_race_finished); content.add_child(race_view)
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
	GameState.complete_race(result); clear("RÉSULTATS"); heading("DRAPEAU À DAMIER", 18); heading("P%d" % result.position, 52); content.add_child(card("DÉPART P%d  →  ARRIVÉE P%d" % [12, result.position], "MEILLEUR TOUR %.3f s\nARGENT +%s €  •  XP +%d" % [money(maxi(250, 1800 - (int(result.position) - 1) * 150)), 120 + maxi(0, 11 - int(result.position)) * 20], 145)); content.add_child(button("CONTINUER", show_dashboard))

func show_settings() -> void:
	clear("PARAMÈTRES"); heading("AUDIO & JEU", 24)
	for key in ["master", "music", "sfx"]:
		label(key.to_upper(), colors.muted, 12); var slider := HSlider.new(); slider.min_value = 0; slider.max_value = 100; slider.value = GameState.data.settings.get(key, 80); slider.custom_minimum_size.y = 48; slider.value_changed.connect(func(v, k = key): GameState.data.settings[k] = int(v); GameState.save_game()); content.add_child(slider)
	content.add_child(button("EFFACER LA SAUVEGARDE", func(): GameState.reset_save(); show_welcome()))

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
