extends Node

const SCREEN_PATH: String = "res://game/ui/screens/manager_selection.tscn"
const EXPECTED: Array[String] = ["alex", "maya", "ethan", "sofia", "marcus"]

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	var packed: PackedScene = load(SCREEN_PATH) as PackedScene
	if not _assert(packed != null, "ManagerSelection V2 scene loads"):
		return
	for viewport_size: Vector2i in [Vector2i(390, 700), Vector2i(390, 844), Vector2i(393, 852), Vector2i(402, 874), Vector2i(430, 932), Vector2i(1080, 1920)]:
		get_tree().root.size = viewport_size
		var screen: ManagerSelection = packed.instantiate() as ManagerSelection
		if not _assert(screen != null, "ManagerSelection V2 scene instantiates"):
			return
		# Exercise both supported lifecycles: setup before and after entering the tree.
		if viewport_size == Vector2i(390, 700):
			screen.setup(GameState.creation_config.get("managers", {}), "alex", "test")
		add_child(screen)
		if viewport_size != Vector2i(390, 700):
			screen.setup(GameState.creation_config.get("managers", {}), "alex", "test")
		await get_tree().process_frame
		await get_tree().process_frame
		if not _assert(screen.selector.get_child_count() == 5, "five managers are visible"):
			return
		if not _assert(screen.selected_id == "alex", "Alex is selected by default"):
			return
		for manager_id: String in EXPECTED:
			screen.select_manager(manager_id)
			await get_tree().process_frame
			var data: Dictionary = GameState.creation_config.get("managers", {}).get(manager_id, {})
			if not _assert(screen.manager_name.text == str(data.get("first_name", "")).to_upper(), "name changes for " + manager_id):
				return
			if not _assert(screen.manager_role.text == str(data.get("title", "")).to_upper(), "role changes for " + manager_id):
				return
			if not _assert(screen.presentation != null and screen.presentation.texture != null, "presentation texture exists for " + manager_id):
				return
			if not _assert(screen.presentation.texture.resource_path == str(data.get("presentation", "")), "portrait changes for " + manager_id):
				return
			if not _assert(screen.confirm_button.text.contains(str(data.get("first_name", "")).to_upper()), "CTA changes for " + manager_id):
				return
			var value: Label = screen.technical_value
			if not _assert(value != null, "TechnicalValue exists for " + manager_id):
				return
			if not _assert(value.text == str(data.get("attributes", {}).get("technical", 0)), "stats change for " + manager_id):
				return
			if not _assert(screen.pagination.text == "%d / 5" % (EXPECTED.find(manager_id) + 1), "pagination changes for " + manager_id):
				return
		if not _assert_non_negative(screen):
			return
		if not _assert_viewport_fit(screen, viewport_size):
			return
		screen.free()
		await get_tree().process_frame
	print("MANAGER V2 TEST: selection and overflow checks passed at 390x700, 390x844, 393x852, 402x874, 430x932 and 1080x1920")
	get_tree().quit(0)

func _assert_viewport_fit(screen: ManagerSelection, viewport_size: Vector2i) -> bool:
	const TOLERANCE: float = 1.0
	var paths: Array[NodePath] = [
		NodePath("ContentMargin/MainVBox/Header"),
		NodePath("ContentMargin/MainVBox/ManagerSelector"),
		NodePath("ContentMargin/MainVBox/CharacterStage"),
		NodePath("ContentMargin/MainVBox/IdentityPanel"),
		NodePath("ContentMargin/MainVBox/StatsPanel"),
		NodePath("ContentMargin/MainVBox/Pagination"),
		NodePath("ContentMargin/MainVBox/ConfirmButton"),
	]
	for path: NodePath in paths:
		var control: Control = screen.get_node(path) as Control
		var rect: Rect2 = control.get_global_rect()
		if not _assert(rect.position.y >= -TOLERANCE, "%s top is inside %s" % [path, viewport_size]):
			return false
		if not _assert(rect.end.y <= float(viewport_size.y) + TOLERANCE, "%s bottom is inside %s (%.1f > %d)" % [path, viewport_size, rect.end.y, viewport_size.y]):
			return false
	for manager_id: String in EXPECTED:
		var avatar: Control = screen.selector.get_node(manager_id.capitalize() + "Avatar") as Control
		var avatar_rect: Rect2 = avatar.get_global_rect()
		if not _assert(avatar_rect.position.x >= -TOLERANCE, "%s avatar left edge is visible at %s" % [manager_id, viewport_size]):
			return false
		if not _assert(avatar_rect.end.x <= float(viewport_size.x) + TOLERANCE, "%s avatar right edge is visible at %s" % [manager_id, viewport_size]):
			return false
	return true

func _assert_non_negative(node: Node) -> bool:
	if node is Control:
		var control: Control = node as Control
		if not _assert(control.size.x >= 0.0 and control.size.y >= 0.0, "non-negative size: " + str(control.get_path())):
			return false
	for child: Node in node.get_children():
		if not _assert_non_negative(child):
			return false
	return true

func _assert(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("MANAGER V2 TEST FAILED: " + message)
	get_tree().quit(1)
	return false
