extends Node

@export var dialog : CanvasLayer

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
