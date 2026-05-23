extends CharacterBody3D

var health = 3

@onready var mesh = $MeshInstance3D


func take_damage():

	health -= 1

	print("Enemy hit! Health:", health)

	flash_damage()

	if health <= 0:
		queue_free()


func flash_damage():

	mesh.material_override.albedo_color = Color.RED

	await get_tree().create_timer(0.1).timeout

	mesh.material_override.albedo_color = Color.WHITE
