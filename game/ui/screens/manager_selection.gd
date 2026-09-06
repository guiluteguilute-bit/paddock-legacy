extends Control
class_name ManagerSelection

signal manager_changed(manager_id: String)
signal manager_confirmed(manager_id: String)

const MANAGER_ORDER: Array[String] = ["alex", "maya", "ethan", "sofia", "marcus"]
var managers: Dictionary = {}
var selected_id: String = "alex"
var preview_mode: bool = false
var _avatar_buttons: Dictionary = {}
var _reveal_tween: Tween
var _swipe_start_x: float = -1.0
var _pending_build_label: String = ""
var _setup_requested: bool = false

@onready var selector: HBoxContainer = $ContentMargin/MainVBox/ManagerSelector
@onready var stage: PanelContainer = $ContentMargin/MainVBox/CharacterStage
@onready var presentation: TextureRect = $ContentMargin/MainVBox/CharacterStage/StageContent/Presentation
@onready var identity: PanelContainer = $ContentMargin/MainVBox/IdentityPanel
@onready var manager_name: Label = $ContentMargin/MainVBox/IdentityPanel/IdentityVBox/ManagerName
@onready var manager_role: Label = $ContentMargin/MainVBox/IdentityPanel/IdentityVBox/ManagerRole
@onready var specialty_badge: Label = $ContentMargin/MainVBox/IdentityPanel/IdentityVBox/SpecialtyBadge
@onready var stats_panel: PanelContainer = $ContentMargin/MainVBox/StatsPanel
@onready var stats_box: VBoxContainer = $ContentMargin/MainVBox/StatsPanel/StatsVBox
@onready var technical_bar: CartoonStatBar = $ContentMargin/MainVBox/StatsPanel/StatsVBox/TechnicalRow/TechnicalBar
@onready var technical_value: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/TechnicalRow/TechnicalValue
@onready var strategy_bar: CartoonStatBar = $ContentMargin/MainVBox/StatsPanel/StatsVBox/StrategyRow/StrategyBar
@onready var strategy_value: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/StrategyRow/StrategyValue
@onready var business_bar: CartoonStatBar = $ContentMargin/MainVBox/StatsPanel/StatsVBox/BusinessRow/BusinessBar
@onready var business_value: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/BusinessRow/BusinessValue
@onready var bonus_card: PanelContainer = $ContentMargin/MainVBox/StatsPanel/StatsVBox/EffectsRow/BonusCard
@onready var bonus_heading: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/EffectsRow/BonusCard/Content/Heading
@onready var bonus_body: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/EffectsRow/BonusCard/Content/Body
@onready var malus_card: PanelContainer = $ContentMargin/MainVBox/StatsPanel/StatsVBox/EffectsRow/MalusCard
@onready var malus_heading: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/EffectsRow/MalusCard/Content/Heading
@onready var malus_body: Label = $ContentMargin/MainVBox/StatsPanel/StatsVBox/EffectsRow/MalusCard/Content/Body
@onready var pagination: Label = $ContentMargin/MainVBox/Pagination
@onready var confirm_button: Button = $ContentMargin/MainVBox/ConfirmButton
@onready var build_label: Label = $BuildLabel

func _ready() -> void:
	_apply_theme()
	stage.gui_input.connect(_on_stage_input)
	$ContentMargin/MainVBox/CharacterStage/StageContent/Previous.pressed.connect(cycle_manager.bind(-1))
	$ContentMargin/MainVBox/CharacterStage/StageContent/Next.pressed.connect(cycle_manager.bind(1))
	confirm_button.pressed.connect(_confirm)
	confirm_button.button_down.connect(_set_cta_pressed.bind(true))
	confirm_button.button_up.connect(_set_cta_pressed.bind(false))
	if _setup_requested:
		_apply_setup()

func setup(manager_data: Dictionary, initial_id: String, build_label: String = "", is_preview: bool = false) -> void:
	managers = manager_data
	preview_mode = is_preview
	selected_id = initial_id if MANAGER_ORDER.has(initial_id) and managers.has(initial_id) else "alex"
	_pending_build_label = build_label
	_setup_requested = true
	if is_node_ready():
		_apply_setup()

