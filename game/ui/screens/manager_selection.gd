extends Control
class_name ManagerSelection

signal manager_changed(manager_id: String)
signal manager_confirmed(manager_id: String)

const MANAGER_UI_REVISION: String = "V2"
const MANAGER_ORDER: Array[String] = ["alex", "maya", "ethan", "sofia", "marcus"]
const BAR_SCRIPT := preload("res://game/ui/components/cartoon_stat_bar.gd")

var managers: Dictionary = {}
var selected_id: String = "alex"
var preview_mode: bool = false
var _avatar_buttons: Dictionary = {}
var _presentation: TextureRect
var _reveal_tween: Tween
var _swipe_start_x: float = -1.0
var _pending_build_label: String = ""
var _setup_requested: bool = false

@onready var selector: HBoxContainer = $SafeArea/MainVBox/ManagerSelector
@onready var stage: PanelContainer = $SafeArea/MainVBox/CharacterStage
@onready var stage_content: Control = $SafeArea/MainVBox/CharacterStage/StageContent
@onready var identity: PanelContainer = $SafeArea/MainVBox/IdentityPanel
@onready var manager_name: Label = $SafeArea/MainVBox/IdentityPanel/IdentityVBox/ManagerName
@onready var manager_role: Label = $SafeArea/MainVBox/IdentityPanel/IdentityVBox/ManagerRole
@onready var stats_panel: PanelContainer = $SafeArea/MainVBox/StatsPanel
@onready var stats_box: VBoxContainer = $SafeArea/MainVBox/StatsPanel/StatsVBox
@onready var pagination: Label = $SafeArea/MainVBox/Pagination
@onready var confirm_button: Button = $SafeArea/MainVBox/ConfirmButton

func _ready() -> void:
	_apply_theme()
	stage.gui_input.connect(_on_stage_input)
	$SafeArea/MainVBox/CharacterStage/StageContent/Previous.pressed.connect(cycle_manager.bind(-1))
	$SafeArea/MainVBox/CharacterStage/StageContent/Next.pressed.connect(cycle_manager.bind(1))
	confirm_button.pressed.connect(_confirm)
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
	var revision: Label = get_node_or_null("SafeArea/MainVBox/Header/Revision") as Label
	if revision != null:
		revision.text = "UI %s  •  BUILD %s" % [MANAGER_UI_REVISION, _pending_build_label]
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
		var button := Button.new()
		button.name = manager_id.capitalize() + "Avatar"
		button.custom_minimum_size = Vector2(0, 122)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.expand_icon = true
		button.icon_max_width = 105
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
		button.modulate = Color(1.08, 1.08, 1.02, 1.0) if selected else Color(0.62, 0.72, 0.82, 0.92)
		button.position.y = -5.0 if selected else 3.0

func _refresh_stage(manager: Dictionary) -> void:
	if stage_content == null:
		return
	if _reveal_tween != null and _reveal_tween.is_valid():
		_reveal_tween.kill()
	if _presentation != null and is_instance_valid(_presentation):
		_presentation.free()
	_presentation = TextureRect.new()
	_presentation.name = "Presentation"
	_presentation.texture = load(str(manager.get("presentation", ""))) as Texture2D
	_presentation.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_presentation.offset_left = 76
	_presentation.offset_right = -76
	_presentation.offset_top = 4
	_presentation.offset_bottom = -8
	_presentation.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_presentation.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_presentation.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_presentation.modulate = Color(1, 1, 1, 0.15)
	stage_content.add_child(_presentation)
	stage_content.move_child(_presentation, 0)
	_reveal_tween = create_tween()
	_reveal_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_reveal_tween.tween_property(_presentation, "modulate", Color.WHITE, 0.24)
	_reveal_tween.parallel().tween_property(_presentation, "scale", Vector2.ONE, 0.24).from(Vector2(0.96, 0.96))

func _refresh_stats(manager: Dictionary) -> void:
	if stats_box == null:
		return
	for child: Node in stats_box.get_children():
		child.queue_free()
	var attributes: Dictionary = manager.get("attributes", {})
	_add_stat("TECHNIQUE", "technical", int(attributes.get("technical", 0)))
	_add_stat("STRATÉGIE", "strategy", int(attributes.get("strategy", 0)))
	_add_stat("BUSINESS", "business", int(attributes.get("business", 0)))
	var effects := HBoxContainer.new()
	effects.add_theme_constant_override("separation", 10)
	stats_box.add_child(effects)
	var advantages: Array = manager.get("advantages", [])
	var drawbacks: Array = manager.get("drawbacks", [])
	_add_effect(effects, "+ BONUS", str(advantages[0]) if not advantages.is_empty() else "Profil équilibré", Color("65e89a"))
	_add_effect(effects, "− MALUS", str(drawbacks[0]) if not drawbacks.is_empty() else "Aucun malus", Color("ff756d"))

