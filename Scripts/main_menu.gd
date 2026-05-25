extends Control


func _ready():

	$NewGameButton.pressed.connect(_on_play_pressed)


func _on_play_pressed():

	get_tree().change_scene_to_file("res://test.tscn")
