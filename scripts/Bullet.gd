extends Area3D

@export var speed = 50.0  # Speed of the bullet
var velocity = Vector3()

func _ready():
	velocity = -transform.basis.z * speed

func _process(delta):
	position += velocity * delta

func _on_Bullet_body_entered(body):
	if body.is_in_group("targets"):  # Assuming targets are in a group named "targets"
		body.queue_free()  # Remove the target
	queue_free()  # Remove the bullet
