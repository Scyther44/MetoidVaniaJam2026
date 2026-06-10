extends Area3D

func _on_body_entered(body):

	if body.is_in_group("player"):
		$ParticleBonfire/AnimationPlayer.play("RESET")
		$ParticleBonfire/AnimationPlayer.play("play")
		body.health = body.max_health

		SaveManager.player_health = body.health
		SaveManager.player_max_health = body.max_health

		SaveManager.has_side_blast = body.is_side_attack_unlocked
		SaveManager.has_down_blast = body.is_down_attack_unlocked

		SaveManager.save_checkpoint(
			get_tree().current_scene.scene_file_path,
			body.global_position,
			body.health
		)

		print("Checkpoint reached")
