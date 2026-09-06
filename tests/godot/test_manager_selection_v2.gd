extends Node

const SCREEN_PATH: String = "res://game/ui/screens/manager_selection.tscn"
const EXPECTED: Array[String] = ["alex", "maya", "ethan", "sofia", "marcus"]

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	var packed: PackedScene = load(SCREEN_PATH) as PackedScene
	_assert(packed != null, "ManagerSelection V2 scene loads")
	if packed == null:
		get_tree().quit(1)
		return
	for viewport_size: Vector2i in [Vector2i(390, 844), Vector2i(393, 852), Vector2i(430, 932), Vector2i(1080, 1920)]:
		get_tree().root.size = viewport_size
		var screen: ManagerSelection = packed.instantiate() as ManagerSelection
		add_child(screen)
		screen.setup(GameState.creation_config.get("managers", {}), "alex", "test")
		await get_tree().process_frame
		_assert(screen.selector.get_child_count() == 5, "five managers are visible")
		_assert(screen.selected_id == "alex", "Alex is selected by default")
		for manager_id: String in EXPECTED:
			screen.select_manager(manager_id)
			await get_tree().process_frame
			var data: Dictionary = GameState.creation_config.get("managers", {}).get(manager_id, {})
			_assert(screen.manager_name.text == str(data.get("first_name", "")).to_upper(), "name changes for " + manager_id)
			_assert(screen.manager_role.text == str(data.get("title", "")).to_upper(), "role changes for " + manager_id)
			_assert(screen._presentation.texture.resource_path == str(data.get("presentation", "")), "portrait changes for " + manager_id)
			_assert(screen.confirm_button.text.contains(str(data.get("first_name", "")).to_upper()), "CTA changes for " + manager_id)
			var value := screen.stats_box.get_node("TechnicalValue") as Label
			_assert(value.text == str(data.get("attributes", {}).get("technical", 0)), "stats change for " + manager_id)
		_assert_non_negative(screen)
		screen.free()
		await get_tree().process_frame
	print("MANAGER V2 TEST: scene, selection, content, CTA and portrait sizes passed")
	get_tree().quit(0)

func _assert_non_negative(node: Node) -> void:
	if node is Control:
		var control := node as Control
		_assert(control.size.x >= 0.0 and control.size.y >= 0.0, "non-negative size: " + str(control.get_path()))
	for child: Node in node.get_children():
		_assert_non_negative(child)

func _assert(condition: bool, message: String) -> void:
	if not condition:
		push_error("MANAGER V2 TEST FAILED: " + message)
		get_tree().quit(1)
