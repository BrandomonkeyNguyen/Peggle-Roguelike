extends Node2D
class_name MainMenu

func _ready() -> void:
	var save_file = FileAccess.open("user://save_data.json", FileAccess.READ)
	if save_file:
		var save_data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		if "money" in save_data and "turnCount" in save_data:
			$SaveData.text = "Turn " + str(save_data.turnCount) + ", $" + str(save_data.money)
	else:
		$SaveData.text = "No save data found"
	
	var high_scores_file = FileAccess.open("user://high_scores.json", FileAccess.READ)
	if high_scores_file:
		var high_scores = JSON.parse_string(high_scores_file.get_as_text())
		high_scores_file.close()
		if "money" in high_scores and "turnCount" in high_scores:
			$HighScores.text = "Turn " + str(high_scores.turnCount) + ", $" + str(high_scores.money)
	else:
		$HighScores.text = "No high scores found"

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
