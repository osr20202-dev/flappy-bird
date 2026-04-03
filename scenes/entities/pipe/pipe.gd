extends Node2D

## Pipe pair entity - moves left and detects scoring
## Does NOT modify score directly, just emits signals

signal scored
signal exited_screen

@export var speed := GameConstants.PIPE_SPEED

var has_scored := false

func _process(delta: float) -> void:
	position.x -= speed * delta
	
	# Check if exited screen
	if position.x < -100:
		exited_screen.emit()
		queue_free()

func _on_score_area_body_entered(body: Node2D) -> void:
	if body.name == "Bird" and not has_scored:
		has_scored = true
		scored.emit()
