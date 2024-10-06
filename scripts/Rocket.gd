extends Node3D

const SPEED : float = 2
const TURNING_RADIUS : float = 30

@onready var mesh := $MeshInstance3D
var velocity := Vector3(0, 0, 0)

func _ready() -> void:
	var theta := deg_to_rad(randf_range(-60, 60))
	velocity = SPEED * Vector3(sin(theta), cos(theta), 0)

func _process(delta: float) -> void:
	var r := global_position - Vector3(0, 10, 0)
	var rot := Quaternion(velocity.normalized(), r.normalized()).normalized()
	rot = Quaternion.IDENTITY.slerp(rot, 1 - exp(-delta * SPEED / TURNING_RADIUS))
	velocity *= rot
	velocity = SPEED * velocity.normalized()
	quaternion = Quaternion(Vector3.UP, velocity.normalized()).normalized()
	global_position += velocity * delta
	
