extends Area3D

@export var speed = 160.0  # Speed of the bullet
@export var upspeed = 5.0  # Speed of the bullet
@export var pulldown = -2  # Gravity affecting the bullet

const Rocket := preload("res://scripts/Rocket.gd")

var gravity_effect = Vector3(0, pulldown, 0)
var velocity = Vector3()

func _ready():
	velocity = -transform.basis.z * speed + transform.basis.y * upspeed
	# connect("body_entered", Callable(self, "_on_Bullet_body_entered"))

func _process(delta):
	velocity += gravity_effect * delta
	position += velocity * delta

func _on_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(5):
		var r : Rocket = area.get_parent()
		r.destroy()
		print("Rocket hit!")
	elif area.get_collision_layer_value(2):
		print("Building hit!")
	else:
		print("Bullet hit something else!")
	collision()
	
func collision():
	
	queue_free()
		# var b : Building = area.get_parent()
		# if building == null && randf() > 0.5:
		# 	building = b
		# 	b.pickup(grab_point)
		# else:
		# 	b.demolish()
