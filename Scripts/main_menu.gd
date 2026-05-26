extends Control

func _ready() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		$LoadGameButton.disabled = false

func _on_load_game_button_pressed() -> void:
	SaveManager.load_checkpoint()


func _on_new_game_button_pressed() -> void:
	SaveManager.delete_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://test.tscn")

func _on_options_button_pressed() -> void:
	pass # Replace with function body.
