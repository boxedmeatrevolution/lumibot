extends Node2D

func _ready() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _process(delta: float) -> void:
	pass