func _apply_setup() -> void:
	if not is_node_ready():
		return
	_setup_requested = false
	build_label.text = "BUILD %s" % _pending_build_label
	_build_selector()
	_refresh()

func select_manager(manager_id: String) -> void:
	if not MANAGER_ORDER.has(manager_id) or not managers.has(manager_id):
		return
	selected_id = manager_id
	if is_node_ready():
		_refresh()
	manager_changed.emit(selected_id)

func cycle_manager(delta: int) -> void:
	var index: int = maxi(0, MANAGER_ORDER.find(selected_id))
	select_manager(MANAGER_ORDER[(index + delta + MANAGER_ORDER.size()) % MANAGER_ORDER.size()])

func _build_selector() -> void:
	if selector == null:
		return
	for child: Node in selector.get_children():
		child.queue_free()
	_avatar_buttons.clear()
	for manager_id: String in MANAGER_ORDER:
		if not managers.has(manager_id):
			continue
		var button: Button = Button.new()
		button.name = manager_id.capitalize() + "Avatar"
		button.custom_minimum_size = Vector2(72, 106)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.expand_icon = true
		button.icon = load(str(managers[manager_id].get("avatar", ""))) as Texture2D
		button.tooltip_text = str(managers[manager_id].get("first_name", manager_id))
		button.pressed.connect(select_manager.bind(manager_id))
		selector.add_child(button)
		_avatar_buttons[manager_id] = button

func _refresh() -> void:
	if not is_node_ready() or managers.is_empty() or not managers.has(selected_id):
		return
	var manager: Dictionary = managers[selected_id]
	_refresh_avatars()
	_refresh_stage(manager)
	manager_name.text = str(manager.get("first_name", selected_id)).to_upper()
	manager_role.text = str(manager.get("title", "Gérant")).to_upper()
	specialty_badge.text = "◆  %s  ◆" % _specialty_name(selected_id)
	pagination.text = "%d / %d" % [MANAGER_ORDER.find(selected_id) + 1, MANAGER_ORDER.size()]
	confirm_button.text = "RETOUR AUX PARAMÈTRES" if preview_mode else "CHOISIR %s" % manager_name.text
	_refresh_stats(manager)

func _refresh_avatars() -> void:
	for manager_id: String in _avatar_buttons:
		var button: Button = _avatar_buttons[manager_id] as Button
		var selected: bool = manager_id == selected_id
		button.add_theme_stylebox_override("normal", _avatar_style(selected))
		button.add_theme_stylebox_override("hover", _avatar_style(true))
		button.add_theme_stylebox_override("pressed", _avatar_style(true, true))
		button.modulate = Color(1.08, 1.06, 0.98, 1.0) if selected else Color(0.82, 0.85, 0.88, 0.96)
		button.pivot_offset = button.size * 0.5
		button.scale = Vector2(1.05, 1.05) if selected else Vector2.ONE
		button.position.y = -4.0 if selected else 2.0

func _refresh_stage(manager: Dictionary) -> void:
	if presentation == null:
		return
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	var texture_path: String = str(manager.get("presentation", ""))
	var texture: Texture2D = null
	if ResourceLoader.exists(texture_path):
		texture = load(texture_path) as Texture2D
	else:
		push_warning("Manager presentation missing: %s" % texture_path)
	presentation.texture = texture
	presentation.pivot_offset = presentation.size * 0.5
	presentation.modulate = Color(1, 1, 1, 0.15)
	presentation.scale = Vector2(0.96, 0.96)
	_reveal_tween = create_tween()
	_reveal_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reveal_tween.tween_property(presentation, "modulate", Color.WHITE, 0.24)
	_reveal_tween.parallel().tween_property(presentation, "scale", Vector2.ONE, 0.24)

