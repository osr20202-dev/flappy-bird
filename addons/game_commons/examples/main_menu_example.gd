extends BaseMenu

## Example: Game-specific main menu
## 
## This script shows how to use BaseMenu logic with your own UI design.
## Copy this to your game's scenes/ui/ folder and customize:
## 1. Design your menu layout in the scene (buttons, labels, background)
## 2. Connect button signals to these methods
## 3. Apply your game's Theme

# These @onready vars should point to YOUR buttons in YOUR scene
@onready var play_button: Button = $VBoxContainer/PlayButton
@onready var options_button: Button = $VBoxContainer/OptionsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	super._ready()  # Call BaseMenu._ready()
	
	# Connect YOUR buttons (node paths will be different per game)
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if options_button:
		options_button.pressed.connect(_on_options_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	AudioManager.play_sfx(preload("res://addons/game_commons/examples/placeholder_click.wav"))
	# Game-specific: change to your game scene
	SceneManager.change_scene("res://scenes/game/game.tscn")

func _on_options_pressed() -> void:
	AudioManager.play_sfx(preload("res://addons/game_commons/examples/placeholder_click.wav"))
	# Game-specific: open your options menu
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
