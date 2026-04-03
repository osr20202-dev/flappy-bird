extends Node2D

## Game scene - orchestrates entities
## Connects entity signals to GameManager
## Handles pipe spawning

const PIPE_SCENE := preload("res://scenes/entities/pipe/pipe.tscn")

@onready var bird: CharacterBody2D = $Bird
@onready var spawn_timer: Timer = $SpawnTimer

var pipes: Array[Node2D] = []

func _ready() -> void:
	# Connect bird signals
	bird.died.connect(_on_bird_died)
	
	# Connect GameManager signals
	GameManager.game_started.connect(_on_game_started)
	
	# Setup spawn timer
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _input(event: InputEvent) -> void:
	# Start game on first input (when READY)
	if GameManager.state == GameEnums.GameState.READY:
		if event.is_action_pressed("flap"):
			GameManager.start_game()

func _on_game_started() -> void:
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if GameManager.state != GameEnums.GameState.PLAYING:
		return
	
	spawn_pipe()

func spawn_pipe() -> void:
	var pipe := PIPE_SCENE.instantiate()
	
	# Random gap position
	var gap_y := randf_range(150, 500)
	pipe.position = Vector2(GameConstants.SCREEN_WIDTH + 50, gap_y)
	
	# Connect pipe signals
	pipe.scored.connect(_on_pipe_scored)
	
	add_child(pipe)
	pipes.append(pipe)

func _on_pipe_scored() -> void:
	GameManager.add_score(GameConstants.SCORE_PER_PIPE)

func _on_bird_died() -> void:
	spawn_timer.stop()
	GameManager.game_over()
