extends Node3D

@export var texture : Texture2D

@onready var sprite := $Sprite3D

func _ready() -> void:
	sprite.texture = texture
	sprite.hframes = 2
	sprite.vframes = 1
	sprite.frame = 1

func _process(delta: float) -> void:
	pass
