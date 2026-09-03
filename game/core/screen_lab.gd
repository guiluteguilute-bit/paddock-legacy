extends Node

const CATALOG_PATH := "res://game/data/screen_catalog.json"

var _active := false
var _main: Node
var _catalog: Dictionary = {}
var _screens: Array = []
var _original_data: Dictionary = {}
var _demo_data: Dictionary = {}
var _current_index := 0
var _layer: CanvasLayer
var _toolbar: PanelContainer
var _minimized: Button
var _selector: OptionButton
var _status: Label

func _ready() -> void:
	if not _lab_requested():
		return
	_active = true
	call_deferred("_start_lab")

func _web_hash() -> String:
	if not OS.has_feature("web"):
		return ""
	var window = JavaScriptBridge.get_interface("window")
	if window == null:
		return ""
	return str(window.location.hash)

func _lab_requested() -> bool:
	if _web_hash().begins_with("#ui-lab"):
		return true
	for arg in OS.get_cmdline_user_args():
		if arg == "--ui-lab":
			return true
	return false

func _requested_screen_id() -> String:
	var hash = _web_hash().trim_prefix("#")
	var parts = hash.split("/")
	if parts.size() >= 2 and parts[0] == "ui-lab":
		return str(parts[1]).pad_zeros(2)
	for arg in OS.get_cmdline_user_args():
		if str(arg).begins_with("--screen="):
			return str(arg).trim_prefix("--screen=").pad_zeros(2)
	return "01"

func _start_lab() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_main = get_tree().current_scene
	if _main == null or not _main.has_method("clear"):
		push_error("[UI LAB] Main scene unavailable")
		return
	_catalog = _load_catalog()
	_screens = _catalog.get("screens", [])
	if _screens.is_empty():
		push_error("[UI LAB] Screen catalog is empty")
		return
	_original_data = GameState.data.duplicate(true)
	_demo_data = _build_demo_data()
	GameState.data = _original_data.duplicate(true)
	_current_index = _find_screen_index(_requested_screen_id())
	_build_overlay()
	_render_current()
	print("[UI LAB] Ready with %d screens" % _screens.size())

func _load_catalog() -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}

func _find_screen_index(screen_id: String) -> int:
	for i in _screens.size():
		if str(_screens[i].get("id", "")) == screen_id:
			return i
	return 0

