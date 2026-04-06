extends Node

## Manages core game state for Flappy Bird

signal score_changed(new_score: int)
signal game_started
signal game_over_triggered
signal high_score_beaten
signal slot_changed(new_slot: int)

var state: GameEnums.GameState = GameEnums.GameState.READY
var score: int = 0
var high_score: int = 0
var current_slot: int = 1

func _ready() -> void:
	_load_high_score()

func start_game() -> void:
	state = GameEnums.GameState.PLAYING
	score = 0
	game_started.emit()

func add_score(amount: int) -> void:
	if state != GameEnums.GameState.PLAYING:
		return
	
	score += amount
	score_changed.emit(score)
	
	if score > high_score:
		high_score = score
		high_score_beaten.emit()

func game_over() -> void:
	if state == GameEnums.GameState.GAME_OVER:
		return
	
	state = GameEnums.GameState.GAME_OVER
	_save_high_score()
	game_over_triggered.emit()

func restart() -> void:
	state = GameEnums.GameState.READY
	score = 0
	SceneManager.reload_current_scene()

func return_to_title() -> void:
	state = GameEnums.GameState.READY
	score = 0
	SceneManager.change_scene("res://scenes/ui/title_menu/title_menu.tscn")

func switch_slot(slot: int) -> void:
	current_slot = slot
	_load_high_score()
	slot_changed.emit(current_slot)

func _load_high_score() -> void:
	var data := SaveManager.load_game(current_slot)
	high_score = data.get("high_score", 0)

func _save_high_score() -> void:
	if score > high_score:
		high_score = score
		SaveManager.save_game(current_slot, {"high_score": high_score})
