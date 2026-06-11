extends Node3D
signal boss_dead
signal boss_active

func _on_ghost_chase_enemy_boss_dead() -> void:
	emit_signal("boss_dead")


func _on_ghost_chase_enemy_boss_active() -> void:
	emit_signal("boss_active")
