extends Node3D

@onready var mesh := $MeshInstance3D
var velocity := Vector3(0, 0, 0)

func _ready() -> void:
	var theta := deg_to_rad(randf_range(-60, 60))
	velocity = 2 * Vector3(sin(theta), cos(theta), 0)

func _process(delta: float) -> void:
	var r := global_position - Vector3(0, 10, 0)
	var rot := Quaternion(velocity.normalized(), r.normalized())
	rot = Quaternion.IDENTITY.slerp(rot, 1 - exp(-delta / 15))
	velocity *= rot
	quaternion = Quaternion(Vector3.UP, velocity.normalized())
	global_position += velocity * delta
	
