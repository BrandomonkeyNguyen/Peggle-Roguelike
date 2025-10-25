extends Node2D
class_name MainMenu

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
