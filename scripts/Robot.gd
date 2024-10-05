extends Node3D

var velocity : Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if randf() > exp(-delta / 3):
		velocity = Vector3(randf_range(-2, 2), 0, randf_range(-1, 1))
	position += velocity * delta
