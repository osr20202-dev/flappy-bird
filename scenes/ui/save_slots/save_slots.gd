extends CanvasLayer

## Save Slots - switch between save slots
## Shows slot status and allows selection/deletion

@onready var slots_container: VBoxContainer = $CenterContainer/VBoxContainer/SlotsContainer
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_build_slot_list()

func _build_slot_list() -> void:
	# Clear existing slot buttons
	for child in slots_container.get_children():
		child.queue_free()

	for i in range(1, SaveManager.get_max_slots() + 1):
		var row := HBoxContainer.new()
		row.name = "SlotRow%d" % i

		# Slot select button
		var btn := Button.new()
		btn.name = "SlotButton%d" % i
		btn.custom_minimum_size = Vector2(220, 45)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var meta := SaveManager.get_slot_metadata(i)
		if meta.is_valid:
			var data := SaveManager.load_game(i)
			var high_score: int = data.get("high_score", 0)
			btn.text = "Slot %d — Best: %d" % [i, high_score]
		else:
			btn.text = "Slot %d — Empty" % i

		# Highlight current slot
		if i == GameManager.current_slot:
			btn.text += "  [current]"

		btn.pressed.connect(_on_slot_selected.bind(i))
		row.add_child(btn)

		# Delete button (only for slots with data)
		var del_btn := Button.new()
		del_btn.name = "DeleteButton%d" % i
		del_btn.custom_minimum_size = Vector2(60, 45)
		del_btn.text = "Del"
		del_btn.disabled = not meta.is_valid
		del_btn.pressed.connect(_on_slot_deleted.bind(i))
		row.add_child(del_btn)

		slots_container.add_child(row)

func _on_slot_selected(slot: int) -> void:
	GameManager.switch_slot(slot)
	_build_slot_list()

func _on_slot_deleted(slot: int) -> void:
	SaveManager.delete_slot(slot)
	if GameManager.current_slot == slot:
		GameManager.switch_slot(slot)
	_build_slot_list()

func _on_back_pressed() -> void:
	SceneManager.change_scene("res://scenes/ui/title_menu/title_menu.tscn")
