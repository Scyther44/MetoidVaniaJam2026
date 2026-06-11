extends Node

@export var dialog: CanvasLayer
const MENTOR_POS2 = Vector3(9, 3.2, -1)
@onready var animation_player = $"../AnimationPlayer"

const NEW_GAME_SCENE = preload("res://Scenes/Levels/world.tscn")

enum Step {
	MOVE,
	JUMP,
	BONFIRE,
	ATTACK,
	FINISHED
}

var current_step = Step.MOVE

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	dialog.start_dialog([
		{
			"speaker": "Mentor",
			"text": "Alright Tabitha. The others tell me you have talent... but talent without control is just another way to start a fire."
		},
		{
			"speaker": "Tabi",
			"text": "I only started one small fire."
		},
		{
			"speaker": "Mentor",
			"text": "It was three fires."
		},
		{
			"speaker": "Tabi",
			"text": "Three small fires."
		},
		{
			"speaker": "Mentor",
			"text": "Anyways..."
		},
		{
			"speaker": "Mentor",
			"text": "Use A and D to move. Press S to kneel and look downward."
		}
	])
	
	

func complete_move_room():
	animation_player.play("move1")
	await animation_player.animation_finished
	current_step = Step.JUMP

	dialog.start_dialog([
		{
			"speaker": "Mentor",
			"text": "Excellent."
		},
		{
			"speaker": "Mentor",
			"text": "Every witch will have obstacles in their way. You must overcome them."
		},
		{
			"speaker": "Mentor",
			"text": "Press SPACEBAR to jump."
		}
	])

func _on_complete_move_room_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player")):
		complete_move_room()


func complete_jump_room():
	animation_player.play("move2")
	await animation_player.animation_finished
	current_step = Step.BONFIRE

	dialog.start_dialog([
		{
			"speaker": "Mentor",
			"text": "Great work today! Now for the most overlooked part of any training. Rest!"
		},
		{
			"speaker": "Mentor",
			"text": "Resting at a bonfire lets you return if something unfortunate happens."
		},
		{
			"speaker": "Tabi",
			"text": "Like what?"
		},
		{
			"speaker": "Mentor",
			"text": "Falling off cliffs."
		},
		{
			"speaker": "Tabi",
			"text": "That seems oddly specific..."
		}
	])

func _on_complete_jump_room_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player")):
		complete_jump_room()

func complete_bonfire_room():
	#animation_player.play("move2")
	#await animation_player.animation_finished
	current_step = Step.ATTACK
	$"../Player".fade_to_black(5)
	$"../Player".change_state_tutattack()
	await get_tree().create_timer(5).timeout
	$"../Player".global_position = Vector3(7, 1.6, 0.0)
	$"../Mentor".global_position = MENTOR_POS2
	$"../Player".fade_from_black(5)
	await get_tree().create_timer(5).timeout
	$"../AfterCamera3D".current = true
	dialog.start_dialog([
		{
			"speaker": "Mentor",
			"text": "Now for the important part. Channel your magic with E (or Q) to perform a blast attack."
		
		}])
		
		
func complete_attack_room():
	current_step = Step.FINISHED
	await get_tree().create_timer(3).timeout
	dialog.start_dialog([
		{
			"speaker": "Mentor",
			"text": "..."
		},
		{
			"speaker": "Mentor",
			"text": "Hm... we probably shouldnt have been practicing by a cliff"
		},
		{
			"speaker": "Mentor",
			"text": "Ah well... She's pretty springy... she will probably be fine..."
		}
	])
	await dialog.dialog_finished
	$"../Player".fade_to_black(5)
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_packed(
		NEW_GAME_SCENE
	)
	#get_tree().change_scene_to_file("res://Scenes/Levels/world.tscn")


func _on_campfire_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player")):
		$"../Campfire/ParticleFire/AnimationPlayer".play("play")
		complete_bonfire_room()


func _on_player_tutattacktriggered() -> void:
	complete_attack_room()
