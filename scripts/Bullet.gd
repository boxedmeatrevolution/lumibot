extends Node3D

@export var speed = 140.0  # Speed of the bullet
@export var upspeed = 0.0  # Speed of the bullet
@export var pulldown = -4  # Gravity affecting the bullet

const Rocket := preload("res://scripts/Rocket.gd")
const Building := preload("res://scripts/Building.gd")
const Trash := preload("res://scripts/Trash.gd")

@onready var area := $Area3D
@onready var area_shape := $Area3D/CollisionShape3D

var gravity_effect = Vector3(0, pulldown, 0)
var velocity = Vector3()
var query := PhysicsRayQueryParameters3D.new()

func _ready():
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = area.collision_mask

func _physics_process(delta : float) -> void:
	velocity += gravity_effect * delta
	query.from = global_position
	query.to = global_position + velocity * delta
	var space_state := get_world_3d().direct_space_state
	var collision := space_state.intersect_ray(query)
	if !collision.is_empty():
		_on_area_entered(collision.collider)
	global_position += velocity * delta

func _on_area_entered(area: Area3D) -> void:
	if area.get_collision_layer_value(5):
		var r : Rocket = area.get_parent()
		r.destroy()
	elif area.get_collision_layer_value(7) || area.get_collision_layer_value(4) || area.get_collision_layer_value(6):
		var b : Building = area.get_parent()
		b.shoot()
	elif area.get_collision_layer_value(9):
		var b : Trash = area.get_parent()
		b.shoot()
	elif area.get_collision_layer_value(2):
		print("Robot hit!")
	else:
		print("Bullet hit something else! ", area.collision_layer)
	collision()

func collision():
	queue_free()
