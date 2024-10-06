extends Node3D

const RocketScene := preload("res://entities/Rocket.tscn")
const Building := preload("res://scripts/Building.gd")

@onready var animation_player := $AnimationPlayer
@onready var grab_point := $BodySprite/RightArmSprite/GrabPoint

var velocity := Vector3.ZERO

enum State {
	STAND,
	WALK
}

var state : State = State.STAND
var building : Building = null

func _ready() -> void:
	animation_player.play("STAND")

func _process(delta: float) -> void:
	if randf() > exp(-delta / 3):
		var rocket = RocketScene.instantiate()
		get_parent().add_child(rocket)
		rocket.global_position = global_position
	if building != null && randf() > exp(-delta / 3):
		building.throw(get_parent())
		building = null
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
	if area.get_collision_layer_value(4):
		var b : Building = area.get_parent()
		if building == null && randf() > 0.0:
			building = b
			b.pickup(grab_point)
		else:
			b.demolish()
