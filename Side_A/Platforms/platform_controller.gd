extends Node2D

@export var configuration: PlatformsConfiguration
var platform_types = [
	"Standard",
	"Falling",
	"Ghost"
]

@export var max_onscreen_platform_count = 12
@export var max_scroll_speed = 8

var spawn_group_index = 1
var platform_object = load("res://Side_A/Platforms/platform.tscn")

var scroll_speed = 1.5

@onready var platform_containers = {
	"Standard" = $Standard,
	"Falling" = $Falling,
	"Ghost" = $Ghost
}

@onready var platform_spawns = $Spawns
var spawn_timer = 0

func _ready():
	spawn_platforms_random()
	pass

func _physics_process(delta):
	spawn_timer += delta
	if (spawn_timer > configuration.spawn_interval):
		spawn_timer = 0
		if (configuration.spawn_mode == 0):
			spawn_platforms_fixed()
		elif (configuration.spawn_mode == 1):
			spawn_platforms_random()
		
			
			
	scroll_speed = lerpf(scroll_speed, max_scroll_speed, 0.1 * delta)
	scroll_screen(delta)
	
func spawn_platforms_fixed():
	var platforms_in_group = configuration.data.filter(func(data: PlatformData): return data.group_id == spawn_group_index)
	for data in platforms_in_group:
		var new_platform_instance: StaticBody2D = platform_object.instantiate()
		new_platform_instance.global_position = platform_spawns.get_child(data.position).position
	
		var parent: Node2D = platform_containers[platform_types[data.type]]
		parent.add_child(new_platform_instance)
	
	if (platforms_in_group.size() > 0):
		spawn_group_index += 1
		
func spawn_platforms_random():
	for index in range(1, 4):
		var do_spawn = true if (index <= configuration.spawn_minimum) else (RandomNumberGenerator.new().randf() > 0.5)
		
		var random_position: Vector2 = platform_spawns.get_child(RandomNumberGenerator.new().randi_range(0, 2)).position
		var random_type = platform_types[RandomNumberGenerator.new().randi_range(0, 2)]
		
		if (do_spawn):
			
			var new_platform_instance: StaticBody2D = platform_object.instantiate()
			new_platform_instance.global_position = random_position
			
			var parent: Node2D = platform_containers[random_type]
			parent.add_child(new_platform_instance)
	
func get_all_platform_instances():
	var all_platforms = []
	for platform_type in platform_containers.values():
		for platform_instance in platform_type.get_children():
			all_platforms.push_back(platform_instance)
	return all_platforms

func get_onscreen_platform_count():
	return get_all_platform_instances().size()
	
func scroll_screen(delta):
	for platform_instance in get_all_platform_instances():
		if ("locked" in platform_instance and platform_instance.locked):
			continue
		platform_instance.position.y += configuration.ascent_speed * delta

func _on_platform_destroy_zone_area_entered(area):
	var instance = area.get_parent()
	if (instance.is_in_group("platforms")):
		instance.queue_free()