func _build_demo_data() -> Dictionary:
	var demo: Dictionary = GameState.defaults()
	demo.team = {"name":"YAKA RACING", "short_name":"YAKA", "nationality":"France", "country":"France", "number":27, "colors":["#19dcc6", "#102a38", "#ffcf4a"], "logo":{"preset":0, "id":"apex_nova"}, "livery_pattern":1, "manager_id":"alex_martin"}
	demo.driver = {"first_name":"Noa", "last_name":"Martin", "nationality":"France", "number":27, "age":17, "appearance":0, "helmet":0, "colors":["#19dcc6", "#102a38", "#ffcf4a"], "profile":"worker", "hidden_potential":86, "stats":{"speed":72, "control":69, "mental":67, "start":64, "overtaking":70, "defence":66, "rain":63, "tyre_management":71}}
	demo.team_dna = GameState.neutral_dna()
	demo.team_dna.manager_id = "alex_martin"
	demo.money = 245000
	demo.reputation = 52
	demo.experience = 1840
	demo.level = 8
	demo.skill_points = 3
	demo.energy = 4
	demo.facilities = {"workshop":2, "technical":1, "simulator":2, "scouting":1, "marketing":1, "strategy":1, "pit_crew":2}
	demo.prestige = 14
	demo.career_path = "GT_ENDURANCE"
	demo.driver_roster = [{"id":"player", "name":"Noa Martin", "grade":"PRO", "fitness":67, "fatigue":12.0, "contract_months":12}, {"id":"reserve", "name":"Lina Diallo", "grade":"SEMI-PRO", "fitness":64, "fatigue":4.0, "contract_months":8}]
	demo.owned_gt_cars = []
	demo.transactions = [{"amount":12000, "label":"Prime sponsor", "date":"2027-04-12"}, {"amount":-3200, "label":"Développement châssis", "date":"2027-04-10"}, {"amount":-900, "label":"Révision du kart", "date":"2027-04-08"}]
	demo.trophies = [{"name":"REGIONAL KART CUP", "year":2027, "position":2}]
	demo.endurance_trophies = ["GT4 ROOKIE PODIUM"]
	demo.endurance_results = [{"year":2027, "series":"EUROPEAN GT CHALLENGE", "overall_position":6, "class":"GT4", "class_position":2, "prestige":4}]
	demo.career_history = [{"year":2027, "championship":"Regional Kart Series", "position":2, "points":92, "wins":2}]
	demo.season_income = 48500
	demo.season_expenses = 27300
	demo.season_xp = 2150
	demo.season_reputation = 18
	demo.offers = [{"id":"f4_private", "title":"PASSER EN F4", "eligible":true, "cost":45000, "objective":"TOP 8"}, {"id":"gt4_factory", "title":"PROGRAMME GT4", "eligible":true, "cost":30000, "objective":"TOP 5"}, {"id":"f3_academy", "title":"ACADÉMIE F3", "eligible":false, "cost":125000, "objective":"RÉPUTATION 65"}]
	GameState.data = demo
	demo.calendar = GameState.make_calendar("KART")
	demo.standings = GameState.make_standings()
	if not demo.standings.is_empty():
		demo.standings[0].points = 92
		demo.standings[0].wins = 2
		demo.standings[0].podiums = 5
		demo.standings[0].fastest_laps = 3
		demo.standings[0].finishes = [2, 1, 4, 1, 3]
	for i in range(1, demo.standings.size()):
		demo.standings[i].points = maxi(12, 88 - i * 7)
		demo.standings[i].wins = 1 if i < 3 else 0
		demo.standings[i].podiums = maxi(0, 4 - i)
		demo.standings[i].fastest_laps = 1 if i == 1 else 0
		demo.standings[i].finishes = [i + 1, i + 2]
	return demo.duplicate(true)

func _creation_preview_draft() -> Dictionary:
	return {"manager":"alex_martin", "team_name":"YAKA Racing", "short_name":"YAKA", "country":"France", "team_number":27, "colors":["#19dcc6", "#102a38", "#ffcf4a"], "logo_preset":0, "livery_pattern":1, "driver_variant":0}

func _build_overlay() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)
	var root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(root)
	_toolbar = PanelContainer.new()
	_toolbar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_toolbar.offset_left = 14
	_toolbar.offset_top = 14
	_toolbar.offset_right = -14
	_toolbar.offset_bottom = 154
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.09, 0.12, 0.96)
	style.border_color = Color("19dcc6")
	style.set_border_width_all(2)
	style.set_corner_radius_all(16)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	_toolbar.add_theme_stylebox_override("panel", style)
	root.add_child(_toolbar)
	var stack = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	_toolbar.add_child(stack)
	var title = Label.new()
	title.text = "UI LAB • ÉCRANS RÉELS • DONNÉES DE DÉMO • SAUVEGARDE PROTÉGÉE"
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("19dcc6"))
	stack.add_child(title)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	stack.add_child(row)
	var previous = Button.new()
	previous.text = "‹"
	previous.custom_minimum_size = Vector2(54, 44)
	previous.pressed.connect(func(): _move(-1))
	row.add_child(previous)
	_selector = OptionButton.new()
	_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_selector.custom_minimum_size.y = 44
	for screen in _screens:
		_selector.add_item("%s • %s • %s" % [screen.id, screen.group, screen.name])
	_selector.item_selected.connect(_select_index)
	row.add_child(_selector)
	var following = Button.new()
	following.text = "›"
	following.custom_minimum_size = Vector2(54, 44)
	following.pressed.connect(func(): _move(1))
	row.add_child(following)
	var hide = Button.new()
	hide.text = "MASQUER"
	hide.pressed.connect(_hide_toolbar)
	row.add_child(hide)
	var exit = Button.new()
	exit.text = "QUITTER"
	exit.pressed.connect(_exit_lab)
	row.add_child(exit)
	_status = Label.new()
	_status.add_theme_font_size_override("font_size", 13)
	_status.add_theme_color_override("font_color", Color("ffcc58"))
	stack.add_child(_status)
	_minimized = Button.new()
	_minimized.text = "UI LAB"
	_minimized.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimized.offset_left = -132
	_minimized.offset_top = 14
	_minimized.offset_right = -14
	_minimized.offset_bottom = 58
	_minimized.visible = false
	_minimized.pressed.connect(_show_toolbar)
	root.add_child(_minimized)

