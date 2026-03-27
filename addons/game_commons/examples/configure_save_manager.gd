extends Node

## Example: How to configure SaveManager on game startup
##
## Place this in your game's autoload or main scene _ready()

func _ready() -> void:
	configure_save_manager()

func configure_save_manager() -> void:
	# Example 1: Simple arcade game (1 slot only)
	# SaveManager.set_max_slots(1)
	
	# Example 2: Standard game (3 slots) - DEFAULT
	SaveManager.set_max_slots(3)
	
	# Example 3: RPG with many slots
	# SaveManager.set_max_slots(10)
	
	# Example 4: Enable encryption for competitive games
	# SaveManager.set_encryption_enabled(true)
	
	# Example 5: Disable auto-backup (not recommended)
	# SaveManager.set_auto_backup(false)
	
	# Example 6: Adjust backup rotation count
	# SaveManager.max_backup_count = 5
	
	print("SaveManager configured: %d slots available" % SaveManager.get_max_slots())

## Example: Different configs per game type

func configure_for_arcade_game() -> void:
	# Single save slot, no encryption needed
	SaveManager.set_max_slots(1)
	SaveManager.set_encryption_enabled(false)

func configure_for_rpg() -> void:
	# Multiple slots, backup important
	SaveManager.set_max_slots(5)
	SaveManager.set_auto_backup(true)
	SaveManager.max_backup_count = 3

func configure_for_competitive_game() -> void:
	# Few slots, encryption to prevent cheating
	SaveManager.set_max_slots(3)
	SaveManager.set_encryption_enabled(true)

func configure_for_roguelite() -> void:
	# 1 run slot + meta progression
	SaveManager.set_max_slots(2)  # Slot 1: current run, Slot 2: meta
	SaveManager.set_encryption_enabled(false)
