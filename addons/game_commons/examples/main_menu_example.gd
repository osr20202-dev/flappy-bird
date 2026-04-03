## Example: Game-specific main menu
## 
## This is a TEMPLATE. Copy this to your game's scenes/ui/ folder and:
## 1. Create a scene with Control root node
## 2. Attach this script to the root
## 3. Design your menu layout (buttons, labels, background)
## 4. Update @onready paths to match YOUR scene structure
## 5. Uncomment and customize the code below

# Uncomment and use in your actual game scene:
#
# extends BaseMenu
#
# @onready var play_button: Button = $VBoxContainer/PlayButton
# @onready var options_button: Button = $VBoxContainer/OptionsButton
# @onready var quit_button: Button = $VBoxContainer/QuitButton
#
# func _ready() -> void:
#     super._ready()
#     play_button.pressed.connect(_on_play_pressed)
#     options_button.pressed.connect(_on_options_pressed)
#     quit_button.pressed.connect(_on_quit_pressed)
#
# func _on_play_pressed() -> void:
#     SceneManager.change_scene("res://scenes/game/game.tscn")
#
# func _on_options_pressed() -> void:
#     # Open options menu
#     pass
#
# func _on_quit_pressed() -> void:
#     get_tree().quit()
