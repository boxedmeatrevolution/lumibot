extends Node3D

const GRAVITY : float = 0.15
const THROW_SPEED : float = 3

var rotation_axis : Vector3
var angular_velocity : float

var shot := false

var throw_pos_1 : Vector3
var throw_pos_2 : Vector3
var throw_dist : float

func shoot() -> void:
	shot = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
	angular_velocity = deg_to_rad(randf_range(0, 40))
	rotation = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))
	if global_position.y < 0:
		global_position.y = 0
	$GPUParticles3D.restart()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform = transform.rotated_local(rotation_axis, angular_velocity * delta)
	if !shot:
		var g := GRAVITY / (THROW_SPEED * THROW_SPEED)
		var throw_delta := Vector3(throw_pos_2.x - throw_pos_1.x, 0, throw_pos_2.z - throw_pos_1.z)
		var c := (throw_pos_2.y - throw_pos_1.y) / throw_delta.length() / (0.5 * g)
		var throw_height := -0.5 * g * throw_dist * (throw_dist - throw_delta.length() - c)
		global_position = throw_pos_1 + Vector3.UP * throw_height + throw_delta.normalized() * throw_dist
		throw_dist += THROW_SPEED * delta
		if (throw_dist > throw_delta.length()):
			queue_free()
	else:
		global_position += 10 * GRAVITY * Vector3.DOWN * delta
		if global_position.y < -10:
			queue_free()
