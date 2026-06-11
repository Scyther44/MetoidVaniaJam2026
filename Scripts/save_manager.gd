extends Node

const SAVE_PATH = "user://savegame.json"

var checkpoint_scene = ""
var checkpoint_position = Vector3.ZERO
var player_health = 1
var player_max_health = 1

var has_side_blast = false
var has_down_blast = false
var has_inital_dialog_been_shown = false

var collected_pickups = []



func save_checkpoint(scene_path, position, health):

	checkpoint_scene = scene_path
	checkpoint_position = position
	player_health = health

	var save_data = {
		"scene": checkpoint_scene,
		"x": checkpoint_position.x,
		"y": checkpoint_position.y,
		"z": checkpoint_position.z,
		"health": player_health,
		"max_health": player_max_health,
		"side_blast": has_side_blast,
		"down_blast": has_down_blast,
		"pickups": collected_pickups,
		"dialog": has_inital_dialog_been_shown
	}

	print("Saving at path: " + SAVE_PATH)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	file.store_string(JSON.stringify(save_data))

	print("Game Saved")


func load_checkpoint():

	if !FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		return

	get_tree().paused = false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	var json_text = file.get_as_text()

	var data = JSON.parse_string(json_text)

	if data == null:
		print("Save corrupted")
		return

	checkpoint_scene = data["scene"]
	player_max_health = data["max_health"]
	has_side_blast = data["side_blast"]
	has_down_blast = data["down_blast"]
	collected_pickups = data["pickups"]
	has_inital_dialog_been_shown = data["dialog"]

	checkpoint_position = Vector3(
		data["x"],
		data["y"],
		data["z"]
	)

	player_health = data["health"]

	call_deferred(
		"_deferred_load_scene"
	)
	
func _deferred_load_scene():

	get_tree().change_scene_to_file(checkpoint_scene)

	await get_tree().process_frame

	var player = null

	while player == null:

		await get_tree().process_frame

		player = get_tree().get_first_node_in_group("player")

	player.global_position = checkpoint_position
	player.health = player_health

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

	checkpoint_scene = ""
	checkpoint_position = Vector3.ZERO

	player_health = 1
	player_max_health = 1

	has_side_blast = false
	has_down_blast = false

	collected_pickups.clear()

	print("Save deleted")