func _refresh_stats(manager: Dictionary) -> void:
	if stats_box == null:
		return
	var attributes: Dictionary = manager.get("attributes", {})
	_set_stat(technical_bar, technical_value, int(attributes.get("technical", 0)), "technical")
	_set_stat(strategy_bar, strategy_value, int(attributes.get("strategy", 0)), "strategy")
	_set_stat(business_bar, business_value, int(attributes.get("business", 0)), "business")
	var advantages: Array = manager.get("advantages", [])
	var drawbacks: Array = manager.get("drawbacks", [])
	bonus_body.text = str(advantages[0]) if not advantages.is_empty() else "Profil équilibré"
	malus_body.text = str(drawbacks[0]) if not drawbacks.is_empty() else "Aucun malus"

func _set_stat(bar: CartoonStatBar, score: Label, value: int, kind: String) -> void:
	bar.configure(float(value), kind)
	score.text = str(value)

func _apply_theme() -> void:
	$ContentMargin/MainVBox/Header/Brand.add_theme_font_size_override("font_size", 22)
	$ContentMargin/MainVBox/Header/Brand.add_theme_color_override("font_color", Color("f7fbff"))
	$ContentMargin/MainVBox/Header/Prompt.add_theme_font_size_override("font_size", 19)
	$ContentMargin/MainVBox/Header/Prompt.add_theme_color_override("font_color", Color("ffd05a"))
	$Background.add_theme_stylebox_override("panel", _panel_style(Color(0, 0, 0, 0), Color(0.01, 0.045, 0.065, 0.64), 0, 0))
	stage.add_theme_stylebox_override("panel", _panel_style(Color("f5b928"), Color(0.02, 0.09, 0.12, 0.84), 30, 2))
	$ContentMargin/MainVBox/CharacterStage/StageContent/StageBackdrop.add_theme_stylebox_override("panel", _panel_style(Color(0, 0, 0, 0), Color(0.02, 0.14, 0.18, 0.42), 28, 0))
	$ContentMargin/MainVBox/CharacterStage/StageContent/CharacterShadow.add_theme_stylebox_override("panel", _panel_style(Color(0, 0, 0, 0), Color(0.005, 0.015, 0.02, 0.44), 190, 0))
	$ContentMargin/MainVBox/CharacterStage/StageContent/GroundGlow.add_theme_stylebox_override("panel", _panel_style(Color(0, 0, 0, 0), Color(0.10, 0.86, 0.80, 0.18), 46, 0))
	var frame_style: StyleBoxFlat = _panel_style(Color(1.0, 0.80, 0.35, 0.64), Color(0, 0, 0, 0), 26, 2)
	frame_style.shadow_color = Color(0.05, 0.75, 0.78, 0.18)
	frame_style.shadow_size = 8
	$ContentMargin/MainVBox/CharacterStage/StageContent/CharacterFrame.add_theme_stylebox_override("panel", frame_style)
	identity.add_theme_stylebox_override("panel", _panel_style(Color("ffd05a"), Color(0.025, 0.085, 0.12, 0.97), 18, 3))
	stats_panel.add_theme_stylebox_override("panel", _panel_style(Color("168da5"), Color(0.018, 0.07, 0.095, 0.97), 18, 2))
	manager_name.add_theme_font_size_override("font_size", 34)
	manager_name.add_theme_color_override("font_color", Color("ffffff"))
	manager_role.add_theme_font_size_override("font_size", 18)
	manager_role.add_theme_color_override("font_color", Color("ffd05a"))
	specialty_badge.add_theme_font_size_override("font_size", 13)
	specialty_badge.add_theme_color_override("font_color", Color("55e1d7"))
	for label_node: Label in [technical_value, strategy_value, business_value]:
		label_node.add_theme_font_size_override("font_size", 18)
		label_node.add_theme_color_override("font_color", Color("ffcf4a"))
	bonus_card.add_theme_stylebox_override("panel", _panel_style(Color("65e89a"), Color(0.025, 0.075, 0.10, 0.96), 12, 1))
	malus_card.add_theme_stylebox_override("panel", _panel_style(Color("ff756d"), Color(0.025, 0.075, 0.10, 0.96), 12, 1))
	bonus_heading.add_theme_color_override("font_color", Color("65e89a"))
	malus_heading.add_theme_color_override("font_color", Color("ff756d"))
	bonus_body.add_theme_font_size_override("font_size", 13)
	malus_body.add_theme_font_size_override("font_size", 13)
	pagination.add_theme_font_size_override("font_size", 18)
	pagination.add_theme_color_override("font_color", Color("9ce9ed"))
	build_label.add_theme_font_size_override("font_size", 9)
	build_label.add_theme_color_override("font_color", Color(0.65, 0.73, 0.76, 0.55))
	var cta: StyleBoxFlat = _panel_style(Color("fff2ad"), Color("f5b928"), 20, 4)
	cta.shadow_color = Color(0, 0, 0, 0.55)
	cta.shadow_size = 10
	confirm_button.add_theme_stylebox_override("normal", cta)
	var hover: StyleBoxFlat = cta.duplicate() as StyleBoxFlat
	hover.bg_color = Color("ffd34e")
	confirm_button.add_theme_stylebox_override("hover", hover)
	var pressed: StyleBoxFlat = cta.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("d99817")
	pressed.shadow_size = 3
	confirm_button.add_theme_stylebox_override("pressed", pressed)
	confirm_button.add_theme_font_size_override("font_size", 22)
	confirm_button.add_theme_color_override("font_color", Color("09202a"))
	for arrow_path: NodePath in [NodePath("ContentMargin/MainVBox/CharacterStage/StageContent/Previous"), NodePath("ContentMargin/MainVBox/CharacterStage/StageContent/Next")]:
		var arrow: Button = get_node(arrow_path) as Button
		arrow.add_theme_font_size_override("font_size", 30)
		arrow.add_theme_color_override("font_color", Color("d8fbff"))
		arrow.add_theme_stylebox_override("normal", _panel_style(Color(0.1, 0.75, 0.82, 0.55), Color(0.01, 0.08, 0.12, 0.72), 18, 2))
		arrow.add_theme_stylebox_override("pressed", _panel_style(Color("ffd05a"), Color("103949"), 18, 3))

