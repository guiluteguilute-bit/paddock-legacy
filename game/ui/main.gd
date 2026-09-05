extends Control

var content: VBoxContainer
var nav: HBoxContainer
var title: Label
var subtitle: Label
var notice: Label
var scroll: ScrollContainer
var race_view: RaceView
var creation_step = 0
var creation_draft: Dictionary = {}
var creation_controls: Dictionary = {}
var manager_swipe_start_x: float = -1.0
var manager_preview_mode: bool = false
var shell_background: TextureRect
var shell_tint: ColorRect
const MANAGER_AVATAR_CARD := preload("res://game/ui/components/manager_avatar_card.gd")
const MANAGER_STATS_CARD := preload("res://game/ui/components/manager_stats_card.gd")
const MANAGER_UI_HELPERS := preload("res://game/ui/components/manager_ui_helpers.gd")
const UI_ICON_ATLAS := preload("res://game/ui/components/ui_icon_atlas.gd")
const MANAGER_UI_DIR := "res://graphics/ui/manager_selection/cartoon/"
const CREATION_STEPS := ["GÉRANT", "ÉCURIE", "DÉPART"]
const TEAM_LOGOS := ["apex_nova", "crimson_orbit", "ember_fox", "helix_racing", "kinetic_arc", "lumen_motorsport", "meridian_kart", "northstar", "pulse_competition", "silver_finch", "vector_peak", "vertex_union"]
const TEAM_LOGO_PATHS := ["res://graphics/logos/logo_team_apex_nova.svg", "res://graphics/logos/logo_team_crimson_orbit.svg", "res://graphics/logos/logo_team_ember_fox.svg", "res://graphics/logos/logo_team_helix_racing.svg", "res://graphics/logos/logo_team_kinetic_arc.svg", "res://graphics/logos/logo_team_lumen_motorsport.svg", "res://graphics/logos/logo_team_meridian_kart.svg", "res://graphics/logos/logo_team_northstar.svg", "res://graphics/logos/logo_team_pulse_competition.svg", "res://graphics/logos/logo_team_silver_finch.svg", "res://graphics/logos/logo_team_vector_peak.svg", "res://graphics/logos/logo_team_vertex_union.svg"]
const MANAGER_ORDER := ["alex", "maya", "ethan", "sofia", "marcus"]
const MANAGER_AVATARS := {
	"alex":"res://graphics/portraits/managers/premium/alex_avatar.png",
	"maya":"res://graphics/portraits/managers/premium/maya_avatar.png",
	"ethan":"res://graphics/portraits/managers/premium/ethan_avatar.png",
	"sofia":"res://graphics/portraits/managers/premium/sofia_avatar.png",
	"marcus":"res://graphics/portraits/managers/premium/marcus_avatar.png"
}
const MANAGER_PRESENTATIONS := {
	"alex":"res://graphics/portraits/managers/premium/alex_presentation.png",
	"maya":"res://graphics/portraits/managers/premium/maya_presentation.png",
	"ethan":"res://graphics/portraits/managers/premium/ethan_presentation.png",
	"sofia":"res://graphics/portraits/managers/premium/sofia_presentation.png",
	"marcus":"res://graphics/portraits/managers/premium/marcus_presentation.png"
}
const TEAM_PALETTES := [["#19dcc6","#102a38","#ffcf4a"],["#ff4d5e","#25152f","#f8f3e8"],["#5f7cff","#101b3d","#f7cc46"],["#ff7a35","#241910","#fff0d2"],["#b56cff","#211534","#53f3d3"],["#36c66d","#10291d","#f6dc5e"],["#eeeeee","#20252c","#e53636"],["#e9c46a","#153047","#f7f5ef"]]
var colors = {"bg": Color("071117"), "panel": Color("10232c"), "panel_2": Color("162f39"), "accent": Color("19dcc6"), "gold": Color("ffcc58"), "text": Color("eff7f5"), "muted": Color("91a8aa"), "danger": Color("ff6b65")}

func _ready() -> void:
	print("[BOOT] Paddock Legacy starting")
	build_shell()
	get_viewport().size_changed.connect(_apply_safe_area)
	if GameState.creation_config.is_empty() or GameState.career_config.is_empty():
		show_boot_error("BOOT_DATA_001", "Configuration de carrière indisponible")
		return
	if GameState.has_career():
		print("[BOOT] Onboarding state = dashboard")
		show_dashboard()
	else:
		print("[BOOT] Onboarding state = manager_selection")
		show_creation()
	print("[BOOT] Main UI ready")

