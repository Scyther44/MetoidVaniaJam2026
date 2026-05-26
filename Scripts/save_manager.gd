extends Node

const SAVE_PATH = "user://savegame.json"

var checkpoint_scene = ""
var checkpoint_position = Vector3.ZERO
var player_health = 5


func save_checkpoint(scene_path, position, health):

	checkpoint_scene = scene_path
	checkpoint_position = position
	player_health = health

	var save_data = {
		"scene": checkpoint_scene,
		"x": checkpoint_position.x,
		"y": checkpoint_position.y,
		"z": checkpoint_position.z,
		"health": player_health
	}

	print("Saving at path: " + SAVE_PATH)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	file.store_string(JSON.stringify(save_data))

	print("Game Saved")


func load_checkpoint():

	if !FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return
		
	get_tree().paused = false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	var json_text = file.get_as_text()

	var data = JSON.parse_string(json_text)

	if data == null:
		print("Save corrupted")
		return

	checkpoint_scene = data["scene"]

	checkpoint_position = Vector3(
		data["x"],
		data["y"],
		data["z"]
	)

	player_health = data["health"]
	get_tree().change_scene_to_file(checkpoint_scene)

	await get_tree().create_timer(0.1).timeout

	var player = get_tree().get_first_node_in_group("player")

	if player != null:
		player.global_position = checkpoint_position
		player.health = player_health
		("Game Loaded")
	else:
		print("Player not found!")

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):

		DirAccess.remove_absolute(SAVE_PATH)

		print("Save deleted")
