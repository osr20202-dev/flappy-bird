@tool
extends EditorPlugin

func _enter_tree() -> void:
	print("Game Commons addon enabled")
	
	# Register autoload singletons
	add_autoload_singleton("SceneManager", "res://addons/game_commons/autoload/scene_manager.gd")
	add_autoload_singleton("AudioManager", "res://addons/game_commons/autoload/audio_manager.gd")
	add_autoload_singleton("SaveManager", "res://addons/game_commons/autoload/save_manager.gd")

func _exit_tree() -> void:
	print("Game Commons addon disabled")
	
	# Remove autoload singletons
	remove_autoload_singleton("SceneManager")
	remove_autoload_singleton("AudioManager")
	remove_autoload_singleton("SaveManager")
