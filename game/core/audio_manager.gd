extends Node

const MUSIC_CROSSFADE_DURATION := 5.0
const MUSIC_NORMAL_DB := -14.0
const MUSIC_SILENT_DB := -60.0
const MUSIC_DIRECTORY := "res://audio/music/"
const TRACK_FILES := ["ambient_01.ogg", "ambient_02.ogg", "ambient_03.ogg"]
var TRACK_PATHS: Array[String] = []

var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _track_index := 0
var _started := false
var _transitioning := false
var _enabled := true
var _volume := 55.0
var _paused_by_app := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for file in TRACK_FILES: TRACK_PATHS.append(MUSIC_DIRECTORY + file)
	_ensure_music_bus()
	for player_name in ["MusicPlayerA", "MusicPlayerB"]:
		var player := AudioStreamPlayer.new()
		player.name = player_name
		player.bus = "Music"
		player.volume_db = MUSIC_SILENT_DB
		add_child(player)
		_players.append(player)
	_load_settings()
	print("[BOOT] AudioManager ready (%d/%d ambient tracks available; waiting for first interaction)" % [_available_track_count(), TRACK_PATHS.size()])

func _input(event: InputEvent) -> void:
	if not _started and (event is InputEventScreenTouch or event is InputEventMouseButton or event is InputEventKey):
		start_music_after_interaction()

func _process(_delta: float) -> void:
	if not _started or _transitioning or not _players[_active].playing: return
	var stream := _players[_active].stream
	if stream and stream.get_length() > 0.0 and _players[_active].get_playback_position() >= stream.get_length() - MUSIC_CROSSFADE_DURATION:
		_crossfade_to_next()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		_paused_by_app = _started
		for player in _players: player.stream_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED and _paused_by_app:
		for player in _players: player.stream_paused = false
		_paused_by_app = false

func start_music_after_interaction() -> void:
	if _started or not _enabled: return
	var next := _next_available_index(-1)
	if next < 0:
		push_warning("[AUDIO] No ambient OGG found; music disabled without blocking the UI")
		return
	_track_index = next
	_players[_active].stream = load(TRACK_PATHS[_track_index])
	_players[_active].volume_db = MUSIC_NORMAL_DB
	_players[_active].play()
	_started = true
	print("[AUDIO] Playlist started after user interaction: %s" % TRACK_PATHS[_track_index])

func _crossfade_to_next() -> void:
	var next_track := _next_available_index(_track_index)
	if next_track < 0: return
	_transitioning = true
	var incoming := 1 - _active
	_players[incoming].stream = load(TRACK_PATHS[next_track])
	_players[incoming].volume_db = MUSIC_SILENT_DB
	_players[incoming].play()
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_players[_active], "volume_db", MUSIC_SILENT_DB, MUSIC_CROSSFADE_DURATION)
	tween.tween_property(_players[incoming], "volume_db", MUSIC_NORMAL_DB, MUSIC_CROSSFADE_DURATION)
	await tween.finished
	_players[_active].stop()
	_players[_active].stream = null
	_active = incoming
	_track_index = next_track
	_transitioning = false

func fade_out_music(duration := 1.0) -> void:
	if _started: create_tween().tween_property(_players[_active], "volume_db", MUSIC_SILENT_DB, duration)

func fade_in_music(duration := 1.0) -> void:
	if _started: create_tween().tween_property(_players[_active], "volume_db", MUSIC_NORMAL_DB, duration)

func set_music_enabled(value: bool) -> void:
	_enabled = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not value)
	_save_setting("music_enabled", value)
	if value: start_music_after_interaction()

func set_music_volume(value: float) -> void:
	_volume = clampf(value, 0.0, 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(_volume / 100.0) if _volume > 0.0 else MUSIC_SILENT_DB)
	_save_setting("music_volume", int(_volume))

func enter_race_music() -> void: fade_out_music()
func exit_race_music() -> void: fade_in_music()

func _next_available_index(after: int) -> int:
	for offset in TRACK_PATHS.size():
		var index := (after + 1 + offset) % TRACK_PATHS.size()
		if ResourceLoader.exists(TRACK_PATHS[index]): return index
	return -1

func _available_track_count() -> int:
	var count := 0
	for path in TRACK_PATHS:
		if ResourceLoader.exists(path): count += 1
	return count

func _ensure_music_bus() -> void:
	if AudioServer.get_bus_index("Music") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")

func _load_settings() -> void:
	if GameState.has_career():
		var settings: Dictionary = GameState.data.get("settings", {})
		_enabled = bool(settings.get("music_enabled", true))
		_volume = float(settings.get("music_volume", settings.get("music", 55)))
	set_music_volume(_volume)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not _enabled)

func _save_setting(key: String, value: Variant) -> void:
	if GameState.has_career():
		GameState.data.settings[key] = value
		GameState.save_game()
