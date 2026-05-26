extends Area3D

func _on_body_entered(body):

	if body.is_in_group("player"):

		SaveManager.save_checkpoint(
		get_tree().current_scene.scene_file_path,
		body.global_position,
		body.health)

		body.health = body.max_health

		print("Checkpoint reached")
