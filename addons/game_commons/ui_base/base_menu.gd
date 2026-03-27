extends Control
class_name BaseMenu

## Base class for all menus (main menu, pause, options, etc.)
## Provides common functionality: show/hide animations, input handling
## 
## Inherit this in your game-specific menu scripts:
##   extends BaseMenu

signal menu_opened
signal menu_closed

@export var can_pause := true
@export var fade_duration := 0.2

var _is_open := false

func _ready() -> void:
	# Hide by default
	if not visible:
		modulate.a = 0.0
		_is_open = false

func open_menu() -> void:
	if _is_open:
		return
	
	visible = true
	_is_open = true
	
	# Fade in
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	await tween.finished
	
	menu_opened.emit()

func close_menu() -> void:
	if not _is_open:
		return
	
	_is_open = false
	
	# Fade out
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween.finished
	
	visible = false
	menu_closed.emit()

func is_menu_open() -> bool:
	return _is_open
