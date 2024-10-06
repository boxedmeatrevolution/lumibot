extends Node3D

const RocketScene := preload("res://entities/Rocket.tscn")
const Building := preload("res://scripts/Building.gd")

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
	if randf() > exp(-delta / 3):
		var rocket = RocketScene.instantiate()
		get_parent().add_child(rocket)
		rocket.global_position = global_position
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

func _on_area_entered(area: Area3D) -> void:
	print("COLLISION")
	if area.get_collision_layer_value(4):
		var building : Building = area.get_parent()
		building.demolish()
