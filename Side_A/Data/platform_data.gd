extends Resource
class_name PlatformData

@export var group_id = 1

enum POSITION {LEFT, CENTER, RIGHT, RANDOM_ALIGNED, RANDOM}
@export var position: POSITION = POSITION.LEFT

enum TYPE {NORMAL, FALLING, GHOST}
@export var type: TYPE = TYPE.NORMAL

@export_range(0.01, 10) var speed = 1

@export var spawn_delay = 0.0

