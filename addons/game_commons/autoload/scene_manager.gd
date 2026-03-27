extends Node

## Scene transition manager with optional fade effect
##
## Usage:
##   SceneManager.change_scene("res://scenes/game.tscn")
##   SceneManager.change_scene_with_fade("res://scenes/menu.tscn", 0.5)

signal scene_changed(new_scene_path: String)

var current_scene: Node = null

func _ready() -> void:
	var root := get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

## Change scene instantly
func change_scene(scene_path: String) -> void:
	call_deferred("_deferred_change_scene", scene_path)

## Change scene with fade transition
func change_scene_with_fade(scene_path: String, fade_duration := 0.3) -> void:
	# TODO: Implement fade overlay (optional, game-specific)
	change_scene(scene_path)

## Reload current scene
func reload_current_scene() -> void:
	get_tree().reload_current_scene()

func _deferred_change_scene(scene_path: String) -> void:
	if current_scene:
		current_scene.free()
	
	var new_scene_resource := load(scene_path) as PackedScene
	if not new_scene_resource:
		push_error("Failed to load scene: %s" % scene_path)
		return
	
	current_scene = new_scene_resource.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene
	
	scene_changed.emit(scene_path)
