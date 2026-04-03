extends CanvasLayer

## HUD - displays score and game state
## Only listens to GameManager signals, never modifies state

@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var ready_label: Label = $MarginContainer/VBoxContainer/ReadyLabel
@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var high_score_label: Label = $GameOverPanel/VBoxContainer/HighScoreLabel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_over_triggered.connect(_on_game_over)
	
	restart_button.pressed.connect(_on_restart_pressed)
	
	_update_display()

func _update_display() -> void:
	score_label.text = str(GameManager.score)
	
	match GameManager.state:
		GameEnums.GameState.READY:
			ready_label.visible = true
			game_over_panel.visible = false
		GameEnums.GameState.PLAYING:
			ready_label.visible = false
			game_over_panel.visible = false
		GameEnums.GameState.GAME_OVER:
			ready_label.visible = false
			game_over_panel.visible = true

func _on_score_changed(new_score: int) -> void:
	score_label.text = str(new_score)

func _on_game_started() -> void:
	ready_label.visible = false

func _on_game_over() -> void:
	game_over_panel.visible = true
	final_score_label.text = "Score: %d" % GameManager.score
	high_score_label.text = "Best: %d" % GameManager.high_score

func _on_restart_pressed() -> void:
	GameManager.restart()
