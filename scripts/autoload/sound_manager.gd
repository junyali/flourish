extends Node

# // GLOBAL SOUND MANAGER \\ #

## VARIABLES ##
var music_player: AudioStreamPlayer = null
var sfx_players: Array[AudioStreamPlayer] = []
var spatial_sfx_players: Dictionary = {}
var sfx_pool_size: int = 32

var looping: bool = false

# Volume
var master_volume: float = 1.0 : set = set_master_volume
var music_volume: float = 1.0 : set = set_music_volume
var ambience_volume: float = 1.0 : set = set_ambience_volume
var sfx_volume: float = 1.0 : set = set_sfx_volume

## CONSTANTS ##
const MASTER_BUS: String = "Master"
const MUSIC_BUS: String = "Music"
const AMBIENCE_BUS: String = "Ambience"
const SFX_BUS: String = "SFX"

func _ready() -> void:
	
	# Initialise main non-spatial music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	music_player.finished.connect(_on_music_finished)
	add_child(music_player)
	
	SoundManager.play_music(load("res://sfx/music/field_theme_1.wav"), 1.0)
	
	for i in range(sfx_pool_size):
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		player.finished.connect(_on_sfx_finished.bind(player))
		add_child(player)
		sfx_players.append(player)
	
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)
	set_ambience_volume(ambience_volume)
	
## ----- MUSIC PLAYBACK ----- ##
func play_music(track: AudioStream, fade_time: float = 1.0, loop: bool = true) -> void:
	if music_player.playing:
		if music_player.stream == track:
			return
		fade_out(music_player, fade_time)
		await get_tree().create_timer(fade_time).timeout
		
	music_player.stop()
	music_player.stream = track
	looping = loop
	music_player.play()
	fade_in(music_player, fade_time)
	
func stop_music(fade_time: float = 1.0) -> void:
	fade_out(music_player, fade_time)
	await get_tree().create_timer(fade_time).timeout
	music_player.stop()
## ----- END OF MUSIC PLAYBACK ----- ##

## ----- GLOBAL SFX PLAYBACK ----- ##
func play_sfx(sound: AudioStream, volume: float = 1.0) -> void:
	var player = get_free_sfx_player()
	if player:
		player.volume_db = linear_to_db(volume)
		player.stream = sound
		player.play()

func get_free_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if !player.playing:
			return player
	print("[SoundManager.gd] SFX Pool is full!")
	return null

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	player.stream = null
## ----- END OF GLOBAL SFX PLAYBACK ----- ##

## ----- SPATIAL 2D SFX PLAYBACK ----- ##
func play_spatial_sfx(sound: AudioStream, parent: Node2D, volume: float = 1.0) -> AudioStreamPlayer2D:
	if not parent:
		return
		
	var player := AudioStreamPlayer2D.new()
	parent.add_child(player)
	player.bus = SFX_BUS
	player.stream = sound
	player.volume_db = linear_to_db(volume)
	player.play()
	
	spatial_sfx_players[parent] = [player]
	
	player.finished.connect(func():
		spatial_sfx_players.erase(parent)
		player.queue_free()
	)
	
	return player
	
func stop_spatial_sfx(parent: Node2D) -> void:
	if parent in spatial_sfx_players:
		spatial_sfx_players[parent].stop()
		spatial_sfx_players.erase(parent)
## ----- END OF SPATIAL 2D SFX PLAYBACK ----- ##
		
func fade_in(player: AudioStreamPlayer, duration: float = 1.0) -> void:
	player.volume_db = -80  # Start muted
	var tween = get_tree().create_tween()
	tween.tween_property(player, "volume_db", linear_to_db(music_volume), duration)

func fade_out(player: AudioStreamPlayer, duration: float = 1.0) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(player, "volume_db", -80, duration)
	
func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	
func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume)

func set_ambience_volume(value: float) -> void:
	ambience_volume = clamp(value, 0.0, 1.0)
	
func _on_music_finished() -> void:
	if looping:
		music_player.play()
