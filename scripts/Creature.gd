extends Node3D

var hp := 1

var velocity := Vector3.ZERO

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if hp <= 0:
		global_position += velocity * delta
		velocity += 10 * Vector3.DOWN * delta
		transform *= Transform3D().translated(Vector3(0, 0.4, 0)) * Transform3D().rotated(Vector3(0, 0, 1), 5 * delta) * Transform3D().translated(Vector3(0, -0.4, 0))
		if global_position.y < 0:
			queue_free()
			Global.num_gremlins -= 1

func shoot() -> void:
	hp -= 1
	if hp <= 0:
		reparent(owner.get_parent(), true)
		velocity = Vector3(randf_range(-6, 6), 10, 0)
