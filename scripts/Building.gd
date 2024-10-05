extends Node3D

@onready var sprite := $Sprite

func _ready() -> void:
	sprite.frame = randi_range(0, sprite.hframes * sprite.vframes)
	var size := randf_range(0.7, 1.5)
	sprite.scale = Vector3(size, size, size)

func _process(delta: float) -> void:
	pass
