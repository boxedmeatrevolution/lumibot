extends Area3D

@export var speed = 25.0  # Speed of the bullet
@export var upspeed = 10.0  # Speed of the bullet
@export var pulldown = -9.8  # Gravity affecting the bullet

var gravity_effect = Vector3(0, pulldown, 0)
var velocity = Vector3()

func _ready():
	velocity = -transform.basis.z * speed + transform.basis.y * upspeed

func _process(delta):
	velocity += gravity_effect * delta
	position += velocity * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("targets"):  # Assuming targets are in a group named "targets"
		body.queue_free()  # Remove the target
	queue_free()  # Remove the bullet
