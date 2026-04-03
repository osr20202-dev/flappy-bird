extends Node

## Manages core game state for Flappy Bird

signal score_changed(new_score: int)
signal game_started
signal game_over_triggered
signal high_score_beaten

var state: GameEnums.GameState = GameEnums.GameState.READY
var score: int = 0
var high_score: int = 0

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

func _load_high_score() -> void:
	var data := SaveManager.load_game(0)
	high_score = data.get("high_score", 0)

func _save_high_score() -> void:
	if score > high_score:
		high_score = score
		SaveManager.save_game(0, {"high_score": high_score})
