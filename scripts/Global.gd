extends Node

var num_gremlins : int = 9
var rocket_count : int = 0

var rocket_speed_factor : float = 1
var building_speed_factor : float = 1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if num_gremlins <= 1:
		rocket_speed_factor = 2
		building_speed_factor = 1.5
	elif num_gremlins <= 3:
		rocket_speed_factor = 1.7
		building_speed_factor = 1.3
	elif num_gremlins <= 6:
		rocket_speed_factor = 1.2
		building_speed_factor = 1.1
	else:
		rocket_speed_factor = 1
		building_speed_factor = 1
