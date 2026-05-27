extends Control

func _ready() -> void:
	$NewGameButton.grab_focus()
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		$LoadGameButton.disabled = false
		
func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("ui_accept")):
		var focused_node = get_viewport().gui_get_focus_owner()
		if focused_node and focused_node is BaseButton:
			focused_node.emit_signal("pressed")#ocused_node._pressed()  # Internal method, works but not recommended for public API
			
func _on_load_game_button_pressed() -> void:
	SaveManager.load_checkpoint()


func _on_new_game_button_pressed() -> void:
	SaveManager.delete_save()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://test.tscn")
	
func _on_Viewport_gui_focus_changed(new_focus):
	if new_focus == null:
		$VBoxContainer.get_child(0).grab_focus() # Focus the first menu item

func _on_options_button_pressed() -> void:
	pass # Replace with function body.
