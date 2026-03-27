class_name GameEnums
extends RefCounted

## Common game enums template
##
## Usage:
## 1. Copy to your project: scripts/config/enums.gd
## 2. Add/remove enums as needed

enum PlayerState {
	IDLE,
	MOVING,
	JUMPING,
	DEAD
}

enum Direction {
	LEFT = -1,
	RIGHT = 1
}

enum ItemRarity {
	COMMON,
	RARE,
	EPIC
}
