extends Node

## Game manager template (Autoload)
##
## Manages core game state: score, lives, game over, etc.
## 
## Usage:
## 1. Copy to your project: scripts/autoload/game_manager.gd
## 2. Register as Autoload "GameManager"
## 3. Customize for your game logic

signal score_changed(new_score: int)
signal game_over_triggered
signal game_started

enum State { MENU, PLAYING, PAUSED, GAME_OVER }

var state: State = State.MENU
var score: int = 0
var high_score: int = 0

func _ready() -> void:
	high_score = SaveManager.load_game(0).get("high_score", 0)

func start_game() -> void:
	state = State.PLAYING
	score = 0
	game_started.emit()

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func game_over() -> void:
	state = State.GAME_OVER
	
	if score > high_score:
		high_score = score
		SaveManager.save_game(0, { "high_score": high_score })
	
	game_over_triggered.emit()

func restart() -> void:
	SceneManager.reload_current_scene()
