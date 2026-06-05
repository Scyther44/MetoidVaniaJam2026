extends Control

@onready var music_slider = $Panel/MusicSlider
@onready var sfx_slider = $Panel/SFXSlider

var return_focus : Control

func _ready():
	$Panel/MusicSlider.grab_focus()
	music_slider.value = Settings.music_volume
	sfx_slider.value = Settings.sfx_volume

func _on_music_slider_value_changed(value):

	Settings.music_volume = value

	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(value)
	)

func _on_sfx_slider_value_changed(value):

	Settings.sfx_volume = value
	$Panel/SFXSlider/SFXSound.play()
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"),
		linear_to_db(value)
	)

func _on_back_button_pressed():
	if return_focus:
		return_focus.grab_focus()
	queue_free()