func _avatar_style(selected: bool, pressed: bool = false) -> StyleBoxFlat:
	var border: Color = Color("ffd05a") if selected else Color("176b89")
	var fill: Color = Color("0d4260") if selected else Color("071f32")
	if pressed:
		fill = Color("082638")
	var style: StyleBoxFlat = _panel_style(border, fill, 16, 4 if selected else 2)
	style.shadow_color = Color(0.1, 0.9, 1.0, 0.36) if selected else Color(0, 0, 0, 0.35)
	style.shadow_size = 10 if selected else 3
	return style

func _panel_style(border: Color, fill: Color, radius: int, width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func _specialty_name(manager_id: String) -> String:
	var names: Dictionary = {
		"alex": "TECHNICIEN", "maya": "STRATÈGE", "ethan": "COMMERCIAL",
		"sofia": "FORMATRICE", "marcus": "MENEUR"
	}
	return str(names.get(manager_id, "GÉRANT"))

func _set_cta_pressed(is_pressed: bool) -> void:
	confirm_button.pivot_offset = confirm_button.size * 0.5
	confirm_button.scale = Vector2(0.98, 0.98) if is_pressed else Vector2.ONE

func _on_stage_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			_swipe_start_x = touch.position.x
		elif _swipe_start_x >= 0.0:
			_finish_swipe(touch.position.x)
	elif event is InputEventMouseButton:
		var mouse: InputEventMouseButton = event as InputEventMouseButton
		if mouse.button_index == MOUSE_BUTTON_LEFT:
			if mouse.pressed:
				_swipe_start_x = mouse.position.x
			elif _swipe_start_x >= 0.0:
				_finish_swipe(mouse.position.x)

func _finish_swipe(end_x: float) -> void:
	var distance: float = end_x - _swipe_start_x
	_swipe_start_x = -1.0
	if absf(distance) >= 80.0:
		cycle_manager(-1 if distance > 0.0 else 1)

func _confirm() -> void:
	manager_confirmed.emit(selected_id)

func _exit_tree() -> void:
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
