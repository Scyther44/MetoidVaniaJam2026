extends Control

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.color.a = 0
	animation_player.play("endme")
	await get_tree().create_timer(1).timeout
	$TextureRect.visible = true
	$ColorRect2.color.a = 0
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
