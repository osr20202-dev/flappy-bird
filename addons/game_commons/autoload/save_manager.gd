extends Node

## Advanced Save Manager with slots, encryption, backup, and versioning
##
## Features:
## - Multiple save slots (1-99)
## - Hierarchical JSON data structure
## - Automatic backup (.bak files)
## - Optional XOR encryption (anti-cheat)
## - Checksum validation (corruption detection)
## - Save metadata (timestamp, playtime, custom data)
## - Version migration support
##
## Usage:
##   var data := { "player": { "hp": 100 }, "world": { "day": 5 } }
##   SaveManager.save_game(1, data, { "playtime": 3600 })
##   var loaded = SaveManager.load_game(1)
##   var slots = SaveManager.list_slots()

signal save_started(slot: int)
signal save_completed(slot: int, success: bool)
signal load_started(slot: int)
signal load_completed(slot: int, success: bool)
signal slot_deleted(slot: int)

class SlotMetadata extends RefCounted:
	var slot_index: int
	var save_time: String  # ISO 8601 format
	var playtime_seconds: int
	var custom_metadata: Dictionary  # Game-specific data (e.g., player name, level)
	var version: String
	var is_valid: bool
	
	func to_dict() -> Dictionary:
		return {
			"slot_index": slot_index,
			"save_time": save_time,
			"playtime_seconds": playtime_seconds,
			"custom_metadata": custom_metadata,
			"version": version
		}
	
	static func from_dict(data: Dictionary) -> SlotMetadata:
		var meta := SlotMetadata.new()
		meta.slot_index = data.get("slot_index", 0)
		meta.save_time = data.get("save_time", "")
		meta.playtime_seconds = data.get("playtime_seconds", 0)
		meta.custom_metadata = data.get("custom_metadata", {})
		meta.version = data.get("version", "1.0.0")
		meta.is_valid = true
		return meta

# Constants
const SAVE_DIR := "user://saves/"
const SAVE_VERSION := "1.0.0"
const ENCRYPTION_KEY := "MyGameSecretKey2026"  # Change this per-game!

# Settings
var encryption_enabled := false
var auto_backup := true
var max_backup_count := 3

func _ready() -> void:
	_ensure_save_directory()

## Save game data to specified slot
func save_game(slot: int, data: Dictionary, custom_metadata := {}) -> bool:
	if slot < 1 or slot > 99:
		push_error("Invalid slot number: %d (must be 1-99)" % slot)
		return false
	
	save_started.emit(slot)
	
	var success := _save_slot(slot, data, custom_metadata)
	
	save_completed.emit(slot, success)
	return success

## Load game data from specified slot
func load_game(slot: int) -> Dictionary:
	if slot < 1 or slot > 99:
		push_error("Invalid slot number: %d" % slot)
		return {}
	
	load_started.emit(slot)
	
	var data := _load_slot(slot)
	var success := not data.is_empty()
	
	load_completed.emit(slot, success)
	return data

## Delete save slot (with backup)
func delete_slot(slot: int) -> bool:
	var path := _get_slot_path(slot)
	
	if not FileAccess.file_exists(path):
		return false
	
	# Backup before deletion
	if auto_backup:
		var backup_path := path + ".deleted"
		DirAccess.copy_absolute(path, backup_path)
	
	DirAccess.remove_absolute(path)
	slot_deleted.emit(slot)
	
	print("Slot %d deleted" % slot)
	return true

## Check if slot exists
func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(_get_slot_path(slot))

## Get metadata for a specific slot (without loading full data)
func get_slot_metadata(slot: int) -> SlotMetadata:
	var path := _get_slot_path(slot)
	
	if not FileAccess.file_exists(path):
		var empty := SlotMetadata.new()
		empty.is_valid = false
		return empty
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open slot %d for metadata read" % slot)
		var empty := SlotMetadata.new()
		empty.is_valid = false
		return empty
	
	var raw_data := file.get_buffer(file.get_length())
	file.close()
	
	if encryption_enabled:
		raw_data = _decrypt(raw_data)
	
	var json_string := raw_data.get_string_from_utf8()
	var parsed = JSON.parse_string(json_string)
	
	if not parsed or not parsed is Dictionary:
		var empty := SlotMetadata.new()
		empty.is_valid = false
		return empty
	
	var wrapper: Dictionary = parsed
	return SlotMetadata.from_dict(wrapper.get("metadata", {}))

## List all available save slots with metadata
func list_slots() -> Array[SlotMetadata]:
	var slots: Array[SlotMetadata] = []
	
	for i in range(1, 100):
		if slot_exists(i):
			slots.append(get_slot_metadata(i))
	
	return slots

## Enable or disable encryption
func set_encryption_enabled(enabled: bool) -> void:
	encryption_enabled = enabled
	print("Save encryption: %s" % ("enabled" if enabled else "disabled"))

## Enable or disable auto-backup
func set_auto_backup(enabled: bool) -> void:
	auto_backup = enabled

