extends Node3D

const BuildingRemnantScene := preload("res://entities/BuildingRemnant.tscn")

@onready var sprite := $Sprite3D
@onready var area := $Area3D

func demolish():
	var remnant := BuildingRemnantScene.instantiate()
	remnant.texture = sprite.texture
	get_parent().add_child(remnant)
	remnant.global_transform = global_transform
	queue_free()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
