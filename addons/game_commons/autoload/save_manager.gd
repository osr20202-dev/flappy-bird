extends Node

## Simple save/load system using ConfigFile
##
## Usage:
##   SaveManager.save_value("game", "high_score", 100)
##   var score = SaveManager.load_value("game", "high_score", 0)

const SAVE_PATH := "user://save.cfg"

var _config := ConfigFile.new()
var _loaded := false

func _ready() -> void:
	load_data()

## Load entire save file
func load_data() -> void:
	var err := _config.load(SAVE_PATH)
	if err == OK:
		_loaded = true
		print("Save file loaded from: %s" % SAVE_PATH)
	else:
		print("No save file found, creating new one")
		_loaded = false

## Save entire save file
func save_data() -> void:
	var err := _config.save(SAVE_PATH)
	if err == OK:
		print("Save file written to: %s" % SAVE_PATH)
	else:
		push_error("Failed to save file: %s" % SAVE_PATH)

## Save a single value
func save_value(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	save_data()

## Load a single value with default fallback
func load_value(section: String, key: String, default: Variant = null) -> Variant:
	if not _loaded:
		return default
	return _config.get_value(section, key, default)

## Check if section exists
func has_section(section: String) -> bool:
	return _config.has_section(section)

## Check if key exists
func has_key(section: String, key: String) -> bool:
	return _config.has_section_key(section, key)

## Erase section
func erase_section(section: String) -> void:
	_config.erase_section(section)
	save_data()

## Clear entire save file
func clear_all() -> void:
	_config.clear()
	save_data()
