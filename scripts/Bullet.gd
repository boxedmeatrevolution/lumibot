extends Area3D

@export var speed = 80.0  # Speed of the bullet
@export var upspeed = 10.0  # Speed of the bullet
@export var pulldown = -9.8  # Gravity affecting the bullet

var gravity_effect = Vector3(0, pulldown, 0)
var velocity = Vector3()

func _ready():
	velocity = -transform.basis.z * speed + transform.basis.y * upspeed
	connect("body_entered", Callable(self, "_on_Bullet_body_entered"))

func _process(delta):
	velocity += gravity_effect * delta
	position += velocity * delta

func _on_Bullet_body_entered():
	print("Bullet hit target!")
