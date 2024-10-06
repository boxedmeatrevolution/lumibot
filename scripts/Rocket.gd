extends Node3D

const SPEED : float = 2

@onready var mesh := $MeshInstance3D

var turning_radius : float
var target : Vector3
var velocity := Vector3(0, 0, 0)
var time : float = 0
var phase : float

func _ready() -> void:
	var theta := deg_to_rad(randf_range(-60, 60))
	turning_radius = randf_range(30, 50)
	velocity = SPEED * Vector3(sin(theta), cos(theta), 0)
	phase = randf_range(-PI, PI)

func _process(delta: float) -> void:
	time += delta
	var r := global_position - target
	r += 0.3 * r.length() * Vector3(sin(time / 2 + phase), cos(time / 2 + phase), 0)
	var rot := Quaternion(velocity.normalized(), r.normalized()).normalized()
	rot = Quaternion.IDENTITY.slerp(rot, 1 - exp(-delta * SPEED / turning_radius))
	velocity *= rot
	velocity = SPEED * velocity.normalized()
	quaternion = Quaternion(Vector3.UP, velocity.normalized()).normalized()
	global_position += velocity * delta
	