# Private methods

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func _get_slot_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.json" % slot

func _save_slot(slot: int, game_data: Dictionary, custom_metadata: Dictionary) -> bool:
	var path := _get_slot_path(slot)
	
	# Backup existing save
	if auto_backup and FileAccess.file_exists(path):
		_create_backup(slot)
	
	# Create metadata
	var metadata := SlotMetadata.new()
	metadata.slot_index = slot
	metadata.save_time = Time.get_datetime_string_from_system()
	metadata.playtime_seconds = custom_metadata.get("playtime_seconds", 0)
	metadata.custom_metadata = custom_metadata
	metadata.version = SAVE_VERSION
	
	# Wrap data with metadata and checksum
	var wrapper := {
		"metadata": metadata.to_dict(),
		"data": game_data,
		"checksum": _calculate_checksum(game_data),
		"version": SAVE_VERSION
	}
	
	# Serialize to JSON
	var json_string := JSON.stringify(wrapper, "\t")  # Pretty print
	var data_bytes := json_string.to_utf8_buffer()
	
	# Encrypt if enabled
	if encryption_enabled:
		data_bytes = _encrypt(data_bytes)
	
	# Write to file
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: %s" % path)
		return false
	
	file.store_buffer(data_bytes)
	file.close()
	
	print("Game saved to slot %d" % slot)
	return true

func _load_slot(slot: int) -> Dictionary:
	var path := _get_slot_path(slot)
	
	if not FileAccess.file_exists(path):
		push_warning("Slot %d does not exist" % slot)
		return {}
	
	# Read file
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open slot %d for reading" % slot)
		return _try_load_backup(slot)
	
	var raw_data := file.get_buffer(file.get_length())
	file.close()
	
	# Decrypt if needed
	if encryption_enabled:
		raw_data = _decrypt(raw_data)
	
	# Parse JSON
	var json_string := raw_data.get_string_from_utf8()
	var parsed = JSON.parse_string(json_string)
	
	if not parsed or not parsed is Dictionary:
		push_error("Corrupted save file in slot %d" % slot)
		return _try_load_backup(slot)
	
	var wrapper: Dictionary = parsed
	
	# Validate version
	var file_version: String = wrapper.get("version", "1.0.0")
	if file_version != SAVE_VERSION:
		push_warning("Save version mismatch: %s (current: %s)" % [file_version, SAVE_VERSION])
		# TODO: Implement version migration here
	
	# Validate checksum
	var game_data: Dictionary = wrapper.get("data", {})
	var stored_checksum: String = wrapper.get("checksum", "")
	var calculated_checksum := _calculate_checksum(game_data)
	
	if stored_checksum != calculated_checksum:
		push_error("Checksum mismatch! Save file may be corrupted.")
		return _try_load_backup(slot)
	
	print("Game loaded from slot %d" % slot)
	return game_data

func _create_backup(slot: int) -> void:
	var path := _get_slot_path(slot)
	var backup_path := path + ".bak"
	
	# Rotate backups if max count reached
	if max_backup_count > 1:
		for i in range(max_backup_count - 1, 0, -1):
			var old_backup := path + ".bak" + ("" if i == 1 else str(i))
			var new_backup := path + ".bak" + str(i + 1)
			
			if FileAccess.file_exists(old_backup):
				if FileAccess.file_exists(new_backup):
					DirAccess.remove_absolute(new_backup)
				DirAccess.rename_absolute(old_backup, new_backup)
	
	DirAccess.copy_absolute(path, backup_path)

func _try_load_backup(slot: int) -> Dictionary:
	var backup_path := _get_slot_path(slot) + ".bak"
	
	if not FileAccess.file_exists(backup_path):
		push_error("No backup found for slot %d" % slot)
		return {}
	
	push_warning("Attempting to load backup for slot %d..." % slot)
	
	# Try loading backup (simplified, no checksum validation on backup)
	var file := FileAccess.open(backup_path, FileAccess.READ)
	if not file:
		return {}
	
	var raw_data := file.get_buffer(file.get_length())
	file.close()
	
	if encryption_enabled:
		raw_data = _decrypt(raw_data)
	
	var json_string := raw_data.get_string_from_utf8()
	var parsed = JSON.parse_string(json_string)
	
	if not parsed:
		return {}
	
	return parsed.get("data", {})

func _calculate_checksum(data: Dictionary) -> String:
	var json := JSON.stringify(data)
	return json.md5_text()

func _encrypt(data: PackedByteArray) -> PackedByteArray:
	# Simple XOR encryption (good enough for save files)
	var key := ENCRYPTION_KEY.to_utf8_buffer()
	var encrypted := data.duplicate()
	
	for i in encrypted.size():
		encrypted[i] ^= key[i % key.size()]
	
	return encrypted

func _decrypt(data: PackedByteArray) -> PackedByteArray:
	# XOR is symmetric
	return _encrypt(data)
