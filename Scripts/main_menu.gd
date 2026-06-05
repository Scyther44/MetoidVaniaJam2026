extends Control

@onready var new_game_button = $NewGameButton
@onready var load_game_button = $LoadGameButton
@onready var options_button = $OptionsButton

const NEW_GAME_SCENE = preload("res://Scenes/Levels/world.tscn")
const OPTIONS_MENU = preload(
	"res://Scenes/options_menu.tscn"
)
var using_controller := true

func _ready() -> void:
	new_game_button.grab_focus()

	if(FileAccess.file_exists(SaveManager.SAVE_PATH)):
		load_game_button.disabled = false
		load_game_button.focus_mode = FocusMode.FOCUS_ALL

	connect_button_signals()

func connect_button_signals():

	for button in [
		new_game_button,
		load_game_button,
		options_button
	]:
		button.mouse_entered.connect(_on_button_mouse_entered.bind(button))

func _unhandled_input(event: InputEvent) -> void:

	# Mouse moved
	if event is InputEventMouseMotion:

		if using_controller:
			using_controller = false

			var focused = get_viewport().gui_get_focus_owner()
			if focused:
				focused.release_focus()

	# Controller / keyboard navigation
	elif (
		event.is_action_pressed("ui_up")
		or event.is_action_pressed("ui_down")
		or event.is_action_pressed("ui_left")
		or event.is_action_pressed("ui_right")
	):

		if !using_controller:
			using_controller = true

			var hovered = get_viewport().gui_get_hovered_control()

			if hovered:
				hovered.release_focus()

			var focused = get_viewport().gui_get_focus_owner()

			if focused == null:
				new_game_button.grab_focus()

func _on_button_mouse_entered(button: Button):

	if !using_controller:
		button.grab_focus()

func _on_new_game_button_pressed() -> void:

	SaveManager.delete_save()

	get_tree().paused = false

	get_tree().change_scene_to_packed(
		NEW_GAME_SCENE
	)

func _on_load_game_button_pressed() -> void:

	SaveManager.load_checkpoint()

func _on_options_button_pressed() -> void:
	var options = OPTIONS_MENU.instantiate()
	options.return_focus = get_viewport().gui_get_focus_owner()
	add_child(options)
	
func _input(event):
	if event is InputEventMouseMotion:
		using_controller = false
			
		var focused = get_viewport().gui_get_focus_owner()
		if focused:
			focused.release_focus()
