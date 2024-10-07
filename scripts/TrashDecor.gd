extends Node3D

var velocity := Vector3.ZERO

var rotation_axis : Vector3
var angular_velocity : float

func _ready() -> void:
	velocity = Vector3(randf_range(-3, 3), randf_range(7, 12), randf_range(-3, 3))
	rotation_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	angular_velocity = deg_to_rad(randf_range(0, 60))
	rotation = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))
	$GPUParticles3D.restart()

func _process(delta: float) -> void:
	transform = transform.rotated_local(rotation_axis, angular_velocity * delta)
	angular_velocity *= exp(-delta / 1.5)
	velocity += 8 * Vector3.DOWN * delta
	global_position += velocity * delta
	if global_position.y < 0.4 && velocity.y < 0:
		global_position.y = 0.4
		velocity = Vector3.ZERO
