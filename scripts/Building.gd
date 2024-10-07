extends Node3D

const BuildingRemnantScene := preload("res://entities/BuildingRemnant.tscn")
const TrashScene := preload("res://entities/Trash.tscn")
const TrashDecorScene := preload("res://entities/TrashDecor.tscn")

const PICKUP_TIME : float = 0.5
const GRAVITY : float = 0.15
const THROW_SPEED : float = 3

var hp := 7

@onready var area := $Area3D
@onready var grab_point := $GrabPoint

enum State {
	NORMAL,
	PICKUP,
	THROW
}

var state := State.NORMAL
var throw_pos_1 : Vector3
var throw_pos_2 : Vector3
var throw_dist : float
var angular_velocity : float

func _create_remnant():
	pass
	#var remnant := BuildingRemnantScene.instantiate()
	#remnant.texture = sprite.texture
	#get_parent().add_child(remnant)
	#remnant.global_transform = global_transform

func demolish():
	if state == State.NORMAL:
		_create_remnant()
		queue_free()

func pickup(parent : Node3D):
	if state == State.NORMAL:
		_create_remnant()
		area.set_collision_layer_value(4, false)
		area.set_collision_layer_value(6, true)
		state = State.PICKUP
		reparent(parent, true)

func throw(parent : Node3D, target : Vector3):
	if state == State.PICKUP:
		area.set_collision_layer_value(6, false)
		area.set_collision_layer_value(7, true)
		state = State.THROW
		reparent(parent, true)
		throw_pos_1 = global_position
		throw_pos_2 = target
		throw_dist = 0
		angular_velocity = deg_to_rad(randf_range(-20, 20))

func _ready() -> void:
	pass

func shoot(damage : int = 1) -> void:
	if state == State.THROW:
		hp -= 3 * damage
	else:
		hp -= 1 * damage
	if hp <= 0:
		if state == State.THROW:
			for i in range(0, 6):
				var trash := TrashScene.instantiate()
				get_parent().add_child(trash)
				trash.global_position = global_position + Vector3(randf_range(-4, 4), randf_range(-4, 4), randf_range(-4, 4))
				trash.throw_dist = 0
				trash.throw_pos_1 = trash.global_position
				trash.throw_pos_2 = throw_pos_2 + Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
			queue_free()
		elif state == State.NORMAL:
			for i in range(0, 12):
				var trash := TrashDecorScene.instantiate()
				get_parent().add_child(trash)
				trash.global_position = global_position + Vector3(randf_range(-4, 4), randf_range(-4, 4), randf_range(-4, 4))
			queue_free()

func _process(delta: float) -> void:
	if state == State.PICKUP:
		var transform_2 : Transform3D = grab_point.transform.affine_inverse()
		var transform_1 : Transform3D = transform
		transform.origin = lerp(transform_1.origin, transform_2.origin, 1 - exp(-delta / PICKUP_TIME))
		transform.basis = transform_1.basis.orthonormalized().slerp(transform_2.basis.orthonormalized(), 1 - exp(-delta / PICKUP_TIME))
	elif state == State.THROW:
		var g := GRAVITY / (THROW_SPEED * THROW_SPEED)
		var throw_delta := Vector3(throw_pos_2.x - throw_pos_1.x, 0, throw_pos_2.z - throw_pos_1.z)
		var c := (throw_pos_2.y - throw_pos_1.y) / throw_delta.length() / (0.5 * g)
		var throw_height := -0.5 * g * throw_dist * (throw_dist - throw_delta.length() - c)
		global_position = throw_pos_1 + Vector3.UP * throw_height + throw_delta.normalized() * throw_dist
		transform *= Transform3D().translated(grab_point.position) * Transform3D().rotated(Vector3(0, 0, 1), angular_velocity * delta) * Transform3D().translated(-grab_point.position)
		if (throw_dist > throw_delta.length()):
			queue_free()
		throw_dist += THROW_SPEED * delta
