extends CharacterBody3D

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	STUMBLE,
	CLIMB,
	Kneel #Look down
}


const SPEED = 5.0
const JUMP_VELOCITY = 6.0
const ACCELERATION = 10.0
const FRICTION = 15.0

const GROUND_RECOIL = 4.0
const AIR_RECOIL = 5.0
const UPWARD_RECOIL = 6.0

const CAMERA_NORMAL = Vector3(0, 2, 6)
const CAMERA_LOOK_DOWN = Vector3(0, -1.5, 6)

var max_health = 3
var health = max_health
var current_state = State.IDLE
var is_facing_left = false
var current_ladder = null
var can_down_attack = true
var camera_tween : Tween
var is_dead = false
var is_afk = false

@onready var visuals = $visuals
@onready var animation_player = $AnimationPlayer

@onready var camera = $PerspectiveCamera
@onready var left_hitbox = $LHitBoxArea3D
@onready var right_hitbox = $RHitBoxArea3D
@onready var down_hitbox = $DHitBoxArea3D
@onready var idle_timer = $IdleTimer

const EXPLOSION_SCENE = preload(
	"res://Scenes/particle_explosion.tscn"
)

func _ready() -> void:
	var preload_explosion = EXPLOSION_SCENE.instantiate()

	add_child(preload_explosion)

	preload_explosion.visible = false

	await get_tree().process_frame

	preload_explosion.queue_free()

func _physics_process(delta):
	apply_gravity(delta)

	handle_input()

	handle_state(delta)

	velocity.z = 0
	
	move_and_slide()


func apply_gravity(delta):
	
	if current_state == State.CLIMB:
		return

	if !is_on_floor():
		velocity += get_gravity() * delta


func handle_input():

	# Jump
	if Input.is_action_just_pressed("accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)
	
	# Down Attack
	if(
		Input.is_action_just_pressed("accept")
		and !is_on_floor() 
		and current_state != State.CLIMB 
		and can_down_attack
	):
		start_down_attack()		

	# Left attack
	if Input.is_action_just_pressed("attack_left"):
		start_attack(true)

	# Right attack
	if Input.is_action_just_pressed("attack_right"):
		start_attack(false)
	
	# Climb
	if (
		current_ladder != null
		and (Input.is_action_pressed("up") or Input.is_action_pressed("down"))
		and current_state != State.CLIMB
	):
		change_state(State.CLIMB)
		
	#Kneel (Look Down)
	if (
	is_on_floor()
	and Input.is_action_pressed("down")
	and current_state == State.IDLE
	):
		change_state(State.Kneel)


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
			
		State.CLIMB:
			state_climb(delta)
			
		State.Kneel:
			state_kneel(delta)


func state_idle(delta):
	
	if is_afk:
		#print("Player is afk")
		play_anim("Animpack5/sad_idle")
	else:
		play_anim("Animpack5/happy_idle2")
	
	visuals.rotation.y = deg_to_rad(225) if is_facing_left else deg_to_rad(-45)
	var direction = Input.get_axis("left", "right")

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

	play_anim("Animpack5/run2")

	var direction = Input.get_axis("left", "right")

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
		can_down_attack = true
		if abs(velocity.x) > 0.1:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)


func state_attack(_delta):
	if is_on_floor():
		can_down_attack = true
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

func state_climb(_delta):
	
	if(current_ladder):
		global_position.x = current_ladder.global_position.x
	
	can_down_attack = true
	velocity = Vector3.ZERO

	var climb_direction = 0

	if Input.is_action_pressed("up"):
		climb_direction = 1

	elif Input.is_action_pressed("down"):
		climb_direction = -1


	velocity.y = climb_direction * SPEED


	# Face ladder
	visuals.rotation.y = deg_to_rad(-90)


	# Animation
	if climb_direction != 0:

		play_anim("AnimPack3/Climb", climb_direction)

	else:

		animation_player.pause()


	# Jump off ladder
	if Input.is_action_just_pressed("accept"):

		velocity.y = JUMP_VELOCITY
		#velocity.x = 4

		change_state(State.JUMP)

		return


	# Exit ladder
	if current_ladder == null:

		change_state(State.FALL)

		return