func _add_stat(label_text: String, kind: String, value: int) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = 42
	stats_box.add_child(row)
	var label_node := Label.new()
	label_node.text = label_text
	label_node.custom_minimum_size.x = 146
	label_node.add_theme_font_size_override("font_size", 18)
	row.add_child(label_node)
	var bar: Control = BAR_SCRIPT.new() as Control
	bar.name = kind.capitalize() + "Bar"
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 30
	bar.call("configure", float(value), kind)
	row.add_child(bar)
	var score := Label.new()
	score.name = kind.capitalize() + "Value"
	score.text = str(value)
	score.custom_minimum_size.x = 48
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score.add_theme_font_size_override("font_size", 20)
	score.add_theme_color_override("font_color", Color("ffcf4a"))
	row.add_child(score)

func _add_effect(parent: HBoxContainer, heading: String, text_value: String, color: Color) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _panel_style(color, Color(0.025, 0.075, 0.10, 0.96), 12, 1))
	parent.add_child(card)
	var box := VBoxContainer.new()
	card.add_child(box)
	var heading_label := Label.new()
	heading_label.text = heading
	heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading_label.add_theme_color_override("font_color", color)
	box.add_child(heading_label)
	var body := Label.new()
	body.text = text_value
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 14)
	box.add_child(body)

func _apply_theme() -> void:
	$SafeArea/MainVBox/Header/Brand.add_theme_font_size_override("font_size", 28)
	$SafeArea/MainVBox/Header/Brand.add_theme_color_override("font_color", Color("f7fbff"))
	$SafeArea/MainVBox/Header/Prompt.add_theme_font_size_override("font_size", 18)
	$SafeArea/MainVBox/Header/Prompt.add_theme_color_override("font_color", Color("33e1da"))
	$SafeArea/MainVBox/Header/Revision.add_theme_font_size_override("font_size", 11)
	$SafeArea/MainVBox/Header/Revision.add_theme_color_override("font_color", Color(0.55, 0.7, 0.75, 0.8))
	$Background.add_theme_stylebox_override("panel", _panel_style(Color("147d91"), Color(0.015, 0.045, 0.065, 0.78), 24, 2))
	stage.add_theme_stylebox_override("panel", _panel_style(Color("29d9dd"), Color(0.025, 0.12, 0.16, 0.72), 28, 3))
	identity.add_theme_stylebox_override("panel", _panel_style(Color("ffd05a"), Color(0.025, 0.085, 0.12, 0.97), 18, 3))
	stats_panel.add_theme_stylebox_override("panel", _panel_style(Color("168da5"), Color(0.018, 0.07, 0.095, 0.97), 18, 2))
	manager_name.add_theme_font_size_override("font_size", 34)
	manager_name.add_theme_color_override("font_color", Color("ffffff"))
	manager_role.add_theme_font_size_override("font_size", 18)
	manager_role.add_theme_color_override("font_color", Color("ffd05a"))
	pagination.add_theme_font_size_override("font_size", 18)
	pagination.add_theme_color_override("font_color", Color("9ce9ed"))
	var cta := _panel_style(Color("fff2ad"), Color("f5b928"), 20, 4)
	cta.shadow_color = Color(0, 0, 0, 0.55)
	cta.shadow_size = 10
	confirm_button.add_theme_stylebox_override("normal", cta)
	var hover := cta.duplicate() as StyleBoxFlat
	hover.bg_color = Color("ffd34e")
	confirm_button.add_theme_stylebox_override("hover", hover)
	var pressed := cta.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("d99817")
	pressed.shadow_size = 3
	confirm_button.add_theme_stylebox_override("pressed", pressed)
	confirm_button.add_theme_font_size_override("font_size", 25)
	confirm_button.add_theme_color_override("font_color", Color("09202a"))
	for arrow_path: NodePath in [NodePath("SafeArea/MainVBox/CharacterStage/StageContent/Previous"), NodePath("SafeArea/MainVBox/CharacterStage/StageContent/Next")]:
		var arrow := get_node(arrow_path) as Button
		arrow.add_theme_font_size_override("font_size", 30)
		arrow.add_theme_color_override("font_color", Color("d8fbff"))
		arrow.add_theme_stylebox_override("normal", _panel_style(Color(0.1, 0.75, 0.82, 0.55), Color(0.01, 0.08, 0.12, 0.72), 18, 2))

func _avatar_style(selected: bool, pressed: bool = false) -> StyleBoxFlat:
	var border: Color = Color("ffd05a") if selected else Color("176b89")
	var fill: Color = Color("0d4260") if selected else Color("071f32")
	if pressed:
		fill = Color("082638")
	var style := _panel_style(border, fill, 16, 4 if selected else 2)
	style.shadow_color = Color(0.1, 0.9, 1.0, 0.36) if selected else Color(0, 0, 0, 0.35)
	style.shadow_size = 10 if selected else 3
	return style

func _panel_style(border: Color, fill: Color, radius: int, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func _on_stage_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_swipe_start_x = touch.position.x
		elif _swipe_start_x >= 0.0:
			_finish_swipe(touch.position.x)
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
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
