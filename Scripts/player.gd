extends CharacterBody3D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	STUMBLE
}


const SPEED = 5.0
const JUMP_VELOCITY = 5.0
const ACCELERATION = 10.0
const FRICTION = 15.0

const GROUND_RECOIL = 4.0
const AIR_RECOIL = 5.0

var max_health = 3
var health = max_health
var current_state = State.IDLE
var is_facing_left = false


@onready var visuals = $visuals
@onready var animation_player = $AnimationPlayer

@onready var left_hitbox = $LHitBoxArea3D
@onready var right_hitbox = $RHitBoxArea3D


func _physics_process(delta):
	apply_gravity(delta)

	handle_input()

	handle_state(delta)

	move_and_slide()


func apply_gravity(delta):

	if !is_on_floor():
		velocity += get_gravity() * delta


func handle_input():

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)

	# Left attack
	if Input.is_action_just_pressed("attack_left"):
		start_attack(true)

	# Right attack
	if Input.is_action_just_pressed("attack_right"):
		start_attack(false)


func handle_state(delta):

	match current_state:

		State.IDLE:
			state_idle(delta)

		State.RUN:
			state_run(delta)

		State.JUMP:
			state_jump(delta)

		State.FALL:
			state_fall(delta)

		State.ATTACK:
			state_attack(delta)
			
		State.STUMBLE:
			state_stumble(delta)


func state_idle(delta):

	play_anim("AnimPack1/idle")

	var direction = Input.get_axis("ui_left", "ui_right")

	velocity.x = move_toward(
		velocity.x,
		0,
		FRICTION * delta
	)

	if direction != 0:
		change_state(State.RUN)

	if !is_on_floor():
		change_state(State.FALL)


func state_run(delta):

	play_anim("AnimPack1/run")

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction == 0:
		change_state(State.IDLE)
		return

	velocity.x = move_toward(
		velocity.x,
		direction * SPEED,
		ACCELERATION * delta
	)

	update_facing(direction)

	if !is_on_floor():
		change_state(State.FALL)


func state_jump(delta):

	play_anim("jumpanimpack/FallingIdle")

	handle_air_movement(delta)

	if velocity.y > 0:
		return

	change_state(State.FALL)


func state_fall(delta):

	play_anim("jumpanimpack/FallingIdle")

	handle_air_movement(delta)

	if is_on_floor():

		if abs(velocity.x) > 0.1:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)


func state_attack(_delta):
	# keep momentum during attack
	pass
	
func state_stumble(delta):
	play_anim("jumpanimpack/StumbleBack", 7)
	apply_gravity(delta)
	await animation_player.animation_finished
	if is_on_floor():

		if abs(velocity.x) > 0.1:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)


func handle_air_movement(delta):

	var direction = Input.get_axis("ui_left", "ui_right")

	velocity.x = move_toward(
		velocity.x,
		direction * SPEED,
		ACCELERATION * delta
	)

	if direction != 0:
		update_facing(direction)


func update_facing(direction):

	if direction > 0:

		is_facing_left = false
		visuals.rotation.y = deg_to_rad(0)

	else:

		is_facing_left = true
		visuals.rotation.y = deg_to_rad(180)


func start_attack(left_attack):

	if current_state == State.ATTACK:
		return

	change_state(State.ATTACK)

	#TODO REMOVE THIS AND ADJUST ANIMTAION INSTEAD
	play_anim("AnimPack1/attack", 4)

	if left_attack:

		var explosion = preload("res://Scenes/particle_explosion.tscn").instantiate()

		get_tree().current_scene.add_child(explosion)

		explosion.global_position = left_hitbox.global_position
		left_hitbox.monitoring = true

		visuals.rotation.y = deg_to_rad(180)

		apply_recoil(-1)

	else:

		var explosion = preload("res://Scenes/particle_explosion.tscn").instantiate()

		get_tree().current_scene.add_child(explosion)

		explosion.global_position = right_hitbox.global_position
		right_hitbox.monitoring = true

		visuals.rotation.y = deg_to_rad(0)

		apply_recoil(1)

	end_attack()


func apply_recoil(direction):
	if is_on_floor():
		velocity.x -= direction * GROUND_RECOIL
	else:
		velocity.x -= direction * AIR_RECOIL
		velocity.y += 1.5

func end_attack():

	await get_tree().create_timer(0.7).timeout

	left_hitbox.monitoring = false
	right_hitbox.monitoring = false

	if is_on_floor():

		if abs(velocity.x) > 0.1:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)

	else:
		change_state(State.FALL)



func change_state(new_state):

	current_state = new_state


func play_anim(anim_name, speed = 1.0):

	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name, -1, speed)


func _on_hit_box_area_3d_body_entered(body):

	if body.is_in_group("enemy"):
		body.take_damage()

func _on_hit_box_area_3d_area_entered(body):
	
	if body.is_in_group("enemy"):
		body.take_damage()
		
func take_damage(amount):

	health -= amount

	print("Health:", health)

	if health <= 0:
		die()
		
func die():

	SaveManager.load_checkpoint()
