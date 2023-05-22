extends Node2D

@onready var player = get_parent().get_node_or_null("Player")

@onready var life_frame: AnimatedSprite2D = get_node_or_null("Life_UI")
@onready var power_frame: AnimatedSprite2D = get_node_or_null("Power_UI")

var power_types = ["Jump", "Float"]

func _ready():
	player.connect("player_life_depleted", _on_player_life_depleted)
	player.connect("player_power_depleted", _on_player_power_depleted)
	update_life_frame()
	update_power_frame()
	
func update_life_frame():
	life_frame.animation = "Life_"+str(player.life_remaining)
	
func update_power_frame():
	power_frame.animation = power_types[player.active_power]+"_"+str(player.power_remaining)
	
func _on_player_life_depleted():
	update_life_frame()
	
func _on_player_power_depleted():
	update_power_frame()
