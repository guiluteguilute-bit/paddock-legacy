extends Node

const VIEWPORTS: Array[Vector2i] = [
	Vector2i(390, 700), Vector2i(390, 844), Vector2i(393, 852),
	Vector2i(402, 874), Vector2i(430, 932), Vector2i(1080, 1920),
]

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	var packed := load("res://game/ui/main.tscn") as PackedScene
	if not _assert(packed != null, "main scene loads"):
		return
	for viewport_size: Vector2i in VIEWPORTS:
		get_tree().root.size = viewport_size
		GameState.data = GameState.defaults()
		var main := packed.instantiate() as Control
		add_child(main)
		await get_tree().process_frame

		# Reproduce the Safari failure: a long page retains a deep global scroll,
		# then onboarding is opened in the same shell.
		main.call("clear", "LONG PAGE")
		var filler := Control.new()
		filler.custom_minimum_size = Vector2(0, 4000)
		var content := main.get("content") as VBoxContainer
		var global_scroll := main.get("scroll") as ScrollContainer
		content.add_child(filler)
		await get_tree().process_frame
		global_scroll.scroll_vertical = 3000
		main.call("show_creation")
		await get_tree().process_frame
		await get_tree().process_frame
		if not _assert_manager_host(main, viewport_size):
			return

		# Manager -> team -> manager must recreate one clean, top-aligned V2 screen.
		main.set("creation_step", 1)
		main.call("show_creation_step")
		await get_tree().process_frame
		main.set("creation_step", 0)
		main.call("show_creation_step")
		await get_tree().process_frame
		await get_tree().process_frame
		if not _assert_manager_host(main, viewport_size):
			return

		main.free()
		await get_tree().process_frame
	GameState.data = GameState.defaults()
	print("MANAGER HOST TEST: fixed host and scroll-leak regression passed")
	get_tree().quit(0)

func _assert_manager_host(main: Control, viewport_size: Vector2i) -> bool:
	var host := main.get("fixed_screen_host") as Control
	var global_scroll := main.get("scroll") as ScrollContainer
	var header := main.get("global_header") as VBoxContainer
	var navigation := main.get("nav") as HBoxContainer
	if not _assert(host != null and host.visible, "fixed host visible at %s" % viewport_size):
		return false
	if not _assert(not global_scroll.visible, "global scroll hidden at %s" % viewport_size):
		return false
	if not _assert(not header.visible and not navigation.visible, "global chrome hidden at %s" % viewport_size):
		return false
	if not _assert(host.get_child_count() == 1, "exactly one fixed screen at %s" % viewport_size):
		return false
	var screen := host.get_child(0) as ManagerSelection
	if not _assert(screen != null, "ManagerSelection mounted in fixed host at %s" % viewport_size):
		return false
	var parent: Node = screen.get_parent()
	while parent != null:
		if not _assert(not parent is ScrollContainer, "ManagerSelection has no ScrollContainer ancestor at %s" % viewport_size):
			return false
		parent = parent.get_parent()
	var screen_rect := screen.get_global_rect()
	var host_rect := host.get_global_rect()
	if not _assert(absf(screen_rect.position.y - host_rect.position.y) <= 1.0, "screen starts at fixed-host top at %s" % viewport_size):
		return false
	for path: NodePath in [
		NodePath("ContentMargin/MainVBox/Header"), NodePath("ContentMargin/MainVBox/ManagerSelector"),
		NodePath("ContentMargin/MainVBox/CharacterStage"), NodePath("ContentMargin/MainVBox/IdentityPanel"),
		NodePath("ContentMargin/MainVBox/StatsPanel"), NodePath("ContentMargin/MainVBox/ConfirmButton"),
	]:
		var control := screen.get_node(path) as Control
		if not _assert(control != null and control.visible, "%s visible at %s" % [path, viewport_size]):
			return false
		var rect := control.get_global_rect()
		if not _assert(rect.position.y >= screen_rect.position.y - 1.0 and rect.end.y <= screen_rect.end.y + 1.0, "%s fits logical screen at %s" % [path, viewport_size]):
			return false
	if not _assert(screen.selector.get_child_count() == 5, "five avatars visible at %s" % viewport_size):
		return false
	return true

func _assert(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error("MANAGER HOST TEST FAILED: " + message)
	get_tree().quit(1)
	return false
