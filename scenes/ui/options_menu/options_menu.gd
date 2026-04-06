extends CanvasLayer

## Options Menu - audio, display settings
## Reads/writes through SettingsManager

@onready var music_slider: HSlider = $CenterContainer/VBoxContainer/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/VBoxContainer/SfxRow/SfxSlider
@onready var fullscreen_check: CheckBox = $CenterContainer/VBoxContainer/FullscreenCheck
@onready var vsync_check: CheckBox = $CenterContainer/VBoxContainer/VsyncCheck
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	# Load current values
	music_slider.value = SettingsManager.get_music_volume()
	sfx_slider.value = SettingsManager.get_sfx_volume()
	fullscreen_check.button_pressed = SettingsManager.is_fullscreen()
	vsync_check.button_pressed = SettingsManager.vsync_enabled

	# Connect signals
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
	SettingsManager.set_music_volume(value)

func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)

func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsManager.set_fullscreen(enabled)

func _on_vsync_toggled(enabled: bool) -> void:
	SettingsManager.set_vsync(enabled)

func _on_back_pressed() -> void:
	SceneManager.change_scene("res://scenes/ui/title_menu/title_menu.tscn")
