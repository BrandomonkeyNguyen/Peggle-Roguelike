extends Node2D
class_name MainMenu

func _ready() -> void:
	var save_file = FileAccess.open("user://save_data.json", FileAccess.READ)
	var save_data = JSON.parse_string(save_file.get_as_text())
	save_file.close()
	$SaveData.text = "Turn " + str(save_data.turnCount) + ", $" + str(save_data.money)
	
	var high_scores_file = FileAccess.open("user://high_scores.json", FileAccess.READ)
	var high_scores = JSON.parse_string(high_scores_file.get_as_text())
	high_scores_file.close()
	$HighScores.text = "Turn " + str(high_scores.turnCount) + ", $" + str(high_scores.money)

func _on_play_button_pressed() -> void:
	if not $ToggleLastSave.button_pressed:
		var save_file = "user://save_data.json"
		var file = FileAccess.open(save_file, FileAccess.WRITE)
		file.store_string("")
		file.close()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_level_editor_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