func _select_index(index: int) -> void:
	_current_index = clampi(index, 0, _screens.size() - 1)
	_render_current()

func _move(delta: int) -> void:
	_current_index = posmod(_current_index + delta, _screens.size())
	_selector.select(_current_index)
	_render_current()

func _render_current() -> void:
	if not _active or _main == null:
		return
	var screen: Dictionary = _screens[_current_index]
	var renderer = str(screen.get("renderer", "main"))
	if renderer == "creation":
		GameState.data = {}
		_main.set("creation_draft", _creation_preview_draft())
		_main.set("creation_step", int(screen.get("step", 0)))
		_main.call(str(screen.get("method", "show_creation")))
	else:
		GameState.data = _demo_data.duplicate(true)
		match renderer:
			"main":
				_main.call(str(screen.method))
			"race":
				var event: Dictionary = GameState.data.calendar[0]
				_main.call(str(screen.method), event)
			"lab":
				call(str(screen.method), _main)
			_:
				push_error("[UI LAB] Unknown renderer: %s" % renderer)
	_freeze_game_actions(_main.get("content"))
	_freeze_game_actions(_main.get("nav"))
	_selector.select(_current_index)
	_status.text = "SCREEN-%s • %s • %s • %d/%d" % [screen.id, screen.group, screen.name, _current_index + 1, _screens.size()]
	_sync_web_hash(str(screen.id))
	print("[UI LAB] SCREEN-%s %s" % [screen.id, screen.name])

func _render_pit_preview(main: Node) -> void:
	var event: Dictionary = GameState.data.calendar[0]
	main.call("open_race", event)
	main.call("open_pit_sheet")

func _render_race_results(main: Node) -> void:
	main.call("clear", "RÉSULTATS")
	main.call("heading", "DRAPEAU À DAMIER", 18)
	main.call("heading", "P3", 52)
	var content_node = main.get("content") as VBoxContainer
	content_node.add_child(main.call("card", "DÉPART P7  →  ARRIVÉE P3  •  +4", "MEILLEUR TOUR 56.842 s  •  TEMPS 18:24.7\nPNEUS 34%  •  INCIDENTS 1\n15 PTS  •  +8 500 €  •  +420 XP  •  +4 RÉP.", 190))
	main.call("label", "APERÇU UI LAB : aucune progression n'est enregistrée.", Color("ffcc58"), 14)

func _freeze_game_actions(node: Node) -> void:
	if node == null:
		return
	if node is BaseButton or node is LineEdit or node is Slider:
		var control := node as Control
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		control.focus_mode = Control.FOCUS_NONE
	for child in node.get_children():
		_freeze_game_actions(child)

func _hide_toolbar() -> void:
	_toolbar.visible = false
	_minimized.visible = true

func _show_toolbar() -> void:
	_toolbar.visible = true
	_minimized.visible = false

func _sync_web_hash(screen_id: String) -> void:
	if not OS.has_feature("web"):
		return
	var window = JavaScriptBridge.get_interface("window")
	if window != null:
		window.location.hash = "ui-lab/%s" % screen_id

func _exit_lab() -> void:
	_active = false
	GameState.data = _original_data.duplicate(true)
	if OS.has_feature("web"):
		var window = JavaScriptBridge.get_interface("window")
		if window != null:
			window.location.hash = ""
	if is_instance_valid(_layer):
		_layer.queue_free()
	get_tree().reload_current_scene()
