extends Node

@export var dialog : CanvasLayer
var is_endgame = false
const ENDING = preload("res://Scenes/ending.tscn")

func _ready() -> void:
	if (SaveManager.has_inital_dialog_been_shown):
		return
		
	await get_tree().create_timer(5).timeout
	dialog.start_dialog([
		{
			"speaker": "Tabi",
			"text": "..."
		},
		{
			"speaker": "Tabi",
			"text": "I guess I really am springy!"
		},
		{
			"speaker": "Mentor",
			"text": "Shoot - I lost my magic catalyst. I won't be able to cast magic without it."
		},
		{
			"speaker": "Tabi",
			"text": "I better find it and try making my way back up to where my mentor was."
		},
	])
	
	SaveManager.has_inital_dialog_been_shown = true


func _on_mentor_area_3d_body_entered(body: Node3D) -> void:
	if(body.is_in_group("player") and !is_endgame):
		is_endgame = true
		dialog.start_dialog([
			{
				"speaker": "Mentor",
				"text": "Ah, Tabitha! Good to see you made it back in one piece."
			},
			{
				"speaker": "Tabi",
				"text": "Yeah. No thanks to you."
			},
			{
				"speaker": "Mentor",
				"text": "I'm sure your little adventure built character."
			},
			{
				"speaker": "Tabi",
				"text": "My 'little adventure' involved me falling off a cliff and bunch of angry ghosts!"
			},
			{
				"speaker": "Mentor",
				"text": "And yet you persevered!"
			},
			{
				"speaker": "Tabi",
				"text": "..."
			},
			{
				"speaker": "Mentor",
				"text": "You left this hut as a student."
			},
			{
				"speaker": "Mentor",
				"text": "You return as a witch."
			},
			{
				"speaker": "Tabi",
				"text": "I'm still thinking about hitting you with a fireball."
			},
			{
				"speaker": "Mentor",
				"text": "Excellent. You're learning already."
			}
			])
		await  dialog.dialog_finished
		
		$"../Player".fade_to_black(5)
		await get_tree().create_timer(5).timeout
		get_tree().change_scene_to_packed(ENDING)
