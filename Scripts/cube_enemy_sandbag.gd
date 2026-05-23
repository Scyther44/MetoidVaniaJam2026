extends CharacterBody3D

const SPEED = 5.0
const ATTACK_RANGE = 0
var health = 1

var player = null

@onready var detection_area = $PlayerDetectionArea
#@onready var animation_player = $AnimationPlayer
@onready var visuals = $visuals
@onready var mesh = $visuals/M_GhostEnemy/GhostEnemy

func _ready():

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(_delta):

	if player != null:

		var distance = global_position.distance_to(player.global_position)

		# Chase player
		if distance > ATTACK_RANGE:

			var direction = (
				player.global_position - global_position
			).normalized()

			velocity.x = direction.x * SPEED
			velocity.y = direction.y * SPEED
			velocity.z = direction.z * SPEED

			# Face player
			if direction.x > 0:
				visuals.rotation.y = deg_to_rad(0)
			else:
				visuals.rotation.y = deg_to_rad(180)

			#play_anim("run")

		# Attack player
		else:

			velocity = Vector3.ZERO

			#play_anim("attack")

	else:

		velocity = Vector3.ZERO

		#play_anim("idle")

	move_and_slide()


#func play_anim(anim_name):

	#if animation_player.current_animation != anim_name:
		#animation_player.play(anim_name)


func _on_body_entered(body):

	if body.is_in_group("player"):
		player = body


func _on_body_exited(body):

	if body == player:
		player = null

func take_damage():

	health -= 1

	print("Enemy hit! Health:", health)

	flash_damage()

	if health <= 0:
		queue_free()


func flash_damage():

	mesh.material_override.albedo_color = Color.RED

	await get_tree().create_timer(0.1).timeout

	mesh.material_override.albedo_color = Color.WHITE