func state_kneel(delta):
	velocity.x = move_toward(
		velocity.x,
		0,
		FRICTION * delta
	)
	play_anim("kneeling/kneeling")
	visuals.rotation.y = deg_to_rad(-90)
	
	if !Input.is_action_pressed("down"):
		change_state(State.IDLE)
		return

	if !is_on_floor():
		change_state(State.FALL)
		return
	

func handle_air_movement(delta):

	var direction = Input.get_axis("left", "right")

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

func start_down_attack():
	if current_state == State.ATTACK:
		return
		
	can_down_attack = false
	play_anim("AnimPack4/down_attack", 4) #3s / 4 
	change_state(State.ATTACK)
	await get_tree().create_timer(0.375).timeout
	var explosion = EXPLOSION_SCENE.instantiate()

	get_tree().current_scene.add_child(explosion)

	explosion.global_position = down_hitbox.global_position
	down_hitbox.monitoring = true

	velocity.y = UPWARD_RECOIL
	
	end_down_attack()

func start_attack(left_attack):

	if current_state == State.ATTACK:
		return

	change_state(State.ATTACK)

	play_anim("AnimPack1/attack", 4)

	if left_attack:

		var explosion = EXPLOSION_SCENE.instantiate()

		get_tree().current_scene.add_child(explosion)

		explosion.global_position = left_hitbox.global_position
		left_hitbox.monitoring = true

		visuals.rotation.y = deg_to_rad(180)

		apply_recoil(-1)

	else:

		var explosion = EXPLOSION_SCENE.instantiate()

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

	await get_tree().create_timer(0.35).timeout

	left_hitbox.monitoring = false
	right_hitbox.monitoring = false

	if is_on_floor():

		if abs(velocity.x) > 0.1:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)

	else:
		change_state(State.FALL)
		
func end_down_attack():
	await get_tree().create_timer(0.1).timeout
	down_hitbox.monitoring = false

	if is_on_floor():

		if abs(velocity.x) > 0.1:
			change_state(State.RUN)
		else:
			change_state(State.IDLE)

	else:
		#TODO change this to flail maybe?
		change_state(State.FALL)

func change_state(new_state):

	if current_state == new_state:
		return

	current_state = new_state

	if current_state == State.IDLE:
		#print("starting idle time")
		idle_timer.start()
	else:
		idle_timer.stop()
		is_afk = false

	# Exit kneel
	if current_state == State.Kneel:
		move_camera(CAMERA_NORMAL)

	current_state = new_state

	# Enter kneel
	if current_state == State.Kneel:
		move_camera(CAMERA_LOOK_DOWN)


func play_anim(anim_name, speed = 1.0):

	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name, -1, speed)

func move_camera(pos: Vector3):

	if camera_tween:
		camera_tween.kill()

	camera_tween = create_tween()

	camera_tween.tween_property(
		camera,
		"position",
		pos,
		0.25
	)

func _on_hit_box_area_3d_body_entered(body):

	if body.is_in_group("enemy"):
		body.take_damage()

func _on_hit_box_area_3d_area_entered(body):
	
	if body.is_in_group("enemy"):
		body.take_damage()
		
func take_damage(amount):

	health -= amount

	print("Health:", health)

	if health <= 0 and !is_dead:
		is_dead = true
		die()
		
func die():
	SaveManager.load_checkpoint()

func _on_climb_detector_area_area_entered(area: Area3D) -> void:
	
	if area.is_in_group("climbable"):
		current_ladder = area
		


func _on_climb_detector_area_area_exited(area: Area3D) -> void:
	
	if area == current_ladder:
		current_ladder = null


func _on_idle_timer_timeout() -> void:
	if current_state == State.IDLE:
		is_afk = true
