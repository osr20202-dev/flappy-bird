extends Node

## Example: How to use the advanced SaveManager
##
## This demonstrates:
## - Saving hierarchical game data
## - Loading with slot selection
## - Listing available slots
## - Metadata usage

# Example game data structure
var game_data := {
	"player": {
		"name": "Hero",
		"level": 15,
		"hp": 80,
		"max_hp": 100,
		"position": { "x": 120.5, "y": 340.2 },
		"inventory": [
			{ "id": "sword_iron", "count": 1 },
			{ "id": "potion_health", "count": 5 }
		]
	},
	"world": {
		"current_scene": "town_plaza",
		"time": { "day": 15, "hour": 14, "minute": 30 },
		"weather": "sunny",
		"flags": {
			"talked_to_mayor": true,
			"quest_dragon_started": false,
			"bridge_repaired": true
		}
	},
	"stats": {
		"enemies_defeated": 127,
		"gold_collected": 4520,
		"deaths": 3
	}
}

func _ready() -> void:
	# Example usage
	example_save_and_load()
	example_list_slots()

## Example: Save game to slot 1
func example_save_and_load() -> void:
	print("\n=== Save/Load Example ===")
	
	# Prepare custom metadata (shown in save slot UI)
	var metadata := {
		"playtime_seconds": 3600,  # 1 hour
		"player_name": game_data["player"]["name"],
		"player_level": game_data["player"]["level"],
		"location": game_data["world"]["current_scene"]
	}
	
	# Save to slot 1
	var success := SaveManager.save_game(1, game_data, metadata)
	if success:
		print("✅ Game saved to slot 1")
	
	# Load from slot 1
	var loaded_data := SaveManager.load_game(1)
	if not loaded_data.is_empty():
		print("✅ Game loaded from slot 1")
		print("Player HP: %d" % loaded_data["player"]["hp"])
		print("World Day: %d" % loaded_data["world"]["time"]["day"])

## Example: List all save slots
func example_list_slots() -> void:
	print("\n=== Available Save Slots ===")
	
	var slots := SaveManager.list_slots()
	
	if slots.is_empty():
		print("No save files found")
		return
	
	for slot_meta in slots:
		print("Slot %d:" % slot_meta.slot_index)
		print("  Saved: %s" % slot_meta.save_time)
		print("  Playtime: %d seconds" % slot_meta.playtime_seconds)
		print("  Player: %s (Level %d)" % [
			slot_meta.custom_metadata.get("player_name", "Unknown"),
			slot_meta.custom_metadata.get("player_level", 1)
		])
		print("  Location: %s" % slot_meta.custom_metadata.get("location", "Unknown"))
		print("---")

## Example: Quick save/load (use slot 99 for quick save)
func quick_save() -> void:
	var metadata := {
		"playtime_seconds": 0,  # Replace with actual playtime
		"is_quicksave": true
	}
	SaveManager.save_game(99, game_data, metadata)
	print("Quick save!")

func quick_load() -> void:
	if SaveManager.slot_exists(99):
		var loaded := SaveManager.load_game(99)
		if not loaded.is_empty():
			game_data = loaded
			print("Quick load!")
	else:
		print("No quick save found")

## Example: Delete slot
func delete_save_slot(slot: int) -> void:
	if SaveManager.delete_slot(slot):
		print("Slot %d deleted" % slot)

## Example: Enable encryption
func enable_encryption() -> void:
	SaveManager.set_encryption_enabled(true)
	print("Save encryption enabled")

## Example: Check if slot exists before showing "Continue" button
func can_continue_game() -> bool:
	# Check if slot 1 (auto-save) exists
	return SaveManager.slot_exists(1)
