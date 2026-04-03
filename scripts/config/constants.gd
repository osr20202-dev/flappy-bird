class_name GameConstants
extends RefCounted

## Flappy Bird game constants

# Physics
const GRAVITY := 980.0
const BIRD_FLAP_FORCE := -300.0
const BIRD_MAX_FALL_SPEED := 500.0

# Gameplay
const PIPE_SPEED := 150.0
const PIPE_SPAWN_INTERVAL := 2.0  # seconds
const PIPE_GAP_SIZE := 150.0
const GROUND_HEIGHT := 100.0

# Scoring
const SCORE_PER_PIPE := 1

# Screen bounds
const SCREEN_WIDTH := 480.0
const SCREEN_HEIGHT := 720.0
