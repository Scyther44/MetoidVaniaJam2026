extends Control
@export var player: CharacterBody3D
@onready var label = $Label
@onready var heart1 = $HBoxContainer/Heart1
@onready var heart2 = $HBoxContainer/Heart2
@onready var heart3 = $HBoxContainer/Heart3
# Called when the node enters the scene tree for the first time.
func _ready():
	update_hearts()

func _process(_delta):
	label.text = "Health = " + str(player.health)
	update_hearts()

func update_hearts():

	heart1.visible = player.health >= 1
	heart2.visible = player.health >= 2
	heart3.visible = player.health >= 3
