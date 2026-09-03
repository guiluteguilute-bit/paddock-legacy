extends Node

const TRACKS: Array[AudioStream] = [
	preload("res://assets/audio/music/paddock_morning.mp3"),
	preload("res://assets/audio/music/paddock_calibration.mp3"),
	preload("res://assets/audio/music/split_second_margin.mp3"),
]
const CROSSFADE_SECONDS := 4.0
const SILENT_DB := -80.0

var _players: Array[AudioStreamPlayer] = []
var _active_player := 0
var _track_index := 0
var _crossfading := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for index in 2:
		var player := AudioStreamPlayer.new()
		player.name = "MenuMusicPlayer%d" % (index + 1)
		player.finished.connect(_on_player_finished.bind(index))
		add_child(player)
		_players.append(player)
	_players[0].stream = TRACKS[0]
	_players[0].volume_db = _target_volume_db()
	_players[0].play()


func _process(_delta: float) -> void:
	if _crossfading or _players.is_empty():
		return
	var current := _players[_active_player]
	if current.stream == null or not current.playing:
		return
	var length := current.stream.get_length()
	if length > 0.0 and current.get_playback_position() >= length - CROSSFADE_SECONDS:
		_crossfade_to_next()


func _crossfade_to_next() -> void:
	if _crossfading:
		return
	_crossfading = true
	var outgoing := _players[_active_player]
	var next_player_index := 1 - _active_player
	var incoming := _players[next_player_index]
	_track_index = (_track_index + 1) % TRACKS.size()
	incoming.stream = TRACKS[_track_index]
	incoming.volume_db = SILENT_DB
	incoming.play()

	var tween := create_tween().set_parallel(true)
	tween.tween_property(outgoing, "volume_db", SILENT_DB, CROSSFADE_SECONDS)
	tween.tween_property(incoming, "volume_db", _target_volume_db(), CROSSFADE_SECONDS)
	tween.finished.connect(func() -> void:
		outgoing.stop()
		_active_player = next_player_index
		_crossfading = false
		refresh_volume()
	)


func _on_player_finished(player_index: int) -> void:
	if player_index != _active_player or _crossfading:
		return
	_crossfade_to_next()


func refresh_volume() -> void:
	if _players.is_empty() or _crossfading:
		return
	_players[_active_player].volume_db = _target_volume_db()


func _target_volume_db() -> float:
	var settings: Dictionary = GameState.data.get("settings", {})
	var master := float(settings.get("master", 80)) / 100.0
	var music := float(settings.get("music", 55)) / 100.0
	var linear_volume := clampf(master * music, 0.0, 1.0)
	return SILENT_DB if linear_volume <= 0.0001 else linear_to_db(linear_volume)
