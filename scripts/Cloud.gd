extends Node3D

@onready var velocity := randf_range(2.5, 3)

func _ready() -> void:
	var size := randf_range(0.8, 1.2)
	scale = Vector3(size, size, size)

func _process(delta: float) -> void:
	position.x += velocity * delta

func _on_screen_exited() -> void:
	if position.x > 0:
		queue_free()
