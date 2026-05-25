extends Node3D

func _ready():

	$Fire.restart()
	$Smoke.restart()
	$Sparks.restart()
	$Shockwave.restart()
	await get_tree().create_timer(2.0).timeout

	queue_free()
