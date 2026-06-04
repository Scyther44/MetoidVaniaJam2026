extends Control

func _process(_delta):
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		$Reload.disabled = false

func _input(event):

	if event.is_action_pressed("pause"):

		if get_tree().paused:
			resume()
		else:
			pause()


func pause():
	$Resume.grab_focus.call_deferred()
	
	visible = true
	get_tree().paused = true


func resume():

	visible = false
	get_tree().paused = false


func _on_resume_pressed():

	resume()

func _on_quit_pressed():

	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_reload_pressed() -> void:
	SaveManager.load_checkpoint()
