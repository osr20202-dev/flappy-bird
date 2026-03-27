extends Node

## Audio manager for music and sound effects
##
## Usage:
##   AudioManager.play_music(preload("res://assets/audio/music.ogg"))
##   AudioManager.play_sfx(preload("res://assets/audio/jump.wav"))
##   AudioManager.set_music_volume(0.7)

signal music_started(stream: AudioStream)
signal sfx_played(stream: AudioStream)

@onready var music_player := AudioStreamPlayer.new()
@onready var sfx_players: Array[AudioStreamPlayer] = []

const MAX_SFX_PLAYERS := 8  # Polyphony limit

var music_volume := 0.8:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		music_player.volume_db = linear_to_db(music_volume)

var sfx_volume := 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)

func _ready() -> void:
	# Setup music player
	add_child(music_player)
	music_player.bus = "Music"
	music_player.volume_db = linear_to_db(music_volume)
	
	# Setup SFX players pool
	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)

## Play background music (loops by default)
func play_music(stream: AudioStream, loop := true) -> void:
	if not stream:
		return
	
	music_player.stream = stream
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	elif stream is AudioStreamOggVorbis:
		stream.loop = loop
	
	music_player.play()
	music_started.emit(stream)

## Stop music
func stop_music() -> void:
	music_player.stop()

## Play sound effect (fire-and-forget)
func play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
	
	# Find available player
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume)
			player.play()
			sfx_played.emit(stream)
			return
	
	# All players busy, use first one (override)
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = linear_to_db(sfx_volume)
	sfx_players[0].play()

## Set music volume (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = volume

## Set SFX volume (0.0 - 1.0)
func set_sfx_volume(volume: float) -> void:
	sfx_volume = volume
