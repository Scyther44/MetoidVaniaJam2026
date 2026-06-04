extends Sprite3D

@export var parallax_factor_x := 10.0
@export var parallax_factor_y := 0.0
@export var camera: Camera3D

var start_position: Vector3

func _ready():
	start_position = position

func _process(_delta):

	# Use assigned camera if available,
	# otherwise find the active viewport camera.
	if camera == null:
		print(get_viewport().get_camera_3d())
		camera = get_viewport().get_camera_3d()

	# No camera found yet.
	if camera == null:
		return

	position.x = (
		start_position.x
		- camera.global_position.x * parallax_factor_x
	)

	position.y = (
		start_position.y
		- camera.global_position.y * parallax_factor_y
	)
