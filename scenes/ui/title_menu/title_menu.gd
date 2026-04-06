extends CanvasLayer

## Title Menu - Main entry point
## Handles navigation to game, options, and save slots

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var save_slots_button: Button = $CenterContainer/VBoxContainer/SaveSlotsButton
@onready var options_button: Button = $CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var current_slot_label: Label = $CenterContainer/VBoxContainer/CurrentSlotLabel

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	save_slots_button.pressed.connect(_on_save_slots_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	_update_slot_display()

func _update_slot_display() -> void:
	var slot := GameManager.current_slot
	var meta := SaveManager.get_slot_metadata(slot)
	if meta.is_valid:
		current_slot_label.text = "Slot %d — Best: %d" % [slot, _get_high_score(slot)]
	else:
		current_slot_label.text = "Slot %d — New Game" % slot

func _get_high_score(slot: int) -> int:
	var data := SaveManager.load_game(slot)
	return data.get("high_score", 0)

func _on_start_pressed() -> void:
	SceneManager.change_scene("res://scenes/main/main.tscn")

func _on_save_slots_pressed() -> void:
	SceneManager.change_scene("res://scenes/ui/save_slots/save_slots.tscn")

func _on_options_pressed() -> void:
	SceneManager.change_scene("res://scenes/ui/options_menu/options_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
