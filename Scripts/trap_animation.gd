extends AnimationPlayer


func _on_trap_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player")):
		play("commence_battle")
