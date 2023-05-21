extends CharacterBody2D

#References

#Signals
signal player_life_depleted
signal player_power_depleted

#Exports
@export var acceleration = 1000
@export var max_speed = 3000
@export var limit_speed_y = 800
@export var jump_height = 36000
@export var min_jump_height = 12000
@export var max_coyote_time = 6
@export var jump_buffer_time = 10
@export var gravity = 2100
@export var shot_camera_shake_trauma = 0.45

#Physics
var axis = Vector2()
var aim_direction = 0
var float_damp = 0

#States
var can_jump = false
var is_floating = false
var friction = false
var trail = false
var is_grabbing = false

#Animation
var animation_locked = false
var last_animation = ""

#Timers
var coyote_timer = 0
var float_timer = 4
var jump_buffer_timer = 0

#Life
var life_remaining = 3: set = _set_life_remaining
func _set_life_remaining(new_life_remaining):
	life_remaining = new_life_remaining
	emit_signal("player_life_depleted")
var invincibility_active = false

#Powers
enum POWERS {Jump, Float}
var active_power: POWERS = POWERS.Float : set = _set_active_power
func _set_active_power(new_active_power):
	active_power = new_active_power
	if (active_power == POWERS.Jump):
		power_remaining = 2
	elif (active_power == POWERS.Float):
		power_remaining = 4
	
var power_remaining = 2 : set = _set_power_remaining
func _set_power_remaining(new_power_remaining):
	var did_change = (power_remaining != new_power_remaining)
	power_remaining = new_power_remaining
	
	if (did_change):
		emit_signal("player_power_depleted")
	
	

func _ready():
	active_power = POWERS.Jump #POWERS.Float
	pass

func _physics_process(delta):
	
	get_input_axis()
	horizontal_movement(delta)
	aim_direction = roundf(rad_to_deg(axis.angle()))
	
	if (velocity.y <= limit_speed_y * float_damp):
		velocity.y += gravity * delta
		
	if (is_floating):
		float_timer -= delta
		power_remaining = round(float_timer)
	
	friction = false
		
	#Jumping / falling animation
	if (!can_jump):
		if velocity.y > 0:
			#Falling
			play_animation("jump", false)
			pass
		elif (velocity.y <= 0):
			#Jumping
			play_animation("jump", false)
			pass
			
	
	if is_on_floor():
		can_jump = true
		coyote_timer = 0
	else:
		coyote_timer += 1
		if coyote_timer > max_coyote_time:
			can_jump = false
			coyote_timer = 0
		friction = true
		
	jump_buffer(delta)
	
	if Input.is_action_just_pressed("jump"):
		if (can_jump):
			jump(delta)
			friction_on_air()
		elif (active_power == POWERS.Jump and power_remaining > 0):
			jump(delta)
			friction_on_air()
			power_remaining -= 1
		else:
			friction_on_air()
			jump_buffer_timer = jump_buffer_time #amount of frame
			
	if Input.is_action_just_pressed("attack"):
		attack()
		
	#Float
	float_damp = 1
	is_floating = false
	if (!can_jump and active_power == POWERS.Float and power_remaining > 0):
		if Input.is_action_just_pressed("float"):
			velocity.y = 0
		if Input.is_action_pressed("float"):
			is_floating = true
			float_damp = pow(8.33, -4)
			play_animation("jump_dbl_glide", true)
		
			
	set_jump_height(delta)
	jump_buffer(delta)

	#set_velocity(velocity)
	set_up_direction(Vector2.UP)
	move_and_slide()
	#velocity = velocity
	
func attack():
	#Left and Right
	if (is_equal_approx(aim_direction, 180.0) or is_equal_approx(aim_direction, 0.0)):
		var animation_to_play = "attack_fwd_grnd" if can_jump else "attack_fwd_air"
		play_animation(animation_to_play, true)
	#Up
	elif (aim_direction >= -135 and aim_direction <= -45):
		var animation_to_play = "attack_up_grnd" if can_jump else "attack_up_air"
		play_animation(animation_to_play, true)
	#Down
	elif ((aim_direction >= 45 and aim_direction <= 135) and !can_jump):
		play_animation("attack_dwn_air", true)
		
func deplete_life():
	if (invincibility_active):
		return
		
	life_remaining -= 1
	if (life_remaining < 1):
		#Restart when player dies (temporarily)
		get_tree().reload_current_scene()
		
	invincibility_active = true
	$InvincibilityTimer.start()
	
func get_input_axis():
	axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	axis.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	axis = axis.normalized()
		
func friction_on_air():
	if (friction):
		velocity.x = lerpf(velocity.x, 0, 0.01)
		
func horizontal_movement(delta):
	if Input.is_action_pressed("right"):
		velocity.x = min(velocity.x + acceleration * delta, max_speed * delta)
		$Body.scale.x = 1
		if (can_jump):
			play_animation("walk", false)
			pass
	elif Input.is_action_pressed("left"):
		velocity.x = max(velocity.x - acceleration * delta, -max_speed * delta)
		$Body.scale.x = -1
		if (can_jump):
			play_animation("walk", false)
			pass
	else:
		velocity.x = lerpf(velocity.x, 0, 0.4)
		if (can_jump):
			play_animation("idle", false)
			pass
			
			
func jump(delta):
	velocity.y = -jump_height * delta
			
func jump_buffer(delta):
	if (jump_buffer_timer > 0):
		if (is_on_floor()):
			jump(delta)
		jump_buffer_timer -= 1
		
func set_jump_height(delta):
	if (Input.is_action_just_released("jump")):
		if velocity.y < -min_jump_height * delta:
			velocity.y = -min_jump_height * delta
			
func play_animation(animation_name, lock_animation):
	if (animation_locked):
		return
		
	animation_locked = lock_animation
	
	$Body/Sprite.play(animation_name)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemies"):
		deplete_life()
	elif area.is_in_group("projectiles"):
		deplete_life()
		area.get_parent().queue_free()

func _on_sprite_animation_finished():
	animation_locked = false





func _on_invincibility_timer_timeout():
	invincibility_active = false
	#Check to see if player is still in a position to receive damage:
	for area in $Hurtbox.get_overlapping_areas():
		if area.is_in_group("enemies"):
			deplete_life()
		elif area.is_in_group("projectiles"):
			deplete_life()
			area.get_parent().queue_free()

