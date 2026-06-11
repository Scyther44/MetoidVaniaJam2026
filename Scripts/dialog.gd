extends CanvasLayer

@onready var speaker_label = $Panel/SpeakerLabel
@onready var text_label = $Panel/TextLabel
signal dialog_finished
var messages = []
var current_index = 0
	
func start_dialog(dialog_messages):

	messages = dialog_messages
	current_index = 0

	show_message()

func show_message():

	var msg = messages[current_index]
	print(speaker_label)
	$Panel/SpeakerLabel.text = msg["speaker"]
	$Panel/TextLabel.text = msg["text"]
	

	show()

	#get_tree().paused = true
	
func _unhandled_input(event):

	if !visible:
		return

	if event.is_action_pressed("ui_accept"):

		current_index += 1

		if current_index >= messages.size():

			hide()
			#get_tree().paused = false
			
			dialog_finished.emit()
			return

		show_message()

#Old
func show_dialog(
	speaker: String,
	text: String
):
	$Panel/SpeakerLabel.text = speaker
	$Panel/TextLabel.text = text

	#get_tree().paused = true

	show()
