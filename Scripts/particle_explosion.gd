extends Node3D

func _ready():

	$AnimationPlayer.play("play")
	await get_tree().create_timer(2.0).timeout

	queue_free()
