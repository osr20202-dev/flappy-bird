class_name GameConstants
extends RefCounted

## Game-wide constants template
## 
## Usage:
## 1. Copy this file to your project: scripts/config/constants.gd
## 2. Remove "class_name GameConstants" if using as Autoload
## 3. Customize values for your game
## 4. Optional: Register as Autoload "Constants"

# Game info
const GAME_TITLE := "My Game"
const VERSION := "1.0.0"

# Player
const PLAYER_MAX_HP := 100
const PLAYER_SPEED := 200.0

# Physics
const GRAVITY := 980.0

# Layers (collision/render)
const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const LAYER_WORLD := 4

# Paths
const PATH_SAVES := "user://saves/"
const PATH_CONFIG := "user://config.cfg"
