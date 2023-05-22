extends Resource
class_name PlatformsConfiguration

enum SPAWN_MODE {Fixed, Random}
@export var spawn_mode: SPAWN_MODE = SPAWN_MODE.Random
@export var data: Array[PlatformData] = []
@export var spawn_minimum = 1
@export var spawn_interval = 1.0
@export var ascent_speed = 8
