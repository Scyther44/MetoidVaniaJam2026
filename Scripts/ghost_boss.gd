extends CharacterBody3D

enum State {
	WAITING_FOR_PLAYER,
	IDLE,
	MOVE,
	SUMMON,
	DASH,
	DEAD,
}

signal boss_dead
signal boss_active

@onready var animation_player = $visuals/M_GhostEnemyRigged/AnimationPlayer

var max_health = 8
var health = 8

var target_position : Vector3
var start_position : Vector3

var state_timer = 0.0
var dash_phase = 0
var dash_wait_timer = 0.0

var current_state = State.WAITING_FOR_PLAYER
var player
var phase = 1

var dash_from_left := true
var original_rotation

const MAX_SUMMONS = 2

# Arena positions
const CENTER_POS = Vector3(44, 52, -3)
const DASH_LEFT_POS = Vector3(36, 48, 0)
const DASH_RIGHT_POS = Vector3(52, 48, 0)

const GHOST_SCENE = preload(
	"res://Scenes/GhostChaseEnemySmall_boss.tscn"
)

func _ready() -> void:
	original_rotation = global_rotation
	start_position = global_position
	target_position = start_position

func _physics_process(delta: float) -> void:

	handle_state(delta)

	move_and_slide()

func handle_state(delta):

	match current_state:

		State.IDLE:
			global_rotation = original_rotation
			state_idle(delta)

		State.MOVE:
			global_rotation = original_rotation
			state_move(delta)

		State.SUMMON:
			global_rotation = original_rotation
			state_summon(delta)

		State.DASH:
			state_dash(delta)

		State.DEAD:
			global_rotation = original_rotation
			state_dead(delta)

		State.WAITING_FOR_PLAYER:
			state_waiting(delta)

func change_state(new_state):

	current_state = new_state
	state_timer = 0.0

	if new_state == State.MOVE:
		pick_new_position()

func pick_new_position():

	target_position = Vector3(
		randf_range(40, 48),
		randf_range(50, 55),
		-3
	)

func state_idle(delta):

	state_timer += delta

	velocity = Vector3.ZERO

	if state_timer > 1.0:
		change_state(State.MOVE)

func state_move(_delta):

	velocity = (
		target_position - global_position
	).normalized() * 4

	if global_position.distance_to(target_position) < 1:

		velocity = Vector3.ZERO

		if randf() < 0.5:

			change_state(State.SUMMON)

		else:

			dash_phase = 0
			dash_from_left = randf() < 0.5

			change_state(State.DASH)

func state_summon(delta):
	state_timer += delta

	if state_timer < 0.5:
		return

	if count_summoned_ghosts() < MAX_SUMMONS:

		spawn_ghost()

		if phase >= 2 and randf() < 0.5:
			spawn_ghost()

	change_state(State.MOVE)

func spawn_ghost():
	animation_player.play("Attack")
	var ghost = GHOST_SCENE.instantiate()

	get_tree().current_scene.add_child(ghost)

	ghost.global_position = global_position + Vector3(
		randf_range(-2, 2),
		randf_range(-1, 1),
		0
	)

func count_summoned_ghosts():

	var count = 0

	for node in get_tree().get_nodes_in_group("boss_minion"):

		if node != self:
			count += 1

	return count

func state_dash(_delta):

	var start_pos
	var end_pos

	if dash_from_left:

		start_pos = DASH_LEFT_POS
		end_pos = DASH_RIGHT_POS

	else:

		start_pos = DASH_RIGHT_POS
		end_pos = DASH_LEFT_POS

	match dash_phase:

		# Move to dash start
		0:

			velocity = (
				start_pos - global_position
			).normalized() * 6

			if dash_from_left:
				$visuals.rotation.y = deg_to_rad(90)
			else:
				$visuals.rotation.y = deg_to_rad(-90)

			if global_position.distance_to(start_pos) < 0.5:

				velocity = Vector3.ZERO

				dash_wait_timer = 0

				dash_phase = 1

		# Windup
		1:

			velocity = Vector3.ZERO

			dash_wait_timer += get_physics_process_delta_time()

			if dash_wait_timer > 0.5:
				dash_phase = 2

		# Dash across arena
		2:
			if(animation_player.current_animation != "Attack"):
				animation_player.play("Attack")
			velocity = (
				end_pos - global_position
			).normalized() * 18

			if dash_from_left:
				$visuals.rotation.y = deg_to_rad(90)
			else:
				$visuals.rotation.y = deg_to_rad(-90)

			if global_position.distance_to(end_pos) < 0.5:

				velocity = Vector3.ZERO

				dash_phase = 3

		# Return to center
		3:
			animation_player.play("Idle")
			velocity = (
				CENTER_POS - global_position
			).normalized() * 6

			if global_position.distance_to(CENTER_POS) < 0.5:

				velocity = Vector3.ZERO

				change_state(State.MOVE)

func _on_player_detection_area_body_entered(body: Node3D) -> void:

	if body.is_in_group("player"):
		player = body

func _on_player_detection_area_body_exited(body: Node3D) -> void:

	if body == player:
		player = null

func take_damage():

	health -= 1

	flash_damage()

	if health <= max_health / 2:
		phase = 2

	if health <= 0:
		change_state(State.DEAD)

func flash_damage():

	var mesh = $visuals/M_GhostEnemyRigged/Armature/Skeleton3D/GhostEnemy

	var mat = mesh.get_surface_override_material(0)

	if mat:

		mat.albedo_color = Color.RED

		await get_tree().create_timer(0.15).timeout

		mat.albedo_color = Color.WHITE

func state_dead(_delta):

	velocity = Vector3.ZERO
	emit_signal("boss_dead")

	queue_free()

func state_waiting(_delta):

	if !player:
		return
	emit_signal("boss_active")
	change_state(State.IDLE)
