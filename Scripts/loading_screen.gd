extends Node3D

var main_menu = preload("res://Scenes/main_menu.tscn")
const EXPLOSION_SCENE = preload(
	"res://Scenes/particle_explosion.tscn"
)
const PLAYER_SCENE = preload("res://Scenes/player.tscn")

const WORLD_SCENE = preload("res://Scenes/Levels/world.tscn")
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	var explosion = EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(explosion)
	await get_tree().create_timer(1).timeout
	explosion.queue_free()
	var player = PLAYER_SCENE.instantiate()
	get_tree().current_scene.add_child(player)
	await get_tree().create_timer(1).timeout
	player.queue_free()
	var world = WORLD_SCENE.instantiate()
	get_tree().current_scene.add_child(world)
	await get_tree().create_timer(1).timeout
	world.queue_free()
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	get_tree().change_scene_to_packed(main_menu)
