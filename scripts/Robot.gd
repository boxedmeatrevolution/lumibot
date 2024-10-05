extends Node3D

var velocity : Vector3 = Vector3(0, 0, 0)
@onready var animation_player := $AnimationPlayer

enum State {
	STAND,
	WALK
}

var state : State = State.STAND

func _ready() -> void:
	animation_player.play("STAND")

func _process(delta: float) -> void:
	if state == State.STAND:
		if randf() > exp(-delta / 3):
			state = State.WALK
			animation_player.play("WALK", 0.5)
			velocity = Vector3(randf_range(-2, 2), 0, randf_range(-1, 1))
	elif state == State.WALK:
		position += velocity * delta
		if randf() > exp(-delta / 3):
			state = State.STAND
			animation_player.play("STAND", 0.5)
			velocity = Vector3(0, 0, 0)