func build_shell() -> void:
	shell_background = TextureRect.new(); shell_background.texture = load("res://graphics/ui/backgrounds/main_menu_garage.svg"); shell_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); shell_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; shell_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; shell_background.modulate = Color(0.42, 0.50, 0.58, 0.34); shell_background.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(shell_background)
	shell_tint = ColorRect.new(); shell_tint.color = Color(0.027, 0.067, 0.09, 0.90); shell_tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); shell_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(shell_tint)
	var glow = ColorRect.new(); glow.color = Color(0.04, 0.28, 0.27, 0.16); glow.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE); glow.custom_minimum_size.y = 270; add_child(glow)
	var safe = MarginContainer.new(); safe.name = "SafeArea"; safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); add_child(safe)
	var root = VBoxContainer.new(); root.add_theme_constant_override("separation", 12); safe.add_child(root)
	var header = VBoxContainer.new(); header.add_theme_constant_override("separation", 0); root.add_child(header)
	title = Label.new(); title.text = "PADDOCK LEGACY"; title.add_theme_font_size_override("font_size", 27); title.add_theme_color_override("font_color", colors.text); header.add_child(title)
	subtitle = Label.new(); subtitle.add_theme_font_size_override("font_size", 13); subtitle.add_theme_color_override("font_color", colors.accent); header.add_child(subtitle)
	notice = Label.new(); notice.add_theme_font_size_override("font_size", 12); notice.add_theme_color_override("font_color", colors.gold); notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; header.add_child(notice)
	scroll = ScrollContainer.new(); scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL; scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; root.add_child(scroll)
	content = VBoxContainer.new(); content.size_flags_horizontal = Control.SIZE_EXPAND_FILL; content.add_theme_constant_override("separation", 12); scroll.add_child(content)
	nav = HBoxContainer.new(); nav.name = "MobileBottomNavigation"; nav.add_theme_constant_override("separation", 5); root.add_child(nav)
	for item in [["ACCUEIL", "accueil", show_dashboard], ["CARRIÈRE", "classements", show_career], ["COURSE", "courses", show_race_prep], ["ÉCURIE", "equipe", show_team], ["PLUS", "parametres", show_more]]:
		var b = button(item[0], item[2], true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; b.custom_minimum_size = Vector2(0, 64)
		var icon: Texture2D = UI_ICON_ATLAS.get_icon(item[1])
		if icon != null: b.icon = icon; b.icon_max_width = 42; b.expand_icon = true
		nav.add_child(b)
	_apply_safe_area()

func _apply_safe_area() -> void:
	var safe = get_node_or_null("SafeArea") as MarginContainer
	if safe == null: return
	# Conservative fallback protects notches and the home indicator on Web, where OS safe-area data is unavailable.
	var top = 28; var bottom = 22; var side = 18
	var screen_safe = DisplayServer.get_display_safe_area()
	if screen_safe.size.x > 0 and DisplayServer.window_get_size().x > 0:
		var scale = size.x / float(DisplayServer.window_get_size().x)
		top = maxi(top, int(screen_safe.position.y * scale)); side = maxi(side, int(screen_safe.position.x * scale))
		bottom = maxi(bottom, int((DisplayServer.window_get_size().y - screen_safe.end.y) * scale))
	safe.add_theme_constant_override("margin_left", side); safe.add_theme_constant_override("margin_right", side); safe.add_theme_constant_override("margin_top", top); safe.add_theme_constant_override("margin_bottom", bottom)

func clear(page_title: String) -> void:
	_set_manager_background(false)
	if GameState.has_career() and GameState.data.team.get("colors", []).size() >= 3:
		colors.accent = Color(GameState.data.team.colors[2])
	for child in content.get_children(): child.queue_free()
	scroll.scroll_vertical = 0
	title.text = "PADDOCK LEGACY"
	subtitle.text = page_title + (("  •  " + GameState.data.get("team", {}).get("name", "").to_upper()) if GameState.has_career() else "")
	notice.text = ("SAISON %d  •  %s €  •  RÉP. %d  •  ÉNERGIE %s/5" % [GameState.data.get("career_year", 2026), money(GameState.data.get("money", 0)), GameState.data.get("reputation", 0), GameState.data.get("energy", 0)]) if GameState.has_career() else "GODOT • PORTRAIT • WEB"

func _set_manager_background(enabled: bool) -> void:
	if shell_background == null or shell_tint == null:
		return
	var cartoon := MANAGER_UI_DIR + "ui_manager_bg.jpg"
	if enabled and ResourceLoader.exists(cartoon):
		shell_background.texture = load(cartoon)
		shell_background.modulate = Color(0.90, 0.95, 1.0, 0.88)
		shell_tint.color = Color(0.01, 0.025, 0.04, 0.48)
	else:
		shell_background.texture = load("res://graphics/ui/backgrounds/main_menu_garage.svg")
		shell_background.modulate = Color(0.42, 0.50, 0.58, 0.34)
		shell_tint.color = Color(0.027, 0.067, 0.09, 0.90)

func show_boot_error(error_id: String, detail: String) -> void:
	push_error("[BOOT] %s: %s" % [error_id, detail])
	clear("ERREUR %s" % error_id)
	heading("IMPOSSIBLE DE CHARGER LE JEU.", 26)
	label(detail, colors.danger, 15)
	content.add_child(button("RÉESSAYER", func(): get_tree().reload_current_scene()))
	set_navigation_enabled(false)

func show_creation() -> void:
	manager_preview_mode = false
	if creation_draft.is_empty():
		creation_draft = {"manager":"alex","team_name":"Nova Racing","short_name":"NOVA","country":"France","team_number":27,"colors":TEAM_PALETTES[0].duplicate(),"logo_preset":0,"livery_pattern":0,"driver_variant":0}
	creation_step = clampi(creation_step, 0, 2)
	show_creation_step()

func show_creation_step() -> void:
	clear(creation_progress()); set_navigation_enabled(false); creation_controls.clear()
	match creation_step:
		0: creation_manager()
		1: creation_team()
		2: creation_summary()

func creation_progress() -> String:
	var dots: Array[String] = []
	for i in 3: dots.append("●" if i <= creation_step else "○")
	return "  ".join(dots)

func creation_manager() -> void:
	_set_manager_background(true)
	heading("CHOISISSEZ VOTRE GÉRANT", 28)
	label("Cinq profils. Une seule vision pour votre écurie.", colors.muted, 14)
	if manager_preview_mode:
		label("MODE APERÇU • VOTRE SAUVEGARDE N’EST PAS MODIFIÉE", colors.gold, 12)
	var managers: Dictionary = GameState.creation_config.get("managers", {})
	var ids: Array[String] = []
	for id in MANAGER_ORDER:
		if managers.has(id): ids.append(id)
	if ids.is_empty():
		label("Aucun gérant disponible.", colors.danger, 16)
		return
	if not ids.has(str(creation_draft.manager)): creation_draft.manager = ids[0]
	var selected := maxi(0, ids.find(str(creation_draft.manager)))
	var manager: Dictionary = managers[ids[selected]]

	var chooser := HBoxContainer.new()
	chooser.add_theme_constant_override("separation", 8)
	chooser.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(chooser)
	for i in ids.size():
		var manager_id: String = ids[i]
		var item: Dictionary = managers[manager_id]
		var avatar_card = MANAGER_AVATAR_CARD.new()
		avatar_card.setup(manager_id, item, MANAGER_AVATARS[manager_id], i == selected)
		avatar_card.chosen.connect(func(id): creation_draft.manager = id; show_creation_step())
		chooser.add_child(avatar_card)

	var stage := Control.new()
	stage.custom_minimum_size.y = 620
	stage.mouse_filter = Control.MOUSE_FILTER_STOP
	stage.gui_input.connect(_manager_stage_input)
	content.add_child(stage)
	var stage_glow := ColorRect.new()
	stage_glow.color = Color(0.02, 0.34, 0.50, 0.14)
	stage_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_glow.offset_left = 190; stage_glow.offset_right = -190
	stage_glow.offset_top = 45; stage_glow.offset_bottom = -45
	stage_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(stage_glow)
	var presentation := TextureRect.new()
	presentation.texture = load(MANAGER_PRESENTATIONS[ids[selected]])
	presentation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	presentation.offset_left = 245; presentation.offset_right = -245
	presentation.offset_top = 30; presentation.offset_bottom = -36
	presentation.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	presentation.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	presentation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	presentation.modulate = Color(1, 1, 1, 0.18)
	stage.add_child(presentation)
	var frame_texture: Texture2D = MANAGER_UI_HELPERS.texture(MANAGER_UI_DIR + "ui_character_frame.png")
	if frame_texture != null:
		var frame := TextureRect.new()
		frame.texture = frame_texture
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame.offset_left = 220; frame.offset_right = -220
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage.add_child(frame)
	var reveal := create_tween()
	reveal.tween_property(presentation, "modulate", Color.WHITE, 0.18)

	var arrows := HBoxContainer.new()
	arrows.add_theme_constant_override("separation", 10)
	content.add_child(arrows)
	var previous := MANAGER_UI_HELPERS.game_button("<", 72)
	previous.custom_minimum_size.x = 78
	previous.pressed.connect(func(): _cycle_manager(-1))
	arrows.add_child(previous)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arrows.add_child(identity)
	var alex_plate: Texture2D = MANAGER_UI_HELPERS.texture(MANAGER_UI_DIR + "ui_name_plate_alex.png")
	if ids[selected] == "alex" and alex_plate != null:
		var plate := TextureRect.new()
		plate.texture = alex_plate
		plate.custom_minimum_size.y = 108
		plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		plate.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		identity.add_child(plate)
	else:
		var manager_name := Label.new()
		manager_name.text = str(manager.first_name).to_upper()
		manager_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		manager_name.add_theme_font_size_override("font_size", 28)
		manager_name.add_theme_color_override("font_color", colors.text)
		identity.add_child(manager_name)
		var role := Label.new()
		role.text = str(manager.title).trim_prefix("Le ").trim_prefix("La ").to_upper()
		role.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		role.add_theme_font_size_override("font_size", 15)
		role.add_theme_color_override("font_color", colors.gold)
		identity.add_child(role)
	var specialty: Texture2D = MANAGER_UI_HELPERS.specialty(ids[selected])
	if specialty != null:
		var badge := TextureRect.new()
		badge.texture = specialty
		badge.custom_minimum_size.y = 60
		badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		identity.add_child(badge)
	var following := MANAGER_UI_HELPERS.game_button(">", 72)
	following.custom_minimum_size.x = 78
	following.pressed.connect(func(): _cycle_manager(1))
	arrows.add_child(following)

	var stats_card = MANAGER_STATS_CARD.new()
	stats_card.setup(manager)
	content.add_child(stats_card)
	var effects := HBoxContainer.new()
	effects.add_theme_constant_override("separation", 18)
	content.add_child(effects)
	var advantages: Array = manager.get("advantages", [])
	var drawbacks: Array = manager.get("drawbacks", [])
	for effect in [["+ " + (str(advantages[0]) if not advantages.is_empty() else "Profil équilibré"), Color("79f19b")], ["- " + (str(drawbacks[0]) if not drawbacks.is_empty() else "Aucun inconvénient majeur"), Color("ff665d")]]:
		var effect_label := Label.new()
		effect_label.text = effect[0]
		effect_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		effect_label.add_theme_font_size_override("font_size", 13)
		effect_label.add_theme_color_override("font_color", effect[1])
		effects.add_child(effect_label)

	var dots := Label.new()
	dots.text = "%d / %d" % [selected + 1, ids.size()]
	dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dots.add_theme_color_override("font_color", colors.gold)
	content.add_child(dots)
	var choose_text := "RETOUR AUX PARAMÈTRES" if manager_preview_mode else "CHOISIR %s" % str(manager.first_name).to_upper()
	var choose := MANAGER_UI_HELPERS.game_button(choose_text, 78)
	choose.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if manager_preview_mode:
		choose.pressed.connect(func(): manager_preview_mode = false; show_settings())
	else:
		choose.pressed.connect(func(): creation_step = 1; show_creation_step())
	content.add_child(choose)

func _cycle_manager(delta: int) -> void:
	var managers: Dictionary = GameState.creation_config.get("managers", {})
	var ids: Array[String] = []
	for id in MANAGER_ORDER:
		if managers.has(id): ids.append(id)
	if ids.is_empty(): return
	var selected := maxi(0, ids.find(str(creation_draft.manager)))
	creation_draft.manager = ids[(selected + delta + ids.size()) % ids.size()]
	show_creation_step()

func _manager_stage_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			manager_swipe_start_x = event.position.x
		elif manager_swipe_start_x >= 0.0:
			var delta: float = event.position.x - manager_swipe_start_x
			manager_swipe_start_x = -1.0
			if abs(delta) >= 80.0: _cycle_manager(-1 if delta > 0.0 else 1)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			manager_swipe_start_x = event.position.x
		elif manager_swipe_start_x >= 0.0:
			var mouse_delta: float = event.position.x - manager_swipe_start_x
			manager_swipe_start_x = -1.0
			if abs(mouse_delta) >= 80.0: _cycle_manager(-1 if mouse_delta > 0.0 else 1)

func creation_team() -> void:
	heading("CRÉEZ VOTRE ÉCURIE", 28)
	add_kart_preview(300)
	var edit = LineEdit.new(); edit.text = creation_draft.team_name; edit.placeholder_text = "NOM DE L'ÉCURIE"; edit.max_length = 24; edit.custom_minimum_size.y = 58; edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.text_changed.connect(func(value): creation_draft.team_name = value; creation_draft.short_name = value.left(10).to_upper())
	content.add_child(edit)
	label("PALETTE", colors.muted, 12); var palette_grid = GridContainer.new(); palette_grid.columns = 4; content.add_child(palette_grid)
	for i in TEAM_PALETTES.size():
		var palette = TEAM_PALETTES[i]; var palette_button = button(("✓ " if creation_draft.colors == palette else "") + "● ● ●", func(): creation_draft.colors = TEAM_PALETTES[i].duplicate(); show_creation_step(), true)
		palette_button.add_theme_color_override("font_color", Color(palette[0])); palette_grid.add_child(palette_button)
	label("LOGO", colors.muted, 12); var logo_grid = GridContainer.new(); logo_grid.columns = 6; content.add_child(logo_grid)
	for i in TEAM_LOGOS.size():
		var logo_button = TextureButton.new(); logo_button.texture_normal = load(TEAM_LOGO_PATHS[i]); logo_button.ignore_texture_size = true; logo_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED; logo_button.custom_minimum_size = Vector2(76, 76); logo_button.modulate = colors.accent if i == int(creation_draft.logo_preset) else Color.WHITE
		logo_button.pressed.connect(func(): creation_draft.logo_preset = i; show_creation_step()); logo_grid.add_child(logo_button)
	choice_buttons("LIVRÉE", ["UNI","BANDE","DIAGONALE","RACING","GÉOMÉTRIQUE"], "livery_pattern")
	var row = HBoxContainer.new(); content.add_child(row); var back = button("‹ RETOUR", func(): creation_step = 0; show_creation_step()); back.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(back)
	var next = button("CONTINUER ›", func():
		if not str(creation_draft.team_name).strip_edges().is_empty(): creation_step = 2; show_creation_step()
		else: toast("Donnez un nom à votre écurie")); next.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(next)

func add_kart_preview(height: int) -> void:
	var preview = LiveryPreview.new(); preview.custom_minimum_size = Vector2(0, height); preview.set_livery(creation_draft.colors, creation_draft.livery_pattern); content.add_child(preview); creation_controls.preview = preview

func creation_summary() -> void:
	var manager: Dictionary = GameState.creation_config.managers[creation_draft.manager]
	heading("VOTRE AVENTURE COMMENCE", 27)
	var portrait = TextureRect.new(); portrait.texture = load(MANAGER_PRESENTATIONS[creation_draft.manager]); portrait.custom_minimum_size.y = 245; portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; content.add_child(portrait)
	heading(manager.name.to_upper(), 21)
	var logo = TextureRect.new(); logo.texture = load(TEAM_LOGO_PATHS[int(creation_draft.logo_preset)]); logo.custom_minimum_size.y = 105; logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; content.add_child(logo)
	heading(creation_draft.team_name.to_upper(), 28); add_kart_preview(225)
	heading("VOTRE HISTOIRE COMMENCE ICI.", 22); label("Un petit garage. Un jeune pilote.\nUn rêve : atteindre les sommets.", colors.muted, 15)
	content.add_child(card("OBJECTIF DE DÉPART", "TERMINER VOTRE PREMIÈRE SAISON", 82))
	var row = HBoxContainer.new(); content.add_child(row); var back = button("‹ MODIFIER", func(): creation_step = 1; show_creation_step()); back.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(back)
	var start = button("COMMENCER LA CARRIÈRE", confirm_creation); start.size_flags_horizontal = Control.SIZE_EXPAND_FILL; row.add_child(start)

func draft_dna() -> Dictionary:
	var manager: Dictionary = GameState.creation_config.managers[creation_draft.manager]
	var dna := GameState.build_team_dna(manager.origin, manager.philosophy, manager.style, "reach_apex", manager.points)
	# Keep legacy identity fields/save compatibility, while the five curated profiles own the balanced effects.
	dna.modifiers = manager.modifiers.duplicate(true)
	dna.advantages = manager.advantages.duplicate()
	dna.drawbacks = manager.drawbacks.duplicate()
	dna.manager_id = creation_draft.manager
	return dna

func stars(value: int) -> String:
	return "★".repeat(value) + "☆".repeat(5 - value)

func choice_buttons(page_title: String, options: Array, key: String, callback: Callable = Callable()) -> void:
	label(page_title, colors.muted, 12); var grid = GridContainer.new(); grid.columns = options.size(); content.add_child(grid)
	for i in options.size():
		var select = func() -> void:
			creation_draft[key] = i
			if callback.is_valid(): callback.call()
			show_creation_step()
		var choice = button(("✓ " if int(creation_draft[key]) == i else "") + options[i], select, true)
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL; grid.add_child(choice)

func confirm_creation() -> void:
	finalize_creation()

func finalize_creation() -> void:
	var starters = [{"first_name":"Noa","last_name":"Martin","stats":{"speed":62,"control":67,"mental":58}},{"first_name":"Lina","last_name":"Diallo","stats":{"speed":65,"control":61,"mental":63}},{"first_name":"Sacha","last_name":"Moreau","stats":{"speed":59,"control":65,"mental":66}}]
	var starter: Dictionary = starters[int(creation_draft.driver_variant) % starters.size()]; var profile: Dictionary = GameState.creation_config.driver_archetypes.worker
	var team = {"name":creation_draft.team_name.strip_edges(),"short_name":creation_draft.short_name,"nationality":"France","country":"France","number":27,"colors":creation_draft.colors.duplicate(),"logo":{"preset":creation_draft.logo_preset,"id":TEAM_LOGOS[int(creation_draft.logo_preset)]},"livery_pattern":creation_draft.livery_pattern,"manager_id":creation_draft.manager}
	var driver = {"first_name":starter.first_name,"last_name":starter.last_name,"nationality":"France","number":27,"age":14,"appearance":int(creation_draft.driver_variant),"helmet":0,"colors":creation_draft.colors.duplicate(),"profile":"worker","hidden_potential":84,"xp_multiplier":profile.xp,"traits":profile.traits.duplicate(true),"stats":starter.stats.duplicate(true)}
	GameState.new_career(team, driver, draft_dna()); creation_draft.clear(); creation_step = 0
	clear("SAISON 1"); heading("LA PORTE DU GARAGE S'OUVRE…", 27); add_kart_preview_transition(); await get_tree().create_timer(0.7).timeout; show_dashboard()

func add_kart_preview_transition() -> void:
	var garage = TextureRect.new(); garage.texture = load("res://graphics/ui/backgrounds/main_menu_garage.svg"); garage.custom_minimum_size.y = 480; garage.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; garage.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; content.add_child(garage)
	heading("KARTING RÉGIONAL", 24)

func show_dashboard() -> void:
	if not GameState.has_career(): show_creation(); return
	set_navigation_enabled(true); clear("ACCUEIL")
	if GameState.data.season_complete:
		show_season_end()
		return
	var event: Dictionary = GameState.data.calendar[GameState.data.race_index] if int(GameState.data.race_index) < GameState.data.calendar.size() else {}
	heading("PROCHAINE COURSE", 16)
	var race_card = card(event.get("track", "SAISON TERMINÉE").to_upper(), "%d TOURS  •  %s  •  ☁ %d%%\nOBJECTIF TOP %d" % [event.get("laps", 0), GameState.data.category, int(event.get("weather_probability", 0.0) * 100), GameState.data.objectives.race.target], 150)
	content.add_child(race_card)
	heading("PILOTE", 16)
	var driver_row = HBoxContainer.new(); content.add_child(driver_row)
	var portrait = TextureRect.new(); portrait.texture = load("res://graphics/portraits/generated/portrait_driver_01.svg"); portrait.custom_minimum_size = Vector2(120, 150); portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; driver_row.add_child(portrait)
	var driver_card = card((GameState.data.driver.first_name + " " + GameState.data.driver.last_name).to_upper(), "NIVEAU %d  •  %d XP\nVIT %d  CTRL %d  MENTAL %d" % [GameState.data.level, GameState.data.experience, GameState.data.driver.stats.speed, GameState.data.driver.stats.control, GameState.data.driver.stats.mental], 150); driver_row.add_child(driver_card)
	heading("OBJECTIFS", 16); content.add_child(card("TOP %d À LA PROCHAINE MANCHE" % GameState.data.objectives.race.target, "+750 €  •  RÉPUTATION", 92))
	content.add_child(button("LANCER LA COURSE  ›", show_race_prep))

func show_career() -> void:
	clear("CARRIÈRE"); heading("DEUX RÊVES. UNE LÉGENDE.", 24)
	content.add_child(card("VOIE MONOPLACE","KART → F4 → REGIONAL → F3 → F2 → FORMULA APEX",92))
	content.add_child(button("EXPLORER LA VOIE GT / ENDURANCE  ›",show_endurance_hub))
	heading("PYRAMIDE MONOPLACE", 20)
	var championships = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/championships.json"))
	for c in championships:
		var unlocked = int(GameState.data.reputation) >= int(c.minimum_reputation); content.add_child(card(("DÉBLOQUÉ  •  " if unlocked else "VERROUILLÉ  •  ") + c.name, "RÉPUTATION %d  •  %s €" % [c.minimum_reputation, money(c.entry_cost)], 78))

func show_endurance_hub() -> void:
	clear("GT / ENDURANCE");heading("LA DEUXIÈME VOIE",28)
	var logo =TextureRect.new();logo.texture=load("res://graphics/logos/logo_world_endurance_series.svg");logo.custom_minimum_size.y=150;logo.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;logo.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;content.add_child(logo)
	label("KART → GT4 → GT3 → WORLD ENDURANCE → HYPERCAR → LEGACY 24",colors.gold,16)
	content.add_child(card("CARRIÈRE %s"%GameState.data.career_path,"PRESTIGE %d  •  %d VOITURE(S) GT  •  %d/3 PILOTES"%[GameState.data.prestige,GameState.data.owned_gt_cars.size(),GameState.data.driver_roster.size()],105))
	var choose =button("CHOISIR GT / ENDURANCE COMME OBJECTIF",func():GameState.choose_career_path("GT_ENDURANCE");show_endurance_hub());choose.disabled=GameState.data.career_path=="GT_ENDURANCE";content.add_child(choose)
	heading("CHAMPIONNATS FICTIFS",19)
	for series in GameState.endurance_config.series:
		var unlocked =int(GameState.data.reputation)>=int(series.minimum_reputation)
		content.add_child(card(("DÉBLOQUÉ" if unlocked else "RÉP. %d REQUISE"%series.minimum_reputation)+"  •  "+series.name.to_upper(),"%s  •  %s MIN SIMULÉES  •  PRESTIGE %d"%[series.class,series.duration_minutes,series.prestige],88))
	content.add_child(button("CONCESSION GT  ›",show_gt_dealership))
	content.add_child(button("STRATÉGIE ENDURANCE  ›",show_endurance_strategy))

func show_gt_dealership() -> void:
	clear("CONCESSION GT");heading("PERFORMANCE BALANCE SYSTEM",22);label("Poids, puissance, consommation et réservoir sont pilotés par les données de chaque modèle.",colors.muted,14)
	for car in GameState.endurance_config.cars:
		if car.class not in ["GT4","GT3"]:continue
		var owned =GameState.data.owned_gt_cars.any(func(item):return item.id==car.id)
		var text =("✓ POSSÉDÉE  •  " if owned else "ACHETER  •  ")+car.name.to_upper()+"  •  "+money(car.price)+" €\n"+car.layout+"  •  "+car.identity.to_upper()+"\nPUI %d  VIR %d  PNEUS %d  FIAB %d"%[car.power,car.cornering,car.tyre_care,car.reliability]
		var buy =button(text,func(id=car.id):
			if GameState.buy_gt_car(id):show_gt_dealership()
			else:toast("Achat impossible : budget ou modèle déjà acquis"))
		buy.disabled=owned;buy.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;buy.custom_minimum_size.y=125;content.add_child(buy)

func show_endurance_strategy() -> void:
	clear("STRATÉGIE ENDURANCE");heading("HUD PORTRAIT",24)
	content.add_child(card("OVERALL P18  •  GT3 P2","DRIVER 1  •  STINT 35 LAPS  •  FATIGUE 42%\nFUEL 8.2 LAPS  •  MEDIUM 61%  •  PIT WINDOW 6–9",125))
	for item in [["MÉTÉO & LUMIÈRE","JOUR → COUCHER → NUIT → AUBE • SEC → PLUIE → PISTE SÉCHANTE"],["PIT STOP","FUEL • TYRES / DOUBLE STINT • DRIVER CHANGE • QUICK / FULL REPAIR"],["NEUTRALISATION","YELLOW FLAG • FULL COURSE YELLOW • SAFETY CAR • PIT NOW ?"],["SIMULATION","x1 • x2 • x4 • x8 • x16 • SIMULATE TO NEXT EVENT"]]:content.add_child(card(item[0],item[1],82))

func show_team() -> void:
	clear("ÉCURIE"); heading(GameState.data.team.name.to_upper(), 25)
	var image = TextureRect.new(); image.texture = load("res://graphics/parallel/facilities/backgrounds/campus_day.svg"); image.custom_minimum_size.y = 300; image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED; content.add_child(image)
	content.add_child(card("ATELIER N%d" % GameState.data.facilities.workshop, "SIMULATEUR N%d  •  PIT CREW N%d" % [GameState.data.facilities.simulator, GameState.data.facilities.pit_crew], 86))
	var dna:Dictionary=GameState.data.team_dna; heading("HISTORIQUE",18); content.add_child(card("FONDÉE EN %d" % dna.founded_year,"ORIGINE : %s\nPHILOSOPHIE : %s\nFONDATEUR : %s" % [choice_name("origins",dna.origin),choice_name("philosophies",dna.philosophy),choice_name("manager_styles",dna.management_style)],125)); heading("ADN DE L'ÉCURIE",18)
	for domain in GameState.DNA_DOMAINS: label("%-11s  %d  %s" % [domain.to_upper(),dna.ratings[domain],rating_bar(dna.ratings[domain])],colors.accent,14)

func choice_name(section:String,id:String)->String: return GameState.creation_config.get(section,{}).get(id,{}).get("name",id.capitalize())

func show_more() -> void:
	clear("PLUS"); heading("GESTION DE L'ÉCURIE", 24)
	for item in [["GT / ENDURANCE",show_endurance_hub],["DÉVELOPPEMENT PILOTE", show_driver_development], ["VÉHICULE & DÉVELOPPEMENT", show_vehicle], ["SPONSORS", show_sponsors], ["PERSONNEL & INFRASTRUCTURES", show_operations], ["FINANCES", show_finance], ["CALENDRIER", show_calendar], ["CHAMPIONNAT", show_championship], ["PALMARÈS", show_honours], ["PARAMÈTRES", show_settings]]: content.add_child(button(item[0] + "  ›", item[1]))

func show_calendar() -> void:
	clear("CALENDRIER"); heading("SAISON %d" % GameState.data.career_year, 24)
	for i in GameState.data.calendar.size():
		var e: Dictionary = GameState.data.calendar[i]; content.add_child(card("M%02d  •  %s" % [i + 1, e.track.to_upper()], "%s  •  %d TOURS  •  %s" % [e.date, e.laps, e.status], 80))

func show_championship() -> void:
	clear("CHAMPIONNAT"); heading("CLASSEMENT PILOTES", 24)
	var rows: Array = GameState.sorted_standings()
	for i in rows.size():
		var row:Dictionary=rows[i]; content.add_child(card(("★ " if row.player else "")+"P%d  %s"%[i+1,str(row.name).to_upper()], "%d PTS  •  %d V  •  %d PODIUMS  •  %d MT"%[row.points,row.wins,row.podiums,row.fastest_laps], 82))

func show_vehicle() -> void:
	clear("VÉHICULE"); var vehicle:Dictionary=GameState.data.vehicles[GameState.data.category.to_lower()]; heading("%s N%d  •  CONDITION %d%%" % [GameState.data.category,vehicle.level,vehicle.condition], 23)
	if GameState.data.category=="F4":
		var f4 =TextureRect.new();f4.texture=load("res://graphics/cars/f4/car_f4_01.svg");f4.custom_minimum_size.y=230;f4.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;f4.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;content.add_child(f4)
	else:
		var image =LiveryPreview.new();image.custom_minimum_size.y=230;image.set_livery(GameState.data.team.get("colors",["#19dcc6","#102a38","#ffcf4a"]),int(GameState.data.team.get("livery_pattern",0)));content.add_child(image)
	label("FIABILITÉ %d%%"%vehicle.reliability,colors.accent,18)
	content.add_child(button("RÉPARER",repair_from_vehicle))
	for component in vehicle.components:
		var base_cost =1500*int(vehicle.components[component]);var shown_cost =GameState.effective_cost(base_cost,"development");content.add_child(button("%s N%d → N%d  •  %s €  •  3 JOURS"%[component.to_upper(),vehicle.components[component],int(vehicle.components[component])+1,money(shown_cost)],func(c=component,p=base_cost):buy_vehicle_upgrade(c,p)))
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
	heading("ENTRE DEUX COURSES",16);var actions =HBoxContainer.new();content.add_child(actions);for item in [["ENTRAÎNER",func():GameState.train_driver();show_race_prep()],["RÉPARER",func():GameState.repair_vehicle();show_race_prep()],["GARAGE",show_vehicle]]:var a =button(item[0],item[1],true);a.size_flags_horizontal=Control.SIZE_EXPAND_FILL;actions.add_child(a)
	content.add_child(button("OUVRIR LA SESSION  ›", func(): GameState.save_game(); open_race(event)))

func open_race(event: Dictionary) -> void:
	clear("LIVE • " + event.track.to_upper()); race_view = RaceView.new(); race_view.custom_minimum_size = Vector2(0, 570); race_view.setup(GameState.data.driver.first_name + " " + GameState.data.driver.last_name, event.laps, event.weather_probability, GameState.data.category); race_view.finished.connect(_race_finished); content.add_child(race_view)
	var camera = HBoxContainer.new(); content.add_child(camera)
	for mode in ["TV", "PILOTE", "CIRCUIT"]: var b = button(mode, func(m = mode): race_view.set_camera(m), true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; camera.add_child(b)
	var sessions = HBoxContainer.new(); content.add_child(sessions)
	for item in [["QUALIFS", race_view.start_qualifying], ["DÉPART", race_view.start_race]]: var b = button(item[0], item[1], true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; sessions.add_child(b)
	label("RYTHME", colors.muted, 12); var pace = HBoxContainer.new(); content.add_child(pace)
	for mode in ["CONSERVE", "NORMAL", "PUSH", "ATTACK"]: var b = button(mode, func(m = mode): race_view.set_strategy(m), true); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL; b.add_theme_font_size_override("font_size", 11); pace.add_child(b)
	var quick = HBoxContainer.new(); content.add_child(quick)
	for item in [["OVERTAKE", func(): race_view.set_risk("HIGH")], ["DEFEND", func(): race_view.set_risk("LOW")], ["PIT", open_pit_sheet]]: var b = button(item[0], item[1], true); b.size_flags_horizontal=Control.SIZE_EXPAND_FILL; quick.add_child(b)

func open_pit_sheet() -> void:
	var sheet = PanelContainer.new(); sheet.name = "PitStrategySheet"; content.add_child(sheet); content.move_child(sheet, content.get_child_count() - 1)
	var v = VBoxContainer.new(); sheet.add_child(v); var h = Label.new(); h.text = "STRATÉGIE D'ARRÊT"; h.add_theme_font_size_override("font_size", 20); v.add_child(h)
	for tyre in ["SOFT", "MEDIUM", "HARD", "INTERMEDIATE", "WET"]: var b = button(tyre, func(t = tyre): race_view.request_pit(t); sheet.queue_free(), true); v.add_child(b)

func _race_finished(result: Dictionary) -> void:
	GameState.complete_race(result);var saved:Dictionary=GameState.data.race_history[-1];clear("RÉSULTATS");heading("DRAPEAU À DAMIER",18);heading("P%d"%saved.position,52);content.add_child(card("DÉPART P%d  →  ARRIVÉE P%d  •  %+d"%[saved.start_position,saved.position,saved.positions_gained],"MEILLEUR TOUR %.3f s  •  TEMPS %.1f s\nPNEUS %d%%  •  INCIDENTS %d\n%d PTS  •  +%s €  •  +%d XP  •  +%d RÉP."%[saved.best_lap,saved.get("total_time",0.0),saved.get("tyres_remaining",0),saved.incidents.size(),saved.points,money(saved.money),saved.xp,saved.reputation],190));content.add_child(button("CONTINUER",show_dashboard))

func show_driver_development() -> void:
	clear("DÉVELOPPEMENT PILOTE");heading("NIVEAU %d"%GameState.data.level,28);label("%d XP  •  %d POINT(S) DE COMPÉTENCE"%[GameState.data.experience,GameState.data.skill_points],colors.gold,18)
	var estimate =GameState.potential_estimate();content.add_child(card("POTENTIEL ESTIMÉ","%d — %d  •  précision scouting"%[estimate.x,estimate.y],85))
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
	if GameState.data.trophies.is_empty() and GameState.data.endurance_trophies.is_empty():label("Aucun trophée pour le moment.",colors.muted,16)
	for trophy in GameState.data.trophies:content.add_child(card("🏆  "+trophy.name,"%d  •  P%d"%[trophy.year,trophy.position],78))
	for trophy in GameState.data.endurance_trophies:content.add_child(card("🏆  "+str(trophy),"GT / ENDURANCE  •  PRESTIGE PERMANENT",78))
	if not GameState.data.endurance_results.is_empty():
		heading("PALMARÈS ENDURANCE",22)
		for result in GameState.data.endurance_results:content.add_child(card("%d  •  %s"%[result.year,result.series],"OVERALL P%d  •  %s P%d  •  PRESTIGE +%d"%[result.overall_position,result.class,result.class_position,result.prestige],92))
	heading("HISTORIQUE CARRIÈRE",22)
	for season in GameState.data.career_history:content.add_child(card("%d  •  %s"%[season.year,season.championship],"P%d  •  %d PTS  •  %d VICTOIRE(S)"%[season.position,season.points,season.wins],85))

func show_season_end() -> void:
	clear("SAISON TERMINÉE")
	var rows: Array = GameState.sorted_standings();var position =1
	for i in rows.size():
		if rows[i].player:
			position=i+1
			break
	var player:Dictionary=GameState.data.standings[0];heading("SAISON TERMINÉE",31)
	if position<=3:
		var trophy =TextureRect.new();trophy.texture=load("res://graphics/championship/regional_kart_series/trophy_regional_kart_series.svg");trophy.custom_minimum_size.y=220;trophy.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;trophy.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;content.add_child(trophy)
	content.add_child(card("CHAMPIONNAT • P%d"%position,"%d PTS • %d VICTOIRES • %d PODIUMS • %d MEILLEURS TOURS\n%s € GAGNÉS • %d XP • +%d RÉPUTATION"%[player.points,player.wins,player.podiums,player.fastest_laps,money(GameState.data.season_income),GameState.data.season_xp,GameState.data.season_reputation],155));content.add_child(button("VOIR LES OFFRES",show_offers))

func show_offers() -> void:
	clear("NOUVELLE OPPORTUNITÉ");heading("CHOIX DE CARRIÈRE",28)
	for offer in GameState.data.offers:
		var state ="DISPONIBLE" if offer.eligible else "CONDITIONS NON REMPLIES"
		var b =button(offer.title+"\n"+state+" • COÛT "+money(offer.cost)+" € • OBJECTIF "+offer.objective,func(id=offer.id):accept_career_offer(id));b.disabled=not offer.eligible;content.add_child(b)
	content.add_child(button("REFUSER POUR LE MOMENT",show_dashboard))

func accept_career_offer(id:String) -> void:
	if GameState.accept_offer(id):show_dashboard()
	else:toast("Offre indisponible ou solde insuffisant")

func show_manager_preview() -> void:
	manager_preview_mode = true
	if creation_draft.is_empty():
		creation_draft = {"manager":"alex","team_name":"Nova Racing","short_name":"NOVA","country":"France","team_number":27,"colors":TEAM_PALETTES[0].duplicate(),"logo_preset":0,"livery_pattern":0,"driver_variant":0}
	creation_step = 0
	show_creation_step()

func show_settings() -> void:
	clear("PARAMÈTRES"); heading("AUDIO & JEU", 24)
	for key in ["master", "sfx"]:
		label(key.to_upper(), colors.muted, 12); var slider = HSlider.new(); slider.min_value = 0; slider.max_value = 100; slider.value = GameState.data.settings.get(key, 80); slider.custom_minimum_size.y = 48; slider.value_changed.connect(func(v, k = key): GameState.data.settings[k] = int(v); GameState.save_game()); content.add_child(slider)
	label("MUSIQUE", colors.muted, 12)
	var music_slider := HSlider.new(); music_slider.min_value = 0; music_slider.max_value = 100; music_slider.value = GameState.data.settings.get("music_volume", 55); music_slider.custom_minimum_size.y = 48; music_slider.value_changed.connect(AudioManager.set_music_volume); content.add_child(music_slider)
	var music_toggle := CheckButton.new(); music_toggle.text = "MUSIQUE ON / OFF"; music_toggle.button_pressed = GameState.data.settings.get("music_enabled", true); music_toggle.toggled.connect(AudioManager.set_music_enabled); content.add_child(music_toggle)
	content.add_child(button("APERÇU CHOIX DU GÉRANT", show_manager_preview))
	content.add_child(button("NOUVELLE CARRIÈRE / EFFACER", confirm_reset))

func confirm_reset() -> void:
	var dialog =ConfirmationDialog.new(); dialog.title="NOUVELLE CARRIÈRE"; dialog.dialog_text="Toute la progression actuelle sera définitivement supprimée."; dialog.ok_button_text="EFFACER ET RECOMMENCER"; add_child(dialog); dialog.confirmed.connect(func():GameState.reset_save();creation_draft.clear();creation_step=0;show_creation()); dialog.popup_centered(Vector2i(480,240))

func heading(text: String, size_px: int) -> Label: var l = label(text, colors.text, size_px); l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; return l
func label(text: String, color: Color, size_px: int) -> Label: var l = Label.new(); l.text = text; l.add_theme_color_override("font_color", color); l.add_theme_font_size_override("font_size", size_px); l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; content.add_child(l); return l
func button(text: String, callable: Callable, compact := false) -> Button: var b = Button.new(); b.text = text; b.custom_minimum_size = Vector2(0, 48 if compact else 58); b.pressed.connect(callable); return b
func card(top: String, bottom: String, height: float) -> PanelContainer:
	var p = PanelContainer.new(); p.custom_minimum_size = Vector2(0, height); p.size_flags_horizontal = Control.SIZE_EXPAND_FILL; var style = StyleBoxFlat.new(); style.bg_color = colors.panel; style.border_color = Color(0.12, 0.35, 0.38, 0.7); style.set_border_width_all(1); style.set_corner_radius_all(16); style.content_margin_left = 18; style.content_margin_right = 18; style.content_margin_top = 15; style.content_margin_bottom = 15; p.add_theme_stylebox_override("panel", style)
	var v = VBoxContainer.new(); p.add_child(v); var a = Label.new(); a.text = top; a.add_theme_font_size_override("font_size", 18); a.add_theme_color_override("font_color", colors.text); a.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; v.add_child(a); var b = Label.new(); b.text = bottom; b.add_theme_font_size_override("font_size", 15); b.add_theme_color_override("font_color", colors.accent); b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; v.add_child(b); return p
func toast(text: String) -> void: notice.text = text
func money(value) -> String: return str(int(value))
func rating_bar(value: int) -> String:
	var filled := clampi(int(round(float(value) / 10.0)), 0, 10)
	return "█".repeat(filled) + "░".repeat(10 - filled)
func set_navigation_enabled(enabled: bool) -> void:
	nav.visible = enabled
	for child in nav.get_children(): child.disabled = not enabled
