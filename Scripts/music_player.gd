extends AudioStreamPlayer

var original_track: AudioStream
var boss_track = preload("res://Music/Witchy Fight.mp3")

func _ready() -> void:
	original_track = stream

func _on_world_blockout_boss_active() -> void:
	stream = boss_track
	play()


func _on_world_blockout_boss_dead() -> void:
	stream = original_track
	play()
