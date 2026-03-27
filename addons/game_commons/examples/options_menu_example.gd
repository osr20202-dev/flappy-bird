extends BaseMenu

## Example: Options/Settings menu
##
## This shows how to create a settings menu using SettingsManager.
## Copy to your game and customize the UI layout/styling.

# Sliders (node paths will differ per game)
@onready var music_slider: HSlider = $VBoxContainer/MusicVolume/Slider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXVolume/Slider

# Toggles
@onready var fullscreen_checkbox: CheckBox = $VBoxContainer/Fullscreen/CheckBox
@onready var vsync_checkbox: CheckBox = $VBoxContainer/VSync/CheckBox

# Buttons
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var reset_button: Button = $VBoxContainer/ResetButton

func _ready() -> void:
	super._ready()
	
	# Initialize UI with current settings
	if music_slider:
		music_slider.value = SettingsManager.get_music_volume()
		music_slider.value_changed.connect(_on_music_volume_changed)
	
	if sfx_slider:
		sfx_slider.value = SettingsManager.get_sfx_volume()
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = SettingsManager.is_fullscreen()
		fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled)
	
	if vsync_checkbox:
		vsync_checkbox.button_pressed = SettingsManager.vsync_enabled
		vsync_checkbox.toggled.connect(_on_vsync_toggled)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)
	
	# Listen for settings changes (e.g., from hotkeys)
	SettingsManager.settings_changed.connect(_on_settings_changed)

func _on_music_volume_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)

func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	# Play a test SFX on change
	AudioManager.play_sfx(preload("res://addons/game_commons/examples/placeholder_click.wav"))

func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsManager.set_fullscreen(enabled)

func _on_vsync_toggled(enabled: bool) -> void:
	SettingsManager.set_vsync(enabled)

func _on_back_pressed() -> void:
	close_menu()

func _on_reset_pressed() -> void:
	SettingsManager.reset_to_defaults()
	
	# Update UI to reflect reset values
	if music_slider:
		music_slider.value = SettingsManager.get_music_volume()
	if sfx_slider:
		sfx_slider.value = SettingsManager.get_sfx_volume()
	if fullscreen_checkbox:
		fullscreen_checkbox.button_pressed = SettingsManager.is_fullscreen()
	if vsync_checkbox:
		vsync_checkbox.button_pressed = SettingsManager.vsync_enabled

func _on_settings_changed(setting_name: String, value: Variant) -> void:
	# React to external settings changes (e.g., from keybinds)
	match setting_name:
		"music_volume":
			if music_slider:
				music_slider.value = value
		"sfx_volume":
			if sfx_slider:
				sfx_slider.value = value
		"fullscreen":
			if fullscreen_checkbox:
				fullscreen_checkbox.button_pressed = value
		"vsync_enabled":
			if vsync_checkbox:
				vsync_checkbox.button_pressed = value
