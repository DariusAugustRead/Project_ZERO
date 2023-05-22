extends Node2D

@onready var player = get_parent().get_node_or_null("Player")

@onready var alligator = get_node_or_null("Alligator")
@onready var turtle = get_node_or_null("Turtle")

var rock_object = load('res://Side_A/Projectiles/rock.tscn')

#Alligator
var alligator_fire_delay = 0.3
var alligator_is_firing = false
var alligator_min_fire_interval = 2
var alligator_max_fire_interval = 4

var alligator_fire_interval = RandomNumberGenerator.new().randf_range(alligator_min_fire_interval, alligator_max_fire_interval): set = _set_alligator_fire_interval
func _set_alligator_fire_interval(new_alligator_fire_interval):
	$AlligatorFireInterval.wait_time = new_alligator_fire_interval
	$AlligatorFireInterval.start()

var turtle_fire_delay = 0.4
var turtle_is_firing = false
var turtle_min_fire_interval = 1.5
var turtle_max_fire_interval = 3

var turtle_fire_interval = RandomNumberGenerator.new().randf_range(turtle_min_fire_interval, turtle_max_fire_interval): set = _set_turtle_fire_interval
func _set_turtle_fire_interval(new_turtle_fire_interval):
	$TurtleFireInterval.wait_time = new_turtle_fire_interval
	$TurtleFireInterval.start()

func _ready():
	alligator_fire_interval = RandomNumberGenerator.new().randf_range(alligator_min_fire_interval, alligator_max_fire_interval)
	turtle_fire_interval = RandomNumberGenerator.new().randf_range(turtle_min_fire_interval, turtle_max_fire_interval)

func _physics_process(delta):
	alligator_behavior(delta)
	turtle_behavior(delta)
	
func alligator_behavior(delta):
	if (!alligator_is_firing):
		alligator.position.x = lerpf(alligator.position.x, player.position.x, delta * 2)
	
func turtle_behavior(delta):
	if (!turtle_is_firing):
		turtle.position.y = lerpf(turtle.position.y, player.position.y, delta * 1.6)
		

func _on_turtle_fire_interval_timeout():
	turtle_is_firing = true
	await get_tree().create_timer(turtle_fire_delay).timeout
	
	var new_rock: RigidBody2D = rock_object.instantiate()
	new_rock.position = turtle.global_position
	
	new_rock.gravity_scale = 0
	new_rock.apply_central_impulse(Vector2(45, 0))
	
	get_parent().get_node_or_null("Projectiles").add_child(new_rock)
	
	
	turtle_fire_interval = RandomNumberGenerator.new().randf_range(turtle_min_fire_interval, turtle_max_fire_interval)
	turtle_is_firing = false


func _on_alligator_fire_interval_timeout():
	alligator_is_firing = true
	await get_tree().create_timer(alligator_fire_delay).timeout
	
	var new_rock: RigidBody2D = rock_object.instantiate()
	new_rock.position = alligator.global_position
	
	new_rock.gravity_scale = 0.26

	
	get_parent().get_node_or_null("Projectiles").add_child(new_rock)
	
	
	alligator_fire_interval = RandomNumberGenerator.new().randf_range(alligator_min_fire_interval, alligator_max_fire_interval)
	alligator_is_firing = false
