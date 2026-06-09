extends CanvasLayer

@onready var title_label = $Panel/ItemName
@onready var body_label = $Panel/Text
@onready var icon = $Panel/Icon

func show_pickup(
	title : String,
	text : String,
	texture : Texture2D
):

	title_label.text = title
	body_label.text = text
	icon.texture = texture

	#get_tree().paused = true

func _unhandled_input(event):

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):

		#get_tree().paused = false
		queue_free()
