extends AnimationPlayer

var is_trapped_triggered = false

func _on_trap_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player") and !is_trapped_triggered):
		is_trapped_triggered = true
		play("commence_battle")


func _on_ghost_chase_enemy_boss_dead() -> void:
	play("end_battle")
