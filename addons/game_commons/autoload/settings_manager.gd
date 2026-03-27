extends Node

## Settings manager for game configuration
##
## Manages and persists:
## - Audio settings (music/sfx volume)
## - Display settings (fullscreen, window size, vsync)
## - Input settings (key rebinding)
##
## Usage:
##   SettingsManager.set_music_volume(0.7)
##   SettingsManager.set_fullscreen(true)
##   var volume = SettingsManager.get_music_volume()

signal settings_changed(setting_name: String, value: Variant)
signal settings_loaded
signal settings_reset

const SETTINGS_SECTION := "settings"

# Audio settings
var music_volume := 0.8:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		AudioManager.set_music_volume(music_volume)
		_save_setting("music_volume", music_volume)
		settings_changed.emit("music_volume", music_volume)

var sfx_volume := 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)
		AudioManager.set_sfx_volume(sfx_volume)
		_save_setting("sfx_volume", sfx_volume)
		settings_changed.emit("sfx_volume", sfx_volume)

# Display settings
var fullscreen := false:
	set(value):
		fullscreen = value
		_apply_fullscreen()
		_save_setting("fullscreen", fullscreen)
		settings_changed.emit("fullscreen", fullscreen)

var vsync_enabled := true:
	set(value):
		vsync_enabled = value
		_apply_vsync()
		_save_setting("vsync_enabled", vsync_enabled)
		settings_changed.emit("vsync_enabled", vsync_enabled)

var window_size := Vector2i(480, 720):
	set(value):
		window_size = value
		_apply_window_size()
		_save_setting("window_size", window_size)
		settings_changed.emit("window_size", window_size)

func _ready() -> void:
	# Wait for other managers to be ready
	await get_tree().process_frame
	load_settings()

## Load all settings from save file
func load_settings() -> void:
	# Load settings from slot 0 (reserved for settings)
	var data := SaveManager.load_game(0)
	
	if data.is_empty():
		# No settings file, use defaults
		print("No settings found, using defaults")
		_apply_all_settings()
		save_settings()
		return
	
	music_volume = data.get("music_volume", 0.8)
	sfx_volume = data.get("sfx_volume", 1.0)
	fullscreen = data.get("fullscreen", false)
	vsync_enabled = data.get("vsync_enabled", true)
	window_size = data.get("window_size", Vector2i(480, 720))
	
	# Apply settings
	_apply_all_settings()
	
	settings_loaded.emit()
	print("Settings loaded")

## Reset all settings to defaults
func reset_to_defaults() -> void:
	music_volume = 0.8
	sfx_volume = 1.0
	fullscreen = false
	vsync_enabled = true
	window_size = Vector2i(480, 720)
	
	_apply_all_settings()
	settings_reset.emit()
	print("Settings reset to defaults")

## Audio setters (with validation)
func set_music_volume(volume: float) -> void:
	music_volume = volume

func set_sfx_volume(volume: float) -> void:
	sfx_volume = volume

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

## Display setters
func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled

func set_vsync(enabled: bool) -> void:
	vsync_enabled = enabled

func set_window_size(size: Vector2i) -> void:
	window_size = size

func is_fullscreen() -> bool:
	return fullscreen

## Input rebinding
func rebind_action(action_name: String, event: InputEvent) -> void:
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	
	# Save to file (simplified - full implementation would serialize InputEvent)
	_save_setting("input_%s" % action_name, event)
	settings_changed.emit("input", action_name)

## Get current binding for action
func get_action_events(action_name: String) -> Array[InputEvent]:
	return InputMap.action_get_events(action_name)

# Private methods

func _save_setting(key: String, value: Variant) -> void:
	# Debounced save (avoid saving on every slider drag)
	if not _save_timer:
		_save_timer = Timer.new()
		add_child(_save_timer)
		_save_timer.one_shot = true
		_save_timer.timeout.connect(save_settings)
	
	_save_timer.start(0.5)  # Save after 0.5s of no changes

var _save_timer: Timer = null

func save_settings() -> void:
	var data := {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"fullscreen": fullscreen,
		"vsync_enabled": vsync_enabled,
		"window_size": window_size
	}
	
	SaveManager.save_game(0, data)  # Slot 0 reserved for settings

func _apply_all_settings() -> void:
	_apply_fullscreen()
	_apply_vsync()
	_apply_window_size()
	AudioManager.set_music_volume(music_volume)
	AudioManager.set_sfx_volume(sfx_volume)

func _apply_fullscreen() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _apply_vsync() -> void:
	if vsync_enabled:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _apply_window_size() -> void:
	if not fullscreen:
		DisplayServer.window_set_size(window_size)
