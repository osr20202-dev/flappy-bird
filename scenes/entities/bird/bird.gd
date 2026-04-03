extends CharacterBody2D

## Bird entity - handles physics and input only
## Does NOT know about game state or scoring

signal died

@export var flap_force := GameConstants.BIRD_FLAP_FORCE
@export var gravity := GameConstants.GRAVITY
@export var max_fall_speed := GameConstants.BIRD_MAX_FALL_SPEED

var is_alive := true

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Apply gravity
	velocity.y += gravity * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	
	# Handle input
	if Input.is_action_just_pressed("flap"):
		flap()
	
	# Update rotation based on velocity
	rotation = lerpf(-PI/6, PI/2, (velocity.y + 300) / 800)
	
	move_and_slide()
	
	# Check collision
	if get_slide_collision_count() > 0:
		die()

func flap() -> void:
	if not is_alive:
		return
	
	velocity.y = flap_force
	# TODO: Play flap sound

func die() -> void:
	if not is_alive:
		return
	
	is_alive = false
	died.emit()
	# TODO: Play death sound

func reset() -> void:
	is_alive = true
	velocity = Vector2.ZERO
	rotation = 0.0
	position = Vector2(GameConstants.SCREEN_WIDTH / 4, GameConstants.SCREEN_HEIGHT / 2)
