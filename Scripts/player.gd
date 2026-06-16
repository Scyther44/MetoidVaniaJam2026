extends CharacterBody3D

signal tutattacktriggered

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	STUMBLE,
	CLIMB,
	KNEEL, #Look down
	DEAD,
	TUTATTACK
}


const SPEED = 5.0
const JUMP_VELOCITY = 6.0
const ACCELERATION = 10.0
const FRICTION = 15.0

const INVULN_DURATION := 1.0
const GROUND_RECOIL = 4.0
const AIR_RECOIL = 5.0
const UPWARD_RECOIL = 6.0

const CAMERA_NORMAL = Vector3(0, 2, 6)
const CAMERA_LOOK_DOWN = Vector3(0, -1.5, 6)

var max_health = 3
var health = max_health
var current_state = State.IDLE
var is_facing_left = false
var ladders := []
var current_ladder = null
var can_down_attack = true
var is_down_attack_unlocked = false
var is_side_attack_unlocked = true
var camera_tween : Tween
var is_dead = false
var is_afk = false
var invulnerable := false

@onready var visuals = $visuals
@onready var animation_player = $AnimationPlayer

@onready var camera = $PerspectiveCamera
@onready var left_hitbox = $LHitBoxArea3D
@onready var right_hitbox = $RHitBoxArea3D
@onready var down_hitbox = $DHitBoxArea3D
@onready var idle_timer = $IdleTimer
@onready var mesh = $visuals/M_WitchPlayerV1/Armature_001/GeneralSkeleton/Witch
@onready var hurt_sound = $Hurt
var mat = StandardMaterial3D


const EXPLOSION_SCENE = preload(
	"res://Scenes/particle_explosion.tscn"
)

const WITCH_ALT_SKIN_RESOURE = preload(
	"res://Assets/witchtexturealt.tres"
)

func _ready() -> void:
	var preload_explosion = EXPLOSION_SCENE.instantiate()

	add_child(preload_explosion)

	preload_explosion.visible = false

	await get_tree().process_frame

	preload_explosion.queue_free()
	
	health = SaveManager.player_health
	max_health = SaveManager.player_max_health

	is_side_attack_unlocked = SaveManager.has_side_blast
	is_down_attack_unlocked = SaveManager.has_down_blast
	
	if is_down_attack_unlocked:
		mesh.set_surface_override_material(
		0,
		WITCH_ALT_SKIN_RESOURE
	)
	
	mat = mesh.get_surface_override_material(0)

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
	if current_state == State.DEAD:
		return
		
	if current_state == State.TUTATTACK:
		return

	# Jump
	if Input.is_action_just_pressed("accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(State.JUMP)
		$Jump.play()
	
	# Down Attack
	if(
		Input.is_action_just_pressed("accept")
		and !is_on_floor() 
		and is_down_attack_unlocked
		and current_state != State.CLIMB 
		and can_down_attack
	):
		start_down_attack()		

	# Left attack
	if Input.is_action_just_pressed("attack_left") and is_side_attack_unlocked:
		start_attack(true)

	# Right attack
	if Input.is_action_just_pressed("attack_right") and is_side_attack_unlocked:
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
		change_state(State.KNEEL)


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
			
		State.KNEEL:
			state_kneel(delta)
			
		State.DEAD:
			state_dead(delta)
			
		State.TUTATTACK:
			state_tutattack(delta)


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
	
func state_dead(_delta):

	velocity = Vector3.ZERO

	play_anim("Animpack5/sad_idle")
	
func state_tutattack(delta):
	handle_tutattack(delta)
	

func handle_tutattack(_delta):
	if Input.is_action_just_pressed("attack_right"):
		emit_signal("tutattacktriggered")
		start_attack(false, 3)

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

func start_attack(left_attack, knockbackmultiplier := 1):

	if current_state == State.ATTACK:
		return

	change_state(State.ATTACK)
	print(randi() % 50)
	if(randi() % 10 == 0): # 1 in 10 chance to play voice line
		$Attack1.play(0.14)
	play_anim("AnimPack1/attack", 4)

	if left_attack:

		var explosion = EXPLOSION_SCENE.instantiate()

		get_tree().current_scene.add_child(explosion)

		explosion.global_position = left_hitbox.global_position
		left_hitbox.monitoring = true

		visuals.rotation.y = deg_to_rad(180)

		apply_recoil(-1 * knockbackmultiplier)

	else:

		var explosion = EXPLOSION_SCENE.instantiate()

		get_tree().current_scene.add_child(explosion)

		explosion.global_position = right_hitbox.global_position
		right_hitbox.monitoring = true

		visuals.rotation.y = deg_to_rad(0)

		apply_recoil(1 * knockbackmultiplier)

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

	# Exit kneel
	if current_state == State.KNEEL:
		move_camera(CAMERA_NORMAL)

	current_state = new_state
	
	if current_state == State.IDLE:
		#print("starting idle time")
		idle_timer.start()
	else:
		#print("Stopping timer")
		idle_timer.stop()
		is_afk = false

	# Enter kneel
	if current_state == State.KNEEL:
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
	if body.is_in_group("breakable"):
		body.break_block()
	print(body.name)
	print(body.get_groups())

func _on_hit_box_area_3d_area_entered(body):
	
	if body.is_in_group("enemy"):
		body.take_damage()
		
func take_damage(amount):

	if invulnerable or is_dead:
		return
	
	hurt_sound.pitch_scale = randf_range(0.75, 1.25)
	hurt_sound.play()
	
	health -= amount

	velocity.y = 2

	if is_facing_left:
		velocity.x = 4
	else:
		velocity.x = -4

	if health <= 0:
		is_dead = true
		die()
		return

	start_invulnerability()
		
func start_invulnerability():

	invulnerable = true

	for i in range(5):
		mat = mesh.get_surface_override_material(0)
		mat.albedo_color = Color.RED

		await get_tree().create_timer(0.1).timeout

		mat.albedo_color = Color.WHITE

		await get_tree().create_timer(0.1).timeout

	invulnerable = false

func die():
	change_state(State.DEAD)
	velocity = Vector3.ZERO
	await $PlayerHud.fade_to_black(3)
	SaveManager.load_checkpoint()
	
func fade_to_black(duration):
	$PlayerHud.fade_to_black(duration)
	
func fade_from_black(duration):
	$PlayerHud.fade_from_black(duration)

func _on_climb_detector_area_area_entered(area: Area3D) -> void:
	
	if area.is_in_group("climbable"):
		current_ladder = area
		ladders.append(area)
		
func _on_climb_detector_area_area_exited(area: Area3D) -> void:
	
	if area.is_in_group("climbable"):
		ladders.erase(area)
		if ladders.size() > 0:
			current_ladder = ladders[0]
		else:
			current_ladder = null


func _on_idle_timer_timeout() -> void:
	#print("IdleTimerTimeout")
	if current_state == State.IDLE:
		is_afk = true
		
func unlock_down_blast():
	is_down_attack_unlocked = true
	mesh.set_surface_override_material(0,
	WITCH_ALT_SKIN_RESOURE)
			
func unlock_side_blast():
	is_side_attack_unlocked = true
	
func change_state_tutattack():
	velocity.x = 0
	velocity.y = 0
	velocity.z = 0
	animation_player.play("Animpack5/happy_idle2")
	change_state(State.TUTATTACK)
